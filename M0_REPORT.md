# M0 Report — Environment Enablement & Linux Baseline Qualification

**Date:** 2026-11-15
**Scope:** Reproduce and honestly document the four-repository baseline (kalos, rkalos, pykalos, persephone3) on this Linux x86_64 host, as the enabling milestone for the numerical roadmap (M1 = Kalos 22b.3a/3b).
**Method:** Four parallel agents (A–D), one per repository, each updating its own `IMPLEMENTATION_STATUS.md` independently and committing locally (no pushes, remotes untouched).

---

## 1. Executive summary

| Repo | Commit (local) | Build | Test baseline on Linux | Verdict |
|---|---|---|---|---|
| kalos | `2b6e66a` | Release OpenMP + serial + ASan/UBSan, 0 warnings | 34/37 programs pass in **every** configuration (incl. sanitizers, 0 findings) | Baseline established; **3 platform-dependent numerical failures** (root cause known) |
| rkalos | `6ab9b3c` | `R CMD INSTALL` 0 warnings; OpenMP probe passed | 240,563 assertions ran; 239,905 pass, 658 fail, 14 files abort | Same single root cause as kalos; all 12 X-11 files fully green (234,320 assertions) |
| pykalos | `6ee3e93` | wheel `pykalos-0.1.0-cp312-cp312-linux_x86_64.whl`, 0 warnings | 3/3 smoke tests pass; correct provider linkage | Baseline established |
| persephone3 | `d966039` | 0 warnings/notes (vignettes skipped) | tinytest: 20 files, **1,329 assertions, 0 failures**, 0 skips; X-13 + TRAMO fits green on JVM 21 | Baseline established; native-unsupported honesty verified |

**Milestone M0 exit gate: conditionally met.** All four repos build and run on Linux; every previously macOS-only claim that could be re-run was re-run. The gate is *not* fully met because 3 standalone + 14 R test files fail from a newly exposed cross-platform numerical issue (Section 3.1) that must be fixed in Kalos core as the **first slice of M1**, before any cross-platform parity claim.

**Closure verified on 2026-11-23.** The M1 integration checkpoint closed the outstanding Linux bootstrap gate. At Kalos `cd004b0`, all 39 CTests passed in serial, OpenMP and sanitizer builds. On the synchronized core, rkalos passed all 270,653 OpenMP assertions and all 270,649 serial assertions. Python passed all three smoke tests and Persephone passed 1,330 assertions. These are the recorded checkpoint results. The original M0 measurements below preserve the evidence that led to the fixes. [M1 integration and validation](M1_REPORT.md#1-executive-summary--exit-gate-met)


---

## 2. Environment

- Ubuntu 24.04.4, x86_64, 8 cores; g++ 13.3.0, cmake 3.28.3, gfortran present.
- R 4.5.3 (`/usr/local/bin/R`) with `BLAS=-lblas`, `LAPACK=-llapack`; alternatives route both through OpenBLAS; effective LAPACK 3.12.0. Rcpp, tinytest, rjd3x13/rjd3tramoseats/rjd3toolkit (3.9.0) installed. CPython 3.12.3 (note: *not* 3.11 as first assumed), pip 26.3.
- **Provider:** system OpenBLAS is 0.3.26 LP64+CBLAS but **without LAPACKE** → unusable for Kalos. The repo-pinned 0.3.34 provider was built out-of-tree via `kalos/tools/build-openblas.py --prefix /tmp/opencode/openblas` (archive sha256 `cd7e1298…` per `openblas.lock.json`; built `.so` sha256 `84de4eab…`). No repo committed provider binaries; macOS lanes remain the only fully-qualified platform to date.

## 3. Cross-cutting findings (M1 input)

### 3.1 80-bit `long double` underflow guards (THE blocker)
- Independently root-caused by Agents A and B. In `src/kalos/src/finite_state_factor.cpp`, `checked()` throws `std::underflow_error` when a nonzero `long double` casts to `double` as 0. On **macOS ARM64 `long double == double`**, so the guard was vacuous; on **x86-64 `long double` is 80-bit**, so sub-double subnormals (≈6.91e-334 seen in the period-12 seasonal AR diffuse filter; ≈1e-400 in regression likelihood) survive and throw.
- Consequences: standalone failures `test_diffuse_state_space`, `test_forecast_arma_information`, `test_regression_likelihood` (thread-independent, all builds); in rkalos, every model with seasonal AR/MA factors (incl. airline) returns `numerical_failure` → 658 failing assertions and 14 aborting test files. Deterministic (identical with `OMP_NUM_THREADS=1`); not provider- or threading-related.
- Needed in M1 slice 1: a platform-independent decision on guard semantics/accumulation representation in Kalos core, then re-sync downstream pins. Secondary: rkalos identification SVD tolerance mismatch (1.29e-10 vs 1e-14, native `dgesvd` vs R `svd()`; ranks/statuses still correct).

### 3.2 `FindKalosOpenBLAS` precedence bug (confirmed twice)
pkg-config hints are placed **before** `${OpenBLAS_ROOT}` in `cmake/FindKalosOpenBLAS.cmake`, so on hosts with system OpenBLAS the documented `-DOpenBLAS_ROOT=` configure silently mixes pinned headers with the system (LAPACKE-less) library → link- or import-time `undefined symbol: LAPACKE_*`. Both agents worked around with explicit `-DKalosOpenBLAS_LIBRARY/INCLUDE_DIR`. Real fix: ROOT must outrank pkg-config (kalos upstream; pykalos carries a vendored copy).

### 3.3 Host/environment hygiene (recorded, not repo defects)
- Global `LD_LIBRARY_PATH` includes `/usr/lib/x86_64-linux-gnu`, shadowing the provider SONAME at runtime (`env -u LD_LIBRARY_PATH` required).
- `/etc/R/Rprofile.site` hardcodes `.libPaths()`, ignoring `R_LIBS_USER` (workarounds: `Rscript --vanilla` + `R_LIBS=`, `R_PROFILE_USER`, or `R CMD INSTALL --library`).
- **Java policy (F10):** rjd3 3.9.0 jars are Java-21 class files, but the site `ldpaths` pins rJava to Java 17 → misleading `UnsupportedClassVersionError`. Enablement: `JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64`. A supported-Java policy must be decided in M1 (item 14).
- ctest `ENVIRONMENT` properties pin `KALOS_NUM_THREADS=2` per test, so shell-env reruns do not change thread counts; true serial requires `-DKALOS_OPENMP=OFF` rebuild.
- `shinycssloaders` is used by persephone3 but missing from hard `Imports` (installed 1.1.0 from CRAN as workaround) — DESCRIPTION fix queued for M1.

## 4. Per-repository detail

### 4.1 kalos (Agent A) — commit `2b6e66a` on `main`
- Configure with pinned provider: `KALOS_LP64_PROVIDER` success, OpenMP 4.5 runtime probe success; zero warnings in `-Wall -Wextra -Wpedantic` Release OpenMP **and** serial builds.
- ctest 37 programs: 34 pass / 3 fail in **all** of: OpenMP build (default 2 threads), true serial build, 4-thread direct sweep, and a gcc ASan+UBSan Debug build (full suite, 174 s, **0 sanitizer findings**). The 3 failures are exactly Section 3.1.
- External consumer check **PASS**: `find_package(kalos CONFIG REQUIRED)` + `kalos::kalos` printed `core_version 0.1.0` at revision `a01473ee…` (matches HEAD).
- `IMPLEMENTATION_STATUS.md`: added dated "Linux (x86_64) baseline qualification" section with probe results, per-config counts, root-cause family, not-run list (Windows, sanitizers with clang). No capability promoted.

### 4.2 rkalos (Agent B) — commit `6ab9b3c` on `main`
- `sync-core.py --verify` PASS offline (84 core + 112 fixture files @ `4f0625cf…`).
- `R CMD build` + `INSTALL`: 0 warnings/notes; OpenMP probe passed; provider = R-configured BLAS/LAPACK (Ubuntu alternatives → OpenBLAS 0.3.26, LAPACK 3.12 semantics).
- tinytest (37 files, Java-free): **240,563 ran / 239,905 pass / 658 fail / 14 abort**. Fully green: all 12 X-11 files (234,320 assertions), preparation/inputs, likelihood, linear algebra, parallel, prediction moments, primitives, package boundary (no rJava/rjd3 loaded). Failures/aborts all trace to Section 3.1 via pinned `src/kalos` — correctly **not** patched locally (snapshot immutability respected).
- Sanity: `core_version()` ✓; `capabilities()` = 43 primitives, `status="unimplemented"`, `fit=FALSE` ✓; `fixed_likelihood` ✓ (loglik −680.6269); README `arma_optimize` terminates at ar≈0.9999972 with `gradient_unavailable` (unit-root boundary) — open item needing a macOS cross-check.
- Not run: full `R CMD check`, sanitizer/serial lanes, focused preparation-equivalence set → queued M1.

### 4.3 pykalos (Agent C) — commit `6ee3e93` on `main`
- Snapshot verify PASS offline. Wheel built with scikit-build-core 1.1.2 / pybind11 3.1.0 / ninja 1.13.2 on CPython 3.12.3; 0 warnings. Required a genuine local fix: `INSTALL_RPATH = "$ORIGIN;<OpenBLAS libdir>"` on Linux (committed).
- 3/3 tests pass. Exact metadata: provider `OpenBLAS 0.3.34 … SkylakeX SINGLE_THREADED`, `blas_integer_bits: 32`, `openmp: True`; `convolve([1,-0.4],[1,0.2])` → `[1.0, -0.2, -0.08]`; `ldd` resolves the pinned provider.
- Build required explicit `-DKalosOpenBLAS_LIBRARY/INCLUDE_DIR` because of Section 3.2; portable public wheels (bundling, manylinux, import-order) remain undone.

### 4.4 persephone3 (Agent D) — commit `d966039` on `rkalos_backend`
- rkalos installed from a read-only `git archive` of `18630ee` (sibling checkout untouched); loads with **zero rjd3/rJava namespaces**; persephone3 installed 0 warnings/notes.
- Java fits: `perX13(AirPassengers)$run()` → `d11final` last 6: 483.5, 480.1, 483.3, 496.8, 487.6, 488.9 (2.24 s); `perTramo` → SA last 6: 484.1, 476.7, 481.5, 495.4, 487.8, 490.6 (0.50 s).
- Native honesty: every native path (constructor, `backend_fit`, `backend_default_spec`, option route) raised the explicit no-Java-fallback error; zero Java namespaces loaded afterwards. PASS.
- tinytest under JVM 21: **20 files / 1,329 assertions / 0 failures / 0 skips** (baseline claim 1,330; the −1 could not be localized — documented as unexplained, no assertion skipped). Dashboard servers started/stopped cleanly.
- Reproduction scripts preserved: `/tmp/opencode/{check_rkalos_standalone,verify_java_fits,verify_native_unsupported,run_tinytest}.R` with `R_PROFILE_USER=/tmp/opencode/rprofile-d.R` + JVM-21 exports.

## 5. Decisions taken in M0

1. Standalone/Python numerical work on this host uses the **repo-pinned 0.3.34 provider** (never the system 0.3.26/LAPACKE-less build) — consistent with `dependencies/README.md`.
2. Snapshot immutability held: no agent edited `src/kalos` / `vendor/kalos`; the Section 3.1 fix belongs upstream in kalos and arrives via a reviewed `sync-core` checkpoint in M1.
3. `long double` guard behavior is treated as a **numerical-parity decision** (Kalos-owned), not an environment workaround; no test tolerances were relaxed.
4. All work is local commits only; pushes, releases and default-branch policy remain with the user.

## 6. M1 backlog (confirmed by M0 evidence)

**Slice 1 (unblocks everything, kalos):**
- [A] Platform-independent `long double` underflow-guard semantics in `finite_state_factor.cpp` (+ regression likelihood guard family); re-qualify the 3 standalone tests; commit.
- [A] `FindKalosOpenBLAS`: explicit `OpenBLAS_ROOT` must outrank pkg-config; document.
- **Integration checkpoint:** `sync-core` refresh for rkalos + pykalos pins → [B] re-run 37-file suite (expect recovery toward 266k-class totals), full `R CMD check`, serial lane.
**Slice 2 (milestone theme, kalos):**
- [A] 22b.3a — moving five-year dispersion + two-pass sigma weights (accurate + Java-free legacy rules; sigma-default decision per descope rule stays explicit if fixtures don't settle it).
- [A] 22b.3b — same-phase replacement neighbors, endpoints, correction factors.
**Parallel downstream (independent of core):**
- [B] SVD-tolerance evidence study; `arma_optimize` unit-root-boundary investigation.
- [C] Vendored finder fix + auditwheel/manylinux bundling spike.
- [D] Item 14 groundwork: Java-policy decision note + CI Java 21 pin; `shinycssloaders` Imports fix; 1,329-vs-1,330 discrepancy hunt; interim-release checklist.

## 7. Reproduction essentials

```sh
# pinned provider (already at /tmp/opencode/openblas)
python3 kalos/tools/build-openblas.py --prefix /tmp/opencode/openblas --jobs 7
# kalos standalone
cmake -S kalos -B /tmp/opencode/kalos-build -DCMAKE_BUILD_TYPE=Release \
  -DOpenBLAS_ROOT=/tmp/opencode/openblas \
  -DKalosOpenBLAS_INCLUDE_DIR=/tmp/opencode/openblas/include \
  -DKalosOpenBLAS_LIBRARY=/tmp/opencode/openblas/lib/libopenblas.so   # until 3.2 is fixed
env -u LD_LIBRARY_PATH cmake --build /tmp/opencode/kalos-build --parallel 7
env -u LD_LIBRARY_PATH ctest --test-dir /tmp/opencode/kalos-build --output-on-failure
# rkalos / persephone3: use R_LIBS_USER workarounds + JVM 21 per §3.3
```
