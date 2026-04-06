#!/usr/bin/env bash
set -euo pipefail

CSV_PATH="/root/metrics_all_runs.csv"
OUT_PATH="/root/METRICS_TABLE.md"
TARGET_ROUTER="NEWGR"
ROW_LABEL="NEWGR_1"

if [ ! -f "$CSV_PATH" ]; then
  echo "ERROR: CSV not found at $CSV_PATH" >&2
  exit 2
fi

awk -v target="$TARGET_ROUTER" -v out="$OUT_PATH" -v label="$ROW_LABEL" -F',' '
  function trim(s) { gsub(/^[ \t\r\n]+|[ \t\r\n]+$/, "", s); return s }
  function unquote(s) {
    s = trim(s)
    if (s ~ /^".*"$/) {
      sub(/^"/, "", s); sub(/"$/, "", s)
    }
    return s
  }
  function to_secs(s,   n, i, parts, total, x) {
    s = trim(s)
    if (s == "" || toupper(s) == "NA") return "NA"
    if (s ~ /^[0-9]+$/) return s + 0
    n = split(s, parts, ":")
    if (n == 3) {
      total = 0
      total += (parts[1] + 0) * 3600
      total += (parts[2] + 0) * 60
      x = parts[3] + 0
      total += x
      return int(total + 0.5)
    } else if (n == 2) {
      total = 0
      total += (parts[1] + 0) * 60
      x = parts[2] + 0
      total += x
      return int(total + 0.5)
    } else {
      return s
    }
  }

  NR==1 {
    for (i=1; i<=NF; i++) {
      h = unquote($i)
      header[h] = i
    }
    next
  }

  {
    gsub(/\r$/, "", $0)          # strip CR if present
    if ($0 ~ /^[[:space:]]*$/) next

    # find router column index (tolerant)
    router_idx = header["router"]
    if (!router_idx) {
      if (header["Router"]) router_idx = header["Router"]
      else if (header["ROUTER"]) router_idx = header["ROUTER"]
    }
    if (!router_idx) next

    router_val = unquote($(router_idx))

    if (router_val == target) {
      found = 1

      dr_wire_idx = header["dr_wirelength"] ? header["dr_wirelength"] : (header["dr_wire_length"] ? header["dr_wire_length"] : (header["dr_wire"] ? header["dr_wire"] : 0))
      dr_via_idx  = header["dr_via_count"] ? header["dr_via_count"] : (header["dr_via"] ? header["dr_via"] : 0)
      gr_runtime_idx = header["gr_runtime"] ? header["gr_runtime"] : (header["gr_runtime(s)"] ? header["gr_runtime(s)"] : (header["gr_runtime(s?)"] ? header["gr_runtime(s?)"] : 0))

      dr_wire = dr_wire_idx ? unquote($(dr_wire_idx)) : "NA"
      dr_via  = dr_via_idx  ? unquote($(dr_via_idx))  : "NA"
      gr_run  = gr_runtime_idx ? unquote($(gr_runtime_idx)) : "NA"

      if (dr_wire == "") dr_wire = "NA"
      if (dr_via == "") dr_via = "NA"
      gr_run_norm = to_secs(gr_run)

      printf("| Metric  | Wirelength | Via Count | Runtime |\n") > out
      printf("| ------- | ---------- | --------- | ------- |\n") >> out
      printf("| %s | %s      | %s    | %s   |\n", label, dr_wire, dr_via, gr_run_norm) >> out

      printf("Wrote %s with: wire=%s, via=%s, runtime=%s\n", out, dr_wire, dr_via, gr_run_norm) > "/dev/stderr"
      exit 0
    }
  }

  END {
    if (!found) {
      print "ERROR: no row with router == " target " found in CSV" > "/dev/stderr"
      exit 3
    }
  }
' "$CSV_PATH"
