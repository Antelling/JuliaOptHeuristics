module Record

using StructArrays
using .JOH
using DataFrames

"""Each problem contains an ID element that has a whole lot of information
about the problem that we might want to split over later. This will take all
the id structs and turn them into a dataframe. Each ID element"""
function get_id_DF(problems::Vector{T}) where T <: JOH.Problem

end


"""Gets a dataframe with a row for each SSIT phase that
is ran on the problem."""
function get_SSIT_dataframe(problem, method)
	results = JOH.Matheur.evaluate(model, method)
	results[:pid] = problem.id.id
	results
end

function experiment_DF()
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

end
