include("../src/JOH.jl")
include("../MDMKP/MDMKP.jl")

""" create a variety of SSIT methods. Accept a parameter to multiply each time
limit by. """
function make_SSIT_methods(m=1; n_threads=6)
    [
        JOH.Matheur.SSIT.make_SSIT_method([.005, .01, .05, .08], [m*5, m*5, m*5, m*5], "even time",
            n_threads)
        JOH.Matheur.SSIT.make_SSIT_method([.005], [m*20], "one tolerance", n_threads)
        JOH.Matheur.SSIT.make_SSIT_method([.005, .01, .05, .08], [m*2, m*4, m*6, m*8],
            "increasing time", n_threads)
        JOH.Matheur.SSIT.make_SSIT_method([.005, .01, .05, .08], [m*8, m*6, m*4, m*2],
            "decreasing time", n_threads)
    ]
end

problems = MDMKP.load_folder()

model = MDMKP.create_MIPS_model(problems[500])

method = make_SSIT_methods(.1)[end]

results = JOH.Matheur.evaluate(model, method)
