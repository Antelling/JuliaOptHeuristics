include("../MDMKP/MDMKP.jl")

function MDMKP_id_dataframe()
	tight_problems = MDMKP.load_folder()
	loose_problems = MDMKP.loosen.(tight_problems)
	all_problems = vcat(tight_problems..., loose_problems...)
	labeled_problems = MDMKP.set_decision.(all_problems)

	ids = [p.id for p in labeled_problems]

	df = DataFrame(
		id = Int[],
		dataset = Int[],
		instance = Int[],
		case = Int[],
		tightness = Number[],
		n_vars = Int[],
		n_demands = Int[],
		n_dimensions = Int[],
		mixed_obj = Bool[],
		loosened = Bool[],
		category = String[]
	)

	get_row(id) = [id.id, id.dataset, id.instance, id.case, id.tightness,
		id.n_vars, id.n_demands, id.n_dimensions, id.mixed_obj, id.loosened,
		"$(id.category)"]

	[push!(df, get_row(id)) for id in ids]
	df
end
