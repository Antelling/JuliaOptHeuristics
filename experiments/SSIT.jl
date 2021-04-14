module SE

using DataFrames
using Random
using XLSX
using StructArrays
using StatsBase
using CSV
using Main.JOH
using JuMP
using JSON

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
	for problem in problems
		model = mips_model(problem)
		ssit_phases = JOH.Matheur.evaluate(model, method)
		result_df = summarize_ssit(ssit_phases, method, problem, model)
		CSV.write("$(results_dir)/$(problem.id.id).csv", result_df)

		push!(results, result_df)
	end

	results
end

function save_model(m, m_path, s_path)
	write_to_file(m, m_path)
	try
		open(s_path, "w") do f
			print(f, json(value.(all_variables(m))))
		end
	catch e
		if !(isa(e, JuMP.OptimizeNotCalled))
			rethrow()
		end
	end
end

function read_solution(s_path::String)
	try
		open(s_path, "r") do f
			JSON.parse(read(f,String))
		end
	catch e
		false
	end
end

function log_ssit_run(m::JuMP.Model, method, res_dir::String, optimizer,
		getdettime)
	JOH.Matheur.set_threads!(m, method.num_threads)

	for i in 1:length(method.tolerances)
		#create a directory to store this phase's information
		phase_dir = joinpath(res_dir, "$(i)")
		mkdir(phase_dir)

		#generate paths to data files
		m_path, s_path, r_path = map(n->joinpath(phase_dir, n),
			["model.mps", "start_sol.json", "results.json"])

		#save the model and starting solution
		save_model(m, m_path, s_path) #TODO: save the method and phase as well

		temp_sol = try
				open(s_path, "r") do f
					JSON.parse(read(f,String))
				end
			catch e
				false
			end
		println(temp_sol)

		#delete the current model, then replace from the saved record
		#this is to make starting from the saved files deterministic
		m = nothing
		m = read_from_file(m_path)
		solution = read_solution(s_path)
		set_optimizer(m, optimizer)

		#update the model according to the SSIT phase parameters
		JOH.Matheur.set_tolerance!(m, method.tolerances[i])
		JOH.Matheur.set_time!(m, method.times[i])
		JOH.Matheur.set_threads!(m, method.num_threads)

		if solution != false
			set_start_value.(all_variables(m), solution)
		end

		# run the optimization, and record the elapsed time
		start_time = time()
		optimize!(m)
		end_time = time()
		elapsed_time = end_time - start_time

		#make sure julia deletes the C optimizers memory
		GC.gc() #this doesn't always happen automatically

		row = JOH.Matheur.get_DF_row(m, elapsed_time=elapsed_time, index=i,
			getdettime=getdettime)

		GC.gc() #this doesn't always happen automatically

		open(r_path, "w") do f
			print(f, json(row))
		end

		if termination_status(m) == MOI.OPTIMAL || termination_status(m) ==
				MOI.INFEASIBLE
			break
		end
	end
end

function log_method_results(
		method::JOH.Matheur.SSIT.SSIT_method,
		problems::Vector{T},
		mips_model, res_dir, optimizer, getdettime) where T <: JOH.Problem

	rm(res_dir, force=true, recursive=true)
	mkpath(res_dir)

	for problem in problems
		problem_dir = joinpath(res_dir, "$(problem.id.id)")
		mkdir(problem_dir)
		log_ssit_run(mips_model(problem), method, problem_dir, optimizer,
			getdettime)
	end
end

function ba_rep(ba)
	join([b == 1 ? "1" : "0" for b in ba], "")
end


end
