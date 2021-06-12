
_split_line(line) = filter(x->x!="", split(line, [' ', '-']))
_parse_int(i) =  try parse(Int, i) catch ArgumentError 
    parse(Int, replace(i, ".00"=>"")) end
_parse_line(line) = map(n->_parse_int(n), _split_line(line))
_find_end(lines) = try first(findall(l->strip(l)=="END OF BENCHMARK", lines)) - 1
        catch BoundsError length(lines) end


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

    MMKP_Data(resource_limits, blocks)
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

    MMKP_Data(resource_limits, blocks)
end

function load_catD(path)
    lines = readlines(open(path))
    file = map(_parse_line, lines) 
    file = filter(l->!isempty(l), file) 
    file
    number_of_blocks, number_of_rows_per_block, number_of_items = popat!(file, 1)
    resource_limits = popat!(file, 1)
    file

    blocks = Vector{Group}() 
    for _ in 1:number_of_blocks
        push!(blocks, extract_fl_block(file, number_of_rows_per_block))
    end

    typeof(resource_limits)
    typeof(blocks)
    MMKP_Data(resource_limits, blocks)
end

folder_keys = [
	"Class A"=>load_catA,
	"Class B"=>load_catB,
	"Class C"=>load_catC,
	"Class D"=>load_catD
]