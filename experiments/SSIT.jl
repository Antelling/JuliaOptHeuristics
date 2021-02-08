module SE

using DataFrames
using Random
using XLSX
using StructArrays
using StatsBase
using CSV
using Main.JOH
using JuMP: objective_value

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

mutable struct ExperimentResults{T}
	problem_ids::Vector{T}
	SSIT_phases::Vector{DataFrame}
	method_problem_results::Vector{MethodProblemResult}
end

ExperimentResults() = ExperimentResults([], [], [])

function flatten_ssit(df::DataFrame, tolerances)
	times = []
	gaps = []
	objectives = []

	n_rows = length(df[!, 1])

	for i in 1:n_rows
		push!(times, df[i, :][:elapsed_time])
		push!(gaps, df[i, :][:gap])
		push!(objectives, df[i, :][:objective])
	end

	flat_df = DataFrame()
	for i in 1:n_rows
		flat_df[!, Symbol("phase $i time")] = [times[i]]
		flat_df[!, Symbol("phase $i gap")] = [gaps[i]]
		flat_df[!, Symbol("phase $i obj")] = [objectives[i]]
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

function include_sol_data(df, ssit_phases, problem, model)
	lp = last(ssit_phases, 1)
	try
		df[!, :objective] = [objective_value(model)]
	catch e
		df[!, :objective] = [-1]
	end
	df
end

function summarize_ssit(ssit_phases::DataFrame, method, problem, model)
	df = include_aux_data(flatten_ssit(ssit_phases, method.tolerances),
		method, problem.id)
	df = include_sol_data(df, ssit_phases, problem, model)
	df
end

function generate_comparison_data(
		method::JOH.Matheur.SSIT.SSIT_method,
		problems::Vector{T},
		mips_model; results_dir="results") where T <: JOH.Problem

	results = []
	index = 0
	for problem in problems
		index += 1
		model = mips_model(problem)
		ssit_phases = JOH.Matheur.evaluate(model, method)
		result_df = summarize_ssit(ssit_phases, method, problem, model)
		CSV.write("$(results_dir)/$(index).csv", result_df)

		push!(results, result_df)
	end

	results
end

function ba_rep(ba)
	join([b == 1 ? "1" : "0" for b in ba], "")
end


end
