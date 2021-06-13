function load_problem(path)
	p = splitpath(path)[end]
	name = replace(p, ".mps"=>"")

	id = Dict("id"=>name)
	model = read_from_file(path)
	MMKP_Prob(id, model)
end

function load_problems(; folder="MMKP/problems")
	map(load_problem, readdir(folder, join=true))
end
