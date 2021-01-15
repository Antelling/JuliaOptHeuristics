module Pop
using ..JOH

function Environment(problem, reproduction_method, training_method;
		brood_size=5, population_size=50, time_limit=10, num_threads=4)
	JOH.Meta.Environment(problem, brood_size, population_size,
			reproduction_method, training_method, time_limit, num_threads)
end

function rand_val(type::Type{BitArray}, length)
	rand(Bool, length)
end

function create_random_solution(environment, solution_type)
	n_vars = environment.problem.id.n_vars
	value_index = findall(x -> x == :value, Base.fieldnames(solution_type))[1]
	type = Base.fieldtypes(solution_type)[value_index]
	val = rand_val(type, n_vars)
	solution_type(val, environment.problem)
end

function populate(env::JOH.Meta.Environment, sol_type::Type{T}) where T<:JOH.Solution
	crs(i) = create_random_solution(env, sol_type)
	JOH.Meta.Population(map(crs, 1:env.population_size), env)
end

end
