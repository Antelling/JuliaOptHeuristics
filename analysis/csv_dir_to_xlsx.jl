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
new_results = [("results/Gurobi_test/", "gur.xlsx")]

for (d, n) in new_results
	r = load_dir(d)
	df = vcat(r..., cols=:union)
	df = select(df, [:method, :termination, :problem_id, :problem_dataset,
		:problem_instance, :problem_case, :problem_tightness, :problem_n_vars,
		:problem_n_demands, :problem_n_dimensions, :problem_mixed_obj,
		:objective, :infeasibility,
		Symbol("phase 1 time"),
		Symbol("phase 2 time"),
		Symbol("phase 3 time"),
		Symbol("phase 4 time"),
		Symbol("phase 5 time"),
		Symbol("phase 1 gap"),
		Symbol("phase 2 gap"),
		Symbol("phase 3 gap"),
		Symbol("phase 4 gap"),
		Symbol("phase 5 gap"),
		])
	XLSX.writetable(
			n,
			results = (
				collect(DataFrames.eachcol(df)),
				DataFrames.names(df)),
			overwrite=true)
end
