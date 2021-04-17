using Random
using JSON
using CPLEX
using JuMP
include("../src/JOH.jl")
include("../experiments/SSIT.jl")
include("../MDMKP/MDMKP.jl")


all_problems = MDMKP.load_folder()

for problem in all_problems
	method = SE.make_SSIT_methods(2)[1]
	i = 1

	m = MDMKP.create_MIPS_model(problem, with_optimizer(CPLEX.Optimizer,
		CPX_PARAM_SCRIND=0))
	JOH.Matheur.set_threads!(m, method.num_threads)
	JOH.Matheur.set_tolerance!(m, method.tolerances[i])
	time_limit = method.times[i]
	JOH.Matheur.set_time!(m, time_limit)

	JOH.Matheur.silent_optimize_slow!(m)
	optimize!(m)

	row = JOH.Matheur.get_DF_row(m, elapsed_time=0, index=i, getdettime=CPLEX.CPXgetdettime)
	# println(row)

	out = read(`top -bn1 -p $(getpid())`, String)
	println(split(split(out,  "\n")[end-1])[6])
	println()
end
