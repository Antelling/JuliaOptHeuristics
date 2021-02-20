include("../src/JOH.jl")
include("SSIT.jl")
include("../MDMKP/MDMKP.jl")

all_problems = MDMKP.load_folder()
p = all_problems[719]
method = SE.make_SSIT_methods()[4]

SE.generate_comparison_data(method, [all_problems[1]], MDMKP.create_MIPS_model, results_dir="results/cplexwhy")
SE.generate_comparison_data(method, [p], MDMKP.create_MIPS_model, results_dir="results/cplexwhy")
