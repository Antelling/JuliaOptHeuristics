is_gurobi(m) = solver_name(m) == "Gurobi"

"""set the MIPGap parameter of the passed CPLEX model to the passed tolerance"""
function set_tolerance!(model, tolerance)
	if !is_gurobi(model)
		set_optimizer_attribute(model, "CPXPARAM_MIP_Tolerances_MIPGap", tolerance)
	else
		set_optimizer_attribute(model, "MIPGap", tolerance)
	end
end

function set_time!(model, time)
	if !is_gurobi(model)
		set_optimizer_attribute(model, "CPXPARAM_TimeLimit", time)
	else
		set_optimizer_attribute(model, "TimeLimit", time)
	end
end

function set_threads!(model, num_threads)
	if !is_gurobi(model)
		set_optimizer_attribute(model, "CPXPARAM_Threads", num_threads)
	else
		set_optimizer_attribute(model, "Threads", num_threads)
	end
end

"""accept a struct with a bitlist attribute and set the model to have the same
bitlist as its start value"""
function set_bitlist!(model, sol)
	set_start_value.(model[:x], convert.(Float64, sol.bitlist))
end

"""Run CPLEX optimization without printing to the console"""
function silent_optimize_slow!(m)
	tempout = stdout # save stream
	start_time, end_time = 0, 0
	try
		redirect_stdout(nothing) # redirect to null
		start_time = time()
		optimize!(m)
		end_time = time()
		GC.gc()
		redirect_stdout(tempout)
	catch e
		#restore stream if user interrupts process, or other error
		redirect_stdout(tempout)
		return e
	end
	end_time - start_time
end


function silent_optimize!(m)
	start_time = time()
	optimize!(m)
	end_time = time()
	GC.gc()
	end_time - start_time
end
