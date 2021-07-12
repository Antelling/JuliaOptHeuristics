### A Pluto.jl notebook ###
# v0.14.8

using Markdown
using InteractiveUtils

# ╔═╡ c7b8a7d7-eda7-4cae-96c8-6c4e52d6e73d
using StructArrays, Query

# ╔═╡ 523d7e80-5c67-47a7-8ed7-69fa06b6b0f3
begin
	using XLSX, DataFrames
	using Statistics: mean
end

# ╔═╡ 9ae4f227-26cc-47c6-b95d-8f7811386171
#split a dataframe by case and dataset, then combine with summary stats
function case_dataset_pivot(summary, method)
	f = filter(row->row.method==method, summary)
	groups = groupby(f, [:case, :dataset])
	combine(groups, nrow => :n_problems,
		:total_elapsed_time => mean => :aver_run_time,
		:highest_rtol => mean => :aver_tol,
		:lowest_gap => mean => :aver_gap)
end

# ╔═╡ db530169-b2d3-48bf-a69a-49b4c070513b
begin
	# table helper functions
	tbl(s) = "<table>" * join(s) * "</table>"
	td(s) = "<td>$(join(s))</td>"
	tr(s) = "<tr>$(join(s))</tr>"
	
	init_table(df) = fill("", (6*9, 6))
end

# ╔═╡ c9f0573c-ce4c-4114-8bee-5c52a3016246
# the combined dataset/case pivot table is a tall rectangle where every entry is a row
# we use this function to write each record to a specific location of a 2D summary 
# table 
""" write the passed dataframe to the record object, at the location specifed by df[:case] and df[:dataset]"""
function store!(record, df) 
	str(i) = "$i"
	j = df[:case]
	i = ((df[:dataset] - 1) * 6) + 1
	
	record[i, j] = str(df[:case])
	record[i + 1, j] = str(df[:dataset])
	record[i + 2, j] = str(df[:n_problems])
	record[i + 3, j] = str(df[:aver_run_time])
	record[i + 4, j] = str(df[:aver_tol])
	record[i + 5, j] = str(df[:aver_gap])
end

# ╔═╡ e4f32a9c-34ff-4990-bd8b-2508eecd6e03
""" turn a combined GroupedDataframe into a flat table """
function flat_tbl(g)
	record = init_table(g)
	map(val -> store!(record, val), eachrow(g))
	record
end

# ╔═╡ 001d0435-b172-47c9-86e4-316a6a1104e0
show_tbl(g) = HTML(tbl(mapreduce(r -> tr(td.(r)), *, eachrow(flat_tbl(g)))))

# ╔═╡ 46b258b5-2e68-4739-a77b-a583afbe3dd6
"""turn an array into a head=>tail pair, used to add titles to the XLSX sheet when
making it a DataFrame"""
function col_to_pair(col)
	h, t = Iterators.peel(col)
	h => collect(t)
end

# ╔═╡ 8e2669a4-5382-45bc-b91e-2fe27b2a6910
#read the excel file we are summarizing
begin 
	f = XLSX.readxlsx("../decision_tree_C.xlsx")
	sh = f["Sheet1"]
	dfm = DataFrame(map(col_to_pair, eachcol(DataFrame(sh[:]))))
	dfm
end

# ╔═╡ dde4a7e7-2298-440c-ae72-3546aaf8ef56
vasko_sum_table = case_dataset_pivot(dfm, "ssit");

# ╔═╡ 853f8eab-e829-423c-9a11-8153ff14090d
show_tbl(vasko_sum_table)

# ╔═╡ 8668715e-a505-4a59-9934-94d9ba824d95


# ╔═╡ 2ed608a9-b0f5-4c1d-85de-a0000f5009b2


# ╔═╡ 76515738-b71a-4d65-8583-3924d160813e


# ╔═╡ Cell order:
# ╠═853f8eab-e829-423c-9a11-8153ff14090d
# ╠═dde4a7e7-2298-440c-ae72-3546aaf8ef56
# ╠═9ae4f227-26cc-47c6-b95d-8f7811386171
# ╠═db530169-b2d3-48bf-a69a-49b4c070513b
# ╠═001d0435-b172-47c9-86e4-316a6a1104e0
# ╠═e4f32a9c-34ff-4990-bd8b-2508eecd6e03
# ╠═c9f0573c-ce4c-4114-8bee-5c52a3016246
# ╠═8e2669a4-5382-45bc-b91e-2fe27b2a6910
# ╠═46b258b5-2e68-4739-a77b-a583afbe3dd6
# ╠═c7b8a7d7-eda7-4cae-96c8-6c4e52d6e73d
# ╟─523d7e80-5c67-47a7-8ed7-69fa06b6b0f3
# ╠═8668715e-a505-4a59-9934-94d9ba824d95
# ╠═2ed608a9-b0f5-4c1d-85de-a0000f5009b2
# ╠═76515738-b71a-4d65-8583-3924d160813e
