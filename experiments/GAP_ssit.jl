include("../src/JOH.jl")
include("SSIT.jl")
include("../GAP/GAP.jl")

all_problems = GAP.load_folder()
ssit_method = JOH.Matheur.SSIT.make_SSIT_method(
			[.001, .004, .007, .01, .02],
			[300,300,300,300,300],
			"gap ssit", 4)

normal = JOH.Matheur.SSIT.make_SSIT_method(
			[.0001],
			[25*60],
			"normal cplex", 4)

for (res_dir, optimizer) in [(ssit_method, "results/GAP_exp/ssit"),
		(normal, "results/GAP_exp/norm")]

	try
		mkdir(res_dir)
	catch IOError
		println("dir already exists")
	end

	#make sure everything is compiled
	SE.generate_comparison_data(optimizer, all_problems[1:1],
			GAP.create_MIPS_model, results_dir=res_dir)

	#run experiment
	data = SE.generate_comparison_data(optimizer, all_problems,
			GAP.create_MIPS_model, results_dir=res_dir)
end
