# M5b milestone report — estimated fixed-order X-13

M5b met its family exit gate on 24 November 2026. Kalos, rkalos, pykalos and Persephone support the stock monthly X-13 RSA0, RSA1 and RSA2c presets. In Persephone, `perX13(AirPassengers, "rsa2c", backend = "native")$run()` estimates the coefficients, selects calendar regressors and outliers, runs X-11, and returns the observed components and twelve months of point forecasts. With the existing monthly RSA3 route, all four X-13 presets named in the M4 gate have a native implementation. [Persephone stock fit implementation](https://github.com/statistikat/persephone3/commit/775ce9d476533c0055311da16c8342444a75e41d)

## Fitting decisions

| Preset | Decisions made from the input observations |
| --- | --- |
| RSA0 | Fit an airline model on the level scale. Select the Henderson trend length and seasonal filters. |
| RSA1 | Also choose log or level and detect additive outliers, level shifts and transitory changes. |
| RSA2c | Also test working days and leap-year effects and compare Easter durations of one, eight and fifteen days. |

The nine end-to-end cases cross these presets with AirPassengers, a series containing an additive outlier, and a difficult seasonal series. On AirPassengers, RSA2c chose working days, one-day Easter and a May 1951 additive outlier. On the second series it chose only the January 1994 outlier. The third series retained its level scale with no calendar regressor or outlier. A separate fifteen-case calendar panel checks all six candidate fits per input, including cases on either side of each calendar decision. [Decision ledger](https://github.com/statistikat/kalos/blob/a32dce6/docs/contracts/x13-estimated-templates.md) · [Calendar candidate tests](https://github.com/statistikat/kalos/commit/281d6a7)

## Verification

Two independent pinned JDemetra+ processes produced identical public reference outputs. All nine native fits reproduced the model decisions, estimated SARIMA and regression coefficients, likelihoods and **891 dated model residuals** bit-for-bit. The **12,276 observed, extended and forecast values** across 126 dated rows passed the existing scaled tolerance of 1e-8. These rows include preadjusted data, intermediate X-11 tables, observed final components and forecasts. [Native fit and reference replay](https://github.com/statistikat/kalos/commit/a32dce6)

| Repository | Verification |
| --- | --- |
| [Kalos](https://github.com/statistikat/kalos/commit/a32dce6) | Eight adjacent Release tests and five serial ASan/UBSan tests passed, including the stock presets and existing automatic X-13 horizon regression. |
| [rkalos 0.1.0.9023](https://github.com/statistikat/rkalos/commit/f53ee8f7516fe2366d3fb8c4fe7ca0ca9058f351) | All 671 stock assertions passed in both serial and OpenMP builds, together with 2,608 adjacent X-13 and seasonality checks and the Java-free smoke test in each build. The full suites passed 309,527 serial and 309,531 OpenMP assertions. The R source check passed with the two documented compiler warnings. |
| [pykalos](https://github.com/statistikat/pykalos/commit/515276a) | The installed wheel passed all 139 tests. A separate subprocess ran the three stock presets and four TRAMO-SEATS presets in an environment without R, Rscript or Java executables. The loaded-library check found no R or JVM runtime. |
| [Persephone](https://github.com/statistikat/persephone3/commit/975c771c21195258cd9f49c091642fdba6924cde) | All nine stock fits passed 315 Java-free and 549 live-reference checks. The application compared six observed series and five forecast fields per case, including the selected calendar and outliers in the relevant reports. General parity passed 206 Java-free and 403 live comparisons. After correcting two earlier refusal expectations and the method-specific capability filter, the full source check passed 8,244 assertions, examples, rebuilt vignettes and the PDF manual with status OK. |

## Supported scope

The three stock entries accept complete monthly observations and use the preset one-year forecast horizon and zero backcasts. The stock route estimates the coefficients within the airline orders. The explicit fixed-coefficient fit and the automatic RSA3 route retain their own documented controls. Windows, Linux and macOS hosted qualification belongs to M6. [R interface](https://github.com/statistikat/rkalos/blob/f53ee8f7516fe2366d3fb8c4fe7ca0ca9058f351/man/native_x13_estimated_fit.Rd) · [Family milestones](PACKAGE_FAMILY_AND_AGENT_PLAN.md)
