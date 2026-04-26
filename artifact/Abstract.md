# Abstract

This artifact accompanies the tool paper **dlinear: Enhancing SMT Solvers with Floating-Point Exact LP Solvers** and is intended to provide other researchers with the tools needed to reproduce the experimental results reported in _Section 6, Benchmarks_ of the paper.

The paper evaluates the performance of **dlinear** (an extended version of **cvc5**) on standard SMT-LIB benchmarks for **QF_LRA** (SMT-LIB 2025 suite) and compares it against the baselines **cvc5 1.3.2**, **cvc5+GLPK** (as in the existing cvc5 LP integration), and the state-of-the-art SMT solvers **Z3 4.13.0** and **Yices 2.7.0**.
We set a timeout of **6 hours** per instance and limited the computational resources to **1 core** and **4 GB RAM**.

In the paper, results are reported on the subset of SMT-LIB instances where the solver configuration triggers at least one call to an external LP solver after a bounded number of internal simplex/tableau pivots.
Concretely, the evaluated pivot thresholds are **n = 100**, **n = 200**, and **n = 300**, yielding subsets of **319**, **177**, and **125** instances, respectively.
Additionally, we explored the capabilities of dlinear in $\delta$-complete mode by setting its pivot threshold to **n = 0** (i.e., immediately calling the external LP solver) and running it on the Sloane–Stufken benchmark suite, which contains 71 problems.
For dlinear, we evaluated the following configurations:

| Solver      | External LP solver | Pivot thresholds | Modes                   | Ran on         |
| ----------- | ------------------ | ---------------- | ----------------------- | -------------- |
| **dlinear** | SoPlex             | 100, 200, 300    | $\varepsilon$, $t$      | SMT-LIB        |
| **dlinear** | qsoptex            | 100, 200, 300    | $\varepsilon$, $t$      | SMT-LIB        |
| **dlinear** | SoPlex             | 0                | $\varepsilon$           | Sloane–Stufken |
| **dlinear** | qsoptex            | 0                | $\varepsilon$, $\delta$ | Sloane–Stufken |

where $\varepsilon$-mode refers to handling strict inequalities via a conservative $\varepsilon$-perturbation, $t$-mode refers to handling strict inequalities by introducing a strictness variable $t$, and $\delta$-mode refers to using $\delta$-complete decision procedures.
More details can be found in _Sections 4.2_ and _Section 5_ of the paper.

The submitted artifact contains a **self-contained Docker image** that includes the **dlinear binary** and the scripts needed to rerun these experiments.
The Docker image also contains the **CSV files** with all reported results, plus a notebook to generate the plots and tables presented in the paper.

**Reproducible experiments:** all benchmark experiments and derived plots/tables reported in the paper’s _Benchmarks_ section for the complete configurations.

**Paper type:** Tool paper.
