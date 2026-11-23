#!/usr/bin/env bash
# Clean stale subagent scratch from the SCRATCH root.
# 2026-11-19 (maintainer decision): scratch moved from /tmp/opencode to
# /data/home/kowa/seasonaladjustment/tmp_opencode — /tmp is off-limits, the
# old symlink is intentionally gone and /tmp/opencode (if present) is a dead
# plain directory left to die.
# Written while slice 21-H is IN FLIGHT: everything with current provenance
# from the active agents is deliberately NOT listed. Files not created by
# this project (PNGs, .Rd, .awk, unrelated .R work) are never touched.
# Safe to re-run; re-derive the list from `ls` if unsure.
set -u

ROOT=/data/home/kowa/seasonaladjustment/tmp_opencode

# --- keep-guard: abort if anything the live agents depend on is missing ---
KEEP_DIRS=(
  openblas            # pinned OpenBLAS provider (builds + all wheels/installs)
  kalos-build         # active kalos OpenMP build dir (21-H uses now)
  kalos-build-serial  # active kalos serial build dir
  kalos-build-san-21h # 21-H sanitizer tree (in use)
  jdprobe             # bytecode probe workspace (21-H may re-probe)
  jarcache            # cached JVM jars (capture scripts)
  venv-pykalos        # pykalos wheel-build venv
  rlib-b rlib-b-serial rlib-c rlib-d  # current R libraries (checkpoints D/C/B/D)
)
for k in "${KEEP_DIRS[@]}"; do
  if [ ! -e "$ROOT/$k" ]; then
    echo "ABORT: keep-target missing: $ROOT/$k (tree differs from expectation)" >&2
    exit 1
  fi
done
for k in getjars.R kalos-21h-pinning.md; do
  if [ ! -e "$ROOT/$k" ]; then
    echo "ABORT: keep-target missing: $ROOT/$k" >&2
    exit 1
  fi
done

# --- explicit stale removals (all from committed, closed slices) ---
STALE=(
  # stale sanitizer/Debug build trees (~1.9 GB)
  kalos-build-san-21c   # 21-C era (committed e19df2c)
  kalos-build-san-21d   # 21-D takeover era (committed 2170435)
  kalos-build-san-21g   # 21-G era (committed e7af23f; 21-H has its own san-21h)
  kalos-asan2           # older ASan tree
  kalos-build-s4        # 21-D takeover era scratch reuse
  kalos-build-s4-serial
  kalos-serial          # older serial-build experiment
  # sanitizer sweep/test binaries from closed slices
  verify-dd-san verify-dd-21d-san   # 21-D
  21g-verify-rvt-san verify_rvt dbg_sweep  # 21-G
  # slice dump dirs from closed slices
  kalos-21f-dump kalos-21g-dump
  # one-off cross-check dumps (fdlibm/transcendental era, evidence is committed)
  lm_full90.txt
)
for p in "${STALE[@]}"; do
  if [ -e "$ROOT/$p" ]; then
    rm -rf -- "$ROOT/$p" && echo "removed $p"
  fi
done

# fdlibm fuzz/cross-check dumps (fdz_*, fdz2_*): pure scratch, reproducible
for p in "$ROOT"/fdz_*.txt "$ROOT"/fdz2_*.txt; do
  [ -e "$p" ] && rm -f -- "$p" && echo "removed ${p##*/}"
done

# 21-G sweep binaries/logs (21-H rebuilt its own 21h*/21h2* set)
for p in "$ROOT"/21g-sweep-*; do
  [ -e "$p" ] && rm -f -- "$p" && echo "removed ${p##*/}"
done

# --- second pass (appended 2026-11-19): remaining closed-milestone scratch ---
STALE2=(
  verify-iai-asan        # 21-E sanitizer binary (committed 7200a56)
  kalos-build-envroot    # old envroot build experiment
  kalos-install          # old install-tree smoke test
  rkalos_0.1.0.tar.gz    # regenerated fresh by every rkalos checkpoint
  # capture scratch dirs from closed 22b/M3-era slices (corpora are committed
  # under kalos validation/evidence/; these are the JVM-run leftovers)
  x11-selection-capture x11-sel-capture2 x11-dpass-capture2
  x13fit-cap1 x13fit-cap2 stale-capture
  m3-cap-b-mult m3-cap-b-mult2 m3-cap-b-mult3
  m3-cap-d-mult m3-cap-d-mult2 m3-cap-d-mult3 m3-cap-d-add
)
for p in "${STALE2[@]}"; do
  if [ -e "$ROOT/$p" ]; then
    rm -rf -- "$ROOT/$p" && echo "removed $p"
  fi
done
# any other m3-cap-* dirs from the same era
for p in "$ROOT"/m3-cap-*; do
  [ -e "$p" ] && rm -rf -- "$p" && echo "removed ${p##*/}"
done

# NOTE: nachholz.csv / nachholz.csv.sicherung are DATA files, not agent
# scratch — deliberately never touched here. Same for PNG/.Rd/.awk files.
# Reminder (outside /tmp, must stay a manual act): two user-pending scratch
# files still sit untracked in the kalos repo root:
#   rm /data/home/kowa/seasonaladjustment/kalos/src/kalos_write_probe.cpp \
#      /data/home/kowa/seasonaladjustment/kalos/cpp-out.txt

echo "---"
df -h "$ROOT" | tail -1
du -sh "$ROOT"
# /tmp/opencode (plain dir, if still present) belongs to the maintainer's
# cleanup schedule, not this script: rm -rf /tmp/opencode
