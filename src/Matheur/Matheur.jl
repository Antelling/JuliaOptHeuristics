module Matheur

using JuMP
using DataFrames: DataFrame
using ..JOH
export Matheuristic, evaluate, Model_DF, get_DF_row

abstract type Matheuristic end

function evaluate(model::Model, matheuristic::T; id=1) where {T<:Matheuristic}
	matheuristic.executor(model, matheuristic, id=id)
end

include("utils.jl")
include("status.jl")
include("SSIT.jl")

end
