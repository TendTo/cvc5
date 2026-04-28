# dlinear Artifact (Docker-based)

## Table of Contents

- [Requirements](#requirements)
- [At a glance](#at-a-glance)
- [Configurations](#configurations)
- [Experiments](#experiments)
  - [Smoke](#smoke)
  - [Run](#run)
  - [Explore](#explore)
  - [Binary](#binary)
- [Troubleshooting](#troubleshooting)

This folder contains the **required artifact materials** for an AE review:

```bash
artifact/
├── README.md # This file
├── LICENCE   # License file for the artifact
├── qest-formats-ae-image.tar.gz # Self-contained Docker image archive
├── clean.sh     # Script to remove all generated results
├── run.sh       # Script to run the smoke test and benchmark suites
├── explore.sh   # Script to explore the results from the paper
├── binary.sh    # Script to run the binaries directly
├── instances/   # CSV files listing benchmark instances for different suites
└── results/     # CSV files with results from the paper's experiments
```

The source code is available on the project's [GitHub repository](https://github.com/TendTo/cvc5).

## Requirements

To run the experiments, reviewers will need:

- Docker (tested with Docker version 29.3.0)
- ~10 GB of free disk space for the image and results (depends on compression)
- Linux is recommended for best compatibility, but Windows and macOS should also work with Docker.

The full setup **has been tested on Linux** but should work on any platform that supports Docker (e.g., Windows, macOS).
All scripts are provided in bash (`.sh`), PowerShell (`.ps1`), and cmd (`.bat`) formats for compatibility with different operating systems.

## At a glance

Run the command corresponding to the desired mode of evaluation.
Each command is described in more detail in the [Experiments](#experiments) section.

| Mode                    | Command                              | What it does                                                                                                                                                                                                           | Expected result                                                                                      | Time estimate                                                                                                        |
| ----------------------- | ------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| [**Smoke**](#smoke)     | `./run.sh`                           | Runs a single benchmark instance with every configuration.                                                                                                                                                             | Writes CSV files to `results-smoke/`, then launches the `results-run.ipynb` notebook.                | Less than a minute.                                                                                                  |
| [**Run**](#run)         | `./run.sh [suite] [limit] [timeout]` | Runs `[limit]` benchmark instances from `instances/[suite].csv`, each taking at most `[timeout]` seconds using all supported configurations.<br>By default, `[suite] = smoke`, `[limit] = 6`, and `[timeout] = 21000`. | Writes CSV files to `results-[suite]/`, then launches the `results-run.ipynb` notebook.              | A few seconds to minutes. May take significantly longer if `[limit]` is increased or a harder `[suite]` is selected. |
| [**Explore**](#explore) | `./explore.sh`                       | Opens the precomputed results presented in the paper.                                                                                                                                                                  | Launches the `results-explore.ipynb` notebook, which contains the figures and tables from the paper. | Less than a minute.                                                                                                  |
| [**Binary**](#binary)   | `./binary.sh [...]`                  | Calls the `cvc5/dlinear` binary directly.                                                                                                                                                                              | Runs the solver with the given options.                                                              | Depends on solver configuration and problem.                                                                         |

By default, **only 6 fast benchmarks are run for each suite**, so each experiment should complete within a **few seconds or minutes**, depending on the configuration and machine performance.
The evaluator is free to change this number and **run all 1753 benchmarks**, but note that this may take **several hours or even days** to complete.

## Configurations

By default, each benchmark instance is evaluated using the configurations below, for a total of 31 possible combinations.
Depending on the selected benchmark suite, some configurations may be skipped to save time and show only the most relevant results, matching those presented in the paper.
The cvc5 baseline is always included.
If you want complete control over the configuration of the solver, see the [Binary](#binary) section below.

| Solver              | External LP solver | Pivot thresholds | Modes                   | Included in benchmarks from |
| ------------------- | ------------------ | ---------------- | ----------------------- | --------------------------- |
| **cvc5** (baseline) | N/A                | N/A              | N/A                     | SMT-LIB, Sloane–Stufken     |
| **cvc5+GLPK**       | GLPK               | 100, 200, 300    | N/A                     | SMT-LIB                     |
| **dlinear**         | SoPlex             | 100, 200, 300    | $\varepsilon$, $t$      | SMT-LIB                     |
| **dlinear**         | qsoptex            | 100, 200, 300    | $\varepsilon$, $t$      | SMT-LIB                     |
| **cvc5+GLPK**       | GLPK               | 0                | N/A                     | Sloane–Stufken              |
| **dlinear**         | SoPlex             | 0                | $\varepsilon$           | Sloane–Stufken              |
| **dlinear**         | qsoptex            | 0                | $\varepsilon$, $\delta$ | Sloane–Stufken              |

See _Sections 4.2_ and _Section 5_ of the paper for more details on modes $\varepsilon$, $t$, and $\delta$.

## Experiments

All scripts in this artifact are bash scripts (`.sh`).
Equivalent PowerShell (`.ps1`) and cmd (`.bat`) scripts are also provided for Windows users.  
If you are on Linux and see a permission error, run it as `bash <scriptname>.sh`.

### Smoke

The smoke test is a quick sanity check that runs a single benchmark instance with all configurations, to verify that the image is functional and the expected outputs are produced.

```bash
./run.sh
```

#### Expected result

On the first run, the script will load the Docker image from `qest-formats-ae-image.tar.gz` (if it is not already present locally).
It will then launch a container and solve one benchmark with all configurations.

The output should include messages like the following while each configuration is executed:

```text
[artifact] Running smoke test
[artifact] Using benchmark listed in /instances/smoke.csv
[artifact] Running smoke test
...
[artifact] Running cvc5 baseline
[artifact] Running cvc5
Local mode: running first 1 benchmarks
Reading file /benchmarks/constraints-tms-2-3-light-40.smt2
Read 1 lines
Storing 1 lines, failed to parse 0 lines
[artifact] Running glpk
[artifact] Running glpk with 100 iterations
Local mode: running first 1 benchmarks
Reading file /benchmarks/constraints-tms-2-3-light-40.smt2
Read 1 lines
Storing 1 lines, failed to parse 0 lines
...
Read 1 lines
Storing 1 lines, failed to parse 0 lines
[artifact] Running qsoptex with 300 iterations and mode delta
Local mode: running first 1 benchmarks
Reading file /benchmarks/constraints-tms-2-3-light-40.smt2
Read 1 lines
Storing 1 lines, failed to parse 0 lines
[artifact] Smoke test complete.
```

After the run completes, the script launches a notebook server inside the container to visualize the results.

To access the GUI in your browser, look for a line like:

```bash
[artifact] Running the Jupyter notebook to produce the plots and tables
[NbConvertApp] Converting notebook results-run.ipynb to notebook
[NbConvertApp] Writing 182629 bytes to results-run.ipynb
[artifact] Launching the Jupyter notebook to visualize the results
[artifact] Jupyter notebook is running at http://localhost:8888/notebooks/results-run.ipynb # <-- Go to this URL in your browser
[artifact] Alternative URLs: http://127.0.0.1:8888/notebooks/results-run.ipynb or http://0.0.0.0:8888/notebooks/results-run.ipynb
[artifact] Press Ctrl+C two times in quick succession to stop the Jupyter notebook when finished.
```

Click (or copy-paste) the URL to open the notebook interface in your browser, where you can explore the results of the smoke test.

### Run

By default, `run.sh` runs the smoke test suite named `smoke`.
You can run a different benchmark suite by passing the suite name `[suite]` as the first script argument.
Supported options are:

| Suite name         | Total number of instances | Description                                                                                        |
| ------------------ | ------------------------- | -------------------------------------------------------------------------------------------------- |
| **smoke**          | 1                         | A single instance for a quick test.                                                                |
| **100_instances**  | 319                       | Instances that trigger at least one external LP call when the pivot threshold $n = 100$.           |
| **200_instances**  | 177                       | Instances that trigger at least one external LP call when the pivot threshold $n = 200$.           |
| **300_instances**  | 125                       | Instances that trigger at least one external LP call when the pivot threshold $n = 300$.           |
| **latendresse**    | 18                        | Benchmarks from biological modeling.                                                               |
| **miplib**         | 42                        | Adapted from the MIPLIB linear programming benchmarks.                                             |
| **dtp-scheduling** | 91                        | Disjunctive Temporal Problems.                                                                     |
| **all_instances**  | 1753                      | The full set of 1753 QF_LRA instances from the SMT-LIB release 2025 of non-incremental benchmarks. |
| **sk_instances**   | 71                        | Sloane–Stufken benchmarks.                                                                         |

The run script loads the specified CSV file (i.e., `instances/[suite].csv`) and runs all listed benchmarks across all supported [configurations](#configurations).

By default, the script executes **only the first 6 instances** per configuration, but you can change this limit by passing a second argument `[limit]` to the script.
While it is possible to **run all 1753 benchmarks**, the process may take **several hours or even days** to complete.

Results are written to `results-[suite]/` in this folder, and the notebook server is launched afterward.
Open the link provided in the terminal to access the notebook interface in your browser, where you can explore the results of the run.

```bash
./run.sh [benchmark suite name, default: smoke] [number of instances to run, default: 6] [timeout per instance in seconds, default: 21000]
```

#### Example

```bash
./run.sh latendresse 3 60
```

will run the first three instances from `instances/latendresse.csv`, each with a 60-second timeout, and write the resulting data to `results-latendresse/`.

#### Custom suite

It is possible to edit `instances/custom.csv` to define your own list of benchmarks.
The file must start with the header `file`, and every following row must name a `.smt2` benchmark.
Only [QF_LRA](https://smt-lib.org/logics-all.shtml#QF_LRA) benchmarks from the [SMT-LIB release 2025 of non-incremental benchmarks](https://zenodo.org/records/16740866) and Sloane–Stufken benchmarks are included.
A [Docker volume](https://docs.docker.com/storage/volumes/) can be used to run external benchmarks.

##### Example

Fill `instances/custom.csv` with the following content:

```csv
file
my_benchmark_1_from_smtlib.smt2
my_benchmark_2_from_smtlib.smt2
```

Then run:

```bash
./run.sh custom 2
```

### Explore

All results from the **Benchmark** section of the paper are included in the artifact as CSV files (see `results/`).
To explore these results, run the `explore.sh` script:

```bash
./explore.sh
```

This will open the notebook interface in your browser.
Open the `results-explore.ipynb` notebook to view the analysis.
You can also modify the notebook to perform your own analysis on the results, or to visualize different metrics, and re-run the cells to see the updated plots.

#### Results from the paper

The notebook recreates the benchmark figures and tables from the paper.

- **Section 2.5** of the notebook contains **Table 1** of the paper
- **Section 2.6** of the notebook contains **Table 2** and **Table 7** of the paper
- **Section 3.1** of the notebook contains **Figure 2** and **Table 3** of the paper
- **Section 3.2** of the notebook contains **Figure 3**, **Figure 5**, and **Figure 6** of the paper
- **Section 3.3** of the notebook contains **Table 8**, **Table 9**, and **Table 10** of the paper

### Binary

To achieve maximum flexibility, the `binary.sh` script interfaces directly with the `cvc5/dlinear` binary inside the Docker container, allowing you to run custom commands on any benchmark instance.

```bash
# Get all the available options from cvc5/dlinear
./binary.sh --help
```

#### Examples

```bash
# Run dlinear with soplex, 100 pivots threshold, strict mode, and a 10s time limit
./binary.sh --use-approx --external-lp-solver=soplex --standard-effort-variable-order-pivots=100 --lp-strict-var --tlimit-per=10000 --stats-all --stats-internal /benchmarks/constraints-tms-2-3-light-40.smt2
```

```bash
# Run dlinear with qsoptex, 200 pivots threshold, epsilon mode, and a 10s time limit
./binary.sh --use-approx --external-lp-solver=qsoptex --standard-effort-variable-order-pivots=200 --no-lp-strict-var --tlimit-per=10000 --stats-all --stats-internal /benchmarks/constraints-tms-2-3-light-40.smt2
```

```bash
# Run cvc5 with glpk, 150 pivots threshold, strict mode, and a 10s time limit
./binary.sh --use-approx --external-lp-solver=glpk --standard-effort-variable-order-pivots=150 --tlimit-per=10000 --stats-all --stats-internal /benchmarks/constraints-tms-2-3-light-40.smt2
```

The script mounts `artifact/instances/` to `/instances` inside the container, so files placed there are directly available to `cvc5`.
A [Docker volume](https://docs.docker.com/storage/volumes/) can still be used if you prefer mounting external directories.

```bash
# Run an arbitrary SMT2 file placed in artifact/instances/
# 1) Copy your file to artifact/instances/my_arbitrary_problem.smt2
# 2) Run it via the /instances path inside the container
./binary.sh --use-approx --external-lp-solver=qsoptex --standard-effort-variable-order-pivots=100 --no-lp-strict-var --tlimit-per=10000 --stats-all --stats-internal /instances/my_arbitrary_problem.smt2
```

## Troubleshooting

If you encounter any issues while running the experiments, please check the following:

- Ensure that Docker is installed and running on your machine.
- Check that you have enough free disk space to load the Docker image and store the results.
- If you see permission errors when running the scripts, try running them with `bash <scriptname>.sh` or check the file permissions.
- If you get the error `docker: Error response from daemon: failed to set up container networking: driver failed programming external connectivity on endpoint ...: Bind for 0.0.0.0:8888 failed: port is already allocated`, it means that port 8888 is already in use on your machine. You can either stop the process using that port or modify the `run.sh` script to use a different port for the notebook server (e.g., change `-p 8888:8888` to `-p 8889:8888` and update the URL accordingly).
- If the artifact fails to work on Windows or Mac, **please try running it on a Linux machine**, as it has been tested on Linux and may have compatibility issues with other operating systems, especially Arm-based Macs.
- If you want to update the Docker image, make sure you delete the existing image from your local Docker registry (e.g., `docker rmi qest-formats-ae:2026`) before loading the new one, to avoid conflicts with the old image.
- If the docker container is not removed automatically after stopping it, you can delete it manually with `docker rm <container_id>`, where `<container_id>` can be found by running `docker ps -a` and looking for the container created from the `qest-formats-ae:2026` image.
- The scripts automize the process of extracting and launching the Docker images and container with the correct configurations. We will use `<pwd>` to refer to the present working directory.
  These are the steps they perform:
  - `docker load -i qest-formats-ae-image.tar.gz` to load the Docker image present in the artifact,
  - `docker run --rm -v "<pwd>/results-[suite]:/results:rw" -v "<pwd>/instances:/instances" --entrypoint ./run_impl.sh qest-formats-ae:2026 [suite] [limit] [timeout]` to run the given benchmark `[suite]` over `[limit]` instances with a set `[timeout]` and store the results in `<pwd>/results-[suite]`,
  - `docker run -p 8888:8888 --rm -e "LOCAL_LIMIT=[limit]" -e "RUN_NAME=[suite]" -e "TIME_LIMIT=[timeout]" -v "<pwd>/results-[suite]:/work/results:rw" -v "<pwd>/instances:/work/instances" -it --entrypoint ./jupyter_impl.sh qest-formats-ae:2026 results-run.ipynb` to explore the results produced by the given benchmark `[suite]` ran over `[limit]` instances with a set `[timeout]`,
  - `docker run -p 8888:8888 --rm -v "<pwd>/results:/work/results:rw" -v "<pwd>/instances:/work/instances" -it --entrypoint ./jupyter_impl.sh qest-formats-ae:2026 results-explore.ipynb` to explore the results from the paper,
  - `docker run --rm -v "<pwd>/instances:/instances" --entrypoint ./binary_impl.sh qest-formats-ae:2026 ...` to launch the docker in binary configuration. `...` can be any argument supported by the binary. Use `--help` to get the full list.
- If you want to try the latest Docker image from the [GitHub repository](https://github.com/TendTo/cvc5), run `docker pull ghcr.io/tendto/cvc5:feat-exact-lp` and then `docker tag ghcr.io/tendto/cvc5:feat-exact-lp qest-formats-ae:2026`.
