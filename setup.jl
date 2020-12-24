using Pkg
Pkg.add("JuMP")
Pkg.add("StructArrays")
Pkg.add("DataFrames")
Pkg.add("XLSX")
Pkg.add("StatsBase")

#cplex needs to be installed and pointed at the CPLEX installation directory
#this will probably fail:
ENV["CPLEX_STUDIO_BINARIES"] = "/opt/ibm/ILOG/CPLEX_Studio1210/cplex/bin/x86-64_linux/"
Pkg.add("CPLEX")
Pkg.build("CPLEX")
