using CSV, XLSX
using DataFrames

function load_dir(dir)
    res = []
    for i in 1:length(readdir(dir))
        push!(res, CSV.read(joinpath(dir, "$i.csv"), DataFrame))
    end
    res
end

r = load_dir("results/Feb1/")
df = vcat(r..., cols=:union)
XLSX.writetable(
		"Feb1.xlsx",
		results = (
			collect(DataFrames.eachcol(df)),
			DataFrames.names(df)),
		overwrite=true)
