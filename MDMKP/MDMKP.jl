module MDMKP

using Main.JOH #import abstract types
using JuMP #used to create the MOI model

export MDMKP_Prob, MDMKP_Sol, load_folder, create_MIPS_model

struct Problem_ID <: JOH.ProblemID
	id::Int
	dataset::Int
	instance::Int
	case::Int
	tightness::Float64
	n_vars::Int
	n_demands::Int
	n_dimensions::Int
	mixed_obj::Bool
end

struct MDMKP_Prob <: JOH.Problem
    objective::Vector{Int}
    upper_bounds::Vector{Tuple{Vector{Int},Int}}
    lower_bounds::Vector{Tuple{Vector{Int},Int}}
	id::Problem_ID
end

struct MDMKP_Sol <: JOH.Solution
	problem::MDMKP_Prob
	value::BitArray
	score::Number
	objective::Number
	infeasibility::Number
end

include("load_folder.jl")

"""Select slices of MDMKP problems"""
function slice_select(problems::Vector{MDMKP_Prob};
		datasets=1:9, cases=1:6, instances=1:15)::Vector{MDMKP_Prob}
	extracted = []
	for prob in problems
		if prob.id.dataset in datasets &&
				prob.id.case in cases &&
				prob.id.instance in instances
			push!(extracted, prob)
		end
	end
	extracted
end

"""Solution Constructor """
function MDMKP_Sol(bitlist::AbstractArray{Bool}, problem::MDMKP_Prob)
    upper_bounds_totals = [sum(coeffs .* bitlist) for (coeffs, bound) in
		problem.upper_bounds]
    lower_bounds_totals = [sum(coeffs .* bitlist) for (coeffs, bound) in
		problem.lower_bounds]

	#add dimension constraint infeasibility
    infeasibility = sum([
		upper_bounds_totals[i] > upper_bound ?
			upper_bounds_totals[i] - upper_bound : 0
    	for (i, (constraint_coeffs, upper_bound)) in enumerate(
				problem.upper_bounds)
	])

	#add demand constraint infeasibility
    infeasibility += sum([
		lower_bounds_totals[i] < lower_bound ?
			lower_bound - lower_bounds_totals[i] : 0
        for (i, (contraint_coeffs, lower_bound)) in enumerate(
				problem.lower_bounds)
	])

	#calculate the objective function
    objective_value = sum(problem.objective .* bitlist)

	#the score is the objective function if feasible, else infeasibility
    score = infeasibility > 0 ? -infeasibility : objective_value

    MDMKP_Sol(
		problem,
        bitlist,
        score,
        objective_value,
        infeasibility
    )
end

"""Accept an MDMKP problem, and return a formulation that includes heavily
penalized artificial variables to make the discovery of a feasibile solution
trivial. """
function create_MIPS_model(problem::MDMKP_Prob, optimizer;
		time_limit=20,
		weight=1000,
		num_threads=6)::Model
	model = Model(optimizer)
	_create_MIPS_model(problem, model, time_limit, weight, num_threads)
end
function create_MIPS_model(problem::MDMKP_Prob;
		time_limit=20,
		weight=1000,
		num_threads=6)::Model
	model = Model()
	_create_MIPS_model(problem, model, time_limit, weight, num_threads)
end
function direct_model(problem::MDMKP_Prob, model;
		time_limit=20,
		weight=1000,
		num_threads=6)::Model
	_create_MIPS_model(problem, model, time_limit, weight, num_threads)
end

function _create_MIPS_model(problem, model, time_limit, weight, num_threads)::Model
	JOH.Matheur.set_threads!(model, num_threads)
	JOH.Matheur.set_time!(model, time_limit)

    #make the problem variables with a Binary constraint
    @variable(model, x[1:length(problem.objective)], Bin)

	#make the artificial variables to fix infeasibility
	@variable(model, s[1:length(problem.upper_bounds)] <= 0)
	@variable(model, ss[1:length(problem.lower_bounds)] >= 0)

	# objective is the normal objective value minus the artificial values
	# needed to make feasible
    @objective(model, Max,
		sum(problem.objective .* x) - weight * (-sum(s)+sum(ss)))

	# add dimension constraints
    for (i, ub) in enumerate(problem.upper_bounds)
        @constraint(model, sum(ub[1] .* x) + s[i] <= ub[2])
    end

	# add demand constraints
    for (i, lb) in enumerate(problem.lower_bounds)
        @constraint(model, sum(lb[1] .* x) + ss[i] >= lb[2])
    end

    model
end

end
