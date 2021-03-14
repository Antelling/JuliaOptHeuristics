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
wtfc = [("results/cplexwhy/", "cplexwhy.xlsx")]

for (d, n) in wtfc
	r = load_dir(d)
	df = vcat(r..., cols=:union)
	XLSX.writetable(
			n,
			results = (
				collect(DataFrames.eachcol(df)),
				DataFrames.names(df)),
			overwrite=true)
end
