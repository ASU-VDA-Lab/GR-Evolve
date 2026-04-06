#!/usr/bin/env bash
# restart_loop_iter.sh
# Deterministic restart loop: runs CMD for iterations CURRENT+1 .. TOTAL
# Usage: edit CMD, CURRENT_ITERATION, TOTAL_ITERATIONS, then run:
# nohup ./restart_loop_iter.sh > wrapper.log 2>&1 &

set -euo pipefail

# --- CONFIGURE ---
#0-19 (nohup1-19, itertion 3-30)
#20-35 (nohup20-)
CMD="/root/SHELL_SCRIPTS/run_CODEX_CLI.sh"   # no trailing & and must NOT daemonize
LOGDIR="/root/nohup_logs"
PIDFILE="${LOGDIR}/restart_loop_iter.pid"
LOCKFILE="${LOGDIR}/restart_loop_iter.lock"
CURRENT_ITERATION=26   # already done
TOTAL_ITERATIONS=51   # want to run up to this (inclusive)
SLEEP_BETWEEN_RUNS=1
BACKOFF_ON_FAILURE=5
MIN_RUN_DURATION=2

# make sure log dir exists
mkdir -p "${LOGDIR}"

# prevent multiple instances
exec 200>"${LOCKFILE}"
if ! flock -n 200 ; then
  echo "Another instance is running; exiting."
  exit 1
fi
echo $$ > "${PIDFILE}"
trap 'rm -f "${PIDFILE}" "${LOCKFILE}"; exit' EXIT INT TERM

# # sanity: reject commands that end with '&'
# if [[ "${CMD}" =~ [&]$ ]] ; then
#   echo "ERROR: CMD ends with '&'. Remove the ampersand or change CMD so it does not background itself."
#   exit 2
# fi

# loop deterministically from CURRENT+1 to TOTAL
start=$((CURRENT_ITERATION + 1))
end=${TOTAL_ITERATIONS}

for i in $(seq "${start}" "${end}"); do
  LOGFILE="${LOGDIR}/nohup${i}.out"
  # create logfile header BEFORE running (so filename is reserved/visible)
  {
    printf "=== Created %s (iteration %d) at %s ===\n" "${LOGFILE}" "${i}" "$(date)"
  } > "${LOGFILE}"

  echo "=== Starting run ${i} at $(date) ==="
  echo "Logging to: ${LOGFILE}"

  START_TS=$(date +%s)
  # run in foreground (wrapper waits). append both stdout/stderr to logfile.
  nohup bash -c "$CMD" >> "${LOGFILE}" 2>&1
  EXIT_CODE=$?
  END_TS=$(date +%s)
  DURATION=$((END_TS - START_TS))

  printf "=== Run %d finished at %s (exit code: %d, duration: %ds) ===\n" \
         "${i}" "$(date)" "${EXIT_CODE}" "${DURATION}" >> "${LOGFILE}"

  if (( DURATION < MIN_RUN_DURATION )); then
    echo "Run ${i} ended quickly (<${MIN_RUN_DURATION}s). Backing off ${BACKOFF_ON_FAILURE}s." >> "${LOGFILE}"
    sleep "${BACKOFF_ON_FAILURE}"
  else
    if (( SLEEP_BETWEEN_RUNS > 0 )); then
      sleep "${SLEEP_BETWEEN_RUNS}"
    fi
  fi
done

echo "All iterations ${start}-${end} completed."
