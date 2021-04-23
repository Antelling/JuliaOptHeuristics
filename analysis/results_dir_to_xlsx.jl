using XLSX, JSON
using DataFrames
include("../src/JOH.jl")
include("MDMKP_id_df.jl")

function vec_to_DF(vec, problem_id)
	dataframe = JOH.Matheur.Model_DF()
	for row in vec
		push!(dataframe, row)
	end

	#add problem id to this dataframe
	id_col = repeat([problem_id], nrow(dataframe))
	dataframe[!, "problem_id"] = id_col

	dataframe
end

function read_problem_dir(folder, problem_id)
	filepath = joinpath(folder, problem_id)
	results = []

	phase = 0
	while true
		phase += 1

		model_path = joinpath(filepath, "$phase", "model.mps")
		results_path = joinpath(filepath, "$phase", "results.json")
		sol_path = joinpath(filepath, "$phase", "start_sol.json")
		try
			results_file = open(results_path, "r")
			phase_results = read(results_file, String)
			close(results_file)

			push!(results, phase_results)
		catch SystemError
			break
		end
	end

	vec_to_DF(JSON.parse.(results), problem_id)
end

function summarize_df(df)
	su = DataFrame()
	su[!, "id"] = [parse(Int, df.problem_id[1])]
	for phase in 1:nrow(df)
		su[!, "p$(phase)_obj"] = [-1*df.objective[phase]]
		su[!, "p$(phase)_gap"] = [df.gap[phase]]
		su[!, "p$(phase)_dettime"] = [df.dettime[phase]]
		su[!, "p$(phase)_solve_time"] = [df.solve_time[phase]]
		su[!, "p$(phase)_elapsed_time"] = [df.elapsed_time[phase]]
		su[!, "p$(phase)_rtol"] = [df.rtol[phase]]
		su[!, "p$(phase)_term"] = [df.term_stat[phase]]
	end
	su[!, "total_solve_time"] = [sum(df.solve_time)]
	su[!, "total_elapsed_time"] = [sum(df.elapsed_time)]
	su[!, "total_dettime"] = [sum(df.dettime)]
	su
end

function read_result_dir(folder)
	results = []
	summaries = []
	for problem in readdir(folder)
		df = read_problem_dir(folder, problem)
		push!(results, df)
		push!(summaries, summarize_df(df))
	end
	vcat(results...), vcat(summaries..., cols=:union)
end

function join_summary_problem_tables(summary_df, problem_df)
	new_results = innerjoin(problem_df, summary_df, on="id")
	new_results
end



function write_table(table_name, summary, complete)
	XLSX.writetable(
		table_name,
		results =(
			collect(DataFrames.eachcol(summary)),
			DataFrames.names(summary) ),
		complete_results =(
			collect(DataFrames.eachcol(complete)),
			DataFrames.names(complete) ))
end


complete, summary = read_result_dir("results/decision_tree/")
problem_df = MDMKP_id_dataframe()
summary = join_summary_problem_tables(summary, problem_df)

write_table("decision_tree_labeled.xlsx", summary, complete)
