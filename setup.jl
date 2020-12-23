using Pkg
Pkg.add("JuMP")
Pkg.add("StructArrays")
Pkg.add("DataFrames")
Pkg.add("XLSX")

#cplex needs to be installed and pointed at the CPLEX installation directory
#this will probably fail:
Pkg.add("CPLEX")
