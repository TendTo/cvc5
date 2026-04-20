# dlinear Artifact (Docker-based)

This folder contains the **required artifact materials** for an AE review:

```bash
artifact/
├── README.md # This file
├── LICENSE   # License file for the artifact
├── qest-formats-ae-image.tar.gz # Self-contained Docker image archive
├── clean.sh     # Script to remove all generated results
├── run.sh       # Script to run the smoke test and benchmark suites
├── explore.sh   # Script to explore the results from the paper
├── binary.sh    # Script to run the binaries directly
├── instances/   # CSV files listing benchmark instances for different suites
└── results/     # CSV files with results from the paper's experiments
```

## Requirements

To run the experiments, reviewers will need:

- Docker (tested with Docker version 29.3.0)
- ~10 GB of free disk space for the image and results (depends on compression)

The full setup has been tested on Linux but should work on any platform that supports Docker (e.g., Windows, macOS).
All scripts are provided in bash (`.sh`), PowerShell (`.ps1`), and cmd (`.bat`) formats for compatibility with different operating systems.

## Configurations

By default, each benchmark instance is evaluated over all the following configurations, for a total of 22 runs:

| Solver              | Pivot thresholds | Mode                             |
| ------------------- | ---------------- | -------------------------------- |
| **cvc5** (baseline) | N/A              | N/A                              |
| **cvc5+GLPK**       | 100, 200, 300    | N/A                              |
| **dlinear+SoPlex**  | 100, 200, 300    | epsilon (default), strict, delta |
| **dlinear+qsoptex** | 100, 200, 300    | epsilon (default), strict, delta |

See _Sections 4.2_ and _Section 5_ of the paper for more details on modes _epsilon_, _strict_, and _delta_.

## At a glance

Run the command corresponding to your desired mode of evaluation.
Each command is described in more detail in the [Experiments](#experiments) section.

| Mode                    | Command                    | What it does                                                                                                                                  | Expected result                                                                                                                                                  | Time estimate                                                                                                    |
| ----------------------- | -------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| [**Smoke**](#smoke)     | `./run.sh`                 | Runs a single benchmark instance with every configuration.                                                                                    | Writes CSV files to `results-smoke/`, then launches JupyterLab with `results-run.ipynb`. Running the notebook will generate the plots from the collected data.   | Few seconds.                                                                                                     |
| [**Run**](#run)         | `./run.sh [suite] [limit]` | Runs `[limit]` benchmark instances from `instances/[suite].csv` with every configuration.<br>By default, `[suite] = smoke` and `[limit] = 6`. | Writes CSV files to `results-[suite]/`, then launches JupyterLab with `results-run.ipynb`. Running the notebook will generate the plots from the collected data. | Few seconds/minutes. May take significantly longer if `[limit]` is increased or an harder `[suite]` is selected. |
| [**Explore**](#explore) | `./explore.sh`             | Opens the shipped result CSVs from the paper.                                                                                                 | Launches JupyterLab with `results-explore.ipynb`, which contains the paper figures generated from the stored data.                                               | Few seconds.                                                                                                     |
| [**Binary**](#binary)   | `./binary.sh [...]`        | Calls the `cvc5/dlinear` binary directly.                                                                                                     | Prints the solver output and statistics for the benchmark and options you choose.                                                                                | Depends on solver configuration and problem.                                                                     |

By default, **only 6 fast benchmarks are run for each suite**, so each experiment should complete within a **few seconds or minutes**, depending on the configuration and machine performance.
The evaluator is free to change this number and **run all 1753 benchmarks**, but note that this may take **several hours or even days** to complete.

## Experiments

All scripts in this artifact are bash scripts (`.sh`).
Equivalent PowerShell (`.ps1`) and cmd (`.bat`) scripts are also provided for Windows users.  
If you are on Linux and see a permission error, run the script as `bash <scriptname>.sh`.

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

After the run completes, the script launches JupyterLab (inside the container) to visualize the results.

To access the GUI in your browser, look for a line like:

```bash
[I 2026-03-26 18:00:41.239 ServerApp] Jupyter Server 2.17.0 is running at:
[I 2026-03-26 18:00:41.239 ServerApp] http://localhost:8888/lab?token=51d44fc4f44ec4fba11187448c5bb6fffc410a4b476329ee
[I 2026-03-26 18:00:41.239 ServerApp]     http://127.0.0.1:8888/lab?token=51d44fc4f44ec4fba11187448c5bb6fffc410a4b476329ee
[I 2026-03-26 18:00:41.239 ServerApp] Use Control-C to stop this server and shut down all kernels (twice to skip confirmation).
[C 2026-03-26 18:00:41.241 ServerApp]

    To access the server, open this file in a browser:
        file:///home/jovyan/.local/share/jupyter/runtime/jpserver-7-open.html
    Or copy and paste one of these URLs:
        http://localhost:8888/lab?token=51d44fc4f44ec4fba11187448c5bb6fffc410a4b476329ee # <-- Any of these urls
        http://127.0.0.1:8888/lab?token=51d44fc4f44ec4fba11187448c5bb6fffc410a4b476329ee
```

Click (or copy-paste) the URL to open the JupyterLab interface in your browser, where you can explore the results of the smoke test.
Select the `results-run.ipynb` notebook, and click on `Run > Run All Cells` to execute the notebook and visualize the results.

### Run

By default, `run.sh` runs the smoke test suite, named `smoke`.
You can run a different benchmark suite by passing the suite name `[suite]` as the first argument to the script among the following options:

| Suite name         | Tot. num. of instances | Description                                                                                        |
| ------------------ | ---------------------- | -------------------------------------------------------------------------------------------------- |
| **smoke**          | 1                      | A single instance for a quick test.                                                                |
| **100_instances**  | 319                    | Instances that trigger at least one external LP call when the pivot threshold $n = 100$.           |
| **200_instances**  | 177                    | Instances that trigger at least one external LP call when the pivot threshold $n = 200$.           |
| **300_instances**  | 125                    | Instances that trigger at least one external LP call when the pivot threshold $n = 300$.           |
| **latendresse**    | 18                     | Benchmarks from biological modeling.                                                               |
| **miplib**         | 42                     | Adapted from the MIPLIB linear programming benchmarks.                                             |
| **dtp-scheduling** | 91                     | Disjunctive Temporal Problems.                                                                     |
| **all_instances**  | 1753                   | The full set of 1753 QF_LRA instances from the SMT-LIB release 2025 of non-incremental benchmarks. |

The run script will load the specified CSV file (i.e., `instances/[suite].csv`) and run all benchmarks listed in it, through all [configurations](#configurations).

By default, the script executes **only the first 6 instances** per configuration, but you can change this limit by passing a second argument `[limit]` to the script.
While it is possible to **run all 1753 benchmarks**, the process may take **several hours or even days** to complete.

Results are written to `results-[suite]/` in this folder, and JupyterLab is launched afterward.
Open the `results-run.ipynb` notebook and run all cells to visualize the results.

```bash
./run.sh [benchmark suite name, default: smoke] [limit of instances to run per configuration, default: 6]
```

#### Example

```bash
./run.sh latendresse 3
```

will run the first three instances from `instances/latendresse.csv` and writes the resulting data to `results-latendresse/`.

#### Custom suite

You can edit `instances/custom.csv` to define your own list of benchmarks. The file must start with the header `file`, and every following row must name a `.smt2` benchmark. Only [QF_LRA](https://smt-lib.org/logics-all.shtml#QF_LRA) benchmarks from the [SMT-LIB release 2025 of non-incremental benchmarks](https://zenodo.org/records/16740866) are available, but you can also add a custom [volume to the docker container](https://docs.docker.com/storage/volumes/) to run your own benchmarks that are not included in the artifact.

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

This will open the JupyterLab interface in your browser.
Open the `results-explore.ipynb` notebook to view the analysis.
You can also modify the notebook to perform your own analysis on the results, or to visualize different metrics, and re-run the cells to see the updated plots.

#### Results from the paper

Many of the figures and tables from the paper have been generated from the `results-explore.ipynb` notebook.

- **Section 2.6** of the notebook contains **Table 1** of the paper
- **Section 2.7** of the notebook contains **Table 2** of the paper
- **Section 3.1** of the notebook contains **Figure 1**, **Figure 2**, and **Table 3** of the paper
- **Section 3.2** of the notebook contains **Figure 3** and **Figure 5** of the paper
- **Section 3.3** of the notebook contains **Table 8**, **Table 9**, and **Table 10** of the paper

### Binary

To achieve maximum flexibility, the `binary.sh` script interfaces directly with the `cvc5/dlinear` binary inside the Docker container, allowing you to run your custom command on any benchmark instance.
You can use a [docker volume](https://docs.docker.com/storage/volumes/) to mount your own smt2 files.

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
