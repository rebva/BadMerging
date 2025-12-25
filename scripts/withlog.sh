#!/usr/bin/env bash
set -Eeuo pipefail

mkdir -p /app/logs /app/results

ts="$(date +%Y%m%d_%H%M%S)"
log="/app/logs/run_${ts}.log"

# ヘッダ（監査証跡）
{
    echo "===== BadMerging Run Log ====="
    echo "TIME=${ts}"
    echo "HOSTNAME=$(hostname)"
    echo "PWD=$(pwd)"
    echo "USER=$(id -u):$(id -g)"
    echo "CMD=$*"
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "COMMIT=$(git rev-parse HEAD 2>/dev/null || true)"
        echo "BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
        echo "CHANGES=$(git status --porcelain 2>/dev/null | wc -l || true)"
    else
        echo "COMMIT=unknown"
    fi
    echo "LOGFILE=${log}"
    echo "=============================="
} | tee -a "${log}"

# 本体：stdout/stderr を丸ごとログへ
# exec を使わず pipe で tee する（終了コードは最後に拾う）
"$@" 2>&1 | tee -a "${log}"
exit_code=${PIPESTATUS[0]}
exit "${exit_code}"
