include("MDMKP.jl")

tight_problems = MDMKP.load_folder()
loose_problems =  MDMKP.loosen.(tight_problems)

decision = MDMKP.decide.(tight_problems)
[(i, count(==(i), decision)) for i in unique(decision)]
