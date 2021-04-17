include("../src/JOH.jl")
include("../MDMKP/MDMKP.jl")
include("SSIT.jl")
using CPLEX

tight_problems = MDMKP.load_folder()
loose_problems = MDMKP.loosen.(tight_problems)
problems = vcat(tight_problems, loose_problems)

method = JOH.Matheur.SSIT.make_SSIT_method(
			[.0001,.001, .003],
			[60,   60*3,  60],
			"A method", 1)


function main(; res_dir="results/decision_tree/")
	dir = joinpath(res_dir, method.name)
	for problem in problems
		problem_dir = joinpath(res_dir, "$(problem.id.id)")

		model = MDMKP.create_MIPS_model(problem, CPLEX.Optimizer)

		#long experiment
		data = SE.log_ssit_run(model, method, problem_dir, CPLEX.Optimizer,
			CPLEX.CPXgetdettime)
	end
end

main()
