[![License: BSD](
    https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](
        https://opensource.org/licenses/BSD-3-Clause)
![CI](https://github.com/cvc5/cvc5/workflows/CI/badge.svg)
[![Coverage](
  https://img.shields.io/endpoint?url=https://cvc5.stanford.edu/downloads/builds/coverage/nightly-coverage.json)](
    https://cvc5.stanford.edu/downloads/builds/coverage)

dlinear (cvc5 extension)
===============================================================================

_dlinear_ is a [CVC5](https://cvc5.github.io/) extension that adds support for exact floating-point [LP](https://en.wikipedia.org/wiki/Linear_programming) 
solvers to be used for the QF\_LRA theory.
_dlinear_ adds support for both [SoPlex](https://github.com/scipopt/soplex) and [Qsopt_ex](https://github.com/TendTo/qsopt-ex).
The goal is to leverage their efficiency to tackle complex linear constraints 
that would take much more time to solve using the existing simplex implementations 
in rational (or delta-rational) arithmetic.
When compared with the floating LP solver [GLPK](https://www.gnu.org/software/glpk/), 
already available in cvc5, we measured a noticeable speedup: the results produced 
by _dlinear_ are exact by design, while GLPK's outputs often require additional pivoting 
to reach a valid solution due to the errors introduced by floating point arithmetic.

If you are using cvc5 in your work, or incorporating it into software of your
own, we invite you to send us a description and link to your
project/software, so that we can link it on our [Third Party
Applications](https://cvc5.github.io/third-party-applications.html) page.

cvc5 is intended to be an open and extensible SMT engine.  It can be used as a
stand-alone tool or as a library.  It has been designed to increase the
performance and reduce the memory overhead of its predecessors.  It is written
entirely in C++ and is released under an open-source software license (see file
[COPYING](https://github.com/cvc5/cvc5/blob/main/COPYING)).

Build and Dependencies
-------------------------------------------------------------------------------

_dlinear_ can be built on Linux and macOS.  For Windows, _dlinear_ can be built using MSYS2
or cross-compiled using Mingw-w64.

For detailed build and installation instructions for cvc5 on these platforms,
see file [INSTALL.rst](https://github.com/cvc5/cvc5/blob/main/INSTALL.rst).
For _dlinear_ specific instructions, check [INSTALL.dlinear.md](./INSTALL.dlinear.md). 


Interfaces
-------------------------------------------------------------------------------

cvc5 features APIs for several different programming languages such as Python and
Java. See the [user documentation](https://cvc5.github.io/docs/) for more information.

Authors
-------------------------------------------------------------------------------

For a full list of authors, please refer to the
[AUTHORS](https://github.com/cvc5/cvc5/blob/main/AUTHORS) file.
