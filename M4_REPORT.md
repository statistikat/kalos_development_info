# M4 Report — Automatic X-13 (item 21)

Date: 2026-11-21. Maintainer accepted the M4 template-envelope deviation (clause redefined: full
support where the qualified pipeline covers; explicit evidence-backed refusal elsewhere).
Repos: kalos `f500162` · rkalos `00c3a88` (core pin `f500162`) ·
pykalos `808e01c` (pin `f500162`) · persephone3 `795a571` @ branch `rkalos_backend` (pin rkalos
`00c3a88`). All commits local; nothing pushed.

## Follow-up qualification on 2026-11-23

The four repositories have published the original M4 commits. The product now exposes RSA3 forward and backward extensions through the same monthly automatic fit that passed the 13-case decision gate. On AirPassengers with three backcasts and six forecasts, the observed original, seasonal and calendar effects matched the public JDemetra outputs within 1e-8. Five forecast point series matched over the requested dates. The installed application parity suite passed 439 of 439 assertions on macOS ARM64. [Persephone component qualification](https://github.com/statistikat/persephone3/commit/1079aa9) · [Forecast implementation and reference checks](https://github.com/statistikat/persephone3/blob/3b2cc14/inst/tinytest/test-native-forecasts.R)

The application also displays the actual X-11 seasonal–irregular ratios, replacement positions and final seasonal factors. Reference checks covered four fixed modes and nonzero-horizon RSA3. The complete Python source-distribution wheel replay passed 102 tests, including 4,353 automatic X-13 checks and 1,287 horizon checks. [Application plot qualification](https://github.com/statistikat/persephone3/commit/3b2cc14) · [Python wheel results](https://github.com/statistikat/pykalos/commit/e6f17e2)

The accepted M4 scope remains monthly RSA3. Fixed-structure X-13 templates RSA0, RSA1 and RSA2c belong to M5b. Calendar-detection templates RSA4 and RSA5c still require item 21-I. The separate TRAMO-SEATS RSA0 route is covered by M5.

## 1. kalos core — stage Z closed + horizon route (FINAL)

Chain (all local, unpushed): a3bbb4e (driver) → b17ee8d (21-H.2 oracle slice) → b773d27 (CI root-cause
fix) → **b2573fc** (21-H.3, full qualification) → 7564ce7 (workflow-only) → **f500162** (21-H.4).

- **JVM oracle: 13/13 cases decision-bit-qualified** — 4637 oracle checks, 0 failures; sweep
  verify_x13_automatic 71,401 checks / 0 bad; every decision family 100% exact (odm 62, diff 39,
  chain-counts 91, arma 52, model-facts 182, variables 32, panel membership, landing orders/stats).
- **Root-cause transcription fixes (5)** in-slice: airline init (q=bq=0 → (0,1,1)(0,1,1) ODM entry
  spec), export sign (SarimaSpec all-plus convention), AICC adjustedLL (LL − Σ log y over estimation
  domain), generator pick translation (factory index), sweep-tool parser. Cumulative across 21-H:
  ~25 corpus-discovered transcription bugs.
- **Measured tiers (no decision-bit tiering, no relaxation)**: tmean 7.4e-4/1e-3 · panel BIC2
  8.1e-3/1e-2 · display AICC 3.4e-6/1e-5 · landing 4.5e-7/2e-3 · ARMA block 9.8e-3/1e-2 · tables
  5.0e-7/1e-6.
- **CI determinism fix** (b773d27): JVM goldens encode unfused IEEE arithmetic; GCC/Clang default
  -ffp-contract=fast fuses on FMA-exposing targets (ubuntu-latest x86-64-v3 image migration; arm64
  macOS baseline) → 17 bit-pin test failures; CI had never been green. Fix: PUBLIC
  -ffp-contract=off (/fp:precise on MSVC), bit-neutral locally, proven under -march=x86-64-v3.
- **Double-JVM byte-identity** on the estimation corpus: oracle-facts.csv sha256
  798c81acc8f7a922997814c5f13a3d6f85c00bdcaea2bacd3a81317f7bb26754 (both processes).
- **21-H.4 (f500162) — nonzero-horizon route**: kalos::arima_forecasts (faithful ExactArimaForecasts
  port: CkmsFilter + diffuse fast initializer + mean-correction fold; reproduces JVM post-initialize
  diffuse state ulp-for-ulp, pinned forecasts ≤3.3e-13); horizons wired through the automatic driver
  only (extended preadjust a1a/a1b, shifted first period, split finals); 4 byte-identical JVM horizon
  captures; test_x13_automatic_horizon 6459/0 with a1/d18/d18a/b bit-exact. Residual extension
  deviation measured to be the oracle's pre-existing banded landing-basin drift (G2 seam), not the
  route. Fixed fit keeps its refusal.
- **Invariants**: ctest 64/64 both lanes; nine sweeps 39/11/27+10/4368/423/98/494/266; automatic
  sweep 71,401/0; ASan/UBSan clean; check-manifest 142/112/195; verify-migration 406 (historical
  root immutable).

## 2. pykalos — automatic preprocessing bound + horizon envelope (FINAL)

Commits d3fd64f (binding, pin b2573fc-era) → 65608fc (CI hygiene) → **808e01c** (pin f500162 +
qualified horizon envelope).

- capabilities(): primitives ('convolve', 'x13_automatic'); schema 2→3 `horizon_envelope`; wrapper
  applies family sigma default; raw entry fully explicit; provenance "legacy (default)"/"legacy
  (explicit)"/"accurate (explicit)".
- Zero-horizon gate: 13/13 decision-bit at the Python boundary, 4353 checks/0, worsts byte-identical
  to core records. **Horizon expansion JVM-qualified**: 4 x13-horizon captures, all bit-tier
  assertions pass, 1287 checks/0 (out 1.047e-6/2e-5, d11final 3.13e-7/5e-6, e11 3.76e-7/5e-6);
  combined gate 5640 checks/0. Fail-closed matrix: horizon entries became acceptance pins; the other
  5 refusal pins verbatim (non-monthly, non-finite, 21-I deferrals, span<n, raw missing-sigma, spec
  names, regression inputs) — no fallback path exists.
- Evidence: allowlisted vendor/kalos-evidence (x13-automatic + x13-horizon, 11 files), SHA256SUMS
  gate. pytest default 30+7; full gate 38+7; wheel 97ae136e…, 66/66 TUs flagged, RUNPATH pinned.

## 3. rkalos — automatic spec export (FINAL)

Commits a02e0f0 + 0a56d1f (M4 surface) → 3e19dc5 (pin f500162) → 15f1251 (CI hygiene) → **00c3a88**
(status; HEAD).

- Surface: native_x13_fit_automatic() (namespace-internal, 49 args, bit-decision chain echo,
  fail-closed matrix), capabilities schema v2 automatic block, wrapper with pinned decoder scalars,
  test-native-x13-automatic.R — 13 cases decisions bit-identical vs JVM goldens, no band relaxation.
- **Numerical sovereignty fix**: link-order leak (system OpenBLAS 0.3.26 satisfied cblas_dgemm
  before the pinned archive → results moved with BLAS/thread env) closed structurally — vendored
  C-API provider is the sole numerical surface, configure fails closed without it
  (KALOS_OPENBLAS_ROOT/_CPPFLAGS/_LINK), --exclude-libs,ALL + -Bsymbolic self-binding, automatic
  calls pin kernels single-threaded, installed .so zero undefined BLAS/LAPACK symbols.
- Tiers at R boundary = oracle measurements (tmean 7.42e-4 · arma-panel 8.09e-3 · arma-landing
  9.75e-3 · AICC 3.42e-6 · tables 5.04e-7 · landing 3.05e-6/4.48e-7); f500162 re-check equal to the
  digit. Suites 291,240/0 OMP + 291,236/0 serial with 49/49 per-file identity across both pin moves;
  restricted closure red-flag 0; provenance byte-identical to pinned core blobs; fail-closed matrix
  mirrored count-preservingly at f500162 (contract change, no numerical re-pinning).
- R envelope deliberately zero-horizon (wrapper-local refusal); mirroring pykalos's qualified
  horizon expansion is a queued future slice.

## 4. persephone3 — native automatic run() (FINAL)

Commits b05fd82 (lane) + abf5369 (CI provider + pin 00c3a88) + **795a571** (docs/status; HEAD,
branch rkalos_backend).

- Pin reconciliation first, zero drift: baseline reproduced exactly at rkalos 00c3a88 (JVM 1,476/0,
  JVM-free 70/70) before any product change.
- Native automatic lane in R/backend_native.R: rsa3 decode table + gate + fail-closed refusals,
  honest envelope, fingerprint over pinned decode state; seams wired (result schema,
  adjusted/forecasts, docs, NAMESPACE/man).
- **Template-envelope reality (contract surprise, documented)**: of the six rsa templates only
  **rsa3** lies inside the qualified automatic envelope and runs natively
  (`perX13(ts, "rsa3", backend="native")`). rsa0/rsa1/rsa2c disable automodel — a dead branch of the
  automatic pipeline contract; rsa4/rsa5c need TD2/TD7 + Easter-ADD (21-I deferral, core status
  quoted verbatim). All others refuse by name with measured jar-dump facts. The plan row "rsa0–rsa3
  fully supported" was aspirational.
  (ERRATUM+RESOLUTION 2026-11-21, gap slices b625852/d8b335c): the automodel-OFF templates are NOT a
  mapping problem — live double-JVM decodes show rsa0/rsa1/rsa2c all require ESTIMATED coefficients,
  SEASONAL_FILTER_MSR, automatic Henderson (H=0) and nfcasts=-1 (12 forecasts), each refused verbatim
  by the restricted envelope; candidate fixed values are series-dependent run outputs, so no pinnable
  mapping exists without fudge. All three STAY REFUSED naming the violated fields (fixtures
  native/refusals-m4gap, live-stack byte-identity re-verification 12 decodes + 9 demand runs).
  rsa0-2c full native support would need a NEW core workstream: fixed-structure/coefficients-estimated
  X-13 (estimator-through-X-11 wiring, MSR filter plan, automatic-Henderson decision stage, horizons) —
  proposed as a numbered roadmap item, not folded into M5. Final: JVM lane 1,753/0, JVM-free 244/244.)
- **Parity (rsa3, decisions bit-exact, no relaxation)**: double-JVM byte-identical captures
  (air/ao/seas) pinned in fixtures; 13 decision lines byte-identical on all three series (log,
  orders, mean, outlier vars, neff, nparams, Henderson 9/13/13, seasonal s3x3/s3x15/s3x9); tier
  worsts vs contract: coefficients 4.1e-4/1e-2, ll 2.0e-9 + AICC 2.0e-8/2e-3, sa 1.7e-7/1e-6,
  t 8.2e-8/1e-5, d13-class i 1.97e-4 (contract's own measured G2 landing-basin class, deterministic);
  AirPassengers all-zero. mode_effective=multiplicative confirmed as X13Kernel.forceMode semantics.
- Fail-closed matrix verbatim (complete finite series, 21-I deferral, monthly_only,
  automatic_spec_pinned, sigma_policy_default, context/userdefined refusals).
- Suites: JVM lane 21 files **1,685/0** (parity 146→354, backend 88→89, rest byte-equal); JVM-free
  parity **197/197**; verify-nojava --native PASS. CI: pinned OpenBLAS provider (0.3.34, f500162
  lockfile) wired into both build workflows.
- Incidents (honest): shared host SIGKILLed two long JVM sessions (re-ran per-file, green — not a
  package defect); a scratch tally bug that masked failures was caught by the harness violation
  report and fixed, both lanes re-ran clean — and it exposed a real test-helper bug (JVM seasonal
  codes replicated per-obs instead of per-period).

## 5. Acceptance assessment

| Clause | Verdict |
|---|---|
| "perX13 templates (rsa0–rsa3…) fully supported natively" | **PARTIAL, by design**: rsa3 native end-to-end; rsa0/1/2c gated pending native restricted-fit export; rsa4/5c pending 21-I. No silent fallback anywhere — refusals are by-name, explicit, evidence-backed. |
| "parity tests vs rjd3 on templates" | **MET for the in-envelope template** (rsa3, three series, decisions bit-identical, double-JVM byte-identical captures). |
| "automatic selection reproduces pinned JDemetra+ choices on the reference corpus" | **MET** (core 13/13 oracle; R + Python boundaries replicate decisions bit-for-bit; persephone3 rsa3 lane 13 decision lines × 3 series byte-identical). |
| "no silent fallback anywhere" | **MET** across all three product boundaries (fail-closed matrices asserted verbatim; capability gating gates on schema-v2 automatic block). |

Standing caveats: scope envelope monthly / horizons {0,0} at R, horizons in-envelope at Python
(qualified) / four modes; BFGS default; user-variable detection deferred to 21-I; SeasonalityDetector
dead in pinned jar (stage-F voided); scan-replay informational (near-tie cv/argmax, documented);
automatic lane pins BLAS kernels single-threaded (oracle surface is per-kernel serial).

## 6. Queue after M4

Horizon envelope: pykalos DONE (808e01c); rkalos DONE (b90d367, R-boundary horizon qualification:
out/d13/c17/e2/landing all in-band, zero-horizon byte-identical, 291,718/291,714 both lanes).
rsa0/rsa1/rsa2c: CLOSED by evidence-backed refusal (gap resolution above); maintainer decision
2026-11-21: the "fixed-structure coefficients-estimated X-13" workstream is numbered as roadmap
**item 28** (kalos docs/NUMERICAL_ROADMAP.md, commit 41776f2) scheduled after M5 (plan milestone
M5b). rsa4/5c need 21-I (TD/Easter). 21-A replay-
fidelity pass (Multiple alternate-start basins); contract-doc touch-ups (check_decomposition message,
X11SelectionPass mode echo); pykalos smoke.yml core-build-tools ref (4f0625c) — cosmetic only
(build-openblas.py + lock blob-identical), deferred.
SCRATCH janitor caution: cleanup-tmp-opencode.sh wiped active artifacts once — run only between
slices or raise its age threshold. Host watch-items: SIGKILLs of long JVM sessions (suspected memory
pressure — check dmesg/cgroup limits if repeated); host R silently upgraded 4.5.1 → 4.5.3 (identity
preserved). Process note 2026-11-21: one rkalos agent disclosed and self-corrected a mid-session
confabulation (narrated unrealized work); deliverables were re-executed and verified post-reconciliation
— treat any agent self-narration of unverified past work as suspect; the identity/byte-identity gates are
the arbiter. CI Node24 hygiene DONE all four repos (kalos 7564ce7, pykalos 65608fc, persephone3
06b27eb, rkalos 15f1251 — workflow-only, pins unaffected).
User actions owed: ~~`rm` two kalos strays + trash-20261120~~ DONE 2026-11-21 (maintainer); ~~`/tmp/never-used.R`~~
DONE 2026-11-21 (maintainer); ~~push all four repos~~ DONE 2026-11-21 (maintainer — kalos now runs M5-era CI
up to be49c69 incl. the self-diagnostic patch a3b3130; fdlibm root fix still local/pending)
(kalos main is far ahead of origin; rkalos main; pykalos main; persephone3 rkalos_backend).
