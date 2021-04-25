include("../src/JOH.jl")
include("SSIT.jl")
include("../GAP/GAP.jl")
using Gurobi


function GAP_SSIT_methods(; s=1)
	first = JOH.Matheur.SSIT.make_SSIT_method(
				[.0001],
				[60*60],
				"1. normal cplex", 4)

	second = JOH.Matheur.SSIT.make_SSIT_method(
				[.0001, .001,  .003,  .007],
				[  150,  150,   300,   300],
				"2. ssit", 4)

	third = JOH.Matheur.SSIT.make_SSIT_method(
			[.001, .004, .007],
			[300,   300,  300],
			"3. ssit long", 4)
	[first, second, third]
end

function run_trial(method, res_dir, all_problems)
	try
		mkdir(res_dir)
	catch IOError
		println("dir already exists")
	end

	#make sure everything is compiled
	mm(p) = GAP.create_MIPS_model(p, optimizer=Gurobi.Optimizer)
	SE.generate_comparison_data(method, all_problems[1:1],
			mm, results_dir=res_dir)

	#run experiment
	data = SE.generate_comparison_data(method, all_problems,
			mm, results_dir=res_dir)
	data
end

function main()
	all_problems = GAP.load_folder()
	methods = GAP_SSIT_methods()
	for (optimizer, res_dir) in [
			(methods[1], "results/GAP_exp_Gurobi/first"),
			(methods[2], "results/GAP_exp_Gurobi/second"),
			(methods[3], "results/GAP_exp_Gurobi/third"),
			# (normal, "results/GAP_exp/norm")
			]
		run_trial(optimizer, res_dir, all_problems)
	end
end

main()

