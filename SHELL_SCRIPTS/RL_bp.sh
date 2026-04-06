cd /root/OpenROAD-flow-scripts/flow         

# unset GLOBAL_ROUTE_ARGS
# make DESIGN_CONFIG=./designs/nangate45/black_parrot/config.mk clean_all 
# make DESIGN_CONFIG=./designs/nangate45/black_parrot/config.mk route
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/black_parrot/base/5_1_grt.log   /root/TESTS/newgr_evolve_test/black_parrot/GR_fastr_nangate45.log
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/black_parrot/base/5_2_route.log /root/TESTS/newgr_evolve_test/black_parrot/DR_fastr_nangate45.log

# export GLOBAL_ROUTE_ARGS='-use_cugr'
# export PLATFORM=nangate45
# export DESIGN_NAME=black_parrot
# export SKIP_INCREMENTAL_REPAIR=1
# make DESIGN_CONFIG=./designs/nangate45/black_parrot/config.mk clean_route
# make DESIGN_CONFIG=./designs/nangate45/black_parrot/config.mk route
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/black_parrot/base/5_1_grt.log   /root/TESTS/newgr_evolve_test/black_parrot/GR_cugr_nangate45.log
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/black_parrot/base/5_2_route.log /root/TESTS/newgr_evolve_test/black_parrot/DR_cugr_nangate45.log


# export GLOBAL_ROUTE_ARGS='-router sproute'
# make DESIGN_CONFIG=./designs/nangate45/black_parrot/config.mk clean_route
# make DESIGN_CONFIG=./designs/nangate45/black_parrot/config.mk route
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/black_parrot/base/5_1_grt.log   /root/TESTS/newgr_evolve_test/black_parrot/GR_sproute_nangate45.log
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/black_parrot/base/5_2_route.log /root/TESTS/newgr_evolve_test/black_parrot/DR_sproute_nangate45.log


export GLOBAL_ROUTE_ARGS='-router NEWGR'
export PLATFORM=nangate45
export DESIGN_NAME=black_parrot
export SKIP_INCREMENTAL_REPAIR=1
make DESIGN_CONFIG=./designs/nangate45/black_parrot/config.mk clean_route
make DESIGN_CONFIG=./designs/nangate45/black_parrot/config.mk route
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/black_parrot/base/5_1_grt.log   /root/TESTS/newgr_autoevolve/GR_newgr_e.${1}.log
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/black_parrot/base/5_2_route.log   /root/TESTS/newgr_autoevolve/DR_newgr_e.${1}.log
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/black_parrot/base/5_1_grt.log   /root/TESTS/newgr_evolve_test/black_parrot/GR_newgr_nangate45.log 
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/black_parrot/base/5_2_route.log /root/TESTS/newgr_evolve_test/black_parrot/DR_newgr_nangate45.log 

