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

## Contents

- `PACKAGE_FAMILY_AND_AGENT_PLAN.md` — milestone series M0–M7, repo roles,
  slice discipline and exit gates.
- `M0_REPORT.md` … `M4_REPORT.md` — per-milestone completion reports
  (delivered surface, gate evidence, decisions, next-milestone state).
- `cleanup-tmp-opencode.sh` — janitor for the local scratch tree
  (`tmp_opencode/`, git-ignored: transient build/probe scratch).
- `m16-cfg-serial.log` — historical configuration log kept as evidence.

## Conventions

- Numerical decision records live in the code repos (`docs/contracts/`,
  `IMPLEMENTATION_STATUS.md`); this repo stores the surrounding analysis.
- Everything here is local-first: pushes to GitHub are done by the
  maintainer, matching the family-wide agent rule (agents commit, never push).
