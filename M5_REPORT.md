# M5 milestone report — native monthly TRAMO-SEATS

M5 met its family exit gate on 24 November 2026. The four packages deliver stock monthly TRAMO-SEATS RSA0, RSA1, RSA3 and RSAfull from the original observations. In Persephone, `perTramo(series, "rsafull", backend = "native")$run()` estimates the model, decomposes the series and supplies the data for the application’s component, forecast, regressor and residual reports. The native path runs without Java. Java was used independently to generate reference outputs and to test the live application comparison. [Application implementation and qualification](https://github.com/statistikat/persephone3/commit/65ed21034e6684479f9df3159fc316945ef830ec)

## Numerical qualification

| Public JDemetra+ comparison | RSA3 | RSAfull |
| --- | ---: | ---: |
| Complete monthly fits from original observations | 20 | 29 |
| Dated preprocessing residuals, bit-for-bit | 2,105 | 4,165 |
| Merged observed component and point forecast values, bit-for-bit | 13,980 | 26,160 |
| Residual diagnostic values, bit-for-bit | 100 | 145 |
| Conditional SEATS forecast errors, bit-for-bit | 480 | 696 |
| Original-series forecast errors within the existing scaled tolerance | 480 | 696 |

All 5,232 observed and forecast RSAfull calendar effects matched on their original scale. The automatic model panel exercises working days, full weekday contrasts, leap year, Easter, outlier detection and a late trading-day decision. The RSA3 panel includes reference-model retries and two fits for which JDemetra returns no stochastic seasonal component. Those fits return a neutral final seasonal factor and identify the unavailable seasonal uncertainty. [Raw product implementation](https://github.com/statistikat/kalos/commit/73115f7) · [Forecast and calendar qualification](https://github.com/statistikat/kalos/commit/45e78cff6a2daa573f59cc9301451341cbf5265f)

## Package verification

| Repository and revision | Local result on macOS ARM64 |
| --- | --- |
| [Kalos](https://github.com/statistikat/kalos/commit/45e78cff6a2daa573f59cc9301451341cbf5265f) | The full RSAfull component revision passed all 87 OpenMP CTests and all eight targeted sanitizer tests. All seven targeted Release tests passed at the subsequent calendar and uncertainty revision. |
| [rkalos 0.1.0.9021](https://github.com/statistikat/rkalos/commit/45cf058c46f225005ce73ebe04e1b96b6587d907) | Serial and two-worker OpenMP builds each passed 3,112 RSAfull, 2,130 RSA3, 990 RSA1, 498 RSA0 and 601 standalone preprocessing checks. The full serial suite passed 308,774 assertions across 64 files. The OpenMP source check passed 308,778 assertions and reported the two existing compiler warnings. |
| [pykalos](https://github.com/statistikat/pykalos/commit/e708a01) | The installed wheel passed all 131 tests, including 5,640 existing X-13 comparisons. The RSAfull suite covered all 29 models and zero-, one- and seven-month forecast requests. |
| [Persephone](https://github.com/statistikat/persephone3/commit/21f09f3cf41a32d10aab0dbfda251736d49f7d60) | The four-template reporting suite passed 3,383 assertions without Java and 5,238 against the live reference. The RSAfull subset passed 1,029 and 1,843 respectively. After correcting the inventory test to expect all four templates, the full source check passed 7,488 of 7,488 assertions, examples, rebuilt vignettes and the PDF manual with status OK. The dependency pin resolves to the published rkalos revision above. |

## Scope and follow-up

The published interface accepts complete monthly univariate series. Stock presets and the documented model and horizon envelopes determine which fits are available. A model that needs an unsupported SEATS approximation returns an explicit status. The application retains the reference backend default until the M7 review. [R interface and supported inputs](https://github.com/statistikat/rkalos/blob/45cf058c46f225005ce73ebe04e1b96b6587d907/man/native_tramoseats_fit.Rd)

M5b covers the separate X-13 fixed-order estimated-coefficient presets. M6 covers hosted Linux, macOS and Windows qualification, timing comparisons and the remaining application diagnostics. M7 requires representative outputs reviewed by a domain specialist and a recorded default-backend decision. [Family milestone plan](PACKAGE_FAMILY_AND_AGENT_PLAN.md)
