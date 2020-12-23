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

"""
Accept an MDMKP problem, an optional initial solution and associated generation
time, and an array of tolerances and a matched array of time limits. Run the
SSIT method on the problem, and record the results thereof.
"""
function run_SSIT(m::JuMP.Model, method::SSIT_method)
	Matheur.set_threads!(m, method.num_threads)

	results_DF = Matheur.Model_DF()

	for i in 1:length(method.tolerances)
		Matheur.set_tolerance!(m, method.tolerances[i])
		Matheur.set_time!(m, method.times[i])

		elapsed_time = Matheur.silent_optimize!(m)

		row = Matheur.get_DF_row(m, elapsed_time=elapsed_time, index=i)
		push!(results_DF, row)

		if termination_status(m) == MOI.OPTIMAL || termination_status(m) ==
				MOI.INFEASIBLE
			break
		end
	end

	results_DF
end

end
