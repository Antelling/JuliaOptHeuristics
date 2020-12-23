using DataFrames
using XLSX
using StructArrays
using StatsBase

include("../src/JOH.jl")
include("../MDMKP/MDMKP.jl")

""" create a variety of SSIT methods. Accept a parameter to multiply each time
limit by. """
function make_SSIT_methods(m=1; n_threads=6)
    [
        JOH.Matheur.SSIT.make_SSIT_method(
			[.005, .01, .05, .08],
			[m*5, m*5, m*5, m*5],
			"even time", n_threads)
        JOH.Matheur.SSIT.make_SSIT_method(
			[.005, .005, .005, .005],
			[m*5,m*5,m*5,m*5],
			"one tolerance", n_threads)
        JOH.Matheur.SSIT.make_SSIT_method(
			[.005, .01, .05, .08],
			[m*2, m*4, m*6, m*8],
            "increasing time", n_threads)
        JOH.Matheur.SSIT.make_SSIT_method(
			[.005, .01, .05, .08],
			[m*8, m*6, m*4, m*2],
            "decreasing time", n_threads)
    ]
end


struct MethodProblemResult
	method_name
	problem_id
	lowest_gap
	highest_reached_tolerance
	total_time
	last_phase_time
	cplex_obj
	true_obj
	infeasibility
	n_phases
end

MethodProblemResult(method, problem, solution, last_row) = MethodProblemResult(
	method.name,
	problem.id.id,
	last_row[:gap],
	last_row[:rtol],
	last_row[:elapsed_time],
	last_row[:solve_time],
	last_row[:objective],
	solution.objective,
	solution.infeasibility,
	last_row[:index])

mutable struct ExperimentResults
	problem_ids::Vector{MDMKP.Problem_ID}
	SSIT_phases::Vector{DataFrame}
	method_problem_results::Vector{MethodProblemResult}
end

ExperimentResults() = ExperimentResults([], [], [])

function generate_comparison_data(
		problems::Vector{T},
		methods::Vector{JOH.Matheur.SSIT.SSIT_method},
		experiment::ExperimentResults) where T <: JOH.Problem

	for problem in problems
		push!(experiment.problem_ids, problem.id)

		for method in methods
			model = MDMKP.create_MIPS_model(problem)
			ssit_phases = JOH.Matheur.evaluate(model, method)
			ssit_phases[!, :method] .= method.name
			ssit_phases[!, :problem_id] .= problem.id.id

			push!(experiment.SSIT_phases, ssit_phases)
			lp = last(ssit_phases, 1)
			solution = MDMKP.MDMKP_Sol(lp[!, :bitarr][1], problem)

			method_problem_result = MethodProblemResult(method, problem,
				solution, lp)
			push!(experiment.method_problem_results, method_problem_result)
		end
	end
	experiment
end

function ba_rep(ba)
	join([b == 1 ? "1" : "0" for b in ba], "")
end

problems = MDMKP.load_folder()
ssit_methods = make_SSIT_methods(12, n_threads=8)

experiment = ExperimentResults()
data = generate_comparison_data(
	problems, ssit_methods, experiment)

pids = DataFrame(StructArray(data.problem_ids))
pms = DataFrame(StructArray(data.method_problem_results))
pms[:id] = pms[:problem_id]
df = innerjoin(pids, pms, on=:id)
df = select(df, Not(:id))
ssit_phases = vcat(experiment.SSIT_phases...)
ssit_phases[:bitarr] = map(ba_rep, ssit_phases[:bitarr])


XLSX.writetable(
	"report.xlsx",
	method_problem_results = (
		collect(DataFrames.eachcol(df)),
		DataFrames.names(df)),
	ssit_phases = ( collect(DataFrames.eachcol(ssit_phases)),
		DataFrames.names(ssit_phases) ),
	problem_id_info = (
		collect(DataFrames.eachcol(pids)),
		DataFrames.names(pids)),
	overwrite=true)
