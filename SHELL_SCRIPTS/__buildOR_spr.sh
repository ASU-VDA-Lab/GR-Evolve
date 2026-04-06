git branch
sleep 2

# Build SPRoute Galois prerequisites.
cd /root/OpenROAD_New_GRT
cmake -S /root/OpenROAD_New_GRT/src/sproute_tool/Galois \
      -B /root/OpenROAD_New_GRT/src/sproute_tool/Galois/build \
      -DCMAKE_POSITION_INDEPENDENT_CODE=ON
cmake --build /root/OpenROAD_New_GRT/src/sproute_tool/Galois/build -j
./etc/Build.sh -no-gui


# Build NEWGR-local Galois prerequisites (separate tree from SPRoute).
cmake -S /root/OpenROAD_New_GRT/src/grt/src/NEWGR/Galois \
      -B /root/OpenROAD_New_GRT/src/grt/src/NEWGR/Galois/build \
      -DCMAKE_POSITION_INDEPENDENT_CODE=ON
cmake --build /root/OpenROAD_New_GRT/src/grt/src/NEWGR/Galois/build -j

./etc/Build.sh -no-gui
