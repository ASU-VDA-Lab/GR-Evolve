cd /root/OpenROAD-flow-scripts/flow

unset GLOBAL_ROUTE_ARGS
export SKIP_INCREMENTAL_REPAIR=1
make DESIGN_CONFIG=./designs/nangate45/aes/config.mk clean_all
make DESIGN_CONFIG=./designs/nangate45/aes/config.mk finish
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/aes/base/5_1_grt.log        /root/TESTS/newgr_evolve_test/aes/GR_fastr_nangate45.log
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/aes/base/5_1_grt.json       /root/TESTS/newgr_evolve_test/aes/GR_fastr_nangate45.json
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/aes/base/5_2_route.log      /root/TESTS/newgr_evolve_test/aes/DR_fastr_nangate45.log
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/aes/base/6_report.json      /root/TESTS/newgr_evolve_test/aes/GR_fastr_nangate45_rpt.json
install -D /root/OpenROAD-flow-scripts/flow/reports/nangate45/aes/base/5_route_drc.rpt /root/TESTS/newgr_evolve_test/aes/DR_fastr_drc.json

export GLOBAL_ROUTE_ARGS='-use_cugr'
export SKIP_INCREMENTAL_REPAIR=1
make DESIGN_CONFIG=./designs/nangate45/aes/config.mk clean_route
make DESIGN_CONFIG=./designs/nangate45/aes/config.mk finish
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/aes/base/5_1_grt.log        /root/TESTS/newgr_evolve_test/aes/GR_cugr_nangate45.log
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/aes/base/5_1_grt.json       /root/TESTS/newgr_evolve_test/aes/GR_cugr_nangate45.json
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/aes/base/5_2_route.log      /root/TESTS/newgr_evolve_test/aes/DR_cugr_nangate45.log
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/aes/base/6_report.json      /root/TESTS/newgr_evolve_test/aes/GR_cugr_nangate45_rpt.json
install -D /root/OpenROAD-flow-scripts/flow/reports/nangate45/aes/base/5_route_drc.rpt /root/TESTS/newgr_evolve_test/aes/DR_cugr_drc.json

export GLOBAL_ROUTE_ARGS='-router sproute'
export SKIP_INCREMENTAL_REPAIR=1
make DESIGN_CONFIG=./designs/nangate45/aes/config.mk clean_route
make DESIGN_CONFIG=./designs/nangate45/aes/config.mk finish
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/aes/base/5_1_grt.log        /root/TESTS/newgr_evolve_test/aes/GR_sproute_nangate45.log
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/aes/base/5_1_grt.json       /root/TESTS/newgr_evolve_test/aes/GR_sproute_nangate45.json
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/aes/base/5_2_route.log      /root/TESTS/newgr_evolve_test/aes/DR_sproute_nangate45.log
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/aes/base/6_report.json      /root/TESTS/newgr_evolve_test/aes/GR_sproute_nangate45_rpt.json
install -D /root/OpenROAD-flow-scripts/flow/reports/nangate45/aes/base/5_route_drc.rpt /root/TESTS/newgr_evolve_test/aes/DR_sproute_drc.json

export GLOBAL_ROUTE_ARGS='-router NEWGR'
export SKIP_INCREMENTAL_REPAIR=1
make DESIGN_CONFIG=./designs/nangate45/aes/config.mk clean_route
make DESIGN_CONFIG=./designs/nangate45/aes/config.mk finish
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/aes/base/5_1_grt.log        /root/TESTS/newgr_evolve_test/aes/GR_newgr_nangate45.log
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/aes/base/5_1_grt.json       /root/TESTS/newgr_evolve_test/aes/GR_newgr_nangate45.json
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/aes/base/5_2_route.log      /root/TESTS/newgr_evolve_test/aes/DR_newgr_nangate45.log
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/aes/base/6_report.json      /root/TESTS/newgr_evolve_test/aes/GR_newgr_nangate45_rpt.json
install -D /root/OpenROAD-flow-scripts/flow/reports/nangate45/aes/base/5_route_drc.rpt /root/TESTS/newgr_evolve_test/aes/DR_newgr_drc.json


cd /root/OpenROAD-flow-scripts/flow
# # # ////////////////////////////////////////////////////////////////
# # # //                                                            //
# # # //                                                            //
# # # //                     ___ ____  _______  __                  //
# # # //                    |_ _| __ )| ____\ \/ /                  //
# # # //                     | ||  _ \|  _|  \  /                   //
# # # //                     | || |_) | |___ /  \                   //
# # # //                    |___|____/|_____/_/\_\                  //
# # # //                                                            //
# # # //                                                            //
# # # ////////////////////////////////////////////////////////////////
# #      _          _ _____  ___  _         _ 
# #  ___| | ___   _/ |___ / / _ \| |__   __| |
# # / __| |/ / | | | | |_ \| | | | '_ \ / _` |
# # \__ \   <| |_| | |___) | |_| | | | | (_| |
# # |___/_|\_\\__, |_|____/ \___/|_| |_|\__,_|
# #           |___/   
unset GLOBAL_ROUTE_ARGS                        
export SKIP_INCREMENTAL_REPAIR=1
make DESIGN_CONFIG=./designs/nangate45/ibex/config.mk clean_all
make DESIGN_CONFIG=./designs/nangate45/ibex/config.mk finish
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/ibex/base/5_1_grt.log        /root/TESTS/newgr_evolve_test/ibex/GR_fastr_nangate45.log
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/ibex/base/5_1_grt.json       /root/TESTS/newgr_evolve_test/ibex/GR_fastr_nangate45.json
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/ibex/base/5_2_route.log      /root/TESTS/newgr_evolve_test/ibex/DR_fastr_nangate45.log
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/ibex/base/6_report.json      /root/TESTS/newgr_evolve_test/ibex/GR_fastr_nangate45_rpt.json
install -D /root/OpenROAD-flow-scripts/flow/reports/nangate45/ibex/base/5_route_drc.rpt /root/TESTS/newgr_evolve_test/ibex/DR_fastr_drc.json

export GLOBAL_ROUTE_ARGS='-use_cugr'
export SKIP_INCREMENTAL_REPAIR=1
make DESIGN_CONFIG=./designs/nangate45/ibex/config.mk clean_route
make DESIGN_CONFIG=./designs/nangate45/ibex/config.mk finish
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/ibex/base/5_1_grt.log        /root/TESTS/newgr_evolve_test/ibex/GR_cugr_nangate45.log
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/ibex/base/5_1_grt.json       /root/TESTS/newgr_evolve_test/ibex/GR_cugr_nangate45.json
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/ibex/base/5_2_route.log      /root/TESTS/newgr_evolve_test/ibex/DR_cugr_nangate45.log
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/ibex/base/6_report.json      /root/TESTS/newgr_evolve_test/ibex/GR_cugr_nangate45_rpt.json
install -D /root/OpenROAD-flow-scripts/flow/reports/nangate45/ibex/base/5_route_drc.rpt /root/TESTS/newgr_evolve_test/ibex/DR_cugr_drc.json

export GLOBAL_ROUTE_ARGS='-router sproute'
export SKIP_INCREMENTAL_REPAIR=1
make DESIGN_CONFIG=./designs/nangate45/ibex/config.mk clean_route
make DESIGN_CONFIG=./designs/nangate45/ibex/config.mk finish
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/ibex/base/5_1_grt.log        /root/TESTS/newgr_evolve_test/ibex/GR_sproute_nangate45.log
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/ibex/base/5_1_grt.json       /root/TESTS/newgr_evolve_test/ibex/GR_sproute_nangate45.json
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/ibex/base/5_2_route.log      /root/TESTS/newgr_evolve_test/ibex/DR_sproute_nangate45.log
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/ibex/base/6_report.json      /root/TESTS/newgr_evolve_test/ibex/GR_sproute_nangate45_rpt.json
install -D /root/OpenROAD-flow-scripts/flow/reports/nangate45/ibex/base/5_route_drc.rpt /root/TESTS/newgr_evolve_test/ibex/DR_sproute_drc.json

export GLOBAL_ROUTE_ARGS='-router NEWGR'
export SKIP_INCREMENTAL_REPAIR=1
make DESIGN_CONFIG=./designs/nangate45/ibex/config.mk clean_route
make DESIGN_CONFIG=./designs/nangate45/ibex/config.mk finish
install -D  /root/OpenROAD-flow-scripts/flow/logs/nangate45/ibex/base/5_1_grt.log       /root/TESTS/newgr_evolve_test/ibex/GR_newgr_nangate45.log
install -D  /root/OpenROAD-flow-scripts/flow/logs/nangate45/ibex/base/5_1_grt.json      /root/TESTS/newgr_evolve_test/ibex/GR_newgr_nangate45.json
install -D  /root/OpenROAD-flow-scripts/flow/logs/nangate45/ibex/base/5_2_route.log     /root/TESTS/newgr_evolve_test/ibex/DR_newgr_nangate45.log
install -D  /root/OpenROAD-flow-scripts/flow/logs/nangate45/ibex/base/6_report.json     /root/TESTS/newgr_evolve_test/ibex/GR_newgr_nangate45_rpt.json
install -D /root/OpenROAD-flow-scripts/flow/reports/nangate45/ibex/base/5_route_drc.rpt /root/TESTS/newgr_evolve_test/ibex/DR_newgr_drc.json

# export GLOBAL_ROUTE_ARGS='-router NEWGR'
# export SKIP_INCREMENTAL_REPAIR=1
# make DESIGN_CONFIG=./designs/nangate45/ibex/config.mk clean_route
# make DESIGN_CONFIG=./designs/nangate45/ibex/config.mk finish
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/ibex/base/5_1_grt.log        /root/TESTS/newgr_autoevolve/GR_newgr_e.${1}_nangate45.log
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/ibex/base/5_2_route.log      /root/TESTS/newgr_autoevolve/DR_newgr_e.${1}_nangate45.log

# cd /root/OpenROAD-flow-scripts/flow
# # //////////////////////////////////////////////////////////////////
# # //                                                              //
# # //                                                              //
# # //                         _ ____  _____ ____                   //
# # //                        | |  _ \| ____/ ___|                  //
# # //                     _  | | |_) |  _|| |  _                   //
# # //                    | |_| |  __/| |__| |_| |                  //
# # //                     \___/|_|   |_____\____|                  //
# # //                                                              //
# # //                                                              //
# # //////////////////////////////////////////////////////////////////
# #      _          _ _____  ___  _         _ 
# #  ___| | ___   _/ |___ / / _ \| |__   __| |
# # / __| |/ / | | | | |_ \| | | | '_ \ / _` |
# # \__ \   <| |_| | |___) | |_| | | | | (_| |
# # |___/_|\_\\__, |_|____/ \___/|_| |_|\__,_|
# #           |___/                           
unset GLOBAL_ROUTE_ARGS
export SKIP_INCREMENTAL_REPAIR=1
make DESIGN_CONFIG=./designs/nangate45/jpeg/config.mk clean_all
make DESIGN_CONFIG=./designs/nangate45/jpeg/config.mk finish
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/jpeg/base/5_1_grt.log        /root/TESTS/newgr_evolve_test/jpeg/GR_fastr_nangate45.log
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/jpeg/base/5_1_grt.json       /root/TESTS/newgr_evolve_test/jpeg/GR_fastr_nangate45.json
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/jpeg/base/5_2_route.log      /root/TESTS/newgr_evolve_test/jpeg/DR_fastr_nangate45.log
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/jpeg/base/6_report.json      /root/TESTS/newgr_evolve_test/jpeg/GR_fastr_nangate45_rpt.json
install -D /root/OpenROAD-flow-scripts/flow/reports/nangate45/jpeg/base/5_route_drc.rpt /root/TESTS/newgr_evolve_test/jpeg/DR_fastr_drc.json

export GLOBAL_ROUTE_ARGS='-use_cugr'
export SKIP_INCREMENTAL_REPAIR=1
make DESIGN_CONFIG=./designs/nangate45/jpeg/config.mk clean_route
make DESIGN_CONFIG=./designs/nangate45/jpeg/config.mk finish
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/jpeg/base/5_1_grt.log        /root/TESTS/newgr_evolve_test/jpeg/GR_cugr_nangate45.log
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/jpeg/base/5_1_grt.json       /root/TESTS/newgr_evolve_test/jpeg/GR_cugr_nangate45.json
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/jpeg/base/5_2_route.log      /root/TESTS/newgr_evolve_test/jpeg/DR_cugr_nangate45.log
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/jpeg/base/6_report.json      /root/TESTS/newgr_evolve_test/jpeg/GR_cugr_nangate45_rpt.json
install -D /root/OpenROAD-flow-scripts/flow/reports/nangate45/jpeg/base/5_route_drc.rpt /root/TESTS/newgr_evolve_test/jpeg/DR_cugr_drc.json

export GLOBAL_ROUTE_ARGS='-router sproute'
export SKIP_INCREMENTAL_REPAIR=1
make DESIGN_CONFIG=./designs/nangate45/jpeg/config.mk clean_route
make DESIGN_CONFIG=./designs/nangate45/jpeg/config.mk finish
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/jpeg/base/5_1_grt.log        /root/TESTS/newgr_evolve_test/jpeg/GR_sproute_nangate45.log
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/jpeg/base/5_1_grt.json       /root/TESTS/newgr_evolve_test/jpeg/GR_sproute_nangate45.json
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/jpeg/base/5_2_route.log      /root/TESTS/newgr_evolve_test/jpeg/DR_sproute_nangate45.log
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/jpeg/base/6_report.json      /root/TESTS/newgr_evolve_test/jpeg/GR_sproute_nangate45_rpt.json
install -D /root/OpenROAD-flow-scripts/flow/reports/nangate45/jpeg/base/5_route_drc.rpt /root/TESTS/newgr_evolve_test/jpeg/DR_sproute_drc.json

export GLOBAL_ROUTE_ARGS='-router NEWGR'
export SKIP_INCREMENTAL_REPAIR=1
make DESIGN_CONFIG=./designs/nangate45/jpeg/config.mk clean_route
make DESIGN_CONFIG=./designs/nangate45/jpeg/config.mk finish
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/jpeg/base/5_1_grt.log         /root/TESTS/newgr_evolve_test/jpeg/GR_newgr_nangate45.log
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/jpeg/base/5_1_grt.json       /root/TESTS/newgr_evolve_test/jpeg/GR_newgr_nangate45.json
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/jpeg/base/5_2_route.log      /root/TESTS/newgr_evolve_test/jpeg/DR_newgr_nangate45.log
install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/jpeg/base/6_report.json      /root/TESTS/newgr_evolve_test/jpeg/GR_newgr_nangate45_rpt.json
install -D /root/OpenROAD-flow-scripts/flow/reports/nangate45/jpeg/base/5_route_drc.rpt /root/TESTS/newgr_evolve_test/jpeg/DR_newgr_drc.json
# 

export GLOBAL_ROUTE_ARGS='-router sproute'
export PLATFORM=asap7
export SKIP_INCREMENTAL_REPAIR=1
export DESIGN_NAME=swerv
make DESIGN_CONFIG=./designs/nangate45/jpeg/config.mk clean_route
make DESIGN_CONFIG=./designs/nangate45/jpeg/config.mk finish
install -D /root/OpenROAD-flow-scripts/flow/logs/asap7/swerv/base/5_1_grt.log        /root/TESTS/newgr_evolve_test/swerv/GR_newgr_asap7.log
install -D /root/OpenROAD-flow-scripts/flow/logs/asap7/swerv/base/5_1_grt.json       /root/TESTS/newgr_evolve_test/swerv/GR_newgr_asap7.json
install -D /root/OpenROAD-flow-scripts/flow/logs/asap7/swerv/base/5_2_route.log      /root/TESTS/newgr_evolve_test/swerv/DR_newgr_asap7.log
install -D /root/OpenROAD-flow-scripts/flow/logs/asap7/swerv/base/6_report.json      /root/TESTS/newgr_evolve_test/swerv/GR_newgr_asap7_rpt.json
install -D /root/OpenROAD-flow-scripts/flow/reports/asap7/swerv/base/5_route_drc.rpt /root/TESTS/newgr_evolve_test/swerv/DR_newgr_drc.json
