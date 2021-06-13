mkpath("problems")
function write_file(problem; folder_name="MMKP/problems")
	path = joinpath(folder_name, problem.id["id"]) * ".mps"
	write_to_file(problem.model, path)
end
write_file.(problems)