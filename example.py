#!/usr/bin/env python3
import argparse
import math
from cvc5.pythonic import *
from operator import ge, eq

stats = {
    "options::pivots",
    "options::checkModels",
    "options::strict",
    "options::delta",
    "options::external-lp-solver",
    "theory::arith::z::approx::externalAdjustmentPivots",
    "theory::arith::z::approx::delta",
    "theory::arith::z::approx::deltaResults",
    "theory::arith::z::approx::strictVar",
    "theory::arith::z::arith::relax::calls",
    "theory::arith::z::arith::relax::exhausted",
    "theory::arith::z::arith::relax::feasible::failures",
    "theory::arith::z::arith::relax::feasible::res",
    "theory::arith::z::arith::relax::infeasible",
    "theory::arith::z::arith::relax::infeasible::failures",
    "theory::arith::z::arith::relax::other",
    "theory::arith::z::approx::lp::timer ",
    "theory::arith::z::approx::lp::setup::timer ",
    "theory::arith::z::approx::pivotLimit",
    "theory::arith::z::approx::externalSimplexType",
    "theory::arith::z::approx::precision",
    "theory::arith::z::approx::refinements",
    "theory::arith::pivots",
    "TheoryEngine::Checks_Full",
    "TheoryEngine::Checks_Last_Call",
    "TheoryEngine::Checks_Standard",
    "TheoryEngine::combineTheoriesCalls",
    "TheoryEngine::combineTheoriesTime",
    "driver::filename",
    "global::totalTime",
    "preprocessing::theory-preprocess",
    "sat::clauses_literals",
    "sat::conflicts",
    "sat::decisions",
    "sat::learnts_literals",
    "sat::max_literals",
    "sat::propagations",
    "sat::rnd_decisions",
    "sat::starts",
    "sat::tot_literals",
    "theory::arith::AssertLowerConflicts",
    "theory::arith::AssertUpperConflicts",
    "theory::arith::AuxiliaryVariables",
    "theory::arith::DisequalityConflicts",
    "theory::arith::DisequalitySplits",
    "theory::arith::UserVariables",
    "theory::arith::attempt::conflicts",
    "theory::arith::attempt::queueTime",
    "theory::arith::attempt::searchTime",
    "theory::arith::attempt::extendedSearch",
    "theory::arith::checkTime",
    "theory::arith::conflicts",
    "theory::arith::pivots",
    "theory::arith::status::nontrivialSatChecks",
    "theory::arith::updates",
}

# ============================================================================
# Krawtchouk polynomial
# P_j^s(x,m)=Σ_i (-1)^i (s-1)^(j-i) C(x,i) C(m-x,j-i)
# ============================================================================


# \f[P^s_j(x,m)=\sum\limits_{i=0}^j(-1)^i(s-1)^{j-i}\binom{x}{i}\binom{m-x}{j-i}\f]
def kpoly(x: int, s: int, j: int, m: int) -> RatNumRef:
    assert m >= x and s >= 1, "Invalid parameters for Krawtchouk polynomial"
    return sum(
        ((-1) ** i) * (s - 1) ** (j - i) * math.comb(x, i) * math.comb(m - x, j - i)
        for i in range(j + 1)
    )


# ============================================================================
# Main
# ============================================================================


def main():
    parser = argparse.ArgumentParser(
        description=("Compute LP bounds for mixed-level orthogonal arrays.")
    )

    parser.add_argument("-d", action="store_true", default=False, help="use dlinear")
    parser.add_argument(
        "-a", type=int, default=3, help="range of values for first OA level"
    )
    parser.add_argument(
        "-b", type=int, default=3, help="range of values for second OA level"
    )
    parser.add_argument(
        "-c", type=int, default=3, help="number of columns for first OA level"
    )
    parser.add_argument(
        "-e", type=int, default=3, help="number of columns for second OA level"
    )
    parser.add_argument("-s", type=int, default=1, help="use scaling")
    parser.add_argument("-o", type=str, help="output filename")
    parser.add_argument("-t", type=int, default=2, help="required strength")

    args = parser.parse_args()

    s1 = args.a
    s2 = args.b
    k1 = args.c
    k2 = args.e

    use_scaling = bool(args.s)
    dlinear = bool(args.d)

    t = args.t

    if min(s1, s2) < 2:
        raise ValueError("s1 and s2 must be >= 2")

    if min(k1, k2) < 1:
        raise ValueError("k1 and k2 must be >= 1")

    if t < 1:
        raise ValueError("t must be >= 1")

    out_file = args.o

    print("Options:")
    print(f"  first level columns  = {k1}")
    print(f"  second level columns = {k2}")
    print(f"  first level range    = {s1}")
    print(f"  second level range   = {s2}")
    print(f"  strength t           = {t}")
    print(f"  scaling              = {use_scaling}")
    print(f"  output file          = {out_file}")

    name = f"OA_SL_{s1}-{k1}_{s2}-{k2}_t-{t}"

    # ------------------------------------------------------------------------
    # Create LP
    # ------------------------------------------------------------------------

    constraints: list[ExprRef] = []
    vars_dict = {}

    # Create variables
    for i in range(k1 + 1):
        for j in range(k2 + 1):
            var = Real(f"V_{i}_{j}")
            vars_dict[(i, j)] = var
            constraints.append(var >= 0)

    # ------------------------------------------------------------------------
    # Constraints
    # ------------------------------------------------------------------------

    rows: "list[tuple[ExprRef, ge | eq]]" = []
    coeff_matrix = {}
    for i in range(k1 + 1):
        for j in range(k2 + 1):
            expr = []
            for k in range(k1 + 1):
                for l in range(k2 + 1):
                    coeff = kpoly(k, s1, i, k1) * kpoly(l, s2, j, k2)
                    if coeff != 0:
                        coeff_matrix[(i, j, k, l)] = coeff
                        expr.append(coeff * vars_dict[(k, l)])
            lhs = sum(expr)
            if 1 <= i + j <= t:
                rows.append([lhs, eq])
            else:
                rows.append([lhs, ge])

    # ------------------------------------------------------------------------
    # Scaling
    # ------------------------------------------------------------------------

    if use_scaling:

        values = [abs(v) for v in coeff_matrix.values() if v != 0]

        if values:
            scale_factor = math.lcm(*values) // math.gcd(*values)
            print(f"Scale factor = {scale_factor}")
            coeff = RealVal(scale_factor)

            for lhs, op in rows:
                lhs = lhs / coeff
                constraints.append(op(lhs, 0))

    s = Solver()
    if dlinear:
        s.set("use-approx", True)
        s.set("external-lp-solver", "soplex")
        s.set("standard-effort-variable-order-pivots", 0)
        s.set("delta", -1)
        s.set("lp-strict-var", True)

    s.set("output-language", "smt2")
    s.set("arith-prop", "none")
    s.set("arith-brab", False)
    s.set("simplification", "none")
    s.set("new-prop", False)

    s.add(constraints)
    res = s.check()
    assert res == sat, "Constraints are unsatisfiable"
    print(s.model())

    for stat in s.statistics():
        if stat[0] in stats or "time" in stat[0].lower():
            print(f"{stat[0]} = {stat[1]}")


if __name__ == "__main__":
    main()
