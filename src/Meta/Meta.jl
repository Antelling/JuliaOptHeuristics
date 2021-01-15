module Meta

using ..JOH


struct Reproducer
	n_top::Int
	n_bottom::Int
	n_random::Int
	use_mean::Bool
	select_extrema_every_perturb::Bool
	reproducer::Function
end

struct Trainer
	trainer::Function
end

struct Environment
	problem::JOH.Problem
    #algorithm behavior settings
    brood_size::Int
    population_size::Int

	#sub methods
    reproduction_method::Reproducer
    training_method::Trainer

    #runtime settings
    time_limit::Int
    num_threads::Int
end

struct Population
	solutions::Vector{JOH.Solution}
	environment::Environment
end


include("Reproduction.jl")
include("LocalSearch.jl")
include("Population.jl")



end
