cd /root/OpenROAD-flow-scripts/flow         

# unset GLOBAL_ROUTE_ARGS
# make DESIGN_CONFIG=./designs/nangate45/ariane136/config.mk clean_all 
# make DESIGN_CONFIG=./designs/nangate45/ariane136/config.mk route
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/ariane136/base/5_1_grt.log   /root/TESTS/newgr_evolve_test/ariane136/GR_fastr_nangate45.log
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/ariane136/base/5_2_route.log /root/TESTS/newgr_evolve_test/ariane136/DR_fastr_nangate45.log

# export GLOBAL_ROUTE_ARGS='-use_cugr'
# export PLATFORM=nangate45
# export DESIGN_NAME=ariane136
# export SKIP_INCREMENTAL_REPAIR=1
# make DESIGN_CONFIG=./designs/nangate45/ariane136/config.mk clean_route
# make DESIGN_CONFIG=./designs/nangate45/ariane136/config.mk route
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/ariane136/base/5_1_grt.log   /root/TESTS/newgr_evolve_test/ariane136/GR_cugr_nangate45.log
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/ariane136/base/5_2_route.log /root/TESTS/newgr_evolve_test/ariane136/DR_cugr_nangate45.log


# export GLOBAL_ROUTE_ARGS='-router sproute'
# make DESIGN_CONFIG=./designs/nangate45/ariane136/config.mk clean_route
# make DESIGN_CONFIG=./designs/nangate45/ariane136/config.mk route
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/ariane136/base/5_1_grt.log   /root/TESTS/newgr_evolve_test/ariane136/GR_sproute_nangate45.log
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/ariane136/base/5_2_route.log /root/TESTS/newgr_evolve_test/ariane136/DR_sproute_nangate45.log


export GLOBAL_ROUTE_ARGS='-router NEWGR'
export PLATFORM=nangate45
export DESIGN_NAME=ariane136
export SKIP_INCREMENTAL_REPAIR=1
make DESIGN_CONFIG=./designs/nangate45/ariane136/config.mk clean_route
make DESIGN_CONFIG=./designs/nangate45/ariane136/config.mk route
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/ariane136/base/5_1_grt.log   /root/TESTS/newgr_autoevolve/GR_newgr_e.${1}.log
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/ariane136/base/5_2_route.log   /root/TESTS/newgr_autoevolve/DR_newgr_e.${1}.log
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/ariane136/base/5_1_grt.log   /root/TESTS/newgr_evolve_test/ariane136/GR_newgr_nangate45.log 
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/ariane136/base/5_2_route.log /root/TESTS/newgr_evolve_test/ariane136/DR_newgr_nangate45.log 

