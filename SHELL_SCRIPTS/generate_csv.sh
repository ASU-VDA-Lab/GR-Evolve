#!/usr/bin/env bash

# Usage:
#   /root/SHELL_SCRIPTS/_find_metrics.sh <run_id> [<run_id> ...]
# Examples:
#   /root/SHELL_SCRIPTS/_find_metrics.sh aes
#   /root/SHELL_SCRIPTS/_find_metrics.sh aes ariane136

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <run_id> [<run_id> ...]"
  exit 1
fi

csv_file="/root/metrics_all_runs.csv"
csv_header="run_id,router,gr_wirelength,gr_via_count,gr_runtime,dr_wirelength,dr_via_count,dr_runtime"
routers=(FastRoute CUGR SPRoute2 NEWGR)
prefixes=(fastr cugr sproute newgr)

extract_metric() {
  local pattern="$1"
  local field="$2"
  local file="$3"
  local value

  if [[ ! -f "$file" ]]; then
    echo "NA"
    return
  fi

  value="$(grep "$pattern" "$file" | tail -n 1 | awk -v f="$field" '{print $f}' | tr -d ',' | tr -d '\r' | sed 's/[.]$//')"
  if [[ -z "$value" ]]; then
    echo "NA"
  else
    echo "$value"
  fi
}

extract_gr_via_count() {
  local file="$1"
  local value=""

  if [[ -f "$file" ]]; then
    value="$(grep 'Final number of vias:' "$file" | tail -n 1 | awk '{print $7}')"
    [[ -z "$value" ]] && value="$(grep 'Final number of via  :' "$file" | tail -n 1 | awk '{print $6}')"
    [[ -z "$value" ]] && value="$(grep 'total via count:' "$file" | tail -n 1 | awk '{print $4}')"
    value="$(printf '%s' "$value" | tr -d ',' | tr -d '\r' | sed 's/[.]$//')"
  fi

  if [[ -z "$value" ]]; then
    echo "NA"
  else
    echo "$value"
  fi
}

extract_dr_runtime() {
  local file="$1"
  local value=""

  if [[ -f "$file" ]]; then
    value="$(grep 'Elapsed time:' "$file" | tail -n 1 | awk '{print $3}' | grep -oE '[0-9][0-9:.]*')"
  fi

  if [[ -z "$value" ]]; then
    echo "NA"
  else
    echo "$value"
  fi
}

mkdir -p "$(dirname "$csv_file")"
if [[ ! -s "$csv_file" ]]; then
  echo "$csv_header" > "$csv_file"
else
  first_line="$(head -n 1 "$csv_file" || true)"
  if [[ "$first_line" != "$csv_header" ]]; then
    tmp_csv="$(mktemp)"
    {
      echo "$csv_header"
      cat "$csv_file"
    } > "$tmp_csv"
    mv "$tmp_csv" "$csv_file"
  fi
fi

while (( $# > 0 )); do
  run_id="$1"
  shift 1

  base_dir="/root/TESTS/newgr_evolve_test/${run_id}"

  printf "\nRun: %s\n" "$run_id"
  printf "| %-15s | %-15s | %-15s | %-15s | %-15s |\n" "Router" "GR Wirelength" "GR Runtime" "DR Wirelength" "DR Via Count"
  printf "|%s|%s|%s|%s|%s|\n" \
    "$(printf '%0.s-' {1..17})" \
    "$(printf '%0.s-' {1..17})" \
    "$(printf '%0.s-' {1..17})" \
    "$(printf '%0.s-' {1..17})" \
    "$(printf '%0.s-' {1..17})"

  for i in "${!routers[@]}"; do
    prefix="${prefixes[$i]}"
    gr_json="${base_dir}/GR_${prefix}_asap7.json"
    gr_log="${base_dir}/GR_${prefix}_asap7.log"
    dr_log="${base_dir}/DR_${prefix}_asap7.log"

    gr_wl="$(extract_metric 'globalroute__global_route__wirelength' 2 "$gr_json")"
    gr_rt="$(extract_metric 'global_route runtime' 5 "$gr_log")"
    gr_via="$(extract_gr_via_count "$gr_log")"
    dr_wl="$(extract_metric 'Total wire length =' 5 "$dr_log")"
    dr_via="$(extract_metric 'Total number of vias =' 6 "$dr_log")"
    dr_rt="$(extract_dr_runtime "$dr_log")"

    printf "| %-15s | %-15s | %-15s | %-15s | %-15s |\n" \
      "${routers[$i]}" "$gr_wl" "$gr_rt" "$dr_wl" "$dr_via"

    # Append one row per router. Never overwrite old rows.
    printf "%s,%s,%s,%s,%s,%s,%s,%s\n" \
      "$run_id" \
      "${routers[$i]}" \
      "$gr_wl" \
      "$gr_via" \
      "$gr_rt" \
      "$dr_wl" \
      "$dr_via" \
      "$dr_rt" >> "$csv_file"
  done
done

printf "\nCSV metrics appended to: %s\n" "$csv_file"
echo "Cumulative metrics table:"
if command -v column >/dev/null 2>&1; then
  column -s, -t "$csv_file"
else
  cat "$csv_file"
fi
