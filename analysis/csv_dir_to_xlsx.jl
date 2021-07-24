using CSV, XLSX
using DataFrames

function load_dir(dir)
    res = []
    for file in readdir(dir)
		df = CSV.read(joinpath(dir, file), DataFrame)
		insertcols!(df, 1, :file=>[file])
        push!(res, df)
    end
    res
end

gap_compare_results = [("results/GAP_exp/ssit", "GAP_comp_ssit.xlsx"), ("results/GAP_exp/norm", "GAP_comp_norm.xlsx")]
gurobi_gap_comp = [
	("results/GAP_exp_Gurobi/first", "gurobi_first.xlsx"),
	("results/GAP_exp_Gurobi/second", "gurobi_second.xlsx"),
	("results/GAP_exp_Gurobi/third", "gurobi_third.xlsx")
]
mmkp_res = [
	("results/long_mmkp/ssit", "long_ssit_mmkp.xlsx"),
	("results/long_mmkp/base", "long_base_mmkp.xlsx")
	]

function write_results(results_pairs)
	for (d, n) in results_pairs 
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

write_results(mmkp_res)
