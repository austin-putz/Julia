#==============================================================================#
# Solve MME
#==============================================================================#

# Author:    Austin Putz
# Created:   Sept 27, 2017
# Modified:  Sept 12, 2018
# License:   MIT

#==============================================================================#
# Description
#==============================================================================#

# This script is to give solutions to the problem in Mrode Linear Models
# Chapter 3 with basic BLUP

#==============================================================================#
# Script
#==============================================================================#

#------------------------------------------------------------------------------#
# Read in functions
#------------------------------------------------------------------------------#

println("#----------------------------------------")
println("# Reading in A function")
println("#----------------------------------------")

# load the A matrix function
include("makeA.jl")

println("\nDone\n")

#------------------------------------------------------------------------------#
# Give Variance Components
#------------------------------------------------------------------------------#

# give variance components
var_a = 20
var_e = 40
alpha = var_e / var_a

#------------------------------------------------------------------------------#
# Set up MME
#------------------------------------------------------------------------------#

println("#----------------------------------------")
println("# Read pedigree and create A and inverse")
println("#----------------------------------------")

# create A
ped = [1 0 0; 2 0 0; 3 0 0; 4 1 0; 5 3 2; 6 1 2; 7 4 5; 8 3 6]

# create A
A = makeA(ped)
Ainv = inv(A)

println("\nDimentions of A: ", size(A), "\n")

println("Done\n")

#------------------------------------------------------------------------------#
# Set up MME
#------------------------------------------------------------------------------#

println("#----------------------------------------")
println("# Set up MME")
println("#----------------------------------------")

# y 
y = [4.5, 2.9, 3.9, 3.5, 5.0]

# X matrix
X = [1 0; 0 1; 0 1; 1 0; 1 0]

# Z matrix elements
Zleft  = zeros(5, 3)
Zright = Array{Float64}(I, 5, 5)    # new in 1.0

# combine left and right sizes of Z
Z = hcat(Zleft, Zright)   # or use [Zleft Zright] will do the same thing

# calculate LHS of MME
top    = hcat(X'X, X'Z)
bottom = hcat(Z'X, Z'Z + Ainv*alpha)
LHS    = vcat(top, bottom)

# Or Use:
# [X'X X'Z
# Z'X  Z'Z .+ (Ainv*alpha)]
# for an 'all in one solution' (may be more efficient)

println("\nLeft Hand Side (LHS) Built!")

# calculate RHS
RHS = vcat(X'y, Z'y)  # or use [X'y; Z'y]  # just the semicolon in between them

println("\nRight Hand Side (RHS) Built!\n")

#------------------------------------------------------------------------------#
# Solving MME
#------------------------------------------------------------------------------#

println("#----------------------------------------")
println("# Solving MME...")
println("#----------------------------------------")

# solve
sol = LHS\RHS   # to solve MME! (inverse(LHS)*RHS)

# fixed effects solutions
sol_fixed = sol[1:size(X)[2]]   # can use size(X)[2] to make sure it's always the right length

# print them
println("\nFixed solutions to MME\n\n", sol_fixed, "\n")

# random effects solutions (breeding values)
sol_random = sol[size(X)[2]+1:end]

println("EBV solutions to MME\n\n", sol_random, "\n")

#------------------------------------------------------------------------------#
# Done
#------------------------------------------------------------------------------#

println("#----------------------------------------")
println("# DONE!!!")
println("#----------------------------------------")











