module GAP

using Main.JOH #import abstract types
using JuMP #used to create the MOI model
using CPLEX #used to provide the default optimizer

struct GAPID <: JOH.ProblemID
	id::Int
	name::String
	dataset::Char
	num_agents::Int
	num_jobs::Int
end

function GAPID(id::Int, dataset::Char, num_agents::Int, num_jobs::Int)
	GAPID(id, "$dataset $(string(num_jobs, pad=6)) $(string(num_agents, pad=2))", dataset, num_agents, num_jobs)
end

struct GAPProb <: JOH.Problem
	id::GAPID
    job_agent_cost::Array{Int, 2}
    job_agent_resource::Array{Int, 2}
    agents_resource_cap::Vector{Int}
end

struct GAPSol <: JOH.Solution
	problem::GAPProb
	value::Array{Int, 2}
end

include("load_folder.jl")

function create_MIPS_model(problem::GAPProb;
		optimizer=CPLEX.Optimizer,
		time_limit=20,
		num_threads=6)::Model
	model = Model(optimizer)

	#set cplex params
	JOH.Matheur.set_threads!(model, num_threads)
	JOH.Matheur.set_time!(model, time_limit)

    #make the problem variables with a Binary constraint
    @variable(model, x[1:problem.id.num_agents, 1:problem.id.num_jobs], Bin)

	# add constraint that the variable matrix columns all sum
	# to 1
	for i in 1:problem.id.num_jobs
		@constraint(model, sum(x[:, i]) == 1)
	end

	# add constraint that the resources used to assign jobs to
	# agents are less than the agent resource caps
	for i in 1:problem.id.num_agents
		@constraint(model, sum(x[i, :] .* problem.job_agent_resource[:, i])
			<= problem.agents_resource_cap[i])
	end

	@objective(model, Min, sum(transpose(x) .* problem.job_agent_cost))

    model
end


# problems = load_folder()

# function ge(model, f)
# 	try
# 		f(model)
# 	catch e
# 		return -1 end
# end
#
# function run_model(problem)
# 	m = create_MIPS_model(problem, time_limit=10)
# 	JOH.Matheur.silent_optimize!(m)
# 	(problem.id.name, m, ge(m, objective_value), ge(m, termination_status))
# end
#
# map(run_model, problems)

end
