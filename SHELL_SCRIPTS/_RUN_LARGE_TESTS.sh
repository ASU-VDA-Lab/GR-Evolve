cd /root/OpenROAD-flow-scripts/flow
# //////////////////////////////////////////////////////////////
# //                                                          //
# //                                                          //
# //      _         _                        _ _____  __      //
# //     / \   _ __(_) __ _ _ __   ___      / |___ / / /_     //
# //    / _ \ | '__| |/ _` | '_ \ / _ \_____| | |_ \| '_ \    //
# //   / ___ \| |  | | (_| | | | |  __/_____| |___) | (_) |   //
# //  /_/   \_\_|  |_|\__,_|_| |_|\___|     |_|____/ \___/    //
# //                                                          //
# //                                                          //
# //////////////////////////////////////////////////////////////
         
unset GLOBAL_ROUTE_ARGS
make DESIGN_CONFIG=./designs/asap7/ariane136/config.mk clean_all 
make DESIGN_CONFIG=./designs/asap7/ariane136/config.mk route
install -D /root/OpenROAD-flow-scripts/flow/logs/asap7/ariane136/base/5_1_grt.log   /root/TESTS/newgr_evolve_test/ariane136/GR_fastr_asap7.log
install -D /root/OpenROAD-flow-scripts/flow/logs/asap7/ariane136/base/5_2_route.log /root/TESTS/newgr_evolve_test/ariane136/DR_fastr_asap7.log

export GLOBAL_ROUTE_ARGS='-use_cugr'
export PLATFORM=asap7
export DESIGN_NAME=ariane
make DESIGN_CONFIG=./designs/asap7/ariane136/config.mk clean_route
make DESIGN_CONFIG=./designs/asap7/ariane136/config.mk route
install -D /root/OpenROAD-flow-scripts/flow/logs/asap7/ariane136/base/5_1_grt.log   /root/TESTS/newgr_evolve_test/ariane136/GR_cugr_asap7.log
install -D /root/OpenROAD-flow-scripts/flow/logs/asap7/ariane136/base/5_2_route.log /root/TESTS/newgr_evolve_test/ariane136/DR_cugr_asap7.log


export GLOBAL_ROUTE_ARGS='-router sproute'
make DESIGN_CONFIG=./designs/asap7/ariane136/config.mk clean_route
make DESIGN_CONFIG=./designs/asap7/ariane136/config.mk route
install -D /root/OpenROAD-flow-scripts/flow/logs/asap7/ariane136/base/5_1_grt.log   /root/TESTS/newgr_evolve_test/ariane136/GR_sproute_asap7.log
install -D /root/OpenROAD-flow-scripts/flow/logs/asap7/ariane136/base/5_2_route.log /root/TESTS/newgr_evolve_test/ariane136/DR_sproute_asap7.log


export GLOBAL_ROUTE_ARGS='-router NEWGR'
make DESIGN_CONFIG=./designs/asap7/ariane136/config.mk clean_route
make DESIGN_CONFIG=./designs/asap7/ariane136/config.mk route
install -D /root/OpenROAD-flow-scripts/flow/logs/asap7/ariane136/base/5_1_grt.log   /root/TESTS/newgr_evolve_test/ariane136/GR_newgr_asap7.log
install -D /root/OpenROAD-flow-scripts/flow/logs/asap7/ariane136/base/5_2_route.log /root/TESTS/newgr_evolve_test/ariane136/DR_newgr_asap7.log



# cd /home/tsjafri/TAIZUN/OpenROAD-flow-scripts/flow
# # //////////////////////////////////////////////////////////////////
# # //                                                              //
# # //                                                              //
# # //   ____  _            _      ____                      _      //
# # //  | __ )| | __ _  ___| | __ |  _ \ __ _ _ __ _ __ ___ | |_    //
# # //  |  _ \| |/ _` |/ __| |/ / | |_) / _` | '__| '__/ _ \| __|   //
# # //  | |_) | | (_| | (__|   <  |  __/ (_| | |  | | | (_) | |_    //
# # //  |____/|_|\__,_|\___|_|\_\ |_|   \__,_|_|  |_|  \___/ \__|   //
# # //                                                              //
# # //                                                              //
# # //////////////////////////////////////////////////////////////////
# #                                _       _  _  ____  
# #  _ __   __ _ _ __   __ _  __ _| |_ ___| || || ___| 
# # | '_ \ / _` | '_ \ / _` |/ _` | __/ _ \ || ||___ \ 
# # | | | | (_| | | | | (_| | (_| | ||  __/__   _|__) |
# # |_| |_|\__,_|_| |_|\__, |\__,_|\__\___|  |_||____/ ``
# #                    |___/                           
# unset GLOBAL_ROUTE_ARGS
# make DESIGN_CONFIG=./designs/nangate45/black_parrot/config.mk clean_route
# make DESIGN_CONFIG=./designs/nangate45/black_parrot/config.mk 
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/bp/base/5_1_grt.log   /root/TESTS/newgr_evolve_test/bp/GR_fastr_nangate45.log
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/bp/base/5_2_route.log /root/TESTS/newgr_evolve_test/bp/DR_fastr_nangate45.log
# # install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/bp/base/5_1_grt.log   /home/tsjafri/TAIZUN/TESTS/GR_fastr_BP_Iter134.log
# # install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/bp/base/5_2_route.log /home/tsjafri/TAIZUN/TESTS/DR_fastr_BP_Iter134.log


# export GLOBAL_ROUTE_ARGS='-use_cugr'
# make DESIGN_CONFIG=./designs/nangate45/black_parrot/config.mk clean_route
# make DESIGN_CONFIG=./designs/nangate45/black_parrot/config.mk route
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/bp/base/5_1_grt.log   /root/TESTS/newgr_evolve_test/bp/GR_cugr_nangate45.log
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/bp/base/5_2_route.log /root/TESTS/newgr_evolve_test/bp/DR_cugr_nangate45.log


# export GLOBAL_ROUTE_ARGS='-router sproute'
# make DESIGN_CONFIG=./designs/nangate45/black_parrot/config.mk clean_route
# make DESIGN_CONFIG=./designs/nangate45/black_parrot/config.mk route
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/bp/base/5_1_grt.log   /root/TESTS/newgr_evolve_test/bp/GR_sproute_nangate45_1.log
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/bp/base/5_2_route.log /root/TESTS/newgr_evolve_test/bp/DR_sproute_nangate45.log


# export GLOBAL_ROUTE_ARGS='-router NEWGR'
# make DESIGN_CONFIG=./designs/nangate45/black_parrot/config.mk clean_route
# make DESIGN_CONFIG=./designs/nangate45/black_parrot/config.mk route
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/bp/base/5_1_grt.log   /root/TESTS/newgr_evolve_test/bp/GR_newgr_nangate45_1.log
# install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/bp/base/5_2_route.log /root/TESTS/newgr_evolve_test/bp/DR_newgr_nangate45.log
# # install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/bp/base/5_1_grt.log   /home/tsjafri/TAIZUN/TESTS/GR_newgr_BP_Iter134.log
# # install -D /root/OpenROAD-flow-scripts/flow/logs/nangate45/bp/base/5_2_route.log /home/tsjafri/TAIZUN/TESTS/DR_newgr_BP_Iter134.log

