using DataFrames
using Random
using XLSX
using StructArrays
using StatsBase
using CSV

include("../src/JOH.jl")
include("../MDMKP/MDMKP.jl")

""" create a variety of SSIT methods. Accept a parameter to multiply each time
limit by. """
function make_SSIT_methods(m=60; n_threads=6)
    [
        JOH.Matheur.SSIT.make_SSIT_method(
			[.001, .005, .01, .02, .05],
			[m*5, m*5, m*5, m*5, m*5],
			"even time", n_threads)
        JOH.Matheur.SSIT.make_SSIT_method(
			[.001, .001, .001, .001, .001],
			[m*5,m*5,m*5,m*5,m*5],
			"one tolerance", n_threads)
        JOH.Matheur.SSIT.make_SSIT_method(
			[.001, .001, .005, .005, .005],
			[m*5, m*5, m*5, m*5, m*5],
			"tight tolerances", n_threads)
        JOH.Matheur.SSIT.make_SSIT_method(
			[.001, .005, .01, .02, .05],
			[m*2, m*4, m*5, m*6, m*8],
            "increasing time", n_threads)
        JOH.Matheur.SSIT.make_SSIT_method(
			[.001, .005, .01, .02, .05],
			[m*8, m*6, m*5, m*4, m*2],
            "decreasing time", n_threads)
    ]
end


struct MethodProblemResult
	method_name
	problem_id
	lowest_gap
	highest_reached_tolerance
	total_time
	last_phase_time
	cplex_obj
	true_obj
	infeasibility
	n_phases
end

MethodProblemResult(method, problem, solution, last_row) = MethodProblemResult(
	method.name,
	problem.id.id,
	last_row[!, :gap],
	last_row[!, :rtol],
	last_row[!, :elapsed_time],
	last_row[!, :solve_time],
	last_row[!, :objective],
	solution.objective,
	solution.infeasibility,
	last_row[!, :index])

mutable struct ExperimentResults
	problem_ids::Vector{MDMKP.Problem_ID}
	SSIT_phases::Vector{DataFrame}
	method_problem_results::Vector{MethodProblemResult}
end

ExperimentResults() = ExperimentResults([], [], [])

function flatten_ssit(df::DataFrame, tolerances)
	times = []
	gaps = []

	n_rows = length(df[!, 1])

	for i in 1:n_rows
		push!(times, df[i, :][:elapsed_time])
		push!(gaps, df[i, :][:gap])
	end

	flat_df = DataFrame()
	for i in 1:n_rows
		flat_df[!, Symbol("phase $i time")] = [times[i]]
		flat_df[!, Symbol("phase $i gap")] = [gaps[i]]
	end
	flat_df[!, :termination] = [last(df)[:term_stat]]
	flat_df[!, :lowest_gap] = [last(df)[:gap]]
	flat_df
end

function include_aux_data(df::DataFrame, method, problem_id)
	df[!, :method] .= method.name
	for field in fieldnames(typeof(problem_id))
		val = getfield(problem_id, field)
		df[!, Symbol("problem_$(field)")] = [val]
	end
	df
end

function include_sol_data(df, ssit_phases, solution_constructor, problem)
	lp = last(ssit_phases, 1)
	solution = solution_constructor(lp[!, :bitarr][1], problem)
	df[!, :objective] = [solution.objective]
	df[!, :infeasibility] = [solution.infeasibility]
	df[!, :solution] = [solution.value]
	df
end

function summarize_ssit(ssit_phases::DataFrame, method, problem, solution)
	df = include_aux_data(flatten_ssit(ssit_phases, method.tolerances),
		method, problem.id)
	df = include_sol_data(df, ssit_phases, solution, problem)
	df
end

function generate_comparison_data(
		methods::Vector{JOH.Matheur.SSIT.SSIT_method},
		problem_groups::Vector{Vector{T}},
		solution; results_dir="results") where T <: JOH.Problem

	results = []
	index = 1
	for (method, problem_group) in zip(methods, problem_groups)
		for problem in problem_group
			model = MDMKP.create_MIPS_model(problem)
			ssit_phases = JOH.Matheur.evaluate(model, method, id=problem.id)
			result_df = summarize_ssit(ssit_phases, method, problem, solution)
			CSV.write("$(results_dir)/$(index).csv", result_df)
			index += 1

			push!(results, result_df)
		end
	end
	results
end

function ba_rep(ba)
	join([b == 1 ? "1" : "0" for b in ba], "")
end

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

function record_dataset(datasets, methods, problems, solution, results_dir="results")
	problems = filter(x->x.id.dataset in datasets, problems)
	problem_groups = split_problems(problems, datasets=datasets)

	generate_comparison_data(methods, problem_groups, solution, results_dir=results_dir)
end

all_problems = MDMKP.load_folder()
ssit_methods = make_SSIT_methods()

res_dir = "results/GurobiTest"
mkpath(res_dir)
data = record_dataset(1:9, ssit_methods, all_problems, MDMKP.MDMKP_Sol, res_dir)
