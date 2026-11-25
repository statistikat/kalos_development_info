#!/usr/bin/env bash
# Dated artifact cleanup, 2026-11-25 (maintainer-requested; agent prepared).
# rm -rf is policy-blocked for agents, so this script is handed over for the
# maintainer to run.  DRY=1 (default) only lists what would be deleted:
#     bash cleanup-2026-11-25.sh            # dry run
#     DO=1 bash cleanup-2026-11-25.sh       # actually delete
# Provenance discipline (same as cleanup-tmp-opencode.sh): only artifacts of
# this project are touched.  Foreign-owned files in /tmp/opencode (qrvenv =
# nnied, pkgsrc = meran) and the OpenCode harness databases (oc-copy.db,
# oc-snap.db) are NEVER listed.  Loose project-misc files in /tmp/opencode
# (.R/.sas/.out/.py from interactive sessions) are left for manual judgment.

set -u
SCRATCH=/data/home/kowa/seasonaladjustment/tmp_opencode

run() {  # echo-and-delete unless dry
  printf '%s\n' "  $*"
  [ "${DO:-0}" = 1 ] && rm -rf -- "$@"
  return 0
}

echo "== disk before =="
df -h /tmp /data | tail -2

# ---------------------------------------------------------------------------
# 1. /tmp/opencode — stale project lanes (M5/M6-era builds, R dev libraries,
#    source snapshots and probe dumps superseded by committed evidence).
#    Kept here: everything not of clear project provenance (see header).
# ---------------------------------------------------------------------------
echo "== /tmp/opencode stale project lanes =="
for d in b24c1f b24c1s headtree item21h2 kalos-build lane24p1 llprobe pretree \
         rlib-base-dev rlib-dev-td ssf; do
  [ -e "/tmp/opencode/$d" ] && run "/tmp/opencode/$d"
done

# ---------------------------------------------------------------------------
# 2. Scratch root — bulk sweep: every entry NOT in KEEP is a finished-slice
#    artifact (old-pin kalos builds, sanitizer/fuzz trees, item-era logs).
#    KEEP = providers + evidence dirs cited or still needed by M7/M8.
# ---------------------------------------------------------------------------
KEEP=" openblas jarcache \
m6-b-rkalos m6-c-verify m6-platform m6-seas \
m7-c-persephone m7-c-verify m7-td-rkalos m7-td2-rkalos m7-cutover m7-san \
m7-inst-b.log m7-inst-bs.log m7-suite-b.log m7-suite-bs.log "

echo "== $SCRATCH bulk sweep (everything outside KEEP) =="
find "$SCRATCH" -maxdepth 1 -mindepth 1 -printf '%f\n' | sort | while IFS= read -r e; do
  case " $KEEP " in
    *" $e "*) ;;
    *) run "$SCRATCH/$e" ;;
  esac
done

# ---------------------------------------------------------------------------
# 3. Keeps, trimmed — installed lane libraries and cmake trees are disposable;
#    logs, scripts, tarballs, baselines and the live-lane library are kept.
# ---------------------------------------------------------------------------
echo "== m6-b-rkalos: lane libraries / verify trees (baselines+scripts kept) =="
cd "$SCRATCH/m6-b-rkalos" 2>/dev/null && for d in rlib-serial rlib-omp \
    rlib-serial-a7d4b12 rlib-serial-b4f2e1d rlib-serial-e2138a3 \
    rlib-omp-a7d4b12 rlib-omp-b4f2e1d rlib-omp-e2138a3 \
    verify-serial verify-omp verify-serial-a7d4b12 verify-serial-b4f2e1d \
    verify-serial-e2138a3 verify-omp-a7d4b12 verify-omp-b4f2e1d verify-omp-e2138a3; do
  [ -e "$d" ] && run "$d"
done

echo "== m6-c-verify: check/src/rlib/tb/nojava trees (live lane + evidence kept) =="
cd "$SCRATCH/m6-c-verify" 2>/dev/null && for d in check-out check-out-iso \
    rlib-attrib9025 rlib-attrib-prepin rlib-check rlib-m5b-repro \
    rlib-persephone rlib-tree-check src-persephone3 src-persephone3-975c771 \
    src-rkalos src-rkalos-0aaa37b src-rkalos-9025 src-rkalos-9026pre \
    tb-new tb-repin nojava9025 nojava9026 nojava-iso-9025 nojava-iso-9026; do
  [ -e "$d" ] && run "$d"
done   # rlib-persephone-live is REFERENCED by the live oracle lanes — kept

echo "== m6-platform: cmake build trees (logs + runner kept) =="
cd "$SCRATCH/m6-platform" 2>/dev/null && for d in build-san build-omp build-serial; do
  [ -e "$d" ] && run "$d"
done

echo "== m6-seas: build/sanitizer/fuzz trees (build5 + probe evidence kept) =="
cd "$SCRATCH/m6-seas" 2>/dev/null && for d in build build2 build3 build4 \
    build-san-rtd build-san-rtd2 classes-frozen classes-fuzz factorizer_fuzz \
    frozen jdmp libkalos-head-snapshot.a; do
  [ -e "$d" ] && run "$d"
done

# m7-san2: ASan/UBSan tree of the finished kalos M7 slices (evidence committed).
[ -e "$SCRATCH/m7-san2" ] && run "$SCRATCH/m7-san2"

# ---------------------------------------------------------------------------
# 4. Repo-internal untracked build residue.
# ---------------------------------------------------------------------------
echo "== untracked build residue in repos =="
run /data/home/kowa/seasonaladjustment/kalos/Testing
run /data/home/kowa/seasonaladjustment/kalos/validation/evidence/native/tramo-fit/classes

echo "== disk after =="
df -h /tmp /data | tail -2
echo "NOT TOUCHED (judgment left to you): /tmp/opencode/qrvenv, pkgsrc (foreign"
echo "users); oc-copy.db, oc-snap.db (OpenCode harness); loose session files"
echo "(.R/.sas/.out) in /tmp/opencode; m7-c-persephone/m7-td2-rkalos check-outs"
echo "(~2.5G — in use by the running cutover slice; re-run this script after)."
