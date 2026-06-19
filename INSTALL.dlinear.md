# _dlinear_ installation

There are two main ways to install and use _dlinear_: either through a Docker container (easy setup, standalone tool), 
or by building _dlinear_ from source (involved setup, standalone tool & library).

## Docker

### Requirements

- x86 processor
- [Docker](https://www.docker.com/)

### Building Docker from source

The Docker image can be built from the source code:

```bash
git clone https://github.com/TendTo/cvc5.git dlinear
cd dlinear
docker build -t dlinear .
```

### Pre-built image

Alternatively, a pre-built image is available on the [GitHub Container Registry](https://github.com/TendTo/cvc5/pkgs/container/cvc5):

```bash
docker pull ghcr.io/tendto/cvc5:feat-exact-lp
docker tag ghcr.io/tendto/cvc5:feat-exact-lp dlinear:latest
```

### Using the Docker image

An SMT-LIB instance can then be solved by mounting the directory containing
the benchmark and invoking the solver inside the container:

```bash
docker run --rm -v "$PWD:/bench" dlinear /bench/benchmark.smt2
```

## _dlinear_ from source

### Requirements

- Linux or MacOs (Tested on Ubuntu 22.04)
- [gcc (>= 7)](https://gcc.gnu.org>) or [Clang (>= 5)](https://clang.llvm.org>)
- [CMake (>= 3.16)](https://cmake.org)
- [GNU Make](https://www.gnu.org/software/make/) or [Ninja](https://ninja-build.org/)
- [Python (>= 3.7)](https://www.python.org)
    + module [tomli](https://pypi.org/project/tomli/)
    + module [pyparsing](https://pypi.org/project/pyparsing/)
- [GMP (6.3)](https://gmplib.org)
- [CaDiCaL (>= 2.1.0)](https://github.com/arminbiere/cadical)
- [SymFPU](https://github.com/martin-cs/symfpu/tree/CVC4)
- [Qsoptex (fork 2.5.10.)](https://github.com/TendTo/qsopt-ex)
- [SoPlex (>= 8.0.1)](https://github.com/scipopt/soplex#)

Some of these dependencies can be automatically downloaded by the configuration script.
If you are on a debian-based system, we advise running the following command to install most of _dlinear_'s and its dependencies' requirements

```bash
apt install build-essential libgmp-dev \
  python3.12-venv libtool libz-dev libbz2-dev
```

You will still need to install both [Qsoptex](https://github.com/TendTo/qsopt-ex) and [SoPlex](https://github.com/scipopt/soplex#).
What follows is a brief guide on how to install them.
Refer to their installation guides for more details and for the complete list of requirements.

#### Installing SoPlex

```bash
git clone https://github.com/scipopt/soplex.git
cd soplex
mkdir build && cd build
cmake .. -DGMP=ON -DMPFR=ON -DBOOST=ON -DCMAKE_BUILD_TYPE=Release -DZLIB=OFF -DCMAKE_POSITION_INDEPENDENT_CODE=ON
make -j4 install
```

#### Installing Qsopt-ex

```bash
git clone https://github.com/TendTo/qsopt-ex.git
cd qsopt-ex
./bootstrap
mkdir build && cd build
../configure
make -j4 install
```

### Installing _dlinear_

```bash
git clone https://github.com/TendTo/cvc5.git dlinear
cd dlinear
./configure.sh --auto-download --gpl --glpk --soplex --qsoptex
cd build
make -j4
```

To ensure the process was successful, run

```bash
./bin/cvc5 --version
```

For detailed instructions on how to use the tool, run

```bash
./bin/cvc5 --help
```
