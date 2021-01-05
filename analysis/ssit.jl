using DataFrames, XLSX
using Query
using Gadfly, Cairo, Fontconfig

table = XLSX.readtable(
    "./results/SSITmethods_2minmax_16core_mcgonagall.xlsx",
    "method_problem_results")
df = DataFrame(table...)

function get_methods(df)
    m = @from i in df begin
        @where i.infeasibility == 0
        @select i.method_name
    end
    m |> @unique() |> collect
end

function get_means(method, df)
    @from i in df begin
        @where i.infeasibility == 0
        @where i.method_name == method
        @select i.lowest_gap
        @collect DataFrame
    end
end

function get_means(df)
    Dict( method.value => get_means(method, df) for method in get_methods(df) )
end

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
