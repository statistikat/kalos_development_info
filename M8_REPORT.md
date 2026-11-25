# M8 milestone report — item 15 final release review (native-default artifact)

M8 ran the item-15 release gate against the exact pushed post-cutover artifacts on 25 November 2026 — the roadmap's closing step ("repeat after 27 for the native-default Java-free release", item 27's acceptance line: *a fresh no-Java install followed by default `perX13()` and `perTramo()` workflows*). Every lane certified from **fresh clones of the pushed GitHub refs**, not workspace trees. Verdict: **PASS** — all four lanes certified the pushed artifacts with zero failures and zero expectation changes.

## Artifact identity (live-proven against origin)

| repo | certified commit | proof |
|---|---|---|
| kalos | `6b59d31` | `git ls-remote` live-equal to `refs/heads/main`; tree built and tested |
| rkalos | `a0c17fb` | clone tree == `origin/main` tree; vendored core `20e6063dea…`; == the persephone3 `Remotes:` pin |
| pykalos | `f8b2607` | clone tree == `origin/main` tree; vendored core `a7d4b12` (its own recorded pin — see follow-up) |
| persephone3 | `8ec3036` | clone HEAD == live `refs/heads/rkalos_backend` |

## Gates

| lane | gate | result |
|---|---|---|
| kalos | Release/OpenMP build, full ctest ×2 | **96/96** both runs |
| kalos | export manifest / migration verifier | **209/112/410**; 406 files without rebaselining |
| kalos | evidence digest spot checks (double-JVM / single-JVM / analytic) | **6/6 recomputed matches**, incl. the full-64-hex TD capture digest |
| kalos | installed-provider consumer probe | exit 0; provider `.so` byte-identical to the CI reference; `OpenBLAS 0.3.34 … SINGLE_THREADED` |
| rkalos | two fresh lane installs from pushed source | probes exact (`0.1.0.9029`, core `20e6063`, serial/OMP as commissioned); both `verify-nojava --native` PASS, transcripts byte-identical |
| rkalos | full suites (69 files, both lanes) | serial **310,308 / 310,312 OMP / 0 fails** — exact target totals (committed-source-reconstructed baselines); cross-lane delta reproduces the recorded 2-file/±4 signature exactly |
| pykalos | wheel build + full suite at its pin `a7d4b12` | wheel byte-identity 1,510,599 vs 1,510,600 B (zip-timestamp only; identity via revision/provider/suite); suite **132 passed / 748 subtests / 0 failed** — exact baseline, 18-file per-file collection matches its recorded table one-for-one |
| persephone3 | **fresh Java-free install + ordinary-defaults acceptance** | `* DONE` with `JAVA_HOME=/nonexistent`; 469-entry isolated lib, six Java packages absent; `resolve_backend()` unset → **native**; both methods `status=success backend=native`; residuals + `fTestSA_td` served; **`LIFECYCLE STEPS=41 GAPS=0` exit 0**; serialize→reload→rerun bit-identical ×4 lanes |
| persephone3 | Java-free native suite | 17 files / **4,451** / 0 (td-parity 101 anchor exact); `verify-nojava` exit 0 |
| persephone3 | oracle lanes | Pass A 39 files / **6,473** / 0, exactly the five deferrals (file-by-file reconciliation); Pass B **5,781** / 0 with capture flags proven in the JVM |
| persephone3 | **published-chain proof** | `install_github` downloaded persephone3@`8ec3036` **and** the pin rkalos@a0c17fb from GitHub; both installed, exit 0 |
| persephone3 | `R CMD check --no-manual` with vignettes (oracle lane) | **Status: OK, exit 0, zero NOTE/WARNING**; vignettes re-built OK |

All headline lines above were independently re-grepped from raw lane logs by the orchestrator, not only reported by the lanes.

## Honest notes

1. **ctest index clarification** (correction to the M7 report's label): at current HEAD the two new oracle tests sit at indices **#39** (residual trading days) and **#96** (automatic diagnostics); M7's "#95/#96" prose was a registration-order slip — same tests, both certified twice here.
2. **Post-M7 scratch purge** (root `d0173f5`) deleted per-file baseline logs and farm harnesses the M8 briefs referenced; dispositions were recorded in the two status docs and the decision package, baselines fell back to the committed totals (310,308/310,312; fresh native-lane per-file table recorded here becomes the new baseline), and harnesses were rebuilt as fresh scripts. Nothing was forced to match remembered numbers.
3. **pykalos core pin divergence**: pykalos@`f8b2607` pins core `a7d4b12` while rkalos pins `20e6063`; both are internally consistent with their own recorded states, and the kalos commits between them are additive surfaces untouched by pykalos. Follow-up (non-blocking): pykalos core re-pin at its next surface change.
4. Site `Rprofile.site` `.libPaths` clobbering and one CRAN gap-fill (`shinycssloaders` from Posit PPM) were environment-side workarounds; the certified artifacts were untouched — no fixes, tolerance edits, fixture changes or commits occurred in any lane.
5. The rkalos lane caught and disclosed two of its own harness slips (a first serial-lane install that picked up OpenMP, quarantined and provably reinstalled serial: 0 `-fopenmp` lines; a mid-run script-edit pipeline kill) — the gate process caught them before any result was consumed, and the contaminated lane was never used.

## Program state after M8

Items 15 (both passes), 16–27 complete with their evidence; item 28 closed at M5b. The numbered program is done. Remaining is publication-side: hosted platform matrices + wheels, CRAN/wheel release logistics, the domain-reviewer sign-off checklist in the decision package, pushes of the three ledger-doc commits (`89090dc`, `383b7e0`, `789f684`), and the recorded small follow-ups (roxygen re-render host pass; D8 zero-composition note; RSA2c TD drift; pykalos re-pin). A separate performance track (M9, external-library evaluation) is running in parallel with its own decision-record discipline.
