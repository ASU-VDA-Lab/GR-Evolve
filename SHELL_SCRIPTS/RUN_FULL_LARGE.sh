cd /root/OpenROAD-flow-scripts/flow         

# unset GLOBAL_ROUTE_ARGS
# make DESIGN_CONFIG=./designs/nangate45/dynamic_node/config.mk clean_route
# make DESIGN_CONFIG=./designs/nangate45/dynamic_node/config.mk route
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/dynamic_node/base/5_1_grt.log        /root/TESTS/newgr_evolve_test/dynamic_node/GR_fastr_nangate45.log
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/dynamic_node/base/5_1_grt.json       /root/TESTS/newgr_evolve_test/dynamic_node/GR_fastr_nangate45.json
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/dynamic_node/base/5_2_route.log      /root/TESTS/newgr_evolve_test/dynamic_node/DR_fastr_nangate45.log
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/dynamic_node/base/6_report.json      /root/TESTS/newgr_evolve_test/dynamic_node/GR_fastr_nangate45_rpt.json
# install -D /root/OpenROAD-flow-scripts/flow/reports/nangate45/dynamic_node/base/5_route_drc.rpt /root/TESTS/newgr_evolve_test/dynamic_node/DR_fastr_drc.json


# export GLOBAL_ROUTE_ARGS='-use_cugr'
# export PLATFORM=nangate45
# export SKIP_INCREMENTAL_REPAIR=1
# export DESIGN_NAME=dynamic_node
# make DESIGN_CONFIG=./designs/nangate45/dynamic_node/config.mk clean_route
# make DESIGN_CONFIG=./designs/nangate45/dynamic_node/config.mk route
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/dynamic_node/base/5_1_grt.log        /root/TESTS/newgr_evolve_test/dynamic_node/GR_cugr_nangate45.log
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/dynamic_node/base/5_1_grt.json       /root/TESTS/newgr_evolve_test/dynamic_node/GR_cugr_nangate45.json
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/dynamic_node/base/5_2_route.log      /root/TESTS/newgr_evolve_test/dynamic_node/DR_cugr_nangate45.log
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/dynamic_node/base/6_report.json      /root/TESTS/newgr_evolve_test/dynamic_node/GR_cugr_nangate45_rpt.json
# install -D /root/OpenROAD-flow-scripts/flow/reports/nangate45/dynamic_node/base/5_route_drc.rpt /root/TESTS/newgr_evolve_test/dynamic_node/DR_cugr_drc.json


# export GLOBAL_ROUTE_ARGS='-router sproute'
# make DESIGN_CONFIG=./designs/nangate45/dynamic_node/config.mk clean_route
# make DESIGN_CONFIG=./designs/nangate45/dynamic_node/config.mk route
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/dynamic_node/base/5_1_grt.log        /root/TESTS/newgr_evolve_test/dynamic_node/GR_sproute_nangate45.log
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/dynamic_node/base/5_1_grt.json       /root/TESTS/newgr_evolve_test/dynamic_node/GR_sproute_nangate45.json
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/dynamic_node/base/5_2_route.log      /root/TESTS/newgr_evolve_test/dynamic_node/DR_sproute_nangate45.log
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/dynamic_node/base/6_report.json      /root/TESTS/newgr_evolve_test/dynamic_node/GR_sproute_nangate45_rpt.json
# install -D /root/OpenROAD-flow-scripts/flow/reports/nangate45/dynamic_node/base/5_route_drc.rpt /root/TESTS/newgr_evolve_test/dynamic_node/DR_sproute_drc.json



export GLOBAL_ROUTE_ARGS='-router NEWGR'
export PLATFORM=asap7
export SKIP_INCREMENTAL_REPAIR=1
export DESIGN_NAME=swerv
make DESIGN_CONFIG=./designs/asap7/swerv/config.mk clean_route
make DESIGN_CONFIG=./designs/asap7/swerv/config.mk route
install -D /root/OpenROAD-flow-scripts/flow/logs/asap7/swerv/base/5_1_grt.log        /root/TESTS/newgr_evolve_test/swerv/GR_newgr_asap7.log
install -D /root/OpenROAD-flow-scripts/flow/logs/asap7/swerv/base/5_1_grt.json       /root/TESTS/newgr_evolve_test/swerv/GR_newgr_asap7.json
install -D /root/OpenROAD-flow-scripts/flow/logs/asap7/swerv/base/5_2_route.log      /root/TESTS/newgr_evolve_test/swerv/DR_newgr_asap7.log
install -D /root/OpenROAD-flow-scripts/flow/logs/asap7/swerv/base/6_report.json      /root/TESTS/newgr_evolve_test/swerv/GR_newgr_asap7_rpt.json
install -D /root/OpenROAD-flow-scripts/flow/reports/asap7/swerv/base/5_route_drc.rpt /root/TESTS/newgr_evolve_test/swerv/DR_newgr_drc.json
