cd /root/OpenROAD_New_GRT
git branch
sleep 2

# Build SPRoute Galois prerequisites.
cmake -S /root/OpenROAD_New_GRT/src/sproute_tool/Galois \
      -B /root/OpenROAD_New_GRT/src/sproute_tool/Galois/build \
      -DCMAKE_POSITION_INDEPENDENT_CODE=ON
cmake --build /root/OpenROAD_New_GRT/src/sproute_tool/Galois/build -j

./etc/Build.sh -no-gui 
