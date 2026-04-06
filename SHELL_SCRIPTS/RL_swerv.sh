cd /root/OpenROAD-flow-scripts/flow         

# unset GLOBAL_ROUTE_ARGS
# make DESIGN_CONFIG=./designs/nangate45/swerv/config.mk clean_all 
# make DESIGN_CONFIG=./designs/nangate45/swerv/config.mk route
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/swerv/base/5_1_grt.log   /root/TESTS/newgr_evolve_test/swerv/GR_fastr_nangate45.log
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/swerv/base/5_2_route.log /root/TESTS/newgr_evolve_test/swerv/DR_fastr_nangate45.log

# export GLOBAL_ROUTE_ARGS='-use_cugr'
# export PLATFORM=nangate45
# export SKIP_INCREMENTAL_REPAIR=1
# export DESIGN_NAME=swerv
# make DESIGN_CONFIG=./designs/nangate45/swerv/config.mk clean_route
# make DESIGN_CONFIG=./designs/nangate45/swerv/config.mk route
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/swerv/base/5_1_grt.log   /root/TESTS/newgr_evolve_test/swerv/GR_cugr_nangate45.log
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/swerv/base/5_2_route.log /root/TESTS/newgr_evolve_test/swerv/DR_cugr_nangate45.log


# export GLOBAL_ROUTE_ARGS='-router sproute'
# make DESIGN_CONFIG=./designs/nangate45/swerv/config.mk clean_route
# make DESIGN_CONFIG=./designs/nangate45/swerv/config.mk route
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/swerv/base/5_1_grt.log   /root/TESTS/newgr_evolve_test/swerv/GR_sproute_nangate45.log
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/swerv/base/5_2_route.log /root/TESTS/newgr_evolve_test/swerv/DR_sproute_nangate45.log


export GLOBAL_ROUTE_ARGS='-router NEWGR'
export PLATFORM=nangate45
export SKIP_INCREMENTAL_REPAIR=1
export DESIGN_NAME=swerv
make DESIGN_CONFIG=./designs/nangate45/swerv/config.mk clean_route
make DESIGN_CONFIG=./designs/nangate45/swerv/config.mk route
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/aes/base/5_1_grt.log        /root/TESTS/newgr_evolve_test/aes/GR_cugr_nangate45.log
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/aes/base/5_1_grt.json       /root/TESTS/newgr_evolve_test/aes/GR_cugr_nangate45.json
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/aes/base/5_2_route.log      /root/TESTS/newgr_evolve_test/aes/DR_cugr_nangate45.log
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/aes/base/6_report.json      /root/TESTS/newgr_evolve_test/aes/GR_cugr_nangate45_rpt.json
install -D /root/OpenROAD-flow-scripts/flow/reports/nangate45/aes/base/5_route_drc.rpt /root/TESTS/newgr_evolve_test/aes/DR_cugr_drc.json
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/swerv/base/5_1_grt.log   /root/TESTS/newgr_autoevolve/GR_newgr_e.${1}.log
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/swerv/base/5_2_route.log   /root/TESTS/newgr_autoevolve/DR_newgr_e.${1}.log
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/swerv/base/5_1_grt.log   /root/TESTS/newgr_evolve_test/swerv/GR_newgr_nangate45.log 
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/swerv/base/5_2_route.log /root/TESTS/newgr_evolve_test/swerv/DR_newgr_nangate45.log 

