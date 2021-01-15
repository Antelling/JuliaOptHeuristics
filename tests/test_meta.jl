include("../src/JOH.jl")
include("../MDMKP/MDMKP.jl")

JOH.Meta.Pop

problem = rand(MDMKP.load_folder())
reproducer = JOH.Meta.Reproducer(
	0, 0, 1, false, false,
	JOH.Meta.Reproduction.CAWS
)
hill_climber = JOH.Meta.Trainer(JOH.Meta.LocalSearch.greedy_flip)
env = JOH.Meta.Pop.Environment(problem, reproducer, hill_climber, population_size=30,
		time_limit=3)
pop = JOH.Meta.Pop.populate(env, MDMKP.MDMKP_Sol)
pop = JOH.Meta.optimize(pop)
