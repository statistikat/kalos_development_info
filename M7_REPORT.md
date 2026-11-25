# M7 milestone report — default-backend cutover (item 27)

M7 closed on 25 November 2026: the default backend of Persephone3 became the native engine, per roadmap item 27, after an evidence-backed decision package (`M7_CUTOVER_DECISION.md`, decision `397cfe8`) that the maintainer reviewed and authorized the same day. The review found two genuine gaps in the mandatory capability of the default template, closed both with double-JVM-oracle-backed core slices, root-caused one numerical deviation to reference parity rather than waive it, and then executed the flip with the full gate matrix re-run on the flipped tree. [Decision package](M7_CUTOVER_DECISION.md) · [Kalos status](kalos/IMPLEMENTATION_STATUS.md)

## Gates found and closed

The item-27 review (live capabilities audit, Java-free dependency-graph closure, and a fresh-install lifecycle harness, `524b3e0`) surfaced two mandatory-surface gaps. First, the automatic route lacked public residual diagnostics — closed in kalos `0fc583b`/`e2138a3` (ctest #95, nine cases bit-exact against the double-JVM oracle), forwarded by rkalos `973bcc9` (0.1.0.9027), and consumed by the Persephone3 envelope ungate (`e8f4bc5`), where the harness GAP line turned into a PASS. Second, `fTestSA_td` and the quality-report "Residual TD Effect" were `Undefined` on every native route — closed by the pure `residual_trading_days_tests` producer (kalos `f1af4df`/`20e6063`, 192/192 doubles bit-exact against the 24-case double-JVM oracle) and the rkalos primitive plus product-route attach (`5e1ddca`, 0.1.0.9028).

## The TD deviation, classified and resolved to parity

The first attach diverged from the live reference on log-transformed templates (rsa3 −21.9%) while agreeing exactly on additive ones. Root cause (dossier, call-graph and witness probes): the live field feeds the same machine the working-scale components, and the test is linear-scale invariant but not log-invariant. Classified same-machine/different-input-representation, then resolved by switching the attach to the reference input convention (rkalos `a0c17fb`, 0.1.0.9029): X-11 reference parity bit-exact, SEATS tolerance-level by construction, and the Persephone3 parity claims upgraded from classification-only to numeric 2e-8 (`da6b1e6`) — with the pure levels primitive still exported and oracle-bit-pinned.

## The cutover

`resolve_backend()` now defaults to native (Persephone3 `8ec3036`): live-rjd3 legacy tests were pinned `backend = "rjd3"` at construction with decision citations (nine files; audit closed to zero implicit sites), structure-only tests retargeted rather than skip-gated, default-resolution assertions flipped with citation, and the pre-cutover serialized-object fallback kept migration-honest. Roadmap wording updated (kalos `6b59d31`).

## Verification

| Repository | Verification |
|---|---|
| kalos | 96/96 CTests (required-OpenMP lane), serial ASan/UBSan clean; new ctests #95/#96 replayed bit-exact on a fresh build by the orchestrator |
| rkalos | suites 310,308 serial / 310,312 OMP with zero drift outside the TD test file; `verify-nojava --native` byte-identical across 9027→9029 |
| persephone3 | Java-free native lane 4,451/0 (per-file identical to baseline, zero new skips); lifecycle on **ordinary defaults** `STEPS=41 GAPS=0`; oracle Pass A 6,473/0, Pass B 5,781/0 with the five documented deferrals; `R CMD check` with vignettes **Status: OK** on the flipped artifact |
| Orchestrator | independent Java-free run of default resolution: unset → native, option/explicit `rjd3` → rjd3, invalid refuses |

## Open items (maintainer-side)

The maintainer pushed the pre-cutover stack (kalos through `20e6063`, rkalos through `a0c17fb`, pykalos, Persephone3 through `da6b1e6`), which resolves the `Remotes:` pin. Still to push: kalos `6b59d31`, Persephone3 `8ec3036` on `rkalos_backend`, and this repository's milestone commits. Then: the item 15 full release pass on the pushed artifact with ordinary defaults; the hosted platform matrix and wheels; a roxygen re-render pass on a healthy host (the pinned 8.1.1 crashes here; seven Rd files synced by hand); and the sign-off checklist in the decision package. Two ledger notes for follow-up consideration: the D8-panel pseudo-additive zero-composition publication (pre-existing, pinned, fail-soft-handled) and the RSA2c estimated-route TD capture drift (no parity claim, documented).
