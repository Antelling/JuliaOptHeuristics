module LocalSearch
using ..JOH

function greedy_flip(sol::JOH.Solution)
    sol(sol.bitlist, sol.problem)

end


"""Performs an exhaustive search of the local bit flip neighborhood, over and
over, until no improvement is found. """
function greedy_flip(sol::Solution, problem::Problem)
    sol = CompleteSolution(sol.bitlist, problem)
    improved = true
    while improved
        improved = greedy_flip_internal!(sol, problem)
    end
    Solution(sol)
end
#
# """Loop over every bit in a bitarry, and calculate the score if the bit were
# flipped. Then, if an improved score were found, flip the bit that lead to the
# greatest improvement, and return true. Else, return false. """
# function greedy_flip_internal!(sol::CompleteSolution, problem::Problem)::Bool
#     index_to_change = 0
#     best_found_score = sol.score
#     # println("best found score is $best_found_score")
#     feas = best_found_score > 0
#     # println("feas is $feas")
#     for i in 1:length(sol.bitlist)
#         # println("starting score is $(sol.score)")
#         if flip_bit!(sol, problem, i, feas=feas)
#             # println("resulting flip scores $(sol.score)")
#             if sol.score > best_found_score
#                 # println("new high found")
#                 best_found_score = sol.score
#                 index_to_change = i
#             else
#                 # println("feas short circuit")
#             end
#
#             flip_bit!(sol, problem, i) #flip the bit back
#         end
#         # println("ending score is $(sol.score)")
#     end
#     if index_to_change > 0
#         # println("changing an index $index_to_change")
#         flip_bit!(sol, problem, index_to_change)
#         # println("score is now $(sol.score)")
#         return true
#     end
#     return false
# end
#
end
