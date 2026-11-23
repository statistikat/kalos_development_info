# Seasonal Adjustment Package Family — Overview & Parallel Agent Development Plan

## The package family

```
/data/home/kowa/seasonaladjustment/
├── kalos/        C++17 core engine (no R/Python/Java deps)
├── rkalos/       R/Rcpp interface to Kalos (uses R's BLAS/LAPACK)
├── pykalos/      Minimal Python bindings to Kalos (links OpenBLAS)
└── persephone3/  R application layer (OO wrapper, batch processing,
                  hierarchical series, charts)
```

**Relationships:**

- **`kalos`** is the numerical core: fixed-order SARIMA estimation, qualified
  inference/prediction, X-11 primitives. Consumers find it via
  `find_package(kalos)` / `kalos::kalos`. Full seasonal-adjustment fitting and
  automatic model selection are still open.
- **`rkalos`** and **`pykalos`** each vendor a *pinned snapshot* of Kalos
  (`src/kalos` / `vendor/kalos`), synchronized via `tools/sync-core.py` with
  `core.lock.json` — never edited in place, never fetched at install time.
- **`persephone3`** depends on `rkalos` at runtime. It currently fits models with
  `backend = "rjd3"` (JDemetra+ via rjd3 packages, Java required); the native
  backend is deliberately incomplete and never falls back silently.

**Shared conventions:**

- Every repo has `IMPLEMENTATION_STATUS.md` describing its scope/status, plus CI
  under `.github/`.
- Thread control via `KALOS_NUM_THREADS` (with `PERSEPHONE_NUM_THREADS` as a
  legacy alias).
- A numerics provider boundary: OpenBLAS standalone/Python, R's BLAS for
  `rkalos`.

---

## Plan of agents developing the packages simultaneously

### Dependency reality check

The repos are coupled (`kalos` → `rkalos`/`pykalos` → `persephone3`), but the
vendor-snapshot + `core.lock.json` model makes parallelism safe: downstream
agents develop against a *pinned* core and only re-sync at defined checkpoints.
The enabler is **contract-first development**: canonical fixtures and API
contracts in `kalos/docs/contracts/` are frozen before parallel work starts, so
downstream agents can code against expected behavior before the core code
exists.

### Agent roster (one per repo, running concurrently)

| Agent | Repo | Scope | Works against |
|-------|------|-------|---------------|
| **A — Core** | `kalos` | Complete seasonal-adjustment fitting: ARIMA order selection, regression outlier detection staging, full X-11 tables, Hilisko prime; keep contracts + canonical fixtures updated | `main` |
| **B — R binding** | `rkalos` | Wrap new core ops at the R boundary, R-level qualification tests in `inst/tinytest`, result formatting, status/capability fields | pinned snapshot N |
| **C — Python binding** | `pykalos` | Expose capability-gated API surface, NumPy interop qualification, GIL/signal handling tests | pinned snapshot N |
| **D — Application** | `persephone3` | Close the `native` backend gaps using the *current* rkalos API plus stubbed status fields; charts, batch/hierarchical paths, backend capability reporting | released rkalos |

### Coordination rules (what keeps them from colliding)

1. **Contract freeze (Phase 0, sequential, short):** Agent A drafts/stabilizes
   `docs/contracts/` and canonical fixtures for the next milestone; agents B–D
   review and sign off. This is the only strictly-sequential step.
2. **Snapshot checkpoints (Phase 2, staggered):** When Agent A lands a
   milestone, run `sync-core.py --kind r` / `--kind python` + `--verify` in a
   *separate integration step* — never by B/C mid-flight. Each sync is a single
   reviewed commit updating `core.lock.json`; B and C then un-stub their tests
   against the real core.
3. **Interface stubs, not guesses:** B, C, D code against frozen contracts. If
   an API must change mid-flight, Agent A posts a contract revision and B/C/D
   adapt in their own repos — no cross-repo edits.
4. **Ownership boundaries:** numerical logic only in `kalos`; R conversion only
   in `rkalos`; Python plumbing only in `pykalos`; application objects/charts
   only in `persephone3`. Never edit `src/kalos` / `vendor/kalos` directly.
5. **No silent fallbacks:** every agent preserves the status/capability honesty
   rule (`capabilities()`, `backend_capabilities("native")`) so partial work is
   always reported as partial.

### Timeline (steady-state pipelining)

```
Phase 0 (sync, short):   A drafts contracts ──► B, C, D review & stub
Phase 1 (parallel):      A: core features      ── milestone commits
                         B: R wrapper + tests  ─┐ against pinned snapshot N
                         C: Python layer       ─┤ + fixtures
                         D: native backend UX  ─┘ + stubbed capabilities
Phase 2 (checkpoint):    sync-core → rkalos/pykalos; B, C re-verify
Phase 3 (parallel again): A starts milestone N+1 while B/C/D qualify N
Phase 4 (integration):   persephone3 end-to-end native run() vs rjd3
                         reference corpus; cross-repo regression suite
```

Phases pipeline continuously; the **Milestone series** below maps each cycle to
Kalos roadmap items M0–M7.

### Conflict hotspots to assign explicitly

- **`IMPLEMENTATION_STATUS.md` (×4):** each agent owns its own file only.
- **CI workflows (`.github/` ×4):** each agent owns its repo's workflows;
  shared CI logic gets extracted to a reusable workflow owned by Agent A.
- **Contract docs:** Agent A authors; B–D may only propose changes (issues/PRs).
- **Fixtures:** generated exclusively in `kalos` and consumed read-only
  downstream.

### Milestone series

Milestones follow Kalos's numbered numerical roadmap (the true gating
sequence) and Persephone's application items. Each milestone is one checkpoint
cycle from the timeline above: core delivery → snapshot sync → downstream
qualification. Agents A–D keep working in parallel *within* every milestone.

| Milestone | Theme | Kalos (A) | rkalos (B) | pykalos (C) | persephone3 (D) | Exit gate |
|---|---|---|---|---|---|---|
| **M0** | Contract freeze & bootstrap | Freeze `docs/contracts/` + fixtures for the 22b.3 slice | Review contracts; stub wrappers/tests | Review; stub API surface | Review; stub native-backend status paths | All four repos' test suites pass against contracts + stubs |
| **M1** | X-11 endpoint statistics (22b.3a/3b) | Five-year dispersion, two-pass sigma weights (**resolve the pending default decision**), same-phase replacement neighbors, endpoints, correction factors | Wrap + R-qualify both accurate and legacy rules; refresh pin | Refresh pin only (no new surface) | Finish item 14 regression matrix; prepare **interim rjd3-stable release** (item 15, first pass) | JDemetra-qualified 22b.3a/3b fixtures pass in serial/OpenMP/sanitizers; rkalos tinytests green on new pin |
| **M2** | Complete additive X-11 (22b.4) | Fixed additive B/C/D passes + qualified selector stages; preserve intermediate tables & correction history | Expose stage-level results + capability flags | NumPy interop qualification; prep/estimation bindings for delivered ops | Native-envelope display of stage results (read-only) | Decomposition identities + original/extended calendars validated; full X-11 additive pass matches reference bytes/tolerances |
| **M3** | Restricted native fit (22b.5 / 22c) | Multiplicative/log/pseudo-additive decomposition + deterministic-effect allocation; **restricted fixed-model X-13 fit capability** | First `x13`-style fit entry point, capability-gated | Expose restricted fit (fixed model only) | **Wire the restricted native fit into `run()`** (app item 2): R6 workflows call rkalos; honest `is_stale`/stale-envelope behavior | End-to-end `perX13(...)$run()` succeeds with `backend = "native"`, no Java, for the restricted specification; matches rjd3 within documented tolerances |
| **M4** | Automatic X-13 (item 21) | Automatic preprocessing (outlier detection, ARIMA selection) feeding X-13/X-13ARIMA-SEATS | Bind automatic-model surface; difficult-model R tests | Bind automatic preprocessing | `perX13` templates (rsa0–rsa3…) fully supported natively; parity tests vs rjd3 on templates | Automatic selection reproduces pinned JDemetra+ choices on the reference corpus; no silent fallback anywhere |
| **M5** | TRAMO/SEATS (items 23–24) | TRAMO estimation + decomposition, SEATS components & uncertainty; method-specific decision-boundary qualification | `tramoseats`-style fit entry, qualified inference/prediction modes | Bind TRAMO/SEATS if surface is stable | `perTramo(...)$run()` works natively; diagnostics parity (app item 12 surfaces) | SEATS components match reference within budget; both methods usable Java-free in Persephone |
| **M5b** | Fixed-structure coefficients-estimated X-13 (item 28; automodel-OFF templates rsa0–rsa2c) — maintainer decision 2026-11-21: numbered, executes **after** the M5 slice train | Own probe/ledger slice first (M5-open style), then estimated-coefficient fit through X-11 incl. MSR filter plan and automatic-Henderson decision stage with its own JVM oracle corpus | Restricted-fit envelope extension, capability-gated | Mirror envelope once surface is stable | Route rsa0/rsa1/rsa2c natively via the extended restricted route; per-template parity vs rjd3; refusals stand until qualified | rsa0–rsa2c native with bit-exact decisions and qualified tiers — M4 "rsa0–rsa3 fully supported" met literally — or refusals retained with refreshed evidence; no tolerance relaxation |
| **M6** | Diagnostics, benchmarking & platform evidence (items 25, 16c/18d.2, app items 14/26) | Diagnostics suite + benchmarking; Linux/macOS/Windows (incl. standalone Windows) qualification; performance pass on airline/mixed-factor workloads | Windows/Linux CI green; expanded platform qualification | Portable bundled-OpenBLAS wheels + import-order qualification | **Product parity (item 26)**: all dashboards/quality reports/forecasts correct on native backend | Full regression matrix green on all supported platforms; timings reported against JDemetra baseline without tolerance relaxation |
| **M7** | Default-backend cutover review (item 27) | Final evidence package for each delivered capability | `capabilities()` reports full native support | — | **Review native as default backend**; Java becomes optional, not required; release review (item 15, full pass) | Explicit, evidence-backed cutover decision; Java-free install/run verified; domain reviewer signs off on representative outputs |

Milestone discipline:

- **One milestone in flight for core at a time** (Agent A), but B/C/D are never
  idle: they qualify milestone *n* while A builds *n+1*, and D always has
  application-side work (items 12–14, 26) independent of the numerical path.
- **No milestone skips a sync checkpoint.** M3 is the first where all four
  repos ship coordinated feature work; M0–M2 keep the sync machinery routine.
- **Exit gates are written into each repo's `IMPLEMENTATION_STATUS.md`** before
  the milestone starts and updated only after validation, per Kalos's rule that
  each numerical slice is a separate commit.
- **Descope rule:** if a gate fails (e.g., the 22b.3a sigma-default can't be
  qualified), the capability stays unpromoted and the milestone exits with an
  explicit "pending decision" note rather than a relaxed tolerance — matching
  the existing "no capability promoted silently" policy.

### Definition of done per cycle

- `kalos`: `ctest` green, contracts + fixtures versioned, CHANGELOG updated.
- `rkalos` / `pykalos`: `sync-core.py --verify` green, tinytest/unittest suites
  pass against the new snapshot, `capabilities()` reflects reality.
- `persephone3`: `R CMD check` clean, native backend results match (or are
  documented as diverging from) the pinned rjd3 reference corpus.
