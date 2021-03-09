module SSIT

using JuMP
using ...JOH
using ...JOH.Matheur

export SSIT_method, make_SSIT_method

""" container for SSIT formulations """
struct SSIT_method <: JOH.Matheur.Matheuristic
    tolerances::Vector{Number}
    times::Vector{Number}
    name::String
    num_threads::Int
	executor
end

function make_SSIT_method(tolerances, times,
		name, num_threads)
	SSIT_method(tolerances, times, name, num_threads, run_SSIT)
end

function save_log(previous_model, current_model, method, phase_index)
	p = mkpath("error_log/$phase_index")
	write_to_file(previous_model, "$p/previous_model.lp")
	write_to_file(current_model, "$p/current_model.lp")
	open("$p/method.dat", "w") do f
		print(f, method)
	end
end

"""
Accept an MDMKP problem, an optional initial solution and associated generation
time, and an array of tolerances and a matched array of time limits. Run the
SSIT method on the problem, and record the results thereof.
"""
function run_SSIT(m::JuMP.Model, method::SSIT_method; phase=1,
		error_handler=save_log)
	Matheur.set_threads!(m, method.num_threads)

	results_DF = Matheur.Model_DF()

	previous_model = copy_model(m)
	for i in 1:length(method.tolerances)
		Matheur.set_tolerance!(m, method.tolerances[i])
		time_limit = method.times[i]
		Matheur.set_time!(m, time_limit)

		elapsed_time = Matheur.silent_optimize!(m)

		if elapsed_time > time_limit * 1.05
			println("error: $(now()) : time elapsed by phase was $elapsed_time,
			 	exceeding $time_limit")
			error_handler(previous_model, m, method, i)
		end

		row = Matheur.get_DF_row(m, elapsed_time=elapsed_time, index=i)
		push!(results_DF, row)

		previous_model = m

		if termination_status(m) == MOI.OPTIMAL || termination_status(m) ==
				MOI.INFEASIBLE
			break
		end
	end

	results_DF
end

end
