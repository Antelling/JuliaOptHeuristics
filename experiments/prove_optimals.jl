include("../src/JOH.jl")
include("../MDMKP/MDMKP.jl")
include("SSIT.jl")

using Gurobi 
const default_opt = Gurobi.Optimizer
default_get_det(model, other_thing) = -1

tight_problems = MDMKP.load_folder()
loose_problems = MDMKP.loosen.(tight_problems)
problems = vcat(tight_problems, loose_problems)
problems = MDMKP.set_decision.(problems)

base_case = JOH.Matheur.SSIT.make_SSIT_method(
			[.0001],
			[60*60*48],
			"2 days 8 cores", 8)

function log_ssit_run(problem, method, dir; 
		opt=default_opt, 
		det_log=default_get_det,
		model_gen=MDMKP.create_MIPS_model)
	SE.log_ssit_run(model_gen(problem, opt), method, dir, opt, det_log)
end

function main(problems, res_dir)
	rm(res_dir, force=true, recursive=true)
	mkpath(res_dir)
	for problem in problems
		problem_dir = joinpath(res_dir, "$(problem.id.id)")
		log_ssit_run(problem, base_case, problem_dir)
	end
end

main(problems, "results/proven_optimal/")