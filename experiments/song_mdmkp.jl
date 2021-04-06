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


"""Run Dr. Song's experimental design to compare SSIT methods on the 810 MDMKP
benchmark problems.

accepts:
	methods::Vector{Method} - list of SSIT methods to compare
	grouped_problems::Vector{Vector{Problem}} - list of list of problems, one
		problem list per method
	name::String - name of this experimental trial
preconditions:
	length(methods) == length(grouped_problems)
success guarantee:
	a folder named name will be created under "results/". This folder will
	contain a file detailing the method names and problem IDs of the
	methods/grouped_problems pairings. Each method's results will be recorded in
	a subfolder."""
function record_experiment(methods, grouped_problems, name,
		getdettime)
	#check preconditions
	@assert length(methods) == length(grouped_problems)

	#make sure results folder exists and is empty
	res_dir = joinpath("results/", name)
	rm(res_dir, force=true, recursive=true)
	mkdir(res_dir)

	log_problem_groups(res_dir, methods, grouped_problems)

	for (method, problem_group) in zip(methods, grouped_problems)
		dir = joinpath(res_dir, method.name)
		#closure for solver equiped solver constructor
		mmm(x) = MDMKP.create_MIPS_model(x, CPLEX.Optimizer)
		#make sure everything is compiled
		SE.log_method_results(method, all_problems[1:1],
				mmm, dir, CPLEX.Optimizer, CPLEX.CPXgetdettime)

		#long experiment
		data = SE.log_method_results(method, problem_group,
				MDMKP.create_MIPS_model, dir, CPLEX.Optimizer,
				CPLEX.CPXgetdettime)
	end
end



all_problems = MDMKP.load_folder()
methods = SE.make_SSIT_methods()
grouped_problems = split_problems(all_problems)

# Juno.@enter record_experiment(methods, grouped_problems, "test")

record_experiment(methods, grouped_problems, "test",
	CPLEX.CPXgetdettime)
