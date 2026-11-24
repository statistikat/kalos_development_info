# kalos_development_info

Development-information workspace for the **kalos** seasonal-adjustment family:
the C++ numerical core [`statistikat/kalos`](https://github.com/statistikat/kalos)
and its binding/application packages
[`rkalos`](https://github.com/statistikat/rkalos),
[`pykalos`](https://github.com/statistikat/pykalos),
[`persephone3`](https://github.com/statistikat/persephone3).
The four code repositories are checked out beside these files but are **not**
part of this repository.

This repo holds the program layer: milestone reports and the
agent/milestone plan governing the family's slice train.

## Resume from the 2026-11-24 GitHub checkpoint

M5 and M5b are complete. Resume at **M6**. Each revision below links to its
implementation status at the published commit. [M5 report](M5_REPORT.md) · [M5b report](M5b_REPORT.md)

| Repository | Branch | Published revision | Dependency pin |
| --- | --- | --- | --- |
| kalos | `main` | [`7299cde`](https://github.com/statistikat/kalos/blob/7299cdefff357309b84f4409cbc76e7f556bb761/IMPLEMENTATION_STATUS.md) | — |
| rkalos | `main` | [`1c2037c`](https://github.com/statistikat/rkalos/blob/1c2037c6e9562337af84416742a4ce8966c617a5/IMPLEMENTATION_STATUS.md) | kalos `3a1f413` |
| pykalos | `main` | [`062b603`](https://github.com/statistikat/pykalos/blob/062b603dd47cc58faab53ce954cd739d3c7a3cbf/IMPLEMENTATION_STATUS.md) | kalos `a21f0f7` |
| persephone3 | `rkalos_backend` | [`a54f55d`](https://github.com/statistikat/persephone3/blob/a54f55d765eee713b61ee5f27b9a5b01838c88e3/IMPLEMENTATION_STATUS.md) | rkalos `0aaa37b` (0.1.0.9025) |

1. Check GitHub Actions for these revisions. All four repositories had queued runs when this checkpoint was recorded. Verify the platform and wheel results before closing M6.
2. Resume the SEATS extraction check on `seas.csv` with TR3 and TRfull. Both select the reference model. The published core stops during spectral factorization. A local prototype reproduced JDemetra’s 14 filter coefficients and variance using the robust symmetric factorizer. The next check is the full component and forecast comparison. [Reproduction input](https://github.com/statistikat/kalos/blob/7299cdefff357309b84f4409cbc76e7f556bb761/validation/evidence/native/x13-refusal-jvm-profiles/seas.csv)
3. Continue the M6 dashboard comparisons for adjusted-series Qs, seasonal F and residual trading-day tests at the binding and application pins above. M7 still requires domain review and a default-backend decision. [Milestone exit criteria](PACKAGE_FAMILY_AND_AGENT_PLAN.md#milestone-series)

## Contents

- `PACKAGE_FAMILY_AND_AGENT_PLAN.md` — milestone series M0–M7, repo roles,
  slice discipline and exit gates.
- `M0_REPORT.md` … `M5b_REPORT.md` — per-milestone completion reports
  (delivered surface, gate evidence, decisions, next-milestone state).
- `cleanup-tmp-opencode.sh` — janitor for the local scratch tree
  (`tmp_opencode/`, git-ignored: transient build/probe scratch).
- `m16-cfg-serial.log` — historical configuration log kept as evidence.

## Conventions

- Numerical decision records live in the code repos (`docs/contracts/`,
  `IMPLEMENTATION_STATUS.md`); this repo stores the surrounding analysis.
- Everything here is local-first: pushes to GitHub are done by the
  maintainer, matching the family-wide agent rule (agents commit, never push).
