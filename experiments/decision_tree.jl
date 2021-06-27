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
			[.0001, .001, .005, .01, .02],
			[60*5,   60*3,  60*3, 60*3, 60*3],
			"A method", 1),
	'B'=> JOH.Matheur.SSIT.make_SSIT_method(
			[.001, .003, .005, .008, .01, .02],
			[60*3, 60*3, 60*3, 60*3, 60*5, 60*5],
			"B method", 1),
	'C'=> JOH.Matheur.SSIT.make_SSIT_method(
			[.005, .01,   .02,   .05],
			[60*3, 60*10, 60*10, 60*10],
			"C method", 1)
)

base_case = JOH.Matheur.SSIT.make_SSIT_method(
			[.0001],
			[60*60],
			"Base method", 1)

function log_ssit_run(problem, method, dir; 
		opt=CPLEX.Optimizer, 
		det_log=CPLEX.CPXgetdettime,
		model_gen=MDMKP.create_MIPS_model)
	SE.log_ssit_run(model_gen(problem, opt), method, dir, opt, det_log)
end

function main(problems, case; res_dir="results/decision_tree/", use_base=true)
	mkpath(res_dir)
	for problem in problems
		if problem.id.category != case
			continue
		end

		method = ssit_methods[problem.id.category]

		problem_dir = joinpath(res_dir, "ssit", "$(problem.id.id)")
		mkpath(problem_dir)
		log_ssit_run(problem, method, problem_dir)

		if use_base
			base_dir = joinpath(res_dir, "base", "$(problem.id.id)")
			mkpath(base_dir)
			log_ssit_run(problem, base_case, base_dir)
		end
	end
end

println("code loaded.")

#compilation run
main(problems[1:1], 'A', res_dir="results/decision_tree/A_v2/", use_base=false)
println("code compiled.")

#main(problems, 'A', res_dir="results/decision_tree/A_v2/", use_base=false)
println("A finished...")

#main(problems, 'B', res_dir="results/decision_tree/B/")
#println("B finished...")

main(problems, 'C', res_dir="results/decision_tree/C/")
#println("C finished. Goodbye.")
