module Meta

using ..JOH

abstract type ReproductionMethod end
abstract type TrainingMethod end

struct Population
    #algorithm behavior settings
    brood_size::Int
    population_size::Int
    reproduction_method::ReproductionMethod
    training_method::TrainingMethod

    #runtime settings
    time_limit::Int
    num_threads::Int
end

include("Reproduction.jl")
include("Mutation.jl")
include("LocalSearch.jl")
include("Population.jl")
include("Subsample.jl")

end
