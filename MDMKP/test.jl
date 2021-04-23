include("../src/JOH.jl")
include("MDMKP.jl")

tight_problems = MDMKP.load_folder()
loose_problems =  MDMKP.loosen.(tight_problems)
all_problems = vcat(tight_problems, loose_problems)

decision = MDMKP.decide.(tight_problems)
[(i, count(==(i), decision)) for i in unique(decision)]



decision = MDMKP.decide.(loose_problems)
[(i, count(==(i), decision)) for i in unique(decision)]


decision = MDMKP.decide.(all_problems)
[(i, count(==(i), decision)) for i in unique(decision)]


println(decision)
