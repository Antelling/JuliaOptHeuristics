include("MMKP.jl")

mp(a, b) = joinpath("MMKP", "benchmark_problems", a, b * ".txt")
flat(a) = vcat(a...)

test_cases = [
	['A', "Class A", ["I07", "I13"]],
	['B', "Class B", ["INST01", "INST11", "INST20"]],
	['C', "Class C", ["INST21", "INST30"]],
	['D', "Class D", ["Instance1", "Instance256"]],
	['D', "Class D", ["Instance100"]]
]
test_problems = flat(map(tc->[[tc[1], mp(tc[2], file)] for file in tc[3]], test_cases))

loaders = Dict('A'=>load_catA, 'B'=>load_catB, 'C'=>load_catC, 'D'=>load_catD)


function load_model(tc)
	println("testing $(tc[2])")
	problem = loaders[tc[1]](tc[2])
	model = jump_model(problem, 4)
	model
end

models = load_model.(test_problems)

load_model(test_problems[end])

function test_optimize(m)
	set_optimizer(m, CPLEX.Optimizer)
	JOH.Matheur.set_time!(m, 5)
	optimize!(m)
	m
end

test_optimize.(models)