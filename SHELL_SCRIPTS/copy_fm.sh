
 bu_copy_test() {
  # docker exec $c bash -c "rm -rf /root/*.csv && rm -rf /root/TESTS/METRICS_TABLE.md" | indent
  docker exec -d "$c" bash -c " {
    /root/SHELL_SCRIPTS/__buildOR.sh &&
    /root/SHELL_SCRIPTS/__copyORbinary.sh &&
    /root/SHELL_SCRIPTS/_RUN_LARGE_TESTS.sh
  } >> /root/runlargetest.out 2>&1"
  # docker exec -d "$c" bash -c "
  # {
  #   set -e
  #   echo \"===== GENERATE TABLE \$(date) =====\" &&
  #   /root/SHELL_SCRIPTS/generate_csv.sh $1 nangate45 &&
  #   /root/SHELL_SCRIPTS/generate_metrics_table.sh
  #   echo \"===== END \$(date) =====\"
  # } >> /root/makecsv.out 2>&1"

  # docker exec -d "$c" bash -c "
  # {
  #   /root/SHELL_SCRIPTS/__buildOR.sh &&
  #   /root/SHELL_SCRIPTS/__copyORbinary.sh &&
  #   /root/SHELL_SCRIPTS/RUN_SMALL_FULL_TESTS.sh
  # } >> /root/runsmallfulltest.out 2>&1"
  # sleep 2
}

make_metric_table() {
  echo "[CONTAINER] Creating Table for $c" | indent
  docker exec -d "$c" bash -c "
  {
    set -e
    rm -rf /root/metrics_all_runs.csv &&
    /root/SHELL_SCRIPTS/__buildOR.sh &&
    /root/SHELL_SCRIPTS/__copyORbinary.sh &&
    /root/SHELL_SCRIPTS/RUN_FULL_LARGE.sh &&
    echo \"===== GENERATE TABLE \$(date) =====\" &&
    /root/SHELL_SCRIPTS/generate_csv.sh $1 &&
    echo \"===== END \$(date) =====\"
  } >> /root/largetest.log 2>&1" 
    # /root/SHELL_SCRIPTS/generate_metrics_table.sh
  # echo "[CSV      ] Creating csv in $c" | indent
  # docker exec $c bash -c "cat /root/metrics_all_runs.csv" | indent | indent
  # echo "[CSV      ] Copy table from $c" | indent
  # docker cp $c:/root/metrics_all_runs.csv /home/tsjafri/TAIZUN/DOCKER_gemini_claude/CSV_FILES/$c.csv | indent
}

indent() { sed 's/^/    /'; }


switch_to_git(){
    local iter="$1"
    local branch="$2"

    # docker exec "$c" bash -lc '
    #     iter="$1"
    #     cd /root/OpenROAD_New_GRT || exit 1
    #     commit=$(git log --grep="^Iteration ${iter}$" --format="%H" -n 1)
    #     [ -n "$commit" ] || { echo "Commit not found for Iteration ${iter}"; exit 1; }
    #     git switch --detach "$commit"
    # ' bash "$iter" | indent

    docker exec "$c" bash -lc "cd /root/OpenROAD_New_GRT && git branch" | indent
    # docker exec "$c" bash -lc "cd /root/OpenROAD_New_GRT && git switch \"$branch\"" | indent
    docker exec "$c" bash -lc "cd /root/OpenROAD_New_GRT && git log -n 1" | indent
    # docker exec "$c" bash -lc "cd /root/OpenROAD_New_GRT && git switch -c \"$branch\"" | indent
    # docker exec "$c" bash -lc "cd /root/OpenROAD_New_GRT && git push --set-upstream origin \"$branch\"" | indent

}
containers=(
            # fr___aes_asap7
            # cugr_aes_asap7
            # spr__aes_asap7
            # fr___ibex_asap7-2
            # cugr_ibex_asap7-2
            # spr__ibex_asap7-2
            # fr___jpeg_asap7-2
            # cugr_jpeg_asap7-2
            # spr__jpeg_asap7-2

            ### Original ASAP7 containers that were wrongly evolved on AES numbers.
            # fr___ibex_asap7
            # cugr_ibex_asap7
            # spr__ibex_asap7
            # fr___jpeg_asap7
            # cugr_jpeg_asap7
            # spr__jpeg_asap7

            # fr___aes_nan45
            # fr___ibex_nan45
            # fr___jpeg_nan45
            # cugr_aes_nan45
            # cugr_ibex_nan45
            # cugr_jpeg_nan45
            # spr__aes_nan45
            # spr__ibex_nan45
            # spr__jpeg_nan45


            ### New designs to evole : 
            ## ASAP7 : 
            ## - ariane136 
            ## - black_parrot 
            ## - swerv 
            ## - dynamic_node 
            ## NANGATE45 : 
            ## - ariane136 
            ## - black_parrot 
            ## - swerv 
            ## - dynamic_node 

          
            # ONGOING EVOLUTION with tables: 
            FR___swerv_asap7 
            # CUGR_swerv_asap7
            SPR__swerv_asap7
            # FR___dn____asap7
            # CUGR_dn____asap7
            # SPR__dn____asap7

            # FR___swerv_nan45
            # SPR__swerv_nan45
            # FR___dn____nan45
            ## Desired evolve improvement achieved.
            # CUGR_swerv_nan45
            # CUGR_dn____nan45
            # SPR__dn____nan45


            ## Evolution without table::
              ## NOT DOING EVOLUTION ON THESE NOW
              #   FR___ar136_asap7
              #   CUGR_ar136_asap7
              #   SPR__ar136_asap7
              # FR___bp____asap7
              # CUGR_bp____asap7
              # SPR__bp____asap7
              # FR___ar136_nan45
              # CUGR_ar136_nan45
              # SPR__ar136_nan45
              # FR___bp____nan45
              # CUGR_bp____nan45
              # SPR__bp____nan45
                        
)
# Are you authenticated and logged in  into OpenAI ?

for c in "${containers[@]}"; do ESE=10
  #############################################################
  # Evolution Setup
  #############################################################
  if [ "$ESE" -eq 1 ]; then 

    echo "[DOCKER] On container : $c"
    # docker run -d -it --hostname $c --name $c genaigr4
    # echo "[LOG] Copying .codex folder " |indent
    # docker exec $c sh -c "rm -rf /root/.codex"
    # docker cp /home/tsjafri/.codex/.codex $c:/root/
    # docker exec $c sh -c "rm -rf /root/TESTS/*"
    # docker exec $c sh -c "rm -rf /root/SHELL_SCRIPTS/*"
    # docker cp /home/tsjafri/TAIZUN/DOCKER_gemini_claude/SHELL_SCRIPTS/ $c:/root/
    # docker cp /home/tsjafri/TAIZUN/DOCKER_gemini_claude/GR_SUMMARY.md  $c:/root/

    # if [[ "$c" == *fr* ]]; then
    #     echo "[FASTROUTE] Switch to FastRoute branch" | indent
    #     # docker exec $c bash -c "cd /root/OpenROAD-flow-scripts && git pull && git switch NEWGR-CodexEvolve" | indent
    #     # docker exec $c bash -c "cd /root/OpenROAD_New_GRT && git pull && git switch NEWGR-CR-FastRoute-base" | indent
    #     docker exec $c bash -c "cd /root/OpenROAD_New_GRT && git branch" | indent
        
        
    #     if [[ "$c" == *aes* ]]; then 
    #         echo "[CONTAINER] $c" | indent
    #         # docker cp /home/tsjafri/TAIZUN/DOCKER_gemini_claude/SHELL_SCRIPTS/_RUN_SMALL_TESTS.sh    $c:/root/SHELL_SCRIPTS/_RUN_SMALL_TESTS.sh  | indent
    #         docker cp /home/tsjafri/TAIZUN/DOCKER_gemini_claude/METRICS_TABLE_FRAES.md    $c:/root/TESTS/METRICS_TABLE.md  | indent
    #     fi 
    #     if [[ "$c" == *ibex* ]]; then 
    #         echo "[CONTAINER] $c" | indent
    #         # docker cp /home/tsjafri/TAIZUN/DOCKER_gemini_claude/_RUN_SMALL_TESTS_IBEX.sh    $c:/root/SHELL_SCRIPTS/_RUN_SMALL_TESTS.sh | indent
    #         docker cp /home/tsjafri/TAIZUN/DOCKER_gemini_claude/METRICS_TABLE_FRIBEX.md    $c:/root/TESTS/METRICS_TABLE.md | indent
    #     fi 
    #     if [[ "$c" == *jpeg* ]]; then 
    #         echo "[CONTAINER] $c" | indent
    #         # docker cp /home/tsjafri/TAIZUN/DOCKER_gemini_claude/_RUN_SMALL_TESTS_JPEG.sh    $c:/root/SHELL_SCRIPTS/_RUN_SMALL_TESTS.sh | indent
    #         docker cp /home/tsjafri/TAIZUN/DOCKER_gemini_claude/METRICS_TABLE_FRJPEG.md    $c:/root/TESTS/METRICS_TABLE.md | indent
    #     fi 
    # fi 

    # if [[ "$c" == *cugr* ]]; then
    #     echo "[CUGR     ] Switch to CUGR branch"
    #     # docker exec $c bash -c "cd /root/OpenROAD-flow-scripts && git pull && git switch NEWGR-CodexEvolve" | indent
    #     # docker exec $c bash -c "cd /root/OpenROAD_New_GRT && git pull && git switch NEWGR-CE-CUGR-base" | indent
    #     docker exec $c bash -c "cd /root/OpenROAD_New_GRT && git branch" | indent
        
    #     if [[ "$c" == *aes* ]]; then 
    #         echo "[CONTAINER] $c" | indent
    #         # docker cp /home/tsjafri/TAIZUN/DOCKER_gemini_claude/SHELL_SCRIPTS/_RUN_SMALL_TESTS.sh    $c:/root/SHELL_SCRIPTS/_RUN_SMALL_TESTS.sh  | indent
    #         docker cp /home/tsjafri/TAIZUN/DOCKER_gemini_claude/METRICS_TABLE_CUGRAES.md    $c:/root/TESTS/METRICS_TABLE.md  | indent
    #     fi 
    #     if [[ "$c" == *ibex* ]]; then 
    #         echo "[CONTAINER] $c" | indent
    #         # docker cp /home/tsjafri/TAIZUN/DOCKER_gemini_claude/_RUN_SMALL_TESTS_IBEX.sh    $c:/root/SHELL_SCRIPTS/_RUN_SMALL_TESTS.sh | indent
    #         docker cp /home/tsjafri/TAIZUN/DOCKER_gemini_claude/METRICS_TABLE_CUGRIBEX.md    $c:/root/TESTS/METRICS_TABLE.md | indent
    #     fi 
    #     if [[ "$c" == *jpeg* ]]; then 
    #         echo "[CONTAINER] $c" | indent
    #         # docker cp /home/tsjafri/TAIZUN/DOCKER_gemini_claude/_RUN_SMALL_TESTS_JPEG.sh    $c:/root/SHELL_SCRIPTS/_RUN_SMALL_TESTS.sh | indent
    #         docker cp /home/tsjafri/TAIZUN/DOCKER_gemini_claude/METRICS_TABLE_CUGRJPEG.md    $c:/root/TESTS/METRICS_TABLE.md | indent
    #     fi 
    # fi 

    # if [[ "$c" == *spr* ]]; then
    #     echo "[SPRoute  ] Switch to SPRoute branch"
    #     docker cp /home/tsjafri/TAIZUN/DOCKER_gemini_claude/__buildOR_spr.sh $c:/root/SHELL_SCRIPTS/__buildOR.sh | indent
    #     # docker exec $c bash -c "cd /root/OpenROAD-flow-scripts && git pull && git switch NEWGR-CodexEvolve" | indent
    #     # docker exec $c bash -c "cd /root/OpenROAD_New_GRT && git pull && git switch NEWGR-CE-SPRoute-base" | indent
    #     docker exec $c bash -c "cd /root/OpenROAD_New_GRT && git branch" | indent
        
    #     if [[ "$c" == *aes* ]]; then 
    #         echo "[CONTAINER] $c" | indent
    #         # docker cp /home/tsjafri/TAIZUN/DOCKER_gemini_claude/SHELL_SCRIPTS/_RUN_SMALL_TESTS.sh    $c:/root/SHELL_SCRIPTS/_RUN_SMALL_TESTS.sh  | indent
    #         docker cp /home/tsjafri/TAIZUN/DOCKER_gemini_claude/METRICS_TABLE_SPRAES.md    $c:/root/TESTS/METRICS_TABLE.md  | indent
    #     fi 
    #     if [[ "$c" == *ibex* ]]; then 
    #         echo "[CONTAINER] $c" | indent
    #         # docker cp /home/tsjafri/TAIZUN/DOCKER_gemini_claude/_RUN_SMALL_TESTS_IBEX.sh    $c:/root/SHELL_SCRIPTS/_RUN_SMALL_TESTS.sh | indent
    #         docker cp /home/tsjafri/TAIZUN/DOCKER_gemini_claude/METRICS_TABLE_SPRIBEX.md    $c:/root/TESTS/METRICS_TABLE.md | indent
    #     fi 
    #     if [[ "$c" == *jpeg* ]]; then 
    #         echo "[CONTAINER] $c" | indent
    #         # docker cp /home/tsjafri/TAIZUN/DOCKER_gemini_claude/_RUN_SMALL_TESTS_JPEG.sh    $c:/root/SHELL_SCRIPTS/_RUN_SMALL_TESTS.sh | indent
    #         docker cp /home/tsjafri/TAIZUN/DOCKER_gemini_claude/METRICS_TABLE_SPRJPEG.md    $c:/root/TESTS/METRICS_TABLE.md | indent
    #     fi 
    # fi 


    # docker exec -d "$c" bash -c \
    #   "/root/codex-x86_64-unknown-linux-musl exec \"Create folder called tes_cap in /root/. In this folder create 4 column md file called 4test. Create git branch in this folder called test1\" --skip-git-repo-check"
    # docker exec $c bash -c "ls /root/ && cd tes_cap && git branch && cat 4test.md"
    # docker exec $c bash -c "cat /root/nohup_tescap.out | tail -n 10" | indent

    # docker exec $c bash -c "cat /root/SHELL_SCRIPTS/RUN_SMALL_FULL_TESTS.sh" | indent
    # bu_copy_test | indent
    # docker exec $c bash -c "ps aux | grep RUN_SMALL_FULL_TESTS.sh" | indent
    # docker exec $c bash -c "cat /root/runsmallfulltest.out | tail -n 10 " | indent
    # docker exec $c bash -c "rm -rf /root/runsmallfulltest.out" | indent
    docker exec $c bash -c "ls /root/TESTS/newgr_evolve_test" | indent

    # bu_copy_test | indent

    # bu_copy_test aes | indent
    # bu_copy_test ibex | indent
    # bu_copy_test jpeg | indent
    # docker exec $c bash -c "ls /root/TESTS/newgr_evolve_test/ -R" | indent
    # docker exec $c bash -c "ls /root/TESTS/" | indent
    # docker exec $c bash -c "ls /root/SHELL_SCRIPTS/ -R" | indent
    # docker exec $c bash -c "rm -rf /root/TESTS/newgr_evolve_test/" | indent
    # docker exec $c bash -c "rm -rf /root/metrics_all_runs.csv" | indent
    # docker exec $c bash -c "cat /root/metrics_all_runs.csv" | indent
    # docker exec $c bash -c "rm -rf /root/runsmallfulltest.out" | indent
    # docker exec $c bash -c "cat /root/runsmallfulltest.out | tail -n 10" | indent
    # docker exec $c bash -c "ps aux | grep RUN_SMALL_FULL_TESTS.sh" | indent
    # docker exec $c bash -c "pkill -f RUN_SMALL_FULL_TESTS.sh" | indent
    # docker exec $c bash -c "pkill ornewgr2" | indent
    # docker cp $c:/root/metrics_all_runs.csv /home/tsjafri/TAIZUN/DOCKER_gemini_claude/CSV_FILES/nan45/$c.csv
    # docker cp $c:/root/runsmallfulltest.out /home/tsjafri/TAIZUN/DOCKER_gemini_claude/CSV_FILES/nan45/$c.log

  fi
  #############################################################
  # Start Evolution
  #############################################################
  if [ $ESE -eq 2 ]; then

    # echo "[CHECK METRICS  ] ========================================= "
    # #Logging Metrics and capturing them to GPU server.
    # if [[ "$c" == *aes* ]]; then 
    #     echo "[CONTAINER] $c" | indent
    #     make_metric_table aes
    # fi 
    # if [[ "$c" == *ibex* ]]; then 
    #     echo "[CONTAINER] $c" | indent
    #     make_metric_table ibex 
    # fi 
    # if [[ "$c" == *jpeg* ]]; then 
    #     echo "[CONTAINER] $c" | indent
    #     make_metric_table jpeg 
    # fi 
    
	  echo "[DOCKER] In container : $c"
    #  if [[ "$c" == *aes* ]]; then 
    #    echo "[CONTAINER] Copy AGENTS.md to AES  : $c" | indent
    #    docker cp /home/tsjafri/TAIZUN/DOCKER_gemini_claude/AGENTS_AES.md           $c:/root/AGENTS.md
    #   #  echo "[CONTAINER] Copy _RUN_SMALL_TESTS.sh to AES  : $c" | indent
    #   #  docker cp /home/tsjafri/TAIZUN/DOCKER_gemini_claude/SHELL_SCRIPTS/_RUN_SMALL_TESTS.sh $c:/root/SHELL_SCRIPTS/_RUN_SMALL_TESTS.sh | indent
    #   #  docker exec $c bash -c "cat /root/TESTS/METRICS_TABLE.md" | indent
    #   # docker exec $c bash -c "cat /root/SHELL_SCRIPTS/_RUN_SMALL_TESTS.sh" | indent
    #  fi 
    #  if [[ "$c" == *ibex* ]]; then 
    #    echo "[CONTAINER] Copy AGENTS.md to IBEX : $c" | indent
    #    docker cp /home/tsjafri/TAIZUN/DOCKER_gemini_claude/AGENTS_IBEX.md          $c:/root/AGENTS.md
    #   #  echo "[CONTAINER] Copy _RUN_SMALL_TESTS.sh to IBEX  : $c" | indent
    #   #  docker cp /home/tsjafri/TAIZUN/DOCKER_gemini_claude/_RUN_SMALL_TESTS_IBEX.sh $c:/root/SHELL_SCRIPTS/_RUN_SMALL_TESTS.sh | indent
    #   #  docker exec $c bash -c "cat /root/TESTS/METRICS_TABLE.md" | indent
    #   #  docker exec $c bash -c "cat /root/SHELL_SCRIPTS/_RUN_SMALL_TESTS.sh" | indent
    #  fi 
    #  if [[ "$c" == *jpeg* ]]; then 
    #    echo "[CONTAINER] Copy AGENTS.md to JPEG : $c" | indent
    #    docker cp /home/tsjafri/TAIZUN/DOCKER_gemini_claude/AGENTS_JPEG.md         $c:/root/AGENTS.md
    #   #  echo "[CONTAINER] Copy _RUN_SMALL_TESTS.sh to JPEG  : $c" | indent
    #   #  docker cp /home/tsjafri/TAIZUN/DOCKER_gemini_claude/_RUN_SMALL_TESTS_JPEG.sh $c:/root/SHELL_SCRIPTS/_RUN_SMALL_TESTS.sh | indent
    #   #  docker exec $c bash -c "cat /root/TESTS/METRICS_TABLE.md" | indent
    #   #  docker exec $c bash -c "cat /root/SHELL_SCRIPTS/_RUN_SMALL_TESTS.sh" | indent
    #  fi 

    # docker exec $c bash -c 'cat ~/SHELL_SCRIPTS/_RUN_SMALL_TESTS.sh | grep newgr_autoevolve' | indent
    # echo "[COPY] Copy GeneticRunCodex.sh to $c" | indent
    # docker cp /home/tsjafri/TAIZUN/DOCKER_gemini_claude/SHELL_SCRIPTS/GeneticRunCodex.sh $c:/root/SHELL_SCRIPTS/GeneticRunCodex.sh | indent
    # docker exec $c bash -c 'grep -E "^(CURRENT_ITERATION|TOTAL_ITERATIONS)=" /root/SHELL_SCRIPTS/GeneticRunCodex.sh' | indent
    
    # docker exec $c bash -c 'sed -n '37,65p' /root/AGENTS.md' | indent
    # docker exec $c bash -c "rm -rf /root/nohup_logs && rm -rf /root/nohup_runs.out && rm -rf /root/tes_cap"  | indent
    # docker exec $c bash -c "ls /root/TESTS -R"  | indent
    
    # echo "[START EVOLUTION] =========== ${c} ===================== " | indent
    # docker exec $c bash -c "cd ~/OpenROAD_New_GRT && git branch && git log -n 1" | indent | indent
    # docker exec $c bash -c 'grep -E "^(CURRENT_ITERATION|TOTAL_ITERATIONS)=" /root/SHELL_SCRIPTS/GeneticRunCodex.sh' | indent
    # docker exec $c bash -c 'cat ~/SHELL_SCRIPTS/_RUN_SMALL_TESTS.sh | grep newgr_autoevolve' | indent
    # docker exec -d "$c" bash -c "nohup /root/SHELL_SCRIPTS/GeneticRunCodex.sh > /root/nohup_runs50-75.out 2>&1 &" | indent | indent
    # docker exec $c bash -c "ps aux | grep ~/SHELL_SCRIPTS/GeneticRunCodex.sh" | indent | indent
    # docker exec $c bash -c 'rm -rf ~/nohup_logs/ ' | indent | indent
    # docker exec $c bash -c 'ls ~/nohup_logs/ -l -v | tail -n 5' | indent | indent
    # docker exec $c bash -c 'cat ~/nohup_logs/nohup58.out' | indent | indent
    
    # docker exec $c bash -c "pkill -f runCodexCLI.sh" | indent
    # docker exec $c bash -c "pkill -f GeneticRunCodex.sh" | indent
    # docker exec $c bash -c "pkill ornewgr2" | indent
    # docker exec $c bash -c "ps aux | grep ~/SHELL_SCRIPTS/GeneticRunCodex.sh" | indent
    # docker exec $c bash -c "ps aux | grep OpenROAD" | indent

    # echo "[CHECK EVOLUTION] =========== ${c} ===================== "
    # docker cp $c:/root/TESTS/METRICS_TABLE.md /home/tsjafri/TAIZUN/DOCKER_gemini_claude/METRICS_TEST/$c.md | indent
    # docker exec $c bash -c "cat /root/TESTS/METRICS_TABLE.md | tail -n 10" | indent
    # docker exec $c bash -c 'ls ~/nohup_logs/ -l -v | tail -n 5' | indent | indent
    # docker exec $c bash -c "ls /root/" | indent
    # docker exec $c bash -c "cd /root/SHELL_SCRIPTS/ && ls -l" | indent
    # echo "[COPY] Copy RUN_SMALL_FULL_TESTS.sh to $c" 
	  # docker cp /home/tsjafri/TAIZUN/DOCKER_gemini_claude/SHELL_SCRIPTS/RUN_SMALL_FULL_TESTS.sh $c:/root/SHELL_SCRIPTS/RUN_SMALL_FULL_TESTS.sh | indent
    # docker exec $c bash -c "cd /root/SHELL_SCRIPTS/ && cat RUN_SMALL_FULL_TESTS.sh" | indent
	  # docker exec $c bash -c "cd /root/TESTS/newgr_autoevolve && ls *GR* -l -v | tail -n 10 && ls *DR* -l -v | tail -n 10" | indent
	  # docker exec $c bash -c "ls /root/nohup_logs -l -v | tail -n 10"  | indent
	  # docker exec $c bash -c "cd /root/OpenROAD_New_GRT && git log -n 1"  | indent
	  # docker exec $c bash -c "cat /root/SHELL_SCRIPTS/_RUN_SMALL_TESTS.sh | tail -n 50"  | indent
	  # docker exec $c bash -c "ls /root/TESTS/newgr_evolve_test/"  | indent
	  # docker exec $c bash -c "rm -rf /root/metrics_all_runs.csv && rm -rf /root/TESTS/newgr_evolve_test/*"  | indent
	  # docker exec -d $c bash -c "cd /root/SHELL_SCRIPTS/ && ./__buildOR.sh && ./__copyORbinary.sh && ./_RUN_SMALL_TESTS.sh" | indent
 



  fi
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
  # Run full tests
  #############################################################
  if [ $ESE -eq 3 ]; then

     

    echo "[RUN FULL TEST] in container : $c" 
    # docker cp /home/tsjafri/TAIZUN/DOCKER_gemini_claude/SHELL_SCRIPTS/RUN_SMALL_FULL_TESTS.sh $c:/root/SHELL_SCRIPTS/RUN_SMALL_FULL_TESTS.sh | indent
    # docker exec $c bash -c "cat /root/SHELL_SCRIPTS/RUN_SMALL_FULL_TESTS.sh "  | indent

    # docker exec -d $c bash -c "{ cd /root/SHELL_SCRIPTS/ && ./__buildOR.sh && ./__copyORbinary.sh && /root/SHELL_SCRIPTS/RUN_SMALL_FULL_TESTS.sh; } > /root/fulltest.log 2>&1"
    # docker exec $c bash -c "ps aux | grep /root/SHELL_SCRIPTS/RUN_SMALL_FULL_TESTS.sh"  | indent
    # sleep 3
    # docker exec $c bash -c "cat /root/fulltest.log | tail -n 20"  | indent
    docker exec $c bash -c "/root/SHELL_SCRIPTS/generate_csv.sh aes asap7"  | indent
    docker exec $c bash -c "/root/SHELL_SCRIPTS/generate_csv.sh ibex asap7"  | indent
    docker exec $c bash -c "/root/SHELL_SCRIPTS/generate_csv.sh jpeg asap7"  | indent
    docker exec $c bash -c "cat /root/metrics_all_runs.csv"  | indent
    docker cp $c:/root/metrics_all_runs.csv /home/tsjafri/TAIZUN/DOCKER_gemini_claude/CSV_FILES/$c.csv
    docker exec $c bash -c "rm -rf /root/metrics_all_runs.csv"  | indent
    # docker exec $c bash -c "pkill -f RUN_SMALL_FULL_TESTS.sh"  | indent
    # docker exec $c bash -c "pkill -f _RUN_SMALL_TESTS.sh"  | indent
    # docker exec $c bash -c "cat /root/fulltest.log | tail -n 10"  | indent
    # docker exec $c bash -c "ps aux | grep ~/SHELL_SCRIPTS/RUN_SMALL_FULL_TESTS.sh" | indent
    # docker exec $c bash -c "ps aux | grep ~/SHELL_SCRIPTS/_RUN_SMALL_TESTS.sh" | indent
    # docker exec $c bash -c "pkill ornewgr2"  | indent
  fi
  #############################################################
  # Save git branch for each container
  #############################################################
  if [ $ESE -eq 4 ]; then
    echo "[DOCKER] On container : $c"

    if [[ "$c" == *fr* ]]; then
        echo "[FASTROUTE] Switch to FastRoute branch" | indent
        if [[ "$c" == *aes* ]]; then 
          echo "[CONTAINER] $c" | indent 
          # switch_to_git 55 NEWGR-CR-FastRoute-base
          switch_to_git 55 NEWGR-CE-FastRoute-AES-Nan45
        fi 
        if [[ "$c" == *ibex* ]]; then  
          echo "[CONTAINER] $c" | indent 
          # switch_to_git 116 NEWGR-CR-FastRoute-base
          switch_to_git 116 NEWGR-CE-FastRoute-IBEX-Nan45
        fi 
        if [[ "$c" == *jpeg* ]]; then 
          echo "[CONTAINER] $c" | indent
          # switch_to_git 60 NEWGR-CR-FastRoute-base
          switch_to_git 60 NEWGR-CE-FastRoute-JPEG-Nan45
        fi 
    fi 

    if [[ "$c" == *cugr* ]]; then
        echo "[CUGR     ] Switch to CUGR branch" | indent
        if [[ "$c" == *aes* ]]; then 
          echo "[CONTAINER] $c" | indent
          # switch_to_git 10 NEWGR-CE-CUGR-base
          switch_to_git 10 NEWGR-CE-CUGR-AES-Nan45
        fi 
        if [[ "$c" == *ibex* ]]; then 
          echo "[CONTAINER] $c" | indent
          # switch_to_git 86 NEWGR-CE-CUGR-base
          switch_to_git 86 NEWGR-CE-CUGR-IBEX-Nan45
        fi 
        if [[ "$c" == *jpeg* ]]; then 
          echo "[CONTAINER] $c" | indent
          # switch_to_git 87 NEWGR-CE-CUGR-base
          switch_to_git 87 NEWGR-CE-CUGR-JPEG-Nan45
        fi 
    fi 

    if [[ "$c" == *spr* ]]; then
        echo "[SPRoute  ]" | indent
        
        if [[ "$c" == *aes* ]]; then 
          echo "[CONTAINER] $c" | indent
          # switch_to_git 10 NEWGR-CE-SPRoute-base
          switch_to_git 10 NEWGR-CE-SPRoute-AES-Nan45
        fi 
        if [[ "$c" == *ibex* ]]; then 
          echo "[CONTAINER] $c" | indent
          # switch_to_git 101 NEWGR-CE-SPRoute-base
          switch_to_git 101 NEWGR-CE-SPRoute-IBEX-Nan45
        fi 
        if [[ "$c" == *jpeg* ]]; then 
          echo "[CONTAINER] $c" | indent
          # switch_to_git 52 NEWGR-CE-SPRoute-base
          switch_to_git 52 NEWGR-CE-SPRoute-JPEG-Nan45
        fi 
    fi 
  fi 

  #############################################################
  # Evolution Setup
  #############################################################
  if [ "$ESE" -eq 10 ]; then 

    echo "[DOCKER] On container : $c"
    #   docker run -d -it --hostname $c --name $c genaigr4 | indent
      # echo "[LOG] Copying .codex folder " |indent
      # docker exec $c sh -c "rm -rf /root/.codex" 
      # docker cp /home/tsjafri/.codex $c:/root/.codex 
      # docker exec $c sh -c "rm -rf /root/TESTS/*"
      # docker exec $c sh -c "rm -rf /root/SHELL_SCRIPTS/*"
      # docker cp /home/tsjafri/TAIZUN/DOCKER_gemini_claude/SHELL_SCRIPTS/ $c:/root/
      # docker cp /home/tsjafri/TAIZUN/DOCKER_gemini_claude/GR_SUMMARY.md  $c:/root/ 
      # docker cp /home/tsjafri/TAIZUN/METRICS_TABLE.md  $c:/root/TESTS/METRICS_TABLE.md 

    #   if [[ "$c" == *FR* ]]; then
    #       echo "[FASTROUTE] Switch to FastRoute branch" | indent
    #       docker exec $c bash -c "cd /root/OpenROAD-flow-scripts && git pull && git switch NEWGR-CodexEvolve" | indent
    #       docker exec $c bash -c "cd /root/OpenROAD_New_GRT && git pull && git switch NEWGR-CR-FastRoute-base" | indent
    #       docker exec $c bash -c "cd /root/OpenROAD_New_GRT && git log --oneline -n 1" | indent
    #   fi 

    #   if [[ "$c" == *CUGR* ]]; then
    #     echo "[CUGR] Switch to CUGR branch" | indent
    #     docker exec $c bash -c "cd /root/OpenROAD-flow-scripts && git pull && git switch NEWGR-CodexEvolve" | indent
    #     docker exec $c bash -c "cd /root/OpenROAD_New_GRT && git pull && git switch NEWGR-CE-CUGR-base" | indent
    #     docker exec $c bash -c "cd /root/OpenROAD_New_GRT && git log --oneline -n 1" | indent

    #   fi 
      
    #   if [[ "$c" == *SPR* ]]; then
    #     echo "[SPRoute] Switch to SPROUTE branch" | indent
    #     docker exec $c bash -c "cd /root/OpenROAD-flow-scripts && git pull && git switch NEWGR-CodexEvolve" | indent
    #     docker exec $c bash -c "cd /root/OpenROAD_New_GRT && git pull && git switch NEWGR-CE-SPRoute-base" | indent
    #     docker exec $c bash -c "cd /root/OpenROAD_New_GRT && git log --oneline -n 1" | indent
    #     docker cp /home/tsjafri/TAIZUN/DOCKER_gemini_claude/__buildOR_spr.sh $c:/root/SHELL_SCRIPTS/__buildOR.sh

    #   fi 


    #   if [[ "$c" == *swerv* ]]; then 
    #       echo "[CONTAINER] $c" | indent
    #       docker cp /home/tsjafri/TAIZUN/DOCKER_gemini_claude/RL_swerv.sh    $c:/root/SHELL_SCRIPTS/_RUN_LARGE_TESTS.sh  | indent
    #   fi 
    #   if [[ "$c" == *dn* ]]; then 
    #       echo "[CONTAINER] $c" | indent
    #       docker cp /home/tsjafri/TAIZUN/DOCKER_gemini_claude/RL_dn.sh    $c:/root/SHELL_SCRIPTS/_RUN_LARGE_TESTS.sh  | indent
    #   fi 

    # echo "[CHECK CODEX] ========================================= " | indent
    #   docker exec -d "$c" bash -c \
    #     "/root/codex-x86_64-unknown-linux-musl exec \"Create folder called tes_cap in /root/. In this folder create 4 column md file called 4test.md . Create git branch in this folder called test1\" --skip-git-repo-check"

    # echo "[CHECK Run] ========================================= " | indent
    #   docker exec $c bash -c "ls tes_cap && cat tes_cap/4test.md"
      # bu_copy_test | indent
      # docker exec $c bash -c "cat /root/runlargetest.out | tail -n 20 " | indent
      # docker exec $c bash -c "ls /root/TESTS/newgr_evolve_test -R" | indent
      # docker exec $c bash -c "/root/SHELL_SCRIPTS/generate_csv.sh" | indent

    # echo "[SETUP EVOLUTION  ] ========================================= " | indent
      # if [[ "$c" == *dn* ]]; then 
      #     echo "[AGENTS] $c" | indent
      #     docker cp /home/tsjafri/TAIZUN/DOCKER_gemini_claude/agents_dn.md    $c:/root/AGENTS.md  | indent
      # fi 
      # if [[ "$c" == *swerv* ]]; then 
      #     echo "[AGENTS] $c" | indent
      #     docker cp /home/tsjafri/TAIZUN/DOCKER_gemini_claude/agents_swerv.md    $c:/root/AGENTS.md  | indent
      # fi 
      # docker exec $c bash -c "ls /root/"
      # docker exec $c bash -c 'sed -n '43,49p' /root/AGENTS.md' | indent
      # docker exec $c bash -c 'cat /root/SHELL_SCRIPTS/RUN_NEWGR.sh | tail -n 10' | indent
      # docker exec $c bash -c 'cat /root/SHELL_SCRIPTS/_RUN_LARGE_TESTS.sh | tail -n 10' | indent
      # docker cp /home/tsjafri/TAIZUN/DOCKER_gemini_claude/SHELL_SCRIPTS/GeneticRunCodex.sh $c:/root/SHELL_SCRIPTS/GeneticRunCodex.sh
      # docker exec $c bash -c 'grep -E "^(CURRENT_ITERATION|TOTAL_ITERATIONS)=" /root/SHELL_SCRIPTS/GeneticRunCodex.sh' | indent
      # docker exec $c bash -c 'cat /root/SHELL_SCRIPTS/__buildOR.sh' | indent

    # echo "[START EVOLUTION] =========== ${c} ===================== " | indent
      # docker exec $c bash -c "cd ~/OpenROAD_New_GRT && git branch && git log --oneline -n 5" | indent | indent
      # docker exec $c bash -c 'grep -E "^(CURRENT_ITERATION|TOTAL_ITERATIONS)=" /root/SHELL_SCRIPTS/GeneticRunCodex.sh' | indent
      # docker exec $c bash -c 'cat ~/SHELL_SCRIPTS/_RUN_LARGE_TESTS.sh | grep newgr_autoevolve' | indent
      # docker exec -d "$c" bash -c "nohup /root/SHELL_SCRIPTS/GeneticRunCodex.sh > /root/nohup_runs26-51.out 2>&1 &" | indent | indent

    # echo "[CHECK EVOLUTION] =========== ${c} ===================== " | indent
      # docker exec $c bash -c "ls /root/TESTS" | indent | indent
      # docker exec $c bash -c 'ls ~/nohup_logs' | indent
      # docker exec $c bash -c 'cat /root/TESTS/METRICS_TABLE.md' | indent
      # docker exec $c bash -c 'cat /root/SHELL_SCRIPTS/_RUN_LARGE_TESTS.sh | tail -n 30' | indent
      # docker exec $c bash -c 'cat ~/nohup_logs/nohup28.out | tail -n 30' | indent
      # docker exec $c bash -c 'cd /root/OpenROAD_New_GRT && git log --oneline -n 5' | indent


    echo "[RETRIEVE METRICS] =========== ${c} ===================== " | indent
      # docker cp $c:/root/TESTS/METRICS_TABLE.md /home/tsjafri/TAIZUN/DOCKER_gemini_claude/METRICS_TEST/$c.md | indent
    #   docker cp /home/tsjafri/TAIZUN/DOCKER_gemini_claude/SHELL_SCRIPTS/RUN_FULL_LARGE.sh $c:/root/SHELL_SCRIPTS/RUN_FULL_LARGE.sh | indent
    #   # docker exec $c bash -c "rm -rf /root/metrics_all_runs.csv" | indent
    #   docker cp /home/tsjafri/TAIZUN/DOCKER_gemini_claude/SHELL_SCRIPTS/generate_csv.sh $c:/root/SHELL_SCRIPTS/generate_csv.sh | indent
      # docker exec $c bash -c "/root/SHELL_SCRIPTS/generate_csv.sh dynamic_node" | indent
      docker exec $c bash -c "/root/SHELL_SCRIPTS/generate_csv.sh swerv" | indent
      # docker exec $c bash -c "cat /root/largetest.log | tail -n 20" | indent
      # docker exec $c bash -c "pkill -f RUN_FULL_LARGE.sh" | indent
      # docker exec $c bash -c "ps aux | grep RUN_FULL_LARGE.sh" | indent
      # docker exec $c bash -c "cat /root/metrics_all_runs.csv" | indent


  fi
done
