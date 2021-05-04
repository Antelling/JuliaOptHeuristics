using Random
using JSON
using CPLEX
include("../src/JOH.jl")
include("SSIT.jl")
include("../MDMKP/MDMKP.jl")


"""accept a vector of problems.
Assign each problem to a group, such that each group will have an even number of
problems, and the problem sets will have the same distribution of tightnesses,
datasets, and cases."""
function split_problems(problems; n_groups=5, datasets=1:9, tightnesses=[.25, .5, .75],
			cases=1:6)::Vector{Vector{JOH.Problem}}
	groups = [[] for _ in 1:n_groups]
	for dataset in datasets
		for tightness in tightnesses
			for case in cases
				random_assignment_order = shuffle(collect(1:n_groups))
				subset = filter(x->x.id.tightness==tightness
					&& x.id.dataset==dataset
					&& x.id.case==case, problems)
				j = 1
				for i in random_assignment_order
					push!(groups[i], subset[j])
					j += 1
				end
			end
		end
	end
	groups
end


"""
Record the method names and problem groups of
"""
function log_problem_groups(folder, methods, problem_groups)
	names = [m.name for m in methods]
	human_readable =
		Dict( names[i] => [p.id.id for p in problem_groups[i]] for i in 1:length(methods))
	open(joinpath(folder, "methods__problem_groups.json"), "w") do f
		JSON.print(f, human_readable)
	end
end


function start_experiment(methods, grouped_problems, all_problems, name,
		getdettime, optimizer)
	#check preconditions
	@assert length(methods) == length(grouped_problems)

	#make sure results folder exists and is empty
	res_dir = joinpath("results/", name)
	rm(res_dir, force=true, recursive=true)
	mkdir(res_dir)

	log_problem_groups(res_dir, methods, grouped_problems)

	run_experiment(res_dir, methods, all_problems, getdettime, optimizer)
end

"""load the assigned method problems from the results folder, than record
results"""
function run_experiment(folder, methods, problems, getdettime, optimizer)
	#load data
	data = []
	open(joinpath(folder, "methods__problem_groups.json"), "r") do f
		data = JSON.parse(read(f, String))
	end

	#call run_method on each problem-subset/method pair
	problem_subset(meth) = filter(p->p.id.id in data[meth.name], problems)
	run_meth(meth) = run_method(folder, meth, problem_subset(meth), getdettime,
			optimizer)
	run_meth.(methods)
end

function run_method(res_dir, method, problems, getdettime, optimizer)
	dir = joinpath(res_dir, method.name)
	mmm(x) = MDMKP.create_MIPS_model(x, CPLEX.Optimizer)
	run_trial(problems) = SE.log_method_results(method, problems,
			mmm, joinpath(res_dir, method.name),
			optimizer, getdettime)

	run_trial(problems[1:1])
	run_trial(problems)
end


all_problems = MDMKP.load_folder()
methods = SE.make_SSIT_methods(n_threads=1)
grouped_problems = split_problems(all_problems)


start_experiment(methods, grouped_problems, all_problems, "song_mdmkp", CPLEX.CPXgetdettime,
		CPLEX.Optimizer)

