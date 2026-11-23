# M3 Report — Decomposition Modes, Deterministic-Effect Allocation, and the Restricted Native X-13 Fit

**Dates:** 2026-11-16 → 2026-11-17
**Scope:** Kalos items 22b.5 + 22c (all four decomposition modes; X-13 deterministic-effect allocation; restricted fixed-model X-13 fit), the rkalos fit-boundary qualification + capability schema v2, pykalos pin realignment, and the Persephone product seam — **first Java-free seasonal adjustment in the family**.
**Participants:** Agents A–D. Predecessors: `M1_REPORT.md`, `M2_REPORT.md`.

---

## 1. Executive summary — exit gate MET

**The demo exists:** `perX13(..., backend = "native")$run()` on a restricted fixed specification produces a seasonal adjustment **bit-exact (max abs diff 0.000e+00 on SA/trend/irregular)** against the raw `x13_fast` reference, with zero Java namespaces loaded, inside a suite of 1,459 green Persephone assertions.

| Gate | Result |
|---|---|
| Multiplicative/log/pseudo-additive modes qualified before any fit capability (roadmap gate) | ✅ M3a `db32989`, M3b-i `4646cca`, M3b-ii `cce7172` — 91-case full sweeps per mode bit-exact at C++ and R layers |
| Deterministic-effect allocation qualified | ✅ M3c `efd4ce0` — pinned `initialStep`/`finals` seams, a-table bucket semantics proven case-by-case |
| Restricted fixed-model X-13 fit with final components + forecast domains | ✅ `f84489e`+`2b93ab0` — `x13_fit`, 9 fixed-route cases end-to-end; forecast domain pinned to **exactly {0,0}** with evidence |
| Native fit at the R boundary; capabilities honest | ✅ rkalos `10afd3e`, suite **290,057 / 0** both lanes; schema v2: `fit` stays FALSE; `native_x13_fit_restricted` + `restricted_fit` scope block |
| Persephone native `run()` + measured parity | ✅ `97865a4` — bit-exact parity vs rjd3, JVM-free proof, refusal wording names violated scope fields |
| No promotions/tolerances without evidence; nothing pushed | ✅ throughout; every layer fail-closed |

## 2. Kalos (Agent A) — 7 commits, `db32989 → 2b93ab0`, suite 44→48/48 all trees

| Slice | Signature pinned facts |
|---|---|
| M3a multiplicative | `calcAbsMeanVariations` relative-lag flag governs the const-MSR degenerate at exactly 3.515625; `MsrTable.of` relative test is strict `mode==Multiplicative`; additive captures byte-identical after mode parameterization |
| M3b-i log-additive | Kernel input `DoubleSeq.log()` bit-identical to C `log` on 6,701 values; additive-composed log-domain tables; shared positivity gate |
| M3b-ii pseudo-additive | `X11{B,C,D}StepPseudoAdd` = multiplicative ratio context + **twelve** `PseudoAddUtility` composition overrides (lambda orders verified from invokedynamic records); zero/negative inputs legal (pinned `check()` gates only mult/log) |
| M3c allocation | a-table classification with exact `regeffect` matching (`a9u` contributes nowhere); `addAY` accumulation order; log exp'ing with `a1` = complete input; `updateSpec` mode forcing; finals op/invOp/mean truth table incl. the log-additive asymmetry |
| 22c fit | Composition = pinned `X13Kernel.process` order; **`finalTrend`/`finalIrregular` don't exist in pinned jars** — the finals triplet `D11final/D12final/D13final` is the honest vocabulary; horizon domain `{0,0}` exactly (a1a/a1b evidence cases `f_h6`/`f_b3h3`); `Math.exp`-vs-libm 1-ULP boundary at worst 4.49e-16 encoded, not smoothed |

One subagent context-compaction crash mid-M3a: recovered from `git diff` + probes under no-destructive-git rules, slice completed — small-qualified-commits again served as crash insurance.

## 3. rkalos (Agent B) — checkpoints `d54f2b7`, `10afd3e`; suite 275,664 → **290,057 / 0**

- Mode coverage at the boundary faithful to pinned composition: C/D *inherit* mode from their companion object (contradicting explicit mode refused boundary-locally — the core has no restatement surface).
- Fit + allocation qualified (875 new assertions), including the two corpus-vs-core subtleties (seam `out` exact vs fit-corpus `out` at the exp boundary) resolved **against the core corpus**, not patched around.
- **Capability schema v2** (the honesty artifact of the milestone): `fit=FALSE` keeps its unrestricted meaning; gate is `native_x13_fit_restricted=TRUE` + `restricted_fit` block (`fixed_coefficients_only`, `fixed_seasonal_requests_only`, `fixed_trend_length_only`, `sigma_policy_required`, `zero_horizon_only`, `monthly_only`, `modes`, entry points). Documented field-by-field for consumer gating.
- Friction list now **12 items** (label-less mode rejection, mode-as-contract-surface, fixture metadata gaps, fit-result regression fingerprint, …) — preserved verbatim, awaiting one consolidated contract-doc slice.

## 4. pykalos (Agent C) — `07168c0`

Batched advance to `2b93ab0` (90→102 vendor files); all new TUs compiled; 12/12; pins realigned with rkalos; `x13_fit` present in the core but deliberately **not exposed** in Python (roadmap: no premature surface).

## 5. persephone3 (Agent D) — `97865a4`

- Template sentinel `"restricted"` → `persephone_native_spec`; scope-field-named refusals with the preserved no-Java-fallback wording; honest envelope class `persephone_native_restricted_fit` (no faked `$output`), provenance echoes + request fingerprint (which caught a real bug: silently omitted sigma policy pre-fix).
- **Parity measured:** AirPassengers, s3x15 all periods, Henderson 13, additive, legacy sigma → SA/T/I max abs diff **0.000e+00**; 1e-8 policy untouched; harness prints per-component diffs on any future violation.
- Java-free lane: symlink-farm JVM-absent run, 53/53, zero Java namespaces; `verify-nojava.R` extended.
- Product finding recorded (rjd3 lane, not fixed): zero-horizon `$run()` violates the pre-existing forecast contract (`cal_f`/`y_ef`) — dual-lane reference therefore uses raw `x13_fast`; follow-up queued.

## 6. Open items and decisions for the maintainer

1. **Sigma-rule default** (22b.3a) — **RESOLVED 2026-11-17 by the maintainer: `legacy` is the product default** (the rule proven bit-exact against pinned JDemetra behavior). Core keeps the policy argument explicit; the default lands at the interface layers (rkalos wrapper, then Persephone spec) — cascade in progress, tracked under M4.
2. Contract-doc consolidation slice (12 friction items) — quick win, scheduled as M4-S0.
3. Restricted-domain gaps (documented, honest): quarterly fit, nonzero horizons (ExactArima route: a1a/a1b/split finals), estimation of coefficients, cross-validation, period-specific corrector, mean-endpoint fallback, benchmarking, LA export stage beyond delivered composition.
4. CI lanes still never executed; Windows standalone; macOS cross-checks (`arma_optimize` boundary, `Math.exp` comparison on Apple libm).

## 7. Next: M4 (item 21 — automatic preprocessing and selection)

Estimation enters the pipeline (outlier detection, ARIMA identification/selection feeding the already-qualified fixed machinery). First dispatches: Kalos contract-doc touch-up (M4-S0) → item-21 scoping decomposition with the first qualified selection-primitive slice. The restricted-fit path stays untouched and green throughout; when M4's automatic spec exists, the Persephone `"rsa"` templates become the next capability block in the same honest schema.
