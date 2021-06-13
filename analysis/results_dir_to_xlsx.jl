using XLSX, JSON
using DataFrames
using Statistics: mean
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
	highest_rtol = -1.0
	lowest_gap = -1.0
	for phase in 1:nrow(df)
		su[!, "p$(phase)_obj"] = [-1*df.objective[phase]]
		su[!, "p$(phase)_gap"] = [df.gap[phase]]
		su[!, "p$(phase)_dettime"] = [df.dettime[phase]]
		su[!, "p$(phase)_solve_time"] = [df.solve_time[phase]]
		su[!, "p$(phase)_elapsed_time"] = [df.elapsed_time[phase]]
		su[!, "p$(phase)_rtol"] = [df.rtol[phase]]
		su[!, "p$(phase)_term"] = [df.term_stat[phase]]

		highest_rtol = df.rtol[phase]
		lowest_gap = df.gap[phase]
	end
	su[!, "total_solve_time"] = [sum(df.solve_time)]
	su[!, "total_elapsed_time"] = [sum(df.elapsed_time)]
	su[!, "total_dettime"] = [sum(df.dettime)]
	su[!, "highest_rtol"] = [highest_rtol]
	su[!, "lowest_gap"] = [lowest_gap]
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

function category_section_table(summary_df, category)
	filtered = filter(row->row.category==category, summary_df)
	filtered
end

function load_summary(folder)
	#make complete and summary dataframes
	complete, summary = read_result_dir(folder)
	problem_df = MDMKP_id_dataframe()
	complete, join_summary_problem_tables(summary, problem_df)
end


function case_dataset_pivot(summary, category)
	f = category_section_table(summary, category)
	groups = groupby(f, [:case, :dataset])
	vasko_summary = combine(groups, nrow => :n_problems,
		:total_elapsed_time => mean => :aver_run_time,
		:highest_rtol => mean => :aver_tol,
		:lowest_gap => mean => :aver_gap)

	XLSX.writetable(
		"category_$(category)_grouped_stats.xlsx",
		results =(
			collect(DataFrames.eachcol(vasko_summary)),
			DataFrames.names(vasko_summary) ))
end

function write_excel_decision_tree_results(; folder="results/decision_tree/")
	complete, summary = load_summary(folder)

	XLSX.writetable(
		"test(decision_tree_results).xlsx",
		results =(
			collect(DataFrames.eachcol(summary)),
			DataFrames.names(summary) ),
		complete_results =(
			collect(DataFrames.eachcol(complete)),
			DataFrames.names(complete) ))
end

function add_column(df, col, data)
	replace(col, " "=>"_")
	println(df, col, data)
	df[!, Symbol(col)] = repeat([data], nrow(df))
	df
end

function load_song_results(; folder="results/full_song_mdmkp")

	load_df(file) = load_summary(file)[2]
	load_method_df(method) = add_column(load_df(method), "method",
		last(splitpath(method)))

	methods = readdir(folder, join=true)
	methods = filter(x->isdir(x), methods)
	dataframes = load_method_df.(methods)

    data = vcat(dataframes..., cols=:union)
	data
end


df = load_song_results(folder="results/decision_tree/B")

XLSX.writetable("decision_tree_B.xlsx", collect(DataFrames.eachcol(df)), DataFrames.names(df))
