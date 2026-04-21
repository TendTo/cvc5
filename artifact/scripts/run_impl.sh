#!/usr/bin/env bash
set -euo pipefail

readonly run_name=${1:-smoke}
readonly local_limit=${2:-6}
readonly time_limit=${3:-21000}
readonly solvers=(soplex qsoptex)
iterations=(100 200 300)
modes=("" "strict")
readonly instances_file="/instances/${run_name}.csv"
readonly common_args="--instances ${instances_file} --instances-prefix /benchmarks/ --skip-first-line --local-limit ${local_limit} --timeout ${time_limit}"

# If the instance file begins with "eg_sloan", set the iterations to (0) and modes to ("") to only run the cvc5 baseline, as the glpk-based solvers do not support the EG encoding.
if [[ $(basename "${instances_file}") == sk_* ]]; then
  iterations=(0)
  modes=("" "delta")
fi

echo "[artifact] Running ${run_name} suite"
echo "[artifact] Using benchmark listed in ${instances_file}"
echo "[artifact] Running cvc5 baseline"
python3 run_benchmarks.py cvc5 ${common_args} --output-dir /results
python3 result_parser.py cvc5 /results -o /results
echo "[artifact] Running glpk"
for iteration in "${iterations[@]}"; do
  echo "[artifact] Running glpk with ${iteration} iterations"
  python3 run_benchmarks.py glpk ${common_args} --output-dir /results/${iteration} --iterations ${iteration}
  python3 result_parser.py glpk /results/${iteration} -o /results
  for solver in "${solvers[@]}"; do
    for mode in "${modes[@]}"; do
      if [[ $solver == "soplex" && $mode == "delta" ]]; then
        continue
      fi
      mode_args=""
      if [[ $mode == "strict" ]]; then
        mode_args="--strict"
      elif [[ $mode == "delta" ]]; then
        mode_args="--delta=1e+30"
      fi
      echo "[artifact] Running ${solver} with ${iteration} iterations and mode ${mode:-epsilon}"
      python3 run_benchmarks.py ${solver} ${common_args} --output-dir /results/${iteration}/${mode} --iterations ${iteration} ${mode_args}
      python3 result_parser.py ${solver} /results/${iteration}/${mode} -o /results
    done
  done
done
echo "[artifact] ${run_name} suite complete."
