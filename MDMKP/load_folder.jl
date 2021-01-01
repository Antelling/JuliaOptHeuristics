"""Will load a collection of 90 problems from a passed filename.
Files must be in the
http://people.brunel.ac.uk/~mastjjb/jeb/orlib/mdmkpinfo.html format."""
function parse_file(filename::String, dataset_num::Int, uid=0)
    f = open(filename)

    problems::Vector{MDMKP_Prob} = []

    #the very first item in the array is the amount of problems found in the
    #file.
    amount_of_problems = next_line(f)[1]

	instance_num = 0
    #so now for every problem:
    for problem in 1:amount_of_problems
		instance_num += 1
        n, m = next_line(f)
        lower_than_values::Vector{Vector{Int}} = []
        for i in 1:m
            push!(lower_than_values, next_line(f))
        end
        lower_than_constraints::Vector{Int} =  next_line(f)
        greater_than_values::Vector{Vector{Int}} = []
        for i in 1:m
            push!(greater_than_values, next_line(f))
        end
        greater_than_constraints = next_line(f)
        cost_coefficient_values::Vector{Vector{Int}} = []
        for i in 1:6
            push!(cost_coefficient_values, next_line(f))
        end

        upper_bounds::Vector{Tuple{Vector{Int},Int}} = []
        lower_bounds::Vector{Tuple{Vector{Int},Int}} = []

        for i in 1:m
            push!(lower_bounds, (greater_than_values[i], greater_than_constraints[i]))
            push!(upper_bounds, (lower_than_values[i], lower_than_constraints[i]))
        end

        q = [1, div(m, 2), m, 1, div(m, 2), m]
        for i in 1:6
			uid += 1
			id = Problem_ID(
				uid,
				dataset_num,
				instance_num,
				i,
				get_tightness(i),
				length(cost_coefficient_values[i]),
				length(lower_bounds[1:q[i]]),
				length(upper_bounds),
				is_mixed(i)
			)
            push!(problems, MDMKP_Prob(
                cost_coefficient_values[i],
                upper_bounds,
                lower_bounds[1:q[i]],
				id
            ))
        end
    end

    (problems, uid)
end

function next_line(file::IOStream)
    return parse_line(readline(file))
end

function parse_line(line)
    return map(parse_int, split(line))
end

function parse_int(x)
    return parse(Int, x)
end

function get_tightness(case)
	[.25, .5, .75][Int(ceil(case/5))]
end

function is_mixed(case)
	case > 3
end

function load_folder(
		folder_path="MDMKP/benchmark_problems",
		filename="mdmkp_ct{ds}.txt", datasets=1:9)::Vector{MDMKP_Prob}
	collection = []
	id = 0
	for ds in datasets
		fn = replace(filename, "{ds}"=>"$ds")
		problems, id = parse_file(joinpath(folder_path, fn), ds, id)
		push!(collection, problems)
	end
	vcat(collection...)
end
