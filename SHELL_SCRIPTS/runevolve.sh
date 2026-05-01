
indent() { sed 's/^/    /'; }

AGENTS_DIR="$(dirname "$0")/../AGENTS"

get_agents_file() {
    local container="$1"

    # Extract PDK
    local pdk=""
    if   [[ "$container" == *sky130* ]]; then pdk="sky130"
    elif [[ "$container" == *nan45*  ]]; then pdk="nan45"
    elif [[ "$container" == *asap7*  ]]; then pdk="asap7"
    fi

    # Extract design
    local design=""
    if   [[ "$container" == *aes*   ]]; then design="AES"
    elif [[ "$container" == *ibex*  ]]; then design="IBEX"
    elif [[ "$container" == *jpeg*  ]]; then design="JPEG"
    elif [[ "$container" == *swerv* ]]; then design="SWERV"
    elif [[ "$container" == *dn*    ]]; then design="DN"
    elif [[ "$container" == *ar136* ]]; then design="AR136"
    elif [[ "$container" == *bp*    ]]; then design="BP"
    fi

    # ar136 and bp have router-specific AGENTS files
    if [[ "$design" == "AR136" || "$design" == "BP" ]]; then
        local router=""
        if   [[ "$container" == fr_*   ]]; then router="FR"
        elif [[ "$container" == cugr_* ]]; then router="CUGR"
        elif [[ "$container" == spr_*  ]]; then router="SPR"
        fi
        echo "${AGENTS_DIR}/AGENTS_${router}_${design}_${pdk}.md"
    else
        echo "${AGENTS_DIR}/AGENTS_${design}_${pdk}.md"
    fi
}

containers=(
            # ASAP7
            fr___aes_asap7
            cugr_aes_asap7
            spr__aes_asap7
            fr___ibex_asap7
            cugr_ibex_asap7
            spr__ibex_asap7
            fr___jpeg_asap7
            cugr_jpeg_asap7
            spr__jpeg_asap7
            fr___swerv_asap7
            cugr_swerv_asap7
            spr__swerv_asap7
            fr___dn____asap7
            cugr_dn____asap7
            spr__dn____asap7

            # # Nangate45
            fr___aes_nan45
            cugr_aes_nan45
            spr__aes_nan45
            fr___ibex_nan45
            cugr_ibex_nan45
            spr__ibex_nan45
            fr___jpeg_nan45
            cugr_jpeg_nan45
            spr__jpeg_nan45
            fr___ar136_nan45
            cugr_ar136_nan45
            spr__ar136_nan45
            fr___bp_nan45
            cugr_bp_nan45
            spr__bp_nan45
            fr___swerv_nan45
            cugr_swerv_nan45
            spr__swerv_nan45
            fr___dn____nan45
            cugr_dn____nan45
            spr__dn____nan45

            #SKY130HD
            fr___aes_sky130-2
            cugr_aes_sky130-2
            spr__aes_sky130-2
            fr___ibex_sky130
            cugr_ibex_sky130
            spr__ibex_sky130
            fr___jpeg_sky130
            cugr_jpeg_sky130
            spr__jpeg_sky130

)

for c in "${containers[@]}"; do ESE=10
  
  #############################################################
  # Delete Containers
  #############################################################
  if [ $ESE -eq 0 ]; then
        echo "[CONTAINER] Deleting and removing container : $c "
        sleep 1
        docker stop $c 
        docker rm $c 
  fi
  
  #############################################################
  # Evolution Setup
  #############################################################
  docker pull docker push tsjafri/gr-evolve:04-30-2026
  if [ "$ESE" -eq 10 ]; then 

    echo "[DOCKER] On container : $c"
      docker run -d -it --hostname $c --name $c grevolve:04-30-2026 | indent
      docker exec $c sh -c "rm -rf /root/.codex" 
      docker exec $c sh -c "rm -rf /root/TESTS/*"
      docker exec $c sh -c "rm -rf /root/SHELL_SCRIPTS/*"
      docker exec $c sh -c "rm -rf /root/nohup_logs/*"
      docker exec $c bash -c "wget https://github.com/openai/codex/releases/download/rust-v0.104.0/codex-x86_64-unknown-linux-musl.tar.gz"  
      docker exec $c bash -c "tar -xzvf codex-x86_64-unknown-linux-musl.tar.gz" 
      docker exec $c bash -c "rm -rf codex-x86_64-unknown-linux-musl.tar.gz" 
      docker cp ../SHELL_SCRIPTS/    $c:/root/
      docker cp ../GR_SUMMARY.md     $c:/root/ 
      docker cp ../METRICS_TABLE.md  $c:/root/TESTS/METRICS_TABLE.md 

      if [[ "$c" == *fr* ]]; then
          echo "[FASTROUTE] Switch to FastRoute branch" | indent
          docker exec $c bash -c "cd /root/OpenROAD-flow-scripts && git pull && git switch NEWGR-CodexEvolve" | indent
          docker exec $c bash -c "cd /root/OpenROAD_New_GRT && git pull && git switch NEWGR-CR-FastRoute-base" | indent
          docker exec $c bash -c "rm -rf /root/OpenROAD_New_GRT/src/grt/src/NEWGR/Galois" | indent
          docker exec $c bash -c "cd /root/OpenROAD_New_GRT && git log --oneline -n 1" | indent
      fi 

      if [[ "$c" == *cugr* ]]; then
        echo "[CUGR] Switch to CUGR branch" | indent
        docker exec $c bash -c "cd /root/OpenROAD-flow-scripts && git pull && git switch NEWGR-CodexEvolve" | indent
        docker exec $c bash -c "cd /root/OpenROAD_New_GRT && git pull && git switch NEWGR-CE-CUGR-base" | indent
        docker exec $c bash -c "rm -rf /root/OpenROAD_New_GRT/src/grt/src/NEWGR/Galois" | indent
        docker exec $c bash -c "cd /root/OpenROAD_New_GRT && git log --oneline -n 1" | indent

      fi 
      
      if [[ "$c" == *spr* ]]; then
        echo "[SPRoute] Switch to SPROUTE branch" | indent
        docker exec $c bash -c "cd /root/OpenROAD-flow-scripts && git pull && git switch NEWGR-CodexEvolve" | indent
        docker exec $c bash -c "cd /root/OpenROAD_New_GRT && git pull && git switch NEWGR-CE-SPRoute-base" | indent
        docker exec $c bash -c "cd /root/OpenROAD_New_GRT && git log --oneline -n 1" | indent
        # docker cp "$(dirname "$0")/__buildOR_spr.sh" $c:/root/SHELL_SCRIPTS/__buildOR.sh
        docker cp ./__buildOR_spr.sh $c:/root/SHELL_SCRIPTS/__buildOR.sh

      fi 


    echo "[TEST CODEX] ========================================= " | indent
      docker exec -d "$c" bash -c \
        "/root/codex-x86_64-unknown-linux-musl exec \"Create folder called tes_cap in /root/. In this folder create 4 column md file called 4test.md . Create git branch in this folder called test1\" --skip-git-repo-check"
        sleep 5
        docker exec $c bash -c "ls tes_cap && cat tes_cap/4test.md"

    echo "[SETUP EVOLUTION  ] ========================================= " | indent
      agents_file=$(get_agents_file "$c")
      if [[ -f "$agents_file" ]]; then
          echo "[AGENTS] Copying $(basename "$agents_file") -> $c:/root/AGENTS.md" | indent
          docker cp "$agents_file" "$c:/root/AGENTS.md" | indent
      else
          echo "[AGENTS] WARNING: No AGENTS file found for $c (looked for $agents_file)" | indent
      fi

    echo "[START EVOLUTION] =========== ${c} ===================== " | indent
      docker exec -d "$c" bash -c "nohup /root/SHELL_SCRIPTS/GeneticRunCodex.sh > /root/evolution_start_time.log 2>&1 &" | indent | indent


  fi
done
