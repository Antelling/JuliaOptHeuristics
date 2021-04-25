using CSV, XLSX
using DataFrames

function load_dir(dir)
    res = []
    for file in readdir(dir)
        push!(res, CSV.read(joinpath(dir, file), DataFrame))
    end
    res
end

gap_compare_results = [("results/GAP_exp/ssit", "GAP_comp_ssit.xlsx"), ("results/GAP_exp/norm", "GAP_comp_norm.xlsx")]
gurobi_gap_comp = [
	("results/GAP_exp_Gurobi/first", "gurobi_first.xlsx"),
	("results/GAP_exp_Gurobi/second", "gurobi_second.xlsx"),
	("results/GAP_exp_Gurobi/third", "gurobi_third.xlsx")
]

function write_results(results_pairs)
	for (d, n) in gurobi_gap_comp
		r = load_dir(d)
		df = vcat(r..., cols=:union)
		XLSX.writetable(
				n,
				results = (
					collect(DataFrames.eachcol(df)),
					DataFrames.names(df)),
				overwrite=true)
	end
end

write_results(gurobi_gap_comp)
