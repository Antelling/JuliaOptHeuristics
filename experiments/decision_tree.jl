include("../src/JOH.jl")
include("../MDMKP/MDMKP.jl")
include("SSIT.jl")
using CPLEX

tight_problems = MDMKP.load_folder()
loose_problems = MDMKP.loosen.(tight_problems)
problems = vcat(tight_problems, loose_problems)
problems = MDMKP.set_decision.(problems)

ssit_methods = Dict(
	'A'=> JOH.Matheur.SSIT.make_SSIT_method(
			[.0001,.001, .003],
			[60,   60*3,  60*1], #3],
			"A method", 1),
	'B'=> JOH.Matheur.SSIT.make_SSIT_method(
			[.001, .003, .005, .008, .01],
			[60*3, 60*3, 60*3, 60*3, 60*5],
			"B method", 1),
	'C'=> JOH.Matheur.SSIT.make_SSIT_method(
			[.005, .01,   .02,   .05],
			[60*3, 60*10, 60*10, 60*10],
			"B method", 1)
)

function main(problems; res_dir="results/decision_tree/")
	for problem in problems
		if problem.id.category == 'A'
			continue
		end

		method = ssit_methods[problem.id.category]

		problem_dir = joinpath(res_dir, "$(problem.id.id)")

		model = MDMKP.create_MIPS_model(problem, CPLEX.Optimizer)

		SE.log_ssit_run(model, method, problem_dir, CPLEX.Optimizer,
			CPLEX.CPXgetdettime)
	end
end

main(problems)
