# M7 — Default-backend cutover decision package (item 27)

Date: 2026-11-25. Assembled from committed evidence; every claim links to a commit, log, or test. Item 27 is maintainer-owned with independent numerical sign-off: this package supplies the evidence and the recommended decision; the default switch is executed **only** upon maintainer authorization (§8).

## 1. Scope

Item 27 (kalos/docs/NUMERICAL_ROADMAP.md): make native the default backend only when current defaults and all promised features pass; remove mandatory Java/rjd3 dependencies; re-run the item 15 release validation against the resulting artifact with ordinary defaults. Family gate (PACKAGE_FAMILY_AND_AGENT_PLAN.md M7 row): explicit, evidence-backed cutover decision; Java-free install/run verified; domain reviewer sign-off on representative outputs.

## 2. Recommendation

**CUTOVER READY — authorize the §8 changeset.** All mandatory features of both methods, including the perX13() default template, pass natively under the full gate matrix; two genuine gaps found during review were closed with core slices and double-JVM oracles; one numerical deviation was found, root-caused, and resolved to reference parity rather than waived. Residual items (§7) are scope-bounded or maintainer-side. Withholding keeps native opt-in; all slices landed here are capability additions that stand independently.

## 3. Readiness gates found and closed during M7 review

| # | Gate | Frozen reference | Delivered |
|---|---|---|---|
| 1 | perX13() default template rsa3 lacked public residual diagnostics natively (plotResiduals refused; dashboard honest "unavailable") | 9-case double-JVM oracle `x13-automatic-diagnostics/public-x86_64.txt` | kalos `0fc583b`+`e2138a3` (generic accessor + producer wiring; 9/9 bit-exact ctest #95, orchestrator-replayed); rkalos `973bcc9` (0.1.0.9027: residuals forwarded, capability field, R-boundary 22-assertion bit pin; suites baseline+22 zero drift); persephone3 `e8f4bc5` (envelope ungate; GAP→PASS) |
| 2 | fTestSA_td / quality-report "Residual TD Effect" `Undefined` on every native product route (verified live) | 24-case double-JVM self-contained oracle `residual-trading-days/public-x86_64.txt` | kalos `f1af4df`+`20e6063` (pure producer; 192/192 doubles bit-exact ctest #96, orchestrator-replayed; semantics bytecode-proven: TradingDaysTest.maTest, TD7 contrast design, ARIMA(0,1,1)[12], F(6, dim−7)); rkalos `5e1ddca`+`a0c17fb` (0.1.0.9028/9029: primitive + reference-scale attach; suites zero drift outside the td file); persephone3 `e8f4bc5`+`da6b1e6` (consumed; numeric live parity) |
| — | Java-free install + item-27 lifecycle acceptance chain | — | persephone3 `524b3e0`: fresh Java-free `R CMD INSTALL` (469-entry isolated lib, six Java packages absent) then construct→fit→forecast→diagnose→plot→dashboard(callr child, Java-free)→serialize→reload→rerun: **STEPS=41 GAPS=0** across four product lanes (`e8f4bc5`/`da6b1e6` confirm on end-state) |

### Gate 2 deviation — found, root-caused, resolved to parity (item 26 classification discipline)

Initial wiring diverged from live rjd3 on log/multiplicative templates (rsa3 −21.9%, rsafull −57.5%) while agreeing exactly on additive fits. Root cause (dossier `tmp_opencode/m7-c-persephone/td-ftest-classification-2026-11-24.md`, call-graph + witness probes; the scratch dossier itself was removed by the maintainer's post-milestone cleanup `d0173f5`, its findings are preserved in this section, in the dated rkalos/persephone3 status entries and in the `da6b1e6` test comments): the live field feeds the SAME machine the WORKING/estimation-scale components (`GenericSaTests` lsa/lirr), not levels; the internal RegSarima fit makes F linear-scale invariant but not log-invariant — explaining the exact agreement pattern. Classified (a): same machine, different input representation. Resolution: attach switched to the reference input convention (rkalos `a0c17fb`), yielding bit-exact X-11 reference parity and tolerance-level SEATS parity (3.05e-08 by construction — the F test amplifies the tolerance-banded SEATS components ~1000×, documented). Consistency confirmation: the reference-scale scalars replay the frozen oracle doubles bit-exactly for all four TRAMO templates (the probe's log-template fixtures were themselves working-scale captures). The pure levels primitive remains exported and oracle-bit-pinned. Final live numeric parity (2e-8·(1+|ref|), persephone3 `da6b1e6`): rsa3 triple at rel 0.0e+00–8.9e-16; rsafull within measured bands (5.2e-08/2.3e-08); rsa0 rel 3.9e-09.

## 4. Java-free dependency graph

- rkalos Imports: Rcpp, stats only. pykalos: no runtime dependencies. persephone3: `rjd3*`/`RProtoBuf` are Suggests-only; transitive closure over all Imports → zero Java-package dependencies.
- Fresh Java-free install proven twice (`524b3e0`, re-certified on the end-state tree with vignettes): configure, compile, install, load, vignettes, with the six Java packages provably absent.
- Persephone `Remotes:` pin now `a0c17fb…` — resolves only after the rkalos push (§9).

## 5. capabilities() audit (rkalos 0.1.0.9029, core 20e6063)

Live transcript matches source; every route reported available maps to ≥1 qualifying tinytest file: tramo_seats_fit RSA0/1/3/full · estimated_x13_fit RSA0/1/2c · automatic_fit (incl. new residuals) · restricted_fit · tramo_preprocessing TR1/3/full · td_tests (new) · combined/adjusted seasonality · 70+ primitives. `fit = FALSE` / `status "unimplemented"` remains the honest description of UNRESTRICTED fitting; the mandatory product matrix (default templates, both methods, diagnostics/forecasts/plots/dashboard) reports full native support. Out-of-domain requests refuse verbatim, "No Java fallback" pinned in tools and tests. Degenerate-route behavior pinned by test: the D8-panel pseudo-additive quick/noout requests publish exactly-zero components (pre-existing route behavior, baseline-passing) — the TD attach omits fields there, never fabricates, and the omission is tested; zero-composition publication itself is noted as a separate numerical follow-up candidate.

## 6. Evidence package

kalos `docs/EVIDENCE_PACKAGE.md` (`8b348b6`, updated by the slices): 30 capability rows — 23 double-JVM-backed, 6 single-JVM-flagged, 1 analytic-only; all 57 evidence dirs + 12 X-11 corpora mapped to consuming tests; both formerly frozen-unwired captures now wired (ctest #95/#96). Hosted Windows/macOS/wheel evidence is maintainer-side and outside this package.

## 7. Bounded caveats (recorded, not hidden)

1. JVM fast-tier nondeterminism: `FastEigenValuesSolver` time-seeded bulge shifts — the reference disagrees with itself on six corpus indices; excluded from parity budgets with bytecode citation; decisions/tier outcomes still claimed.
2. Capture domains: bridge-flag, six-flag-refusal, and default-JVM panels coexist; consumers pin the matching arithmetic arm (automatic-route DH pins std::pow; estimated route keeps portable; both replayed). Persephone's two-pass oracle contract (Pass A 6,471 + Pass B 5,781 with five documented deferrals) enforces the domains with a fail-loud guard.
3. Pre-policy single-process X-11 fixture captures (documented per evidence row).
4. Hosted platform matrices (Windows/macOS/standalone Windows/wheels) remain maintainer-side; local lanes substitute the Linux CI job.
5. RSA2c estimated-route TD values carry NO parity claim (its fixture capture drifts up to 0.10 log units from this route under either convention — documented, unpromoted).

## 8. The cutover changeset (executed ONLY on authorization)

1. `persephone3/R/backend.R:12` default `"rjd3"` → `"native"`; roxygen default-statements (R/backend.R, perSingle.R, perTramo.R, perX13.R); roadmap item-19 transitional-default wording.
2. Engine-explicitness audit of `inst/tinytest`: every live-rjd3-reference and legacy test pins `backend = "rjd3"` explicitly at construction (backend change invalidates, never relabels); ~14+ files carry implicit-default constructions; full per-file audit in the slice.
3. Title/description/NEWS/backend-docs review; serialization/migration guidance for pre-cutover rjd3-backed objects (engine recorded per fit; existing objects keep their recorded engine).
4. Re-verify with ORDINARY defaults: Java-free lane full suite + lifecycle with no option and no backend argument; live lanes unchanged; then item 15 full pass against the exact artifact (§9.3).

## 9. Maintainer actions

1. **Push** (agents never do): kalos ×8 (`970a857`…`20e6063`), rkalos ×6 (`e3b5974`…`a0c17fb`), pykalos ×1 (`f8b2607`), persephone3 ×5 on `rkalos_backend` (`b063367`…`da6b1e6`). Push rkalos at or before persephone3 (Remotes pin).
2. Decide §8 (authorize / withhold / condition).
3. Post-switch: item 15 full pass on the resulting artifact with ordinary defaults (fresh Java-free install → default perX13()/perTramo() workflows), plus the hosted platform matrix on the final tree.

## 10. Sign-off checklist (domain reviewer)

- [ ] Representative outputs reviewed: rsa0/rsa3 + rsa0/rsafull fitted tables, forecast intervals, diagnostics tables incl. residuals + fTestSA_td, dashboard HTML (Java-free child), serialize→reload fidelity — the run logs lived under `tmp_opencode/m7-c-verify/` and `tmp_opencode/m7-c-persephone/`; the maintainer's post-milestone cleanup (`d0173f5`) removed that scratch, and every figure these logs carried is restated in the repositories' dated `IMPLEMENTATION_STATUS.md` entries and in §3/§11 above (and re-certified on fresh clones in the item-15 pass).
- [ ] Numeric parity table (`da6b1e6`, §3) and Gate-2 classification accepted.
- [ ] Caveats §7 accepted as bounded scope.
- [ ] Decision recorded; §8 authorized or withheld.

## 11. Execution record (2026-11-25)

Maintainer authorized §8 the same day. Executed as Persephone3 `8ec3036` ("Flip the default backend to native"): `resolve_backend()` unset → `native`; the pre-engine-recording-era `persephone$backend` fallback stays rjd3 (migration-honest); explicit/option `rjd3` fully supported. Engine-explicitness audit closed to zero implicit sites: 9 live-rjd3 legacy files pinned `backend = "rjd3"` with decision citations, default-resolution assertions flipped with citation, structure-only files left running (not skip-gated). Verification on the flipped tree: Java-free native lane 17 files **4451/0** (per-file identical to baseline, zero new skips); lifecycle with **ordinary defaults** `STEPS=41 GAPS=0`; oracle Pass A **6473/0** (+2, the cited test-backend.R additions; five deferrals unchanged); Pass B **5781/0** (bridge files untouched); `R CMD check` with vignettes **Status: OK**. Roadmap wording updated at kalos `6b59d31`. Orchestrator spot-checks: independent Java-free run confirmed unset→native / option+explicit rjd3→rjd3 / invalid refuses. Remaining (§9): pushing `6b59d31` and `8ec3036` (the maintainer pushed the pre-cutover stack the same day, resolving the `Remotes:` pin), item 15 full pass on the pushed artifact with ordinary defaults, hosted platform matrix, and a roxygen re-render pass on a healthy host (pinned roxygen 8.1.1 crashes on this host; the 7 affected Rd files were synced by hand).
