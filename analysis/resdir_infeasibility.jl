using JSON, CPLEX

include("../src/JOH.jl")
include("../MDMKP/MDMKP.jl")

tight_problems = MDMKP.load_folder()
loose_problems = MDMKP.loosen.(tight_problems)
probs = vcat(tight_problems, loose_problems)
problems = MDMKP.set_decision.(probs)


function get_infeasibility(solution, problem) end 

function load_problem_results(path)::Tuple{Int, Vector{Int}}
	highest_phase = max(map(f->parse(Int, f), readdir(path))...)
	final_data = read(joinpath(path, "$highest_phase", "results.json"), String)
	solution = JSON.parse(JSON.parse(final_data)[begin])
	problem_id = splitpath(path)[end]
	(parse(Int, problem_id), round.(solution))
end 

function load_method_dir(method)
	problem_data_files = readdir("results/decision_tree/A/$method/", join=true)
	results = load_problem_results.(problem_data_files)
end

_get_problem(id) = filter(p->p.id.id==id, problems)[begin]
function count_infeasibility(problem_id, solution)
	p = _get_problem(problem_id)
	art = solution[length(p.objective)+1:end]
	sol = solution[begin:length(p.objective)]
	obj = MDMKP.MDMKP_Sol(Bool.(sol), p)
	(problem_id, sum(art), obj)
end
count_inf(x) = count_infeasibility(x...)

ssit_res = load_method_dir("ssit")
base_res = load_method_dir("base")


