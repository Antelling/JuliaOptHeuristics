### A Pluto.jl notebook ###
# v0.14.5

using Markdown
using InteractiveUtils

# ╔═╡ 8be48d92-2916-40a9-bd99-c3967465e135
using Statistics, Plots, StatsPlots, DataFrames, XLSX, Gadfly, Query

# ╔═╡ 92541b63-eea6-46bc-9961-6c10edf9faea
Gadfly.set_default_plot_size(25cm, 15cm)

# ╔═╡ 50544e4d-5291-46bb-956b-153cb65d527a
"""create stacked histograms showing time results of the different methods"""
function plot_df(df)
	Gadfly.plot(df, 
		x = :total_elapsed_time,
		ygroup=:method,
		Geom.subplot_grid(Geom.histogram()),
		Guide.title("Method over time histograms"))
end

# ╔═╡ 943a8e8f-56dd-4a12-855c-3c18449509a7
f = XLSX.readxlsx("../df.xlsx")

# ╔═╡ 41947d17-3833-4113-ab77-11bfb8e85856
sh = f["Sheet1"]

# ╔═╡ 68b8dc02-b2aa-42a2-8f47-99a1353f511f
"""turn an array into a head=>tail pair, used to add titles to the XLSX sheet when
making it a DataFrame"""
function col_to_pair(col)
	h, t = Iterators.peel(col)
	h => collect(t)
end

# ╔═╡ 7e59a9ce-7bc6-464b-9263-44dcffc2d581
#load excel file into dataframe
dfm = DataFrame(map(col_to_pair, eachcol(DataFrame(sh[:]))))

# ╔═╡ c7b835d6-abff-42b3-b2d6-6b17ab42a9c0
begin
	g1 = groupby(dfm, [:method])
	md"# Method Group Summary", combine(g1, nrow, 
		:lowest_gap=>mean, 
		:total_elapsed_time=>mean=>:time_mean)
end

# ╔═╡ ae2ef880-85d6-4362-acd4-812a8722ff32
begin
	groups = groupby(dfm, [:dataset, :case])
	dc_sum = combine(groups, nrow, 
		:lowest_gap=>mean, 
		:total_elapsed_time=>mean=>:time_mean, :method)
	(md"# Dataset/Case Group Summary", dc_sum)
end

# ╔═╡ c9708e1a-2e9d-43cf-b0f6-768bdf5364a0
plot_df(dfm)

# ╔═╡ Cell order:
# ╠═c7b835d6-abff-42b3-b2d6-6b17ab42a9c0
# ╠═ae2ef880-85d6-4362-acd4-812a8722ff32
# ╠═c9708e1a-2e9d-43cf-b0f6-768bdf5364a0
# ╠═92541b63-eea6-46bc-9961-6c10edf9faea
# ╠═50544e4d-5291-46bb-956b-153cb65d527a
# ╟─943a8e8f-56dd-4a12-855c-3c18449509a7
# ╟─41947d17-3833-4113-ab77-11bfb8e85856
# ╟─68b8dc02-b2aa-42a2-8f47-99a1353f511f
# ╟─7e59a9ce-7bc6-464b-9263-44dcffc2d581
# ╠═8be48d92-2916-40a9-bd99-c3967465e135
