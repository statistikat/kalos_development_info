# M1 Report — Cross-Platform Parity Fix + X-11 Endpoint Statistics (22b.3a/3b)

**Dates:** 2026-11-15 → 2026-11-16
**Scope:** M1 of `PACKAGE_FAMILY_AND_AGENT_PLAN.md`, plus the parity work M0 promoted ahead of it (long-double guard semantics, provider-finder precedence).
**Participants:** Agents A–D (one per repo) and the maintainer (external commits in kalos/rkalos/pykalos, integration checkpoint).
**Predecessor:** `M0_REPORT.md` (Linux baselines; the three cross-cutting blockers).

---

## 1. Executive summary — exit gate MET

| Gate (from the plan) | Result |
|---|---|
| Kalos 22b.3a/3b qualified against JDemetra+ fixtures; serial/OpenMP/sanitizer green | ✅ legacy sigma rule **exact-double-equal on all 125 cases**; replacement plan **exact on all 22 cases** (218 flagged rows slot-for-slot); **39/39** in Release OpenMP, serial, **and ASan+UBSan (0 findings)** at `cd004b0` |
| Platform parity (prerequisite): 3 Linux failures resolved without touching fixtures/tolerances | ✅ fixed by binary64-contract decision (`0cbd012`) + maintainer refinement (`cd004b0`); zero rebaselining |
| rkalos green on new pin (recovery of 658 failures / 14 aborts) | ✅ **270,653 assertions / 0 failures** (OpenMP), 270,649 / 0 (serial), all 39 files — first all-green Linux state; 266,549 baseline count exactly reproduced after the 22b.3 tests were added |
| pykalos pin advanced, surface honest | ✅ pinned `cd004b0` (aligned with rkalos), 3/3 smoke, no surface creep |
| persephone3 item-14 groundwork | ✅ 1,330/1,330 after localizing the missing assertion; Java-21 policy; CI refs pinned; `RELEASE_CHECKLIST.md` |
| No capability/default silently promoted | ✅ sigma rule is a **required argument, no default**; 22b.3 entry points not exported yet; sanitizer status recorded |

**Delivered numerical roadmap items: 22b.3a and 22b.3b** — the first Kalos numerical advance since the repository split, and the first time downstream repos consumed core work through the designed sync-checkpoint discipline (including catching a real export gap; §4).

## 2. Kalos (Agent A + maintainer) — 7 commits, `0cbd012 → 5dc0d13`

| Commit | Slice |
|---|---|
| `0cbd012` | Platform-independent underflow guards: **binary64 is the numeric contract, `long double` is scratch only**; guarded conversions flush sub-binary64 magnitudes. 3 previously failing programs pass; 37/37 OpenMP+serial |
| `c6a1881` | `FindKalosOpenBLAS`: explicit `OpenBLAS_ROOT` exclusive (`NO_DEFAULT_PATH`), incomplete roots fail loudly — M0 hazard closed |
| `0d20d21` | **22b.3a** — `x11_sigma_weights` (moving five-year dispersion, two-pass sigma weights). 125-case pinned oracle matrix; `legacy` rule bit-exact incl. infinite/zero-dispersion semantics decoded from pinned bytecode; accurate rule qualified; **default decision stays open** |
| `8e91ee4` | **22b.3b** — `x11_replacements` (same-phase replacement neighbors, endpoints, correction factors). 22 pinned cases; neighbor walk proven against pinned `searchPositionsForOutlierCorrection` via JNI re-run; NaN-poisoning, insufficient-neighbor → `period_average`, reciprocal-multiply blend arithmetic all reproduced operation-for-operation |
| `f96603f` | Export-manifest completion (see §4) + `tools/check-manifest.py` guard wired into CI |
| `cd004b0` | *(maintainer)* profiled variances published as binary64 quotients — found **through rkalos** (1-ULP disagreement in 15/64 pinned forecasts that the standalone suite didn't cover) |
| `5dc0d13` | Sanitizer re-qualification at `cd004b0`: 39/39, zero ASan/UBSan findings; Release OpenMP + serial re-confirmed |

New artifacts: `docs/contracts/extended-precision-range-contract.md`, `x11-sigma-contract.md`, `x11-replacement-contract.md`; fixture sets + rJava pinned-oracle captures; `test_x11_sigma`, `test_x11_replacement`.

## 3. rkalos (Agent B + maintainer session) — pin `4f0625c → cd004b0`

- Groundwork (`cf46a95`, `b1f107f`): `R CMD check --no-tests` **Status OK** (0/0/0, incl. PDF manual, no-Java lib); serial lane via supported `R_MAKEVARS_USER` probe override; **byte-level serial↔OpenMP equality** (SHA-256 over 408,959 values in 17 files); SVD evidence note proving the 2 identification failures are κ-amplified 0.21-ULP input differences, with the fix landed at `0696fb1` (norm-derived tolerance; 196/196).
- `arma_optimize` investigation: the unit-root-boundary `gradient_unavailable` is **not** the guard issue — tanh-coordinate step scaling (`dc/dw ≈ 1.8e5`) kills central stencils near the boundary; objective is smooth, true minimum interior (`ar ≈ 0.99999733`). Kalos-side follow-up candidate; macOS cross-check open.
- Integration checkpoint (maintainer): pin advance to `cd004b0` via `sync-core` (`--verify` clean, 88 core + 132 fixture files); **full suite recovered to 0 failures** (the decisive validation of `0cbd012`+`cd004b0`).
- 22b.3 R boundary (`5342b89`, `6c033c3`): `.native_x11_sigma_weights` / `.native_x11_replacements` + ts-domain wrappers; 125+22 pinned cases **bit-exact through R**, incl. the 3a→3b chain (computed legacy weights equal fixture weights); **no default policy argument**; entry points unexported pending the default decision. Totals: 270,653/0 (OpenMP), 270,649/0 (serial); the 4-assertion lane difference is documented conditional tests, not drift.
- Relicensing: DESCRIPTION `GPL (>= 3)` (user decision, metadata-only), `LICENSE` files removed per R convention (resolves the NOTE).

## 4. Process proof — the guardrails fired twice

1. **Export-manifest gap:** slices 3–4 added sources to `CMakeLists.txt` but not `tools/source-files.json`. pykalos's checkpoint **proved the snapshot unbuildable at configure** and correctly pinned the last self-consistent commit (`c6a1881`) instead of faking anything → kalos `f96603f` completed the manifest (+24 entries) and added a CI guard (CMakeLists↔manifest, with deliberate-catch demos). Both downstream pins then advanced safely.
2. **Coverage gap in standalone tests:** the 1-ULP profiled-variance issue existed only in the forecast kernels' rkalos-pinned fixtures — detected downstream, fixed upstream (`cd004b0`), re-synced, re-qualified. Exactly the loop the plan intends.

## 5. pykalos (Agent C) — `6756579 → 44aaa74`

- Hardened OpenBLAS resolution in a pykalos-owned shadow finder (`OpenBLAS_ROOT` authoritative + `LAPACKE_dpotrf_work` `try_compile` probe; hazard simulations fail loudly); cooperates with the refreshed upstream finder (`FOUND` short-circuit proven).
- auditwheel spike: `repair` self-contains the provider (manylinux_2_38 ceiling); public wheels still need a namespaced private provider build (symbol-interposition vs NumPy) and a real manylinux baseline.
- Pin final at `cd004b0` (88 files); wheel warning-free, 3/3 smoke, provider linkage correct; **no new Python surface**.

## 6. persephone3 (Agent D) — `b10574e`, `ae37687`

- **Assertion mystery closed:** the 1,330th assertion was a backend-detection-count-gated check in `test-extraction.R:40` that silently didn't fire on Linux; replaced by the semantically identical unconditional form → 1,330/1,330 both platforms; per-file census recorded as local baseline.
- Java policy: JVM ≥ 21 required by rjd3 3.9.0 jars; documented in README/NEWS + strengthened error in the existing `backend_rjd3_function()` hook; no heavyweight runtime probe invented (respects `runtime_checked = FALSE` contract). `shinycssloaders` premise corrected (already declared since `f9cb071`).
- CI: rjd3 refs pinned (`v3.9.1`/`v3.9.0`/`v3.9.0`); Java 21 already consistent. **Configured, never run** — recorded as such.
- `RELEASE_CHECKLIST.md` — interim release currently **RED** (P1 findings F1–F9, CI evidence, domain review).

## 7. Open items carried to M2

| Item | Owner | Notes |
|---|---|---|
| **22b.4** complete fixed additive B/C/D passes + selector stages | kalos | M2 headline |
| Sigma-rule default decision (22b.3a) | kalos maintainer | both rules qualified; export/entry-point promotion waits on it |
| rkalos export of 22b.3 wrappers after default decision | rkalos | bit-exact tests already in place |
| `arma_optimize` tanh-coordinate boundary handling | kalos | evidence in rkalos status; macOS cross-check open |
| License consistency pass (kalos/pykalos/persephone3 `LICENSE*` still MIT text) | maintainer | rkalos pattern established |
| CI lanes actually executed (all repos); Windows standalone; macOS re-qualification incl. `arma_optimize` | all | M6 platform-evidence scope, start opportunistically |
| pykalos public wheels (namespaced provider, manylinux) | pykalos | spike done |
| Persephone item 14 substantive parity matrix + P1 fixes F1–F9 | persephone3 | release-red blockers |

## 8. Reproduction anchors

- Provider: `/tmp/opencode/openblas` (pinned 0.3.34; builds now work with bare `-DOpenBLAS_ROOT` since `c6a1881`). Always `env -u LD_LIBRARY_PATH`.
- kalos builds: `/tmp/opencode/kalos-build` (OpenMP), `-serial`, `-san-cd004b0`; guard: `python3 tools/check-manifest.py`.
- rkalos: `Rscript --vanilla` + `R_LIBS=/tmp/opencode/rlib-b…`; serial lane via `R_MAKEVARS_USER` OpenMP-flag override; SVD probe under `tools/svd-tolerance-*`.
- persephone3: `R_PROFILE_USER=/tmp/opencode/rprofile-d.R`, `JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64`; scripts `/tmp/opencode/*.R`.
- All work is **local commits only**; nothing pushed anywhere.
