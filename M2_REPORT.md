# M2 Report — Complete Fixed Additive X-11 Passes (22b.4) + Downstream Checkpoints

**Dates:** 2026-11-16
**Scope:** Kalos roadmap item **22b.4** (fixed additive B/C/D passes + qualified selector stages) with per-slice R-boundary checkpoints in rkalos; pykalos NumPy interop qualification; Persephone item-14 parity harness + P1 truth table.
**Participants:** Agents A–D. Predecessor: `M1_REPORT.md`.

---

## 1. Executive summary — exit gate MET

| Gate | Result |
|---|---|
| Fixed additive B/C/D passes with preserved intermediate tables + correction history | ✅ **S1–S3** (`16f2785`, `7e8e38d`, `886f4e1`): 19+14+16 pinned tables, correction rounds, **bit-exact vs pinned JDemetra+ captures** (18/18/22 cases; identities recomputed independently) |
| Decomposition identities + original/extended calendars validated | ✅ 10+ identities capture-side and unit-side; extended-qualified via 4 hand-built extended-calendar cases (MSRE is the only calendar-sensitive pinned component — proven, not assumed) |
| Qualified selector stages connected | ✅ **S4** (`0ad8c59`): `x11_selection_pass` composes the 22b.3c/3d primitives; 15 decision cases + 6 full selected-state cases bit-exact incl. the 19-evaluation MSR attempt walk and five-year-cap truncation at the exact pinned prefix |
| All configurations green | ✅ Kalos **43/43** Release-OpenMP + true serial at `0ad8c59` (44/44 incl. M3a at `db32989`); ASan/UBSan zero diagnostics; thread sweeps 1/2/4 identical |
| rkalos per-slice checkpoints green | ✅ three syncs (`2802d14` → `4485be0` → `ca17f88`), suite grew **270,653 → 275,664 assertions, 0 failures** every lane; all new entry points unexported, explicit policy, nothing promoted |
| No capability/default promoted; no tolerance relaxed | ✅ sigma policy remains a required argument; unsupported paths return explicit `unsupported:<stage>` statuses |
| Application track | ✅ F1–F9 P1s **empirically verified fixed** (release now amber); item-14 parity harness with pinned 1e-8 tolerance policy |

**State at milestone end:** the entire fixed-model additive X-11 pipeline — initial tables → sigma weights → replacements → B → C → D → selection — exists in Kalos as qualified, individually contracted, bit-exact pieces, consumable through R at unexported internal entry points. That is precisely the foundation M3's restricted X-13 fit composes.

## 2. Kalos (Agent A) — five commits, `16f2785 → db32989`

| Slice | Content | Signature evidence |
|---|---|---|
| S1 `16f2785` | B pass (`x11_b_pass`), 19 tables, 3 correction rounds | pinned `b21` moment decode (whole-right-dot `addProduct` order — interleaved accumulation is 1–2 ULP off); `henderson(p)+of2_3` trend weights; 18 cases × 20 tables bit-exact |
| S2 `7e8e38d` | C pass (`x11_c_pass`), 14 tables, B-pass **required** with enforced coupling | C2 cropped-table semantics; `C11 = Y − C10`; `iStart=c2drop` normalizer + endpoint extension; shared machinery moved to `detail/x11_pinned.hpp` with B re-verified after the refactor |
| S3 `886f4e1` | D pass (`x11_d_pass`) + MSRE diagnostics + extended calendars | **`defaultMsrTable` additive branch is plain `x − mean`** (λ-form belongs to other modes) — proven by isolation; `D9_g_bis ≡ D9bis`; D never extends internally |
| S4 `0ad8c59` | Selection flow (`x11_selection_pass`) | **inline B7 branch** (ratio ≥ 1 → period+1; quarterly picks 5 where `selectFilter` says 7); always-computed D-final iCRatio; NaN degenerates → explicit unsupported |
| `04b9030` (+`db32989` early-M3) | Verifier fixture-path hard-wiring; multiplicative mode (reported under M3) | manifest guard caught a real fixture omission; capture serialization bug caught by a new structural CSV guard |

Fixtures now total 97 core + 180 manifest entries with `check-manifest.py` green each commit — the M1-added guard fired three times in M2 (msr.csv omission, capture serialization bug, verifier path staleness fixed in `04b9030`).

## 3. rkalos (Agent B) — three checkpoints, pin `cd004b0 → 0ad8c59`

- Established the **faithful-rebuild/passthrough wrapper pattern**: each pass wrapper consumes the prior pass's R result object, rebuilds the pinned core struct, and lets the core's own coupling checks enforce the composition (never silently recomputes upstream passes). This caught a real schema-change friction (S3 struct growth) exactly as designed.
- New unexported entries + bit-exact tests: `native_x11_b_pass` (18 cases, 1,395 assertions), `native_x11_c_pass` (1,124), `native_x11_d_pass` incl. extended calendars (1,638), `native_x11_selection_pass` (854, incl. attempt-walk bit-exactness and cap truncation).
- Suite trajectory (all lanes, 0 failures): **270,653 → 272,048 → 273,172 → 275,664** (serial −4, the known conditional-test delta). R-side gotcha caught and fixed in-house (`$` partial-matching `round`→`rounds`).
- **Friction list for upstream (7 items, verbatim in rkalos `IMPLEMENTATION_STATUS.md`)** — B9d/B20 table-mapping wording, shadowed quarterly validation gate, duplicate input CSVs across fixtures, composition-schema changes as contract surface, msr.csv row-semantics documentation, unsupported-run record semantics. → queued as one small kalos contract-doc slice.

## 4. pykalos (Agent C)

- NumPy interop **qualified, not changed**: pybind11 boundary matrix (strided/read-only/converted inputs; core-error verbatim propagation) pinned by 9 new tests (suite 12/12); copy-in policy justified (GIL release ⇒ aliasing unsafe).
- Import-order study: coexists bit-identically with NumPy's private provider; **proven** SONAME-preemption hazards (system `libopenblas.so.0` preloaded; ambient `LD_LIBRARY_PATH`) — concrete requirements for the future private-namespaced wheel.
- Pin advanced to `16f2785` (`ab12a4a`); deliberately parked 2 commits behind rkalos — advances once, batched, at the next M3 checkpoint. Surface unchanged: `capabilities()['primitives'] == ('convolve',)`.

## 5. persephone3 (Agent D)

- **P1 truth table F1–F9: all empirically fixed** at current HEAD (original dd38e10 reproducers run live; F4 confirmed by reproducing the historic 36.89 delta as the now-meaningful selected-vs-indirect difference; F5 hits the hand-computed 51). Checklist gates red→green; interim release now **amber** (CI execution, numerical re-evidence, domain review outstanding).
- New backend-side finding: rjd3toolkit NA-pvalue protobuf crash on degenerate series → encoded as a **self-retiring known-issue test** (green if fixed, green on pinned message, deliberately red on contract change).
- **Item-14 parity harness** (`7ae9dac`): 8-spec matrix + hierarchical guard, cached references, metric-level comparisons at a **measured 1e-8 policy** (98/98 metrics bit-identical across sessions; exact-integer ts domains), capability-gated honest native lane with the single `parity_native_fit()` seam that M3's fit export will activate. Suite: **1,427 assertions, 0 failures**.

## 6. Process notes

- **Subagent context failure, zero data loss:** Agent A's session died on a context-compaction error mid-M3a; recovery ran from `git diff` + staged bytecode probes under no-destructive-git rules and finished the slice (`db32989`). The small-qualified-commit cadence is validated as crash insurance; noted as an operational risk of long numerical sessions.
- Agent self-corrections recorded rather than hidden (wrong-interpreter test rerun, dropped false friction item after verification, `$`-matching fix, capture scoping bug) — all evidence-grade.
- Everything remains **local commits only**; external pushes to remotes observed once (pykalos, not by agents).

## 7. Carried into M3

| Item | Status |
|---|---|
| M3a multiplicative mode | ✅ `db32989` (44/44, additive captures byte-identical after mode parameterization) |
| M3b log/pseudo-additive | 🔄 in flight (anchors staged: Kernel export-stage `exp`, undecoded `PseudoAddUtility`, two divergent pinned pseudo paths) |
| M3c deterministic-effect allocation | next |
| 22c restricted fixed-model X-13 fit (monthly, explicit deterministic-effect allocation, forecast domains) | then — M3 exit gate |
| rkalos fit export ⇒ `capabilities()$fit` flip ⇒ D's parity seam | after 22c |
| Kalos contract-doc touch-up slice (7 friction items) | quick win, schedule between major slices |
| Sigma-rule default maintainer decision | still open — blocks export promotion of 22b.3/pass entry points |
