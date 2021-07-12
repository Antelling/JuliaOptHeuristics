module MMKP 

using JuMP 

export load_folder

struct Item
    profit::Int64 
    resources::Vector{Int64}
end
function Item(v::Vector{Int64})
    Item(first(v), v[2:end])
end

const Group = Vector{Item}

struct MMKP_Data
    resource_bounds::Vector{Int}
    groups::Vector{Group}
end

mutable struct MMKP_Prob 
    id::Dict 
    model::Union{Model,Nothing}
end

include("loaders.jl")
include("moi_model.jl")
include("load_mps.jl")
problems = load_problems()

function get_id(path)
    class, instance = splitpath(path)[end-1:end]
    Dict("class"=>class, "instance"=>first(split(instance, ".")))
end

function load_file(path, loader; n_threads=4)
    id = get_id(path)
    problem = loader(path)
    model = jump_model(problem, n_threads)
    MMKP_Prob(id, model)
end

_get_loader(path) = first(filter(i-> !isnothing(i), 
        map(fl->occursin(fl[1], path) ? fl[2] : nothing, folder_keys)))
function load_subfolder(path)
    l = _get_loader(path)
    map(f->load_file(f, l), readdir(path, join=true))
end

function load_folder(path=joinpath(@__DIR__, "benchmark_problems"))
    vcat(load_subfolder.(readdir(path, join=true))...)
end


end
