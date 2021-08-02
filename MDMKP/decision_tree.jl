function loosen(problem; percent=.1, id_increment=1000, label::Char='?')
    new_lower_bounds = []
    for lb in problem.lower_bounds
        new_lb = convert(Int, floor(lb[2] * percent))
        push!(new_lower_bounds, (lb[1], new_lb))
    end

    MDMKP.MDMKP_Prob(problem.objective, problem.upper_bounds, new_lower_bounds,
        MDMKP.Problem_ID(
            problem.id.id + id_increment,
            problem.id.dataset,
            problem.id.instance,
            problem.id.case,
            problem.id.tightness,
            problem.id.n_vars,
            problem.id.n_demands,
            problem.id.n_dimensions,
            problem.id.mixed_obj,
            true,
            '?'
        ))
end

function decide(problem)
    id = problem.id
    if id.loosened
        if id.n_dimensions < 20
            'A'
        else
            if id.n_vars < 175
                'A'
            else
                if id.tightness >= .625
                    'A'
                else
                    if id.mixed_obj
                        'A'
                    else
                        'C'
                    end
                end
            end
        end
    else
        if id.dataset == 7 && in(id.case, [3, 6]) 
            'D'
        elseif id.n_demands >= 12.5
            'C'
        else
            if id.n_dimensions < 7.5
                if !id.mixed_obj
                    'A'
                else
                    if id.n_vars < 175
                        'A'
                    else
                        'B'
                    end
                end
            else
                if id.n_vars < 175
                    'A'
                else
                    'B'
                end
            end
        end
    end
end

function set_decision(problem)
    decision = decide(problem)

    MDMKP.MDMKP_Prob(
        problem.objective,
        problem.upper_bounds,
        problem.lower_bounds,
        
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
            problem.id.loosened,
            decision
        ))
end
