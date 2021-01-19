using DataFrames, XLSX, Statistics
using Query
using Gadfly, Cairo, Fontconfig

table = XLSX.readtable(
    "./results/SSITmethods_2minmax_16core_mcgonagall.xlsx",
    "method_problem_results")
df = DataFrame(table...)

theme() = Theme(
    panel_stroke=colorant"black",
    background_color=colorant"white",
    # point_size=.07cm,
    grid_color=colorant"grey")

function save_plot(p, name)
    img = PNG("analysis/graphs/$name.png", 30cm, 35cm, dpi=300)
    draw(img, p)
end

feasible_df = df |> @filter(_.infeasibility == 0 && _.dataset > 4) |> DataFrame
infeasible_df = df |> @filter(_.infeasibility > 0 && _.dataset > 4) |> DataFrame

names(feasible_df)
summary_stats = combine(
    groupby(feasible_df, :method_name),
    :lowest_gap=>mean,
    :total_time=>mean)

xticks = [.005, .05, .25, .5, .75]
p = plot(feasible_df, x="lowest_gap", y="total_time",
    ygroup="case", xgroup="dataset",
    color="method_name",
    # Scale.x_log10(),
    Geom.subplot_grid(Geom.point),
    theme())
save_plot(p, "infeasible_scatter")
