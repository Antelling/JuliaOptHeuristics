using DataFrames, XLSX
using Query
using Gadfly, Cairo, Fontconfig

table = XLSX.readtable(
    "./results/SSITmethods_2minmax_16core_mcgonagall.xlsx",
    "method_problem_results")
df = DataFrame(table...)

function save_plot(p, name)
    Gadfly.with_theme(:dark) do
        img = PNG("analysis/graphs/$name.png", 30cm, 10cm, dpi=300)
        draw(img, p)
    end
end

feasible_df = df |> @filter(_.infeasibility == 0 && _.case > 3 && _.dataset > 6) |> DataFrame

xticks = [.005, .05, .25, .5, .75]
p = plot(feasible_df, x="lowest_gap", y="total_time",
    ygroup="case", xgroup="dataset",
    color="method_name",
    # Scale.x_log10(),
    Geom.subplot_grid(Geom.point))
save_plot(p, "scatter")
