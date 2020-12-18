module Matheur

include("utils.jl")
using JuMP

abstract type Matheuristic end

function evaluate(model::Model, matheuristic::T) where {T<:Matheuristic}
	matheuristic.executor(model, matheuristic)
end

SolverStatus() = []

"""Create a SolverStatus from a model"""
function SolverStatus(m::Model, elapsed_time::Number=-1)
	bitarr::BitArray = []
	try
		bitarr = convert(BitArray, value.(m[:x]))
	catch e
		bitarr = [0]
	end
	rtol = get_optimizer_attribute(m, "CPXPARAM_MIP_Tolerances_MIPGap")
	solve_time = MOI.get(m, MOI.SolveTime())
	objective = objective_value(m)
	time_limit = get_optimizer_attribute(m, "CPXPARAM_TimeLimit")
	solution_status = "$(primal_status(m))"
	term_stat = "$(termination_status(m))"
	gap = MOI.get(m, MOI.RelativeGap())

	[bitarr, rtol, objective, solve_time, elapsed_time, time_limit,
		solution_status, term_stat, gap]
end

include("SSIT.jl")


end
