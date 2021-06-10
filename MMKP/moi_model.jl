using JuMP

function one_hot_encode(index, group, n_groups)
    enc = zeros(n_groups)
    enc[index] = 1 
    map(elem->vcat(elem.resources, enc), group)
end

function jump_model(problem::Problem, num_threads)::Model
    model = Model()
	JOH.Matheur.set_threads!(model, num_threads)

    #get matrix of resource requirements per item 
    n_groups = length(problem.groups)
    groups = map(t -> one_hot_encode(t[1], t[2], n_groups), enumerate(problem.groups))
    flat_groups = vcat(groups...)
    resource_mat = hcat(flat_groups...)

    #add the one-hot dimensions to the resource bounds
    res_lims = vcat(problem.resource_bounds, ones(n_groups))

    #extract the profit 
    profit = vcat(map(g->[i.profit for i in g], problem.groups)...)
    
    #make the model
    @variable(model, x[1:length(profit)], Bin)
    @objective(model, Max, sum(profit .* x))
    for (i, row) in enumerate(eachrow(resource_mat))
        @constraint(model, sum(row .* x) <= res_lims[i])
    end

    model
end