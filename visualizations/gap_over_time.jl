include("../src/JOH.jl")
include("../MDMKP/MDMKP.jl")
using CPLEX, JuMP, Plots

problems = MDMKP.load_folder()

function graph_problem(problem)
    m = MDMKP.create_MIPS_model(problem, time_limit=1)
	set_optimizer(m, with_optimizer(CPLEX.Optimizer, CPX_PARAM_SCRIND=false))
	JOH.Matheur.set_tolerance!(m, .01)
	JOH.Matheur.set_threads!(m, 5)
    gaps = []
    while true
        optimize!(m)
		gap = MOI.get(m, MOI.RelativeGap())
		push!(gaps, gap)
		println(termination_status(m), gap)
		if termination_status(m) == MOI.OPTIMAL
			return gaps
		end
    end
end

looser_gaps = graph_problem.(problems[1:20])


plot(looser_gaps)
plot(gaps)
