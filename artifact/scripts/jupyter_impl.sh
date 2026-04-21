#!/usr/bin/env bash
set -euo pipefail

readonly notebook_name=${1:-results-explore.ipynb}

echo "[artifact] Running the Jupyter notebook to produce the plots and tables"
jupyter nbconvert --to notebook --execute --inplace "${notebook_name}"
echo "[artifact] Launching the Jupyter notebook to visualize the results"
echo "[artifact] Jupyter notebook is running at http://localhost:8888/notebooks/${notebook_name}"
echo "[artifact] Alternative URLs: http://127.0.0.1:8888/notebooks/${notebook_name} or http://0.0.0.0:8888/notebooks/${notebook_name}"
echo "[artifact] Press Ctrl+C two times in quick succession to stop the Jupyter notebook when finished."
jupyter notebook --NotebookApp.token='' --NotebookApp.password='' "${notebook_name}" > /dev/null 2>&1
