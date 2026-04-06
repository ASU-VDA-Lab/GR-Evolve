#!/bin/bash
# ============================================================
# extract_metrics.sh
# Extracts DRC/DRV/Timing metrics from OpenROAD *_rpt.json files
# for all hardcoded designs and writes to a single CSV file.
#
# Usage: ./extract_metrics.sh
# ============================================================

# ============================================================
#  HARDCODE YOUR DESIGNS HERE
#  Format: DESIGNS["design_name"]="/path/to/its/directory"
# ============================================================
declare -A DESIGNS
DESIGNS["AES"]="/root/TESTS/newgr_evolve_test/aes"
DESIGNS["IBEX"]="/root/TESTS/newgr_evolve_test/ibex"
DESIGNS["JPEG"]="/root/TESTS/newgr_evolve_test/jpeg"
DESIGNS["ARIANE136"]="/root/TESTS/newgr_evolve_test/ariane136"
DESIGNS["BP"]="/root/TESTS/newgr_evolve_test/bp"


# Fixed order — designs will appear in the CSV in this exact sequence
DESIGN_ORDER=("AES" "IBEX" "JPEG" "ARIANE136" "BP")

# ============================================================
#  OUTPUT CSV FILE  (hardcoded)
# ============================================================
CSV_OUT="/root/openroad_DRC-DRV-WNS-TNS.csv"

# ============================================================
#  ROUTER CONFIG  (order + display names)
# ============================================================
ROUTER_ORDER=("fastr" "cugr" "sproute" "newgr")
declare -A ROUTER_MAP
ROUTER_MAP["fastr"]="FastRoute"
ROUTER_MAP["cugr"]="CUGR"
ROUTER_MAP["sproute"]="SPRoute"
ROUTER_MAP["newgr"]="NEWGR"

# ============================================================
#  HELPER: extract a value from JSON by key
# ============================================================
get_val() {
    local file="$1"
    local key="$2"
    local val
    val=$(grep -o "\"${key}\"[[:space:]]*:[[:space:]]*[^,}]*" "$file" \
          | sed 's/.*:[[:space:]]*//' \
          | tr -d ' "')
    echo "${val:-N/A}"
}

# ============================================================
#  HELPER: overall PASS/FAIL
# ============================================================
check_status() {
    local setup_wns="$1"
    local setup_tns="$2"
    local setup_viols="$3"
    local hold_viols="$4"
    local max_slew="$5"
    local max_cap="$6"
    local flow_err="$7"

    local status="PASS"

    # Fail if any count metric is non-zero
    for val in "$setup_tns" "$setup_viols" "$hold_viols" "$max_slew" "$max_cap" "$flow_err"; do
        if [ "$val" != "N/A" ]; then
            result=$(awk -v v="$val" 'BEGIN { print (v+0 != 0) ? "FAIL" : "PASS" }')
            [ "$result" = "FAIL" ] && status="FAIL"
        fi
    done

    # Fail if setup WNS is negative
    if [ "$setup_wns" != "N/A" ]; then
        result=$(awk -v v="$setup_wns" 'BEGIN { print (v+0 < 0) ? "FAIL" : "PASS" }')
        [ "$result" = "FAIL" ] && status="FAIL"
    fi

    echo "$status"
}

# ============================================================
#  HELPER: process one design directory
# ============================================================
process_design() {
    local design="$1"
    local dir="$2"

    if [ ! -d "$dir" ]; then
        echo "  [ERROR] Directory not found for '$design': $dir"
        return
    fi

    for router_key in "${ROUTER_ORDER[@]}"; do
        json_file=$(find "$dir" -maxdepth 1 -iname "*${router_key}*_rpt.json" | head -1)

        if [ -z "$json_file" ]; then
            echo "  [SKIP]    $design / ${ROUTER_MAP[$router_key]} — no _rpt.json found"
            # Write N/A row so design still appears in CSV
            echo "${design},${ROUTER_MAP[$router_key]},N/A,N/A,N/A,N/A,N/A,N/A,N/A,N/A,N/A,N/A,N/A,N/A,N/A" >> "$CSV_OUT"
            continue
        fi

        echo "  [OK]      $design / ${ROUTER_MAP[$router_key]} -> $(basename "$json_file")"

        # --- Extract metrics ---
        setup_wns=$(get_val "$json_file" "finish__timing__setup__ws")
        setup_tns=$(get_val "$json_file" "finish__timing__setup__tns")
        hold_wns=$(get_val  "$json_file" "finish__timing__hold__ws")
        hold_tns=$(get_val  "$json_file" "finish__timing__hold__tns")
        setup_viols=$(get_val "$json_file" "finish__timing__drv__setup_violation_count")
        hold_viols=$(get_val  "$json_file" "finish__timing__drv__hold_violation_count")
        max_slew=$(get_val    "$json_file" "finish__timing__drv__max_slew")
        max_cap=$(get_val     "$json_file" "finish__timing__drv__max_cap")
        max_fanout=$(get_val  "$json_file" "finish__timing__drv__max_fanout")
        antenna=$(get_val     "$json_file" "finish__design__instance__count__class:antenna_cell")
        flow_err=$(get_val    "$json_file" "finish__flow__errors__count")
        fmax_raw=$(get_val    "$json_file" "finish__timing__fmax")

        # Convert fmax Hz -> MHz
        if [ "$fmax_raw" != "N/A" ]; then
            fmax_mhz=$(awk -v f="$fmax_raw" 'BEGIN { printf "%.2f", f / 1e6 }')
        else
            fmax_mhz="N/A"
        fi

        status=$(check_status "$setup_wns" "$setup_tns" "$setup_viols" \
                               "$hold_viols" "$max_slew" "$max_cap" "$flow_err")

        # --- Append row ---
        echo "${design},${ROUTER_MAP[$router_key]},${setup_wns},${setup_tns},${hold_wns},${hold_tns},${setup_viols},${hold_viols},${max_slew},${max_cap},${max_fanout},${antenna},${flow_err},${fmax_mhz},${status}" >> "$CSV_OUT"
    done
}

# ============================================================
#  MAIN
# ============================================================

# Always overwrite CSV with a fresh header
echo "Design,Router,Setup_WNS(ns),Setup_TNS(ns),Hold_WNS(ns),Hold_TNS(ns),Setup_Violations,Hold_Violations,Max_Slew_Viols,Max_Cap_Viols,Max_Fanout_Viols,Antenna_Cells,Flow_Errors,Fmax(MHz),Status" > "$CSV_OUT"

echo "============================================================"
echo " OpenROAD Metrics Extraction"
echo " Output: $CSV_OUT"
echo "============================================================"

# Iterate designs in the hardcoded order above
for design in "${DESIGN_ORDER[@]}"; do
    echo ""
    echo "[ $design ]"
    process_design "$design" "${DESIGNS[$design]}"
done

echo ""
echo "============================================================"
echo " Done. CSV written to: $CSV_OUT"
echo "============================================================"
