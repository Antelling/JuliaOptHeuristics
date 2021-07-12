using JuMP
using Gurobi

include("../MMKP/MMKP.jl")
include("../src/JOH.jl")
include("SSIT.jl")

ssit_method(m=60, n_threads=1) = JOH.Matheur.SSIT.make_SSIT_method(
	[.0001, .001, .003, .005],
	[m, 	m,	  m, 	m],
	"even time", n_threads)

base_method(m=60, n_threads=1) = JOH.Matheur.SSIT.make_SSIT_method(
	[.0001],
	[m*20],
	"base", n_threads)

_make_result_table(res_dir) = try mkpath(res_dir) catch IOError println("dir already exists") end
function run_trial(res_dir, problems)
	bd = joinpath(res_dir, "base")
	sd = joinpath(res_dir, "ssit")
	_make_result_table(bd)
	_make_result_table(sd)

	base_problems = deepcopy(problems)

	for (method, probs, dir) in [
			(ssit_method(1), problems, sd), 
			(base_method(1), base_problems, bd)]
		map(p->set_optimizer(p.model, Gurobi.Optimizer), probs)
		SE.generate_comparison_data2(method, probs, results_dir=dir)
	end
end

problems =  MMKP.load_problems()
resdir="./results/test_mmkp"
mkpath(resdir)

run_trial(resdir, problems)
