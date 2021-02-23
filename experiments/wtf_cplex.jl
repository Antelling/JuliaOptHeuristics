include("../src/JOH.jl")
include("SSIT.jl")
include("../MDMKP/MDMKP.jl")

all_problems = MDMKP.load_folder()
problematic_problems = [719, 674, 654, 653, 705, 710]
problems = [all_problems[p] for p in problematic_problems]
method = SE.make_SSIT_methods()[4]

SE.generate_comparison_data(method, [all_problems[1]], MDMKP.create_MIPS_model, results_dir="results/cplexwhy")

SE.generate_comparison_data(method, problems, MDMKP.create_MIPS_model, results_dir="results/cplexwhy")
