#------------------------------------------------------------------------------#
# Script: create_G.jl
#------------------------------------------------------------------------------#

# Author:   Austin Putz
# Created:  Dec 2, 2022
# Modified: Jan 8, 2023
# License:  GPLv3
# Version:  0.1.0

#------------------------------------------------------------------------------#
# Descrition
#------------------------------------------------------------------------------#

# This script creates the genomic relationship matrix (G) from genotypes

#------------------------------------------------------------------------------#
# Libraries
#------------------------------------------------------------------------------#

# Packages
using BenchmarkTools
using LinearAlgebra

# set thread (core) count for BLAS
BLAS.set_num_threads(7)

#------------------------------------------------------------------------------#
# Main
#------------------------------------------------------------------------------#

# message
println("Create Haplotypes")

# set boolean 0/1 for haplotypes
@time M1 = rand(Bool, (10000, 50000))
@time M2 = rand(Bool, (10000, 50000))

# message
println("Add Haplotypes for Genotype")

# add haplotypes to get genotype matrix (0/1/2)
@time M = M1 + M2

# reset X1 and X2 variables to garbage collect later
M1 = 1
M2 = 1

# message
println("Convert to Float32")

# convert Int to Float
@time M = Matrix{Float32}(M)

# message
println("Get Column Means (2 x p) and p (allele freq)")

# get allele freq * 2 (column mean)
@time col_means = mean(M, dims=1)
@time p = vec(col_means / 2)

# message
println("Calc Sum(2pq)")

# calculate sum(2pq)
@time sum2pq = 2 * (p' * (1 .- p))
println("  Sum2pq: $sum2pq")

# message
println("Create Z = M - P")

# create Z
@time Z = M .- col_means

# message
println("Create G")

# multiply M by itself to get G matrix
@time G = (Z * Z') / sum2pq

# message
println("Det of G")

# calc determinant
#@time det(G)
#@time eigen(G)

# message
println("Diagonals of G")

# extract diagonals of G
Gdiag_mat = Diagonal(G)
Gdiag_vec = diag(G)

# print space
println("\n\n")
