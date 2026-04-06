You must follow the flow given below: 
1. Read the [Intial Prompt](#initial-prompt-) section. You will perform the actions given in this section.
2. Once you have made changes to the codebase, you must then build the OpenROAD software using instructions given in the [Build OpenROAD](#build-openroad) section. If you get errors when building this software, you are allowed to modify code to solve the error. 
3. After you have built the software successfully, you must run the binary on a sample design using the instructions in the [Scripts](#scripts) section. 
4. After running the software, some log files will be generated. You must save certain metrics given in those log files by following instructions give in [Log Files](#log-files) section . 
5. You will now perform git tracking if the previous three steps are a success using instructions mentioned in the [Git Tracking](#git-tracking) section.

You must run the available scripts in this order when you are done making code changes : 
1. `/root/SHELL_SCRIPTS/__buildOR.sh`
2. `/root/SHELL_SCRIPTS/__copyORbinary.sh`
3. `/root/SHELL_SCRIPTS/__runEOR.sh` 

Read the git log in the `/root/OpenROAD_New_GRT` directory and read the metrics for the corresponding git log in the `/root/TESTS/METRICS_TABLE.md` file and continue from here. 
After reading the summary, you must propose and apply drastic moves that could affect wirelenght. While the main goal is reducing wirelength, your previous series of changes have not made any changes to the wirelength. So you may propose radical changes to the global router. You are allowed to mix and match source code from different global routers whose source code is provided to you, and you are allowed to come up with your own changes that radically change how the global router operates. First make a theory on why your change would work, then implement that change in the source code. **MAKE RADICAL CHANGES EVERY ITERATION**. During these changes, wirelength may increase, which is fine, as long as there is a difference in wirelength, good or bad, a change is good. 

## Initial Prompt 

You are provided a summary of various Global routers available in the OpenROAD software. Your main goal is to create a new global router called `NEWGR` under the `src/grt/src/NEWGR` folder. This new global router is supposed to improve runtime metric when compared to the included **FastRoute**/**CUGR**/**SPRoute** global routers. These global routers come with research papers that descibe the ideas behind each of these global routers and what makes them successfull in different measurement metrics. A summary of these research papers and main ideas mentioned in these papers are provided in the `/root/GR_SUMMARY.md` file. 

Overall Goal :
- Your goal is to create a new global routing algorithm that improved on the baseline metrics, especially runtime that these global routers provide. 
- You are given the creative freedom to mix and match ideas from these routers and create a global router that improves upon the wirelenght metric as the primary goal, with a secondary (less important) goal of reducing via count. 
- You may also create novel ideas based on your intution and impelment them as C/C++ source files so that we may compare your created global router against these default global routers. 

Context:
  You have access to the source code for three global routers, source code for FLUTE to create RSMTs and a technical summary document that summarizes the three global routers. 

   1. Source Code Locations:
       * FastRoute: `/root/OpenROAD_New_GRT/src/grt/src/fastroute` and `/root/OpenROAD_New_GRT/src/grt/src`
       * CUGR: `/root/OpenROAD_New_GRT/src/grt/src/cugr` and `/root/OpenROAD_New_GRT/src/grt/src`
       * SPRoute2: `/root/OpenROAD_New_GRT/src/sproute_tool`
       * FLUTE : `/root/.flute-3.1`
   2. I have created a folder called NEWGR : `/root/OpenROAD_New_GRT/src/grt/src/NEWGR` that already has the FastRoute algorithm as its base and some manual modifications performed on the algorithm 

   3. Baseline Performance Metrics: Here is the performance of the above mentioned routers on a sample design.

| Metric                   | Wirelength(um) | Via Count | Runtime (milliseconds) |
| ------------------------ | -------------- | --------- | ---------------------- |
| FastRoute 4.1 (Baseline) | 250927         | 136749    | 5376                   |
| CUGR (Baseline)          | 263197         | 146930    | 2110                   |
| SPRoute2 (Baseline)      | 260720         | 140752    | 1708                   |




<!-- You have acheived a faster runtime. Now you must focus on reducing via count/wirelength below that of FastRoute. You may take inspiration from other given global routers for this.   -->

You must now strictly focus on reducing runtime below that of SPRoute while maintaining the current Wirelength and Via Count metrics

You are allowed to modify only the contents of the `NEWGR` folder and the build files to include changes made in this folder for the new algorithm. 
This new router is selectable using the `-router NEWGR` option. 


After reading the summary of global routers, you may also propose novel ideas that are not mentioned in the summary, but ideas that you think could improve our required metrics. 

Read the codebase first to get an idea of the `NEWGR` folder and what it contains, then start implementing your own ideas. If you want, you can completely remove the contents of this folder and start from scratch if you want. 

This project will be tracked through git and code must be saved after every Iteration.

You must continue to improve the metrics until you arrive at metrics where no matter what changes you produce, you are not able to improve the metrics any further. You are allowed as many `code-change/compile/run-tests/propose-code-change` as you need to improve metrics. 

## Main Goal : 

Improve via count/wirelength using techniques from FastRoute global router, and keep runtime where it is now or even lower.

## Build OpenROAD 

To build OpenROAD software, you must use the `/root/SHELL_SCRIPTS/__buildOR.sh` script. This script changes directories to the correct folder and applies the correct commands to build OpenROAD. You must monitor the terminal output to look for compilation errors. If there are compilation errors, you must then correct those errors so that OpenROAD successfully compiles. You are given permission to make changes to allow the software to compile successfully. 

WHen you modify the code files, also take a look at the CMake files, because I did face an issue once when building this software where the CMake files were not configured correctly and hence the build did not pickup the new code changes. 

If because of some errors the build fails, correct the error and run the build script again.

## Scripts 

After the OpenROAD binary has successfully built using the `__buildOR.sh` script, you must run OpenROAD on a sample design to test for changes. To run the build software on a design, you will use the `/root/SHELL_SCRIPTS/__runEOR.sh`. This script takes in one command line argument. This argument is a number. This number is the current iteration number. This should be `1` for the first run only, and will increase to match the number of runs. One run classifies as one iteration. An iteration can change multiple files.


## Log Files 

Running the binary will generate two log files in the `/root/TESTS/newgr_autoevolve` folder. 
These log files will have prefix `GR_newgr_e.<iteration_number>_asap7.log` and `DR_newgr_e.<iteration_number>_asap7.log`. From the second log file (`DR_newgr...`) you must extract the `wirelength` and `via count` metrics. These metrics should generally be towards the end of the log file. 

You must save these metrics in the `/root/TESTS/METRICS_TABLE.md` file. This file contains a table with four columns. The first column contains `NEWGR_<iteration_number>`. This is simply what I want to name the log. The second column contains `Wirelength` and third column contains `Via Count` metric which must be extracted from the `DR_newgr_e.<iteration_number>_asap7.log` file.
The last (fourth) column contains Runtime metric which can be found in the file  `GR_newgr_e.<iteration_number>_asap7.log` . 
All of these metrics can be extracted using the script: `/root/SHELL_SCRIPTS/_find_metrics.sh <iteration_number>`. This should give you an ouput similar to : 
```bash
GR runtime   : 1256
DR Via count : 133017.
DR Wirelength: 683369
```
## Git Tracking 

A single git commit can contain multiple files that have been modified in the current iteration. All files modified in the current iteration must be added to this commit. The commit will be labelled `Iteration <iteration_number>`. You may use the commands to perform git tracking.

Commands : 
1. `git add .`
2. `git commit -m "Iteration <iteration_number>`
3. `git push`. 


## Terminate Loop 

You must look at the `/root/TESTS/METRICS_TABLE.md` file after every iteration. If you find that no matter what changes you perform to the algorithm, the metrics seem to either stay the same after 30 iterations or continue increasing after 30 iterations of code changes, you must stop making code changes and exit. 

## Shell scripts available to you : 
1. `/root/SHELL_SCRIPTS/__buildOR.sh`
2. `/root/SHELL_SCRIPTS/__copyORbinary.sh`
3. `/root/SHELL_SCRIPTS/__runEOR.sh` 
4. `/root/SHELL_SCRIPTS/_find_metrics.sh`


## File Edit Scope: 

You can modify all files within the following directories only :
1. `/root/OpenROAD_New_GRT`
2. `/root/TESTS/newgr_autoevolve` 

You can execute shell commands in any directory. 
