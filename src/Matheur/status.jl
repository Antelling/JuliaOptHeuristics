function Model_DF()::DataFrame
	DataFrame(
		bitarr = BitArray[],
		rtol = Number[],
		objective = Number[],
		solve_time = Number[],
		elapsed_time = Number[],
		time_limit = Number[],
		solution_status = String[],
		term_stat = String[],
		gap = Number[],

		#this snapshot's index
		index = Int[]
	)
end


"""Create a SolverStatus from a model"""
function get_DF_row(m::Model;
		index::Int=0,
		elapsed_time::Number=-1)

	bitarr::BitArray = [0]
	objective=0.0
	gap = -1.0
	try
		bitarr = convert(BitArray, round.(value.(m[:x])))
		objective = objective_value(m)
		gap = MOI.get(m, MOI.RelativeGap())
	catch e
		sleep(.1)
		bitarr = convert(BitArray, round.(value.(m[:x])))
		objective = objective_value(m)
		gap = MOI.get(m, MOI.RelativeGap())
	end

	att = is_gurobi(m) ? "MIPGap" : "CPXPARAM_MIP_Tolerances_MIPGap"
	rtol = get_optimizer_attribute(m, att)

	solve_time = MOI.get(m, MOI.SolveTime())

	att = is_gurobi(m) ? "TimeLimit" : "CPXPARAM_TimeLimit"
	time_limit = get_optimizer_attribute(m, att)
	solution_status = "$(primal_status(m))"
	term_stat = "$(termination_status(m))"
	objective = objective_value(m)

	[bitarr, rtol, objective, solve_time, elapsed_time, time_limit,
		solution_status, term_stat, gap, index]
end
