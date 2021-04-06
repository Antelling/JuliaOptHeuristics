using JSON

function Model_DF()::DataFrame
	DataFrame(
		bitarr = String[],
		rtol = Number[],
		objective = Number[],
		dettime = Number[],
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


"""Record attributes of interest from a model"""
function get_DF_row(m::Model;
		index::Int=0,
		elapsed_time::Number=-1,
		getdettime=nothing)

	sol = json(value.(all_variables(m)))
	objective = objective_value(m)
	gap = MOI.get(m, MOI.RelativeGap())

	att = is_gurobi(m) ? "MIPGap" : "CPXPARAM_MIP_Tolerances_MIPGap"
	rtol = get_optimizer_attribute(m, att)

	solve_time = MOI.get(m, MOI.SolveTime())

	if !isnothing(getdettime)
		env = m.moi_backend.optimizer.model.env
		dettime_P = Ref{Float64}()
		getdettime(env, dettime_P)
		dettime = dettime_P[]
	else
		dettime = -1.0
	end

	att = is_gurobi(m) ? "TimeLimit" : "CPXPARAM_TimeLimit"
	time_limit = get_optimizer_attribute(m, att)
	solution_status = "$(primal_status(m))"
	term_stat = "$(termination_status(m))"
	objective = objective_value(m)

	[sol, rtol, objective, dettime, solve_time, elapsed_time, time_limit,
		solution_status, term_stat, gap, index]
end
