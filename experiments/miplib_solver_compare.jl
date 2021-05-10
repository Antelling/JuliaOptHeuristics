using JuMP
using CPLEX

m = read_from_file("academic_timetables/academictimetablesmall.mps")

set_optimizer(m, CPLEX.Optimizer)
optimize!(m)
