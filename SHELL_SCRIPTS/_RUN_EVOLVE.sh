
cd /root/OpenROAD-flow-scripts/flow

CONTAINER=$(hostname)

# Map container name fragment -> design directory name
if   [[ "$CONTAINER" == *ar136* ]]; then DESIGN="ariane136"
elif [[ "$CONTAINER" == *bp*    ]]; then DESIGN="black_parrot"
elif [[ "$CONTAINER" == *dn*    ]]; then DESIGN="dynamic_node"
elif [[ "$CONTAINER" == *aes*   ]]; then DESIGN="aes"
elif [[ "$CONTAINER" == *ibex*  ]]; then DESIGN="ibex"
elif [[ "$CONTAINER" == *jpeg*  ]]; then DESIGN="jpeg"
elif [[ "$CONTAINER" == *swerv* ]]; then DESIGN="swerv"
else
    echo "[ERROR] Unknown design in container name: $CONTAINER"
    exit 1
fi


if   [[ "$CONTAINER" == *sky130* ]]; then PDK="sky130hd"
elif [[ "$CONTAINER" == *nan45*  ]]; then PDK="nangate45"
elif [[ "$CONTAINER" == *asap7*  ]]; then PDK="asap7"
else
    echo "[ERROR] Unknown PDK in container name: $CONTAINER"
    exit 1
fi


LOGS="/root/OpenROAD-flow-scripts/flow/logs/${PDK}/${DESIGN}/base"
OUT="/root/TESTS/newgr_autoevolve"

export GLOBAL_ROUTE_ARGS='-router NEWGR'
export SKIP_INCREMENTAL_REPAIR=1
make DESIGN_CONFIG=./designs/${PDK}/${DESIGN}/config.mk clean_route
make DESIGN_CONFIG=./designs/${PDK}/${DESIGN}/config.mk finish

install -D "${LOGS}/5_1_grt.log"    "${OUT}/GR_newgr_e.${1}_${PDK}.log"
install -D "${LOGS}/5_2_route.log"  "${OUT}/DR_newgr_e.${1}_${PDK}.log"
