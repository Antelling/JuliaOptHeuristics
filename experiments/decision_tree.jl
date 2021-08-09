include("../src/JOH.jl")
include("../MDMKP/MDMKP.jl")
include("SSIT.jl")

use_cplex = true
if use_cplex
	using CPLEX
	optimizer = CPLEX.Optimizer
	get_det_time = CPLEX.CPXgetdettime
else
	using Gurobi 
	optimizer = Gurobi.Optimizer
	get_det_time = nothing 
end 

tight_problems = MDMKP.load_folder()
loose_problems = MDMKP.loosen.(tight_problems)
problems = vcat(tight_problems, loose_problems)
problems = MDMKP.set_decision.(problems)

ass = map(p->p.id.category, problems)
count(i->i=='A', ass)
count(i->i=='B', ass)
count(i->i=='C', ass)
count(i->i=='D', ass)

const ssit_methods = Dict(
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
			"C method", 1),
	'D'=> JOH.Matheur.SSIT.make_SSIT_method(
			[.005, .01,   .02,   .05],
			[60*3, 60*10, 60*10, 60*10],
			"D method", 1)
) 

const base_case = JOH.Matheur.SSIT.make_SSIT_method(
			[.0001],
			[60*60],
			"Base method", 1) 


"""
Configured SSIT run using the optimizer configured at the beginning of the file. 
"""
function log_ssit_run(problem, method, dir; 
		opt=optimizer, 
		det_log=get_det_time,
		model_gen=MDMKP.create_MIPS_model)
	SE.log_ssit_run(model_gen(problem, opt), method, dir, opt, det_log)
end

"""
test the problems with the passed case on the corresponding method defined in the const ssit_methods
parameters: 
	problems: list of MDMKP problems to test 
	case: decision tree classification to test on 
		accepts: A, B, C, or D 
	loosen: if -1, do not loosen problem, if value from 0 to 1, loosen demand constraints of tested problems via 
			demand * loosen
		default: -1
	use_base: should the base case be tested?
		default: true
	res_dir: directory to store results in 
		default: results/decision_tree
	ssit_methods: dict of SSIT methods. Must contain entry for the passed case. 
"""
function main(problems, case; res_dir="results/decision_tree/", use_base=true, loosen=-1, 
		ssit_methods=ssit_methods, base_method=base_case)
	
	mkpath(res_dir)

	for problem in problems
		if problem.id.category != case #check case matches 
			continue
		end

		if 0 < loosen < 1 #check if we should loosen the problem demand constraints 
			problem = MDMKP.loosen(problem, percent=loosen, id_increment=0, label=case)
		end

		# make directory for resutls
		problem_dir = mkpath(joinpath(res_dir, "ssit", "$(problem.id.id)"))

		# run SSIT trial 
		log_ssit_run(problem, ssit_methods[case], problem_dir)

		# run base test 
		if use_base
			base_dir = mkpath(joinpath(res_dir, "base", "$(problem.id.id)"))
			log_ssit_run(problem, base_method, base_dir)
		end
	end
end


println("code loaded.")

#compilation run
main(problems[1:1], 'A', res_dir="results/decision_tree/A_v2/", use_base=false)
println("code compiled.")

main(problems, 'D', res_dir="results/decision_tree/D_95/", loosen=.95)

println("finished. Goodbye.")
