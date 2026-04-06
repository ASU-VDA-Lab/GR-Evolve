cd /root/OpenROAD-flow-scripts/flow         

# unset GLOBAL_ROUTE_ARGS
# make DESIGN_CONFIG=./designs/nangate45/dynamic_node/config.mk clean_all 
# make DESIGN_CONFIG=./designs/nangate45/dynamic_node/config.mk route
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/dynamic_node/base/5_1_grt.log   /root/TESTS/newgr_evolve_test/dynamic_node/GR_fastr_nangate45.log
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/dynamic_node/base/5_2_route.log /root/TESTS/newgr_evolve_test/dynamic_node/DR_fastr_nangate45.log

# export GLOBAL_ROUTE_ARGS='-use_cugr'
# export PLATFORM=nangate45
# export SKIP_INCREMENTAL_REPAIR=1
# export DESIGN_NAME=dynamic_node_top_wrap
# make DESIGN_CONFIG=./designs/nangate45/dynamic_node/config.mk clean_route
# make DESIGN_CONFIG=./designs/nangate45/dynamic_node/config.mk route
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/dynamic_node/base/5_1_grt.log   /root/TESTS/newgr_evolve_test/dynamic_node/GR_cugr_nangate45.log
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/dynamic_node/base/5_2_route.log /root/TESTS/newgr_evolve_test/dynamic_node/DR_cugr_nangate45.log


# export GLOBAL_ROUTE_ARGS='-router sproute'
# make DESIGN_CONFIG=./designs/nangate45/dynamic_node/config.mk clean_route
# make DESIGN_CONFIG=./designs/nangate45/dynamic_node/config.mk route
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/dynamic_node/base/5_1_grt.log   /root/TESTS/newgr_evolve_test/dynamic_node/GR_sproute_nangate45.log
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/dynamic_node/base/5_2_route.log /root/TESTS/newgr_evolve_test/dynamic_node/DR_sproute_nangate45.log


export GLOBAL_ROUTE_ARGS='-router NEWGR'
export PLATFORM=nangate45
export SKIP_INCREMENTAL_REPAIR=1
export DESIGN_NAME=dynamic_node_top_wrap
make DESIGN_CONFIG=./designs/nangate45/dynamic_node/config.mk clean_route
make DESIGN_CONFIG=./designs/nangate45/dynamic_node/config.mk route
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/dynamic_node/base/5_1_grt.log   /root/TESTS/newgr_autoevolve/GR_newgr_e.${1}.log
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/dynamic_node/base/5_2_route.log   /root/TESTS/newgr_autoevolve/DR_newgr_e.${1}.log
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/dynamic_node/base/5_1_grt.log   /root/TESTS/newgr_evolve_test/dynamic_node/GR_newgr_nangate45.log 
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/dynamic_node/base/5_2_route.log /root/TESTS/newgr_evolve_test/dynamic_node/DR_newgr_nangate45.log 

