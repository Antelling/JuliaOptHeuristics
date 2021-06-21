using JuMP
using Gurobi

include("../MMKP/MMKP.jl")
include("../src/JOH.jl")
include("SSIT.jl")

method(m=60, n_threads=1) = JOH.Matheur.SSIT.make_SSIT_method(
	[.0001, .001, .003, .005],
	[m, 	m,	  m, 	m],
	"even time", n_threads)

method(m=60, n_threads=1) = JOH.Matheur.SSIT.make_SSIT_method(
	[.0001],
	[m*20],
	"base", n_threads)

_make_result_table(res_dir) = try mkdir(res_dir) catch IOError println("dir already exists") end
function run_trial(method, res_dir, problems)
	_make_result_table(res_dir)

	#attach optimizer 
	map(p->set_optimizer(p.model, Gurobi.Optimizer), problems)

	#make sure everything is compiled
	SE.generate_comparison_data2(method, problems[1:1],
			results_dir=res_dir)

	#run experiment
	data = SE.generate_comparison_data2(method, problems,
			results_dir=res_dir)

	data
end

function main(res_dir, problems)
	run_trial(method(), res_dir, problems)
end

problems =  MMKP.load_problems()

resdir="./results/test_mmkp"
mkpath(resdir)
main(resdir, problems[1:1])
main(resdir, problems)
