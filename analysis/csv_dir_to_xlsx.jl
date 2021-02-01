using CSV, XLSX
using DataFrames

function load_dir(dir)
    res = []
    for i in 1:length(readdir(dir))
        push!(res, CSV.read(joinpath(dir, "$i.csv"), DataFrame))
    end
    res
end

pwd()
length(readdir("./results/fast_trial/"))

r = load_dir("results/fast_trial/")
df = vcat(r..., cols=:union)
XLSX.writetable(
		"fast.xlsx",
		results = (
			collect(DataFrames.eachcol(df)),
			DataFrames.names(df)),
		overwrite=true)
