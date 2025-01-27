"""Main module for Julia Optimization Heuristics"""
module JOH

export Solution, Problem

abstract type Solution end
abstract type ProblemID end
abstract type Problem end

include("Matheur/Matheur.jl")
include("Meta/Meta.jl")

end
