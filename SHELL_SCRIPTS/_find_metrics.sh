echo "GR runtime   : $(grep 'global_route runtime'   /root/TESTS/newgr_autoevolve/GR_newgr_e.${1}.log | awk '{print $5}')"
echo "DR Via count : $(grep 'Total number of vias =' /root/TESTS/newgr_autoevolve/DR_newgr_e.${1}.log | tail -n 1 | awk '{print $6}')"
echo "DR Wirelength: $(grep 'Total wire length ='    /root/TESTS/newgr_autoevolve/DR_newgr_e.${1}.log | tail -n 1 | awk '{print $5}')"
