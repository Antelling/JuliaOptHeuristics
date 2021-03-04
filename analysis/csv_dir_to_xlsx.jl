using CSV, XLSX
using DataFrames

function load_dir(dir)
    res = []
    for i in 1:length(readdir(dir))
        push!(res, CSV.read(joinpath(dir, "$i.csv"), DataFrame))
    end
    res
end

gap_compare_results = [("results/GAP_exp/ssit", "GAP_comp_ssit.xlsx"), ("results/GAP_exp/norm", "GAP_comp_norm.xlsx")]
wtfc = [("results/cplexwhy/", "cplexwhy.xlsx")]

for (d, n) in gap_compare_results
	r = load_dir(d)
	df = vcat(r..., cols=:union)
	XLSX.writetable(
			n,
			results = (
				collect(DataFrames.eachcol(df)),
				DataFrames.names(df)),
			overwrite=true)
end