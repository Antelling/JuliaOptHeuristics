using JSON, CPLEX, JuMP

include("../src/JOH.jl")
include("../MDMKP/MDMKP.jl")

tight_problems = MDMKP.load_folder()
loose_problems = MDMKP.loosen.(tight_problems)
probs = vcat(tight_problems, loose_problems)
problems = MDMKP.set_decision.(probs)


function get_infeasibility(solution, problem) end 

"""read the passed results directory (for one problem)
and return a (id.id, solution)"""
function load_problem_results(path)::Tuple{Int, Vector{Int}}
	highest_phase = max(map(f->parse(Int, f), readdir(path))...)
	final_data = read(joinpath(path, "$highest_phase", "results.json"), String)
	solution = JSON.parse(JSON.parse(final_data)[begin])
	problem_id = splitpath(path)[end]
	(parse(Int, problem_id), round.(solution))
end 


"""load the results for the passed method and category"""
function load_method_dir(method, category::Char)
	problem_data_files = readdir("results/decision_tree/$category/$method/", 
		join=true)
	load_problem_results.(problem_data_files)
end

_get_problem(id) = filter(p->p.id.id==id, problems)[begin]
function count_infeasibility(problem_id, solution)
	p = _get_problem(problem_id)
	n_real_vars = length(p.objective)
	n_artificial_vars = length(solution) - n_real_vars
	artificial_part = solution[begin:begin+n_artificial_vars-1]
	real_part = solution[end-n_real_vars+1:end]
	(problem_id, sum(abs.(artificial_part)))
end
count_inf(x) = count_infeasibility(x...)

res = load_method_dir("ssit", 'B')

output(count_inf.(res))

function output(d)
	for (p, inf) in d 
		println("$p $inf")
	end
end



#get a specific result from the res var 
_get_result(id) = first(filter(r->r[1] == id, res))

#get the base case result for the easiest problem, and load the problem itself
easiest_result = _get_result(1)
easiest_problem = _get_problem(1)

#solve the problem here 
model = MDMKP.create_MIPS_model(easiest_problem)
set_optimizer(model, CPLEX.Optimizer)
optimize!(model)
objective_value(model)

#what is the solution? 
computed_sol = value.(all_variables(model))
result_sol = easiest_result[2]

a = computed_sol[begin:begin+99]
b = result_sol[end-99:end]
c = result_sol[begin:begin+5]
