### A Pluto.jl notebook ###
# v0.14.5

using Markdown
using InteractiveUtils

# ╔═╡ 523d7e80-5c67-47a7-8ed7-69fa06b6b0f3
begin
	using XLSX, DataFrames
	using Statistics: mean
end

# ╔═╡ 474add99-3a68-4ec7-8acc-1f02179093ec
begin
	each_elem(row) = zip(names(row), first.(eachcol(row)))
	tr(v) = "<tr><td>$(round(last(v), sigdigits=3))</td></tr>"
	group_summary(row) = join(["<table>", tr.(each_elem(row))..., "</table>"])
end

# ╔═╡ d0d4237f-d8e9-4ebe-a154-e6ee689b748e
function vasko_summary_table(df::DataFrame)
	elements = ["<h1>Title</h1>", "<table>"]
	for dataset in 1:9
		push!(elements, "<tr>")
		for case in 1:6
			push!(elements, "<td>")
			row = filter(r->r.dataset==dataset&&r.case==case, df)
			try
				push!(elements, group_summary(row))
			catch BoundsError
				push!(elements, "<table><tr><td>$case</td></tr><tr><td>$dataset</td></tr><tr><td>0</td></tr><tr><td>-1</td></tr><tr><td>-1</td></tr><tr><td>-1</td></tr></table>")
			end
			push!(elements, "</td>")
		end
		push!(elements, "</tr>")
	end
	push!(elements, "</table>")
	HTML(join(elements))	
end

# ╔═╡ 9ae4f227-26cc-47c6-b95d-8f7811386171
function case_dataset_pivot(summary, category)
	f = filter(row->row.category==category, summary)
	groups = groupby(f, [:case, :dataset])
	vasko_summary = combine(groups, nrow => :n_problems,
		:total_elapsed_time => mean => :aver_run_time,
		:highest_rtol => mean => :aver_tol,
		:lowest_gap => mean => :aver_gap)
end

# ╔═╡ 46b258b5-2e68-4739-a77b-a583afbe3dd6
"""turn an array into a head=>tail pair, used to add titles to the XLSX sheet when
making it a DataFrame"""
function col_to_pair(col)
	h, t = Iterators.peel(col)
	h => collect(t)
end

# ╔═╡ 8e2669a4-5382-45bc-b91e-2fe27b2a6910
begin 
	f = XLSX.readxlsx("../df.xlsx")
	sh = f["Sheet1"]
	dfm = DataFrame(map(col_to_pair, eachcol(DataFrame(sh[:]))))
	md"### dfm = ", dfm
end

# ╔═╡ 0dbe71da-1a47-41fe-b80e-c7ebba9f1d47
vasko_summary_table(case_dataset_pivot(dfm, "A"))

# ╔═╡ fa1b76a5-e117-43c0-9873-231ead43c602
row = filter(r->r.dataset==3&&r.case==2, case_dataset_pivot(dfm, "A"))

# ╔═╡ dd2dc6e2-fb9b-406d-a794-373a3816bfff


# ╔═╡ Cell order:
# ╠═0dbe71da-1a47-41fe-b80e-c7ebba9f1d47
# ╠═474add99-3a68-4ec7-8acc-1f02179093ec
# ╠═d0d4237f-d8e9-4ebe-a154-e6ee689b748e
# ╠═fa1b76a5-e117-43c0-9873-231ead43c602
# ╠═9ae4f227-26cc-47c6-b95d-8f7811386171
# ╠═8e2669a4-5382-45bc-b91e-2fe27b2a6910
# ╠═46b258b5-2e68-4739-a77b-a583afbe3dd6
# ╠═523d7e80-5c67-47a7-8ed7-69fa06b6b0f3
# ╠═dd2dc6e2-fb9b-406d-a794-373a3816bfff
