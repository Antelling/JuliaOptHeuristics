module MMKP 


using JuMP 

export load_folder

_split_line(line) = filter(x->x!="", split(line, [' ', '-']))
_parse_int(i) =  try parse(Int, i) catch ArgumentError 
    parse(Int, replace(i, ".00"=>"")) end
_parse_line(line) = map(n->_parse_int(n), _split_line(line))
_find_end(lines) = try first(findall(l->strip(l)=="END OF BENCHMARK", lines)) - 1
        catch BoundsError length(lines) end


struct Item
    profit::Int64 
    resources::Vector{Int64}
end
function Item(v::Vector{Int64})
    Item(first(v), v[2:end])
end

const Group = Vector{Item}

struct Problem
    resource_bounds::Vector{Int}
    groups::Vector{Group}
end


include("moi_model.jl")

function extract_block(data; header=true)::Group
    if header
        useless_number = popat!(data, 1)
        @assert length(useless_number) == 1
    end
    extracted = Group()
    while length(data) > 0 && length(first(data)) > 1
        push!(extracted, Item(popat!(data, 1)))
    end
    extracted
end

function extract_fl_block(data, n_items::Int)::Group
    extracted = Group()
    for _ in 1:n_items
        push!(extracted, Item(popat!(data, 1)))
    end
    extracted
end

function load_catA(path)
    lines = readlines(open(path))
    end_index = _find_end(lines)
    file = map(_parse_line, lines[2:end_index]) #skip first empty line 
    file = filter(l->!isempty(l), file) #remove any empty lines
    header_row = popat!(file, 1)
    resource_limits = popat!(file, 1)

    blocks = []
    while length(file) > 0 
        push!(blocks, extract_block(file))
    end

    Problem(resource_limits, blocks)
end

const load_catB = load_catA

function load_catC(path)
    lines = readlines(open(path))
    file = map(_parse_line, lines) 
    file = filter(l->!isempty(l), file) 
    amount_of_groups = popat!(file, 1)
    amount_of_resources = popat!(file, 1)
    resource_limits = popat!(file, 1)
    max_items_per_group = popat!(file, 1)

    blocks = []
    push!(blocks, extract_block(file, header=false))
    while length(file) > 0 
        push!(blocks, extract_block(file))
    end

    Problem(resource_limits, blocks)
end

function load_catD(path)
    path = "MMKP/benchmark_problems/Class D/Instance256.txt"
    lines = readlines(open(path))
    file = map(_parse_line, lines) 
    file = filter(l->!isempty(l), file) 
    file
    number_of_blocks, number_of_rows_per_block, number_of_items = popat!(file, 1)
    resource_limits = popat!(file, 1)
    file

    blocks = Vector{Group}() 
    for _ in 1:number_of_blocks
        push!(blocks, extract_fl_block(file, number_of_items))
    end

    typeof(resource_limits)
    typeof(blocks)
    Problem(resource_limits, blocks)
end

load_catD("MMKP/benchmark_problems/Class D/Instance256.txt")

_block_start_index(i, n_rows) = (i-1)*(n_rows+1) + 1
""" accept the index of a group, the amount of groups and rows per group of this file, and the file data.
Extract the group specified by the index, split into a profit vector and resource matrix, then return the 
tuple. """
function load_block(i, n_blocks, n_items, data)
	d = data[_block_start_index(i, n_items):_block_start_index(i+1, n_items)-1]
	@assert first(first(d)) == i
	items = d[2:end]
	#exactly one of each element in this group must be turned on 
	#in order to represent this in MPS form, we need to one-hot encode the class index
	index = falses(n_blocks)
	index[i] = true 
	
	#then combine the one-hot encoding with the resource requirements
	resource_reqs = map(x->vcat(x[2:end], index), items)
	
	#strip the profit vector, then return the (profit, resources) tuple
	profit = map(x->first(x), items)
	profit, resource_reqs
end



function load_subfolder(path)
    load_problem.(readdir(path, join=true))
end

function load_folder(path=joinpath(@__DIR__, "benchmark_problems"))
    load_subfolder.(readdir(path, join=true))
end

end
