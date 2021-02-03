
function read_file(filename)
    data = read(open(filename, "r"), String)

    parsed_data = Vector{Vector{Int}}()
    for line in split(data, "\n")
        parsed_line = []
        for number in split(line, " ")
            if number != ""
                number = parse(Int, number)
                push!(parsed_line, number)
            end
        end
        push!(parsed_data, parsed_line)
    end
    parsed_data
end

function parse_file(d::Vector{Vector{Int}}, ds, id)
    i = 1
    (num_agents, num_jobs) = d[i]
    # return num_agents, num_jobs
    agent_job_cost_mat = hcat(d[i+1:i+num_agents]...)
    i += num_agents
    # return agent_job_cost_mat
    agent_job_resource_mat = hcat(d[i+1:i+num_agents]...)
    i += num_agents
    agents_resource_cap = d[i+1]
    GAPProb(
        GAPID(ds, num_agents, num_jobs),
        agent_job_cost_mat,
        agent_job_resource_mat,
        agents_resource_cap)
end

function flat_parse_file(d::Vector{Int}, ds)
    i = 0
    function ni(l)
        i += 1
        l[i]
    end

    num_agents = ni(d)
    num_jobs = ni(d)

    agent_job_costs = []
    for agent in 1:num_agents
        row = []
        for job in 1:num_jobs
            push!(row, ni(d))
        end
        push!(agent_job_costs, row)
    end

    agent_job_resources = []
    for agent in 1:num_agents
        row = []
        for job in 1:num_jobs
            push!(row, ni(d))
        end
        push!(agent_job_resources, row)
    end

    agents_resource_cap = []
    for agent in 1:num_agents
        push!(agents_resource_cap, ni(d))
    end

    prep(l) = hcat(l...)
    GAPProb(
        GAPID(ds, num_agents, num_jobs),
        prep(agent_job_costs),
        prep(agent_job_resources),
        agents_resource_cap)
end

function load_folder(folder="GAP/benchmark_problems/")
    gaps = Vector{GAPProb}()
    for file in readdir(folder)
        dataset = file[1]
        data = read_file(joinpath(folder, file))
        try
            gap = flat_parse_file(vcat(data...), dataset)
            push!(gaps, gap)
        catch  DimensionMismatch
            println("error loading $file")
        end
    end
    sort(gaps, by=x->x.id.name)
end
