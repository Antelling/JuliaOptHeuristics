using Random
using JSON
using CPLEX
using JuMP
include("../src/JOH.jl")
include("../experiments/SSIT.jl")
include("../MDMKP/MDMKP.jl")


all_problems = MDMKP.load_folder()
method = SE.make_SSIT_methods(2)[1]

problem = all_problems[719]

indirect_model = MDMKP.create_MIPS_model(problem, CPLEX.Optimizer)


m = MDMKP.direct_model(all_problems[717], direct_model(CPLEX.Optimizer()))

m = indirect_model

JOH.Matheur.set_threads!(m, method.num_threads)
i = 1
JOH.Matheur.set_tolerance!(m, method.tolerances[i])
time_limit = method.times[i]
JOH.Matheur.set_time!(m, 10)

optimize!(m)

row = JOH.Matheur.get_DF_row(m, elapsed_time=0, index=i,
	getdettime=CPLEX.CPXgetdettime)

df = JOH.Matheur.Model_DF()
push!(df, row)
