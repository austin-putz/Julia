#------------------------------------------------------------------------------#
# Script: create_G_GPU.jl
#------------------------------------------------------------------------------#

# Author:   Austin Putz
# Created:  Jan 3, 2023
# Modified: Jan 9, 2023
# License:  GPLv3
# Version:  0.0.1

#------------------------------------------------------------------------------#
# Descrition
#------------------------------------------------------------------------------#

# This script creates the genomic relationship matrix (G) from genotypes
# with the help of a GPU hopefully.

# NOTE: This scripts requires a GPU. I'm currently testing on an
# Nvidia 2080. You need drivers from Nvidia if you install one on your machine.
# Test with CUDA.versioninfo() to see if it recognizes and run
# Pkg.test("CUDA") as well.

#------------------------------------------------------------------------------#
# Libraries
#------------------------------------------------------------------------------#

# Packages
using BenchmarkTools
using LinearAlgebra
using CUDA
using Random
using Distributions

# set thread (core) count for BLAS
BLAS.set_num_threads(7)

#------------------------------------------------------------------------------#
# Main
#------------------------------------------------------------------------------#
# message
println("Create Haplotypes")

# set boolean 0/1 for haplotypes
@time M = rand(Binomial(2, 0.5), (10000, 50000))

# message
println("Convert to Float32")

# convert Int to Float
#@time M = Matrix{Float32}(M)   # OLD
@time M = Float32.(M)

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

println("Convert to CuArray")

# convert to CuArray and use GPU
@time Z2 = CuArray(Z)
@time G = (Z2 * Z2') / sum2pq
#@time G = (Z2 * Z2') / sum2pq  # sometimes running it twice changes timing...

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

