function loosen(problem)
    new_lower_bounds = []
    for lb in problem.lower_bounds
        new_lb = convert(Int, floor(lb[2] * .1))
        push!(new_lower_bounds, (lb[1], new_lb))
    end

    MDMKP.MDMKP_Prob(problem.objective, problem.upper_bounds, new_lower_bounds,
        MDMKP.Problem_ID(
            problem.id.id,
            problem.id.dataset,
            problem.id.instance,
            problem.id.case,
            problem.id.tightness,
            problem.id.n_vars,
            problem.id.n_demands,
            problem.id.n_dimensions,
            problem.id.mixed_obj,
            true
        ))
end

function decide(problem)
    id = problem.id
    if id.loosened
        if id.n_dimensions < 20 ||
                id.n_vars < 175 ||
                id.tightness >= .625 ||
                id.mixed_obj
            'A'
        else
            'C'
        end
    else
        if id.n_demands >= 12.5
            return 'C' end
        if id.n_dimensions < 7.5
            if !id.mixed_obj || id.n_vars < 175
                return 'A' end
            'B'
        else
            if id.n_vars < 175
                'A'
            else
                'B'
            end
        end
    end
end
