# GR-Evolve: Design-Adaptive Global Routing via LLM-Driven Algorithm Evolution

<p align="center">
  <a href="https://arxiv.org/abs/2604.22234"><img src="https://img.shields.io/badge/arXiv-2604.22234-b31b1b.svg" alt="arXiv"></a>
</p>

<p align="center">
  <i>Design-Adaptive Global Routing via LLM-Driven Algorithm Evolution</i>
</p>

---

## Overview

**GR-Evolve** is a research framework that uses Large Language Models (LLMs) to automatically evolve global routing algorithms tailored to specific circuit designs. Instead of hand-crafting heuristics or training black-box ML models, GR-Evolve treats algorithm design itself as the search space: an LLM proposes algorithmic variants, candidates are evaluated on real routing benchmarks, and the population evolves toward solutions that adapt to the structural characteristics of each design.

This repository contains the official implementation of the paper:

> **GR-Evolve: Design-Adaptive Global Routing via LLM-Driven Algorithm Evolution**
> Taizun Jafri, Vidya A. Chhabria — *arXiv:2604.22234*, 2026.

For a full description of the methodology, motivation, and experimental results, please refer to the paper.


## Repository Structure

```
GR-Evolve/
├── AGENTS                # Contains AGENTS.md file for each benchmark and tech node.
│   └── *.md  
│   
├── Dockerfile            # Dockerfile to build docker image to run multiple benchmarks in parallel
├── GR_SUMMARY.md         # Global routing paper summary. 
├── OpenROAD-flow-scripts # ORFS-Suite used to run GR+DR flow
├── OpenROAD_New_GRT      # OpenROAD fork where LLM will make source code changes
├── README.md             # This file
└── SHELL_SCRIPTS         # Directory containg shell scripts for LLM to use
    └── *.md  

```


## Installation

### Prerequisites

- An API key for your preferred LLM provider (e.g., Anthropic, OpenAI)

## Setup


We use docker to create our router-design evolution. The Docker workflow runs evolution in parallel across multiple benchmarks and technology nodes, with one container per (router × design × PDK) combination.

To use docker to run multiple design-router pair evolutions in parallel, please run the [runevolve.sh](./SHELL_SCRIPTS/runevolve.sh) script using:

```bash 

bash SHELL_SCRIPTS/runevolve.sh 

``` 
This will create the 45 router-design pairs used in our experiments. 


## What the setup script does

The `runevolve.sh` script iterates over every container in the list and performs four steps automatically:

**Step 1 — Container setup** (`[DOCKER]`)
Creates the Docker container from the built image, copies the `SHELL_SCRIPTS/` directory into it, provides the `GR_SUMMARY.md` reference document, and seeds the `METRICS_TABLE.md` file used to record Quality-of-Results (QoR) metrics. It also checks out the correct source branch for the router assigned to that container (FastRoute, CUGR, or SPRoute).

**Step 2 — Codex smoke test** (`[TEST CODEX]`)
Runs a lightweight sanity check to confirm that the Codex agent inside the container has the correct write permissions. It instructs Codex to create a folder with a four-column Markdown file. If this step succeeds, the agent is ready to make source code changes.

**Step 3 — AGENTS file setup** (`[SETUP EVOLUTION]`)
Copies the correct `AGENTS.md` file from the [`AGENTS/`](AGENTS/) directory into `/root/AGENTS.md` inside the container. The file is selected automatically based on the design and PDK encoded in the container name (e.g., `fr___aes_sky130` receives `AGENTS_AES_sky130.md`). This file provides the LLM agent with design-specific context and instructions.

**Step 4 — Start evolution** (`[START EVOLUTION]`)
Launches `GeneticRunCodex.sh` in the background via `nohup`. Evolution runs are logged to `/root/evolution_start_time.log` inside each container. From this point the containers run autonomously.


## Acknowledgements

This work was conducted at the [ASU VDA Lab](https://github.com/ASU-VDA-Lab). We thank the maintainers of the open-source EDA tools and benchmark suites that made this research possible.


## Citation

If you use GR-Evolve in your research, please cite our paper:

```bibtex
@article{jafri2026gr,
  title={GR-Evolve: Design-Adaptive Global Routing via LLM-Driven Algorithm Evolution},
  author={Jafri, Taizun and Chhabria, Vidya A},
  journal={arXiv preprint arXiv:2604.22234},
  year={2026}
}
```
