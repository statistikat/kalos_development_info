# M6 milestone report — diagnostics, benchmarking & platform evidence

M6 closed its local gates on 24 November 2026 across all four repositories: the public diagnostic surfaces were frozen from the pinned JDemetra+ reference and ported, the SEATS WK extraction gained the complete JVM factorizer chain, a randomized differential harness hardened the factorizer core against adversarial filters, and the full test matrix was replayed through the platform lanes locally while the hosted runners stayed queued. The hosted Windows/macOS matrices and published wheels remain maintainer-side items. [Kalos status](kalos/IMPLEMENTATION_STATUS.md)

## Diagnostics suite (kalos item 25)

Public diagnostics were captured from the pinned reference and mirrored natively: preprocessing diagnostics frozen from nine automatic X-13 fits (`81fc994`), stock preprocessing forecast errors and residual diagnostics (`3a1f413`), adjusted-series Qs and seasonal F tests on fitted monthly products (`a21f0f7`), combined SI seasonality on automatic, raw-RSAfull and estimated RSA0/RSA1 products, portable residual-normality arithmetic, and the public RSA0 residual Ljung–Box test. The monthly RSA0 forecast-error projection consumes constant state storage; the 24-month projection itself takes about 0.03 ms on AirPassengers, and all 144 public JVM forecast errors pass at maximum absolute error 2.63e−13.

The performance pass on airline and mixed-factor workloads cut the mean of four case medians from 1,976 to 896 ms (airline) and from 1,111 to 489 ms (mixed factors) while preserving all 14,016 gains and every prediction, innovation and innovation variance. The separate JDemetra+ baseline and the remaining fixed-order gap are documented in the Python benchmark.

## SEATS WK factorizer chain

`factorize_sf` now mirrors the full installed JVM chain, EV2 → EV1 → fast → robust, including the symmetric Muller–Newton root tier. The reference was frozen from two independent JVM processes (`e59063f`) and the fast and robust tiers landed bit-exact against it (`b4f2e1d`). The previously refused `seas.csv` profile is the first chain member that resolves on the robust tier, and its frozen stage walk reproduces exactly.

## Adversarial randomized differential

A 512-case randomized differential of all four tiers plus the consumer seam was built with per-case process isolation, after establishing that the JVM reference itself can spin forever on adversarial filters (`EigenRoutines.balance`) and must be bounded by timeout, not by input filtering. The corpus found one real porting bug: every JVM `Complex` arithmetic result passes through `Complex.cart`, whose singletons normalize −0.0 to +0.0; the native mirrors kept the raw signed zero, and on two filters that sign flipped a square-root branch inside the Muller solver and turned a converging robust factorization into an `ArrayIndexOutOfBoundsException`. The fix routes all cart-ending operations through the singleton tree (`970a857`, local); the two adversarial filters are frozen as double-JVM `muller-adversarial` evidence (`c1d7f36`, local). The post-fix matrix is bit-exact JVM-versus-native with JVM and native repeats identical, on every scaling word, factor coefficient, null domain and refusal category. The only exclusions are six cases where the JVM reference disagrees with itself: `FastEigenValuesSolver` applies time-seeded `Random().nextGaussian()` bulge shifts every 25th stalled iteration. These are cited to the bytecode and listed in every run, never hidden.

## Platform evidence

The CI Linux matrix was replayed locally while hosted runs were queued: Release with owned OpenMP at two threads under the required-OpenMP gate, Release serial, and a full Debug run with address and undefined-behaviour sanitizers — 94/94 CTests in each lane with zero sanitizer reports, plus the installed-provider consumer against the pinned single-thread OpenBLAS 0.3.34 and the historical migration gate. The export manifest covers 207 core, 112 fixture and 410 evidence files (`94caffd`). The standalone Windows qualification job is authored and queued with the hosted matrix.

## Verification

| Repository | Verification |
| --- | --- |
| [Kalos](https://github.com/statistikat/kalos/commit/94caffd) | WK chain bit-exact against the double-JVM oracle; 512-case tier differential clean on the JVM-deterministic domain after the cart-singleton fix; 94/94 CTests in each of three lanes on a fresh build; manifest and migration gates green. Local follow-ups `970a857`, `c1d7f36`, `a7d4b12` await push. |
| [rkalos](https://github.com/statistikat/rkalos/commit/eb64ba3) | Re-pinned twice (to `b4f2e1d`, then to the fixed `a7d4b12`). Both lanes ran the full Java-free suite at exact baselines — 309,932 serial and 309,936 OpenMP assertions, zero differing files versus the previous pin. Full source check: status 1 WARNING, the retained deliberate `-ffp-contract=off` note; qualification OK. Local follow-ups `e3b5974`, `7b31e88`, `4419c42` await push. |
| [pykalos](https://github.com/statistikat/pykalos/commit/329cccc) | Wheel rebuilt on the pinned provider for each re-pin; provider digests unchanged; `core_version()` reports the pinned core. Full pytest 132 passed with 748 subtests, per-file identical to the baseline. Local follow-up `f8b2607` awaits push. |
| Persephone | Product parity held: the RSA3 product suite passes with Java hidden and against the live pipeline, and the general parity file passes 403 live comparisons with five documented deferrals. The 118 apparent parity failures were root-caused to a JVM math-flag capture-domain split, not a numerical regression: the bridge references were frozen with the `dexp`/`dlog` intrinsics disabled. The oracle suite is now partitioned into a 6,312-assertion default pass and a 2,132-assertion bridge pass under the matching JVM flags (total 8,444), with a fail-loud guard so a naive single pass cannot produce a false green. Java-free lane 563/563. Branch `rkalos_backend` commits `b063367` and `d5ee808` await push. |

## Deferred to the maintainer

Hosted GitHub Actions runs were queued since 24 November and remain maintainer-side per decision: the Windows and macOS matrices, standalone Windows qualification, and published wheels can only be produced there. The local lanes substitute the Linux CI job in the meantime.

## Supported scope

All M6 diagnostics are public reference comparisons on the pinned JDemetra+ 3.9.x capture; no tolerance was relaxed and no capability was promoted without evidence. The tier differential's bounded scope — JVM fast-tier bit-parity holds except under the documented random bulge shifts — is recorded in the kalos status. [Family milestones](PACKAGE_FAMILY_AND_AGENT_PLAN.md)
