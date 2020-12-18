"""Main module for Julia Optimization Heuristics"""
module JOH

export Solution, Problem

abstract type Solution end
abstract type Problem end

include("Matheur/Matheur.jl")

end
