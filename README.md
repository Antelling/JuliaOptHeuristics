# Julia Opt Heuristics

## Structure:

1. JOH - module
  1. Matheur - module
    1. Matheuristic - abstract type
      - has executor property that accepts a JuMP Model and itself and then acts
        on the model
    2. SSIT - module
      1. SSIT_method - struct
        - tolerance vector for phases
        - time vector for phases
        - name of method
        - number of threads of method
        - executor function







-----------------Problem ID SETUP

DATASET 1-9
CASE    1-6
VARS  100 250 500
DEMAND  NUMBER OF DEMAND CONSTRAINTS
DIM    NUMBER OF DIMENSIONAL CONSTRAINTS
TIGHTNESS  .25  .50  .75
OBJFN  0,1 (O FOR POSITIVE COEFFICIENTS, 1 FOR MIXED)
PROBNUM  1-15

----------------Experiment SETUP
--------SSIT Setup
METHOD  D, E, I, O

--------Start Setup
START  WARM OR COLD
warm start time
warm start objective
warm start infeasibility

-------------------RESULTS
GAP
HIGHEST_TOL
CPLEX TIME

CPLEX objective
true objective
infeasibility

SSIT tolsteps
