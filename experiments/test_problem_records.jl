include("../src/JOH.jl")
include("../MDMKP/MDMKP.jl")
include("SSIT.jl")

using CPLEX
const Optimizer = CPLEX

function extract_info(d)
    d1 = split(d, "(Number[")[2]
    d2 = split(d1, "], Number[")
    first = d2[1]
    d3 = split(d2[2], "], \"")
    second = d3[1]
    d4 = split(d3[2], "\", ")
    third = d4[1]
    d5 = split(d4[2], ", ")
    fourth = d5[1]
    fifth = split(d5[2], ")")[1]
    [first, second, third, fourth, fifth]
end

function parse_info(info)
    numbers(data, type) = [parse(type, n) for n in split(data, ", ")]

    methods = SE.make_SSIT_methods()
    get_method(name) = filter(m->m.name == name, methods)
    get_method(info[3])[1]
end

function load_ssit_method(d)
    parse_info(extract_info(d))
end


struct Error
    problem::JOH.Problem
    method
    model
    solution::AbstractArray{Bool}
    phase::Int
end

function load_folder_info(filename)
    s = split(filename, "(")[2]
    s = split(s, ",")[1]
    id = parse(Int, s)
    problem = MDMKP.load_folder()[id]

    phase = parse(Int, split(filename, "_")[3])

    method = open(joinpath("./error_log/", filename, "method.dat")) do io
        load_ssit_method(read(io, String))
    end

    model = MDMKP.create_MIPS_model(problem, Optimizer.Optimizer)

    solution = open(joinpath("./error_log/", filename, "solution.dat")) do io
        read(io, String)
    end
    sol = solution[2:end-1]
    parser(x) = parse(Float64, x) == 1.0
    solution = parser.(split(sol, ","))

    Error(problem, method, model, solution, phase)
end


all_problems = MDMKP.load_folder()
errors = load_folder_info.(readdir("./error_log/"))

function test_error(e::Error; mod=1)
    model = e.model
	model[:x] = e.solution
	JOH.Matheur.set_threads!(model, e.method.num_threads)

	JOH.Matheur.set_tolerance!(model, e.method.tolerances[e.phase])
	time_limit = e.method.times[e.phase]/mod
	JOH.Matheur.set_time!(model, time_limit)
	elapsed_time = JOH.Matheur.silent_optimize!(model)
	ratio = elapsed_time/time_limit
	return (elapsed_time, ratio)
end

test_error(errors[2], mod=60)

# println(test_error.(errors))
