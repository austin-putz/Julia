#------------------------------------------------------------------------------#
# process_genotypes.jl
#------------------------------------------------------------------------------#

# How to download packages:
# using Pkg
# Pkg.add("CSV")

# load packages
using CSV
using DataFrames
using DataFramesMeta
using BenchmarkTools
using UnicodePlots
using Statistics
using Missings

#------------------------------------------------------------------------------#
# Inputs
#------------------------------------------------------------------------------#

# genotype file name
folder = "/Users/austinputz/Documents/Hypor/Research/Inbreeding/"
genotype_file_name = "genotype_with_ped_sub.mrk"

#------------------------------------------------------------------------------#
# Read in Full Genotype File
#------------------------------------------------------------------------------#

# read in genotype file
@time data_geno = CSV.read(folder * genotype_file_name, 
	DataFrame, 
	delim = ' ', 
	header = false, 
	ntasks = 4, 
	types = [Int64, Int64, Int64, String, String, String, String, String])

# rename all columns
data_geno = rename(data_geno, 
		[:Column1 => :ID,
		:Column2 => :Sire,
		:Column3 => :Dam,
		:Column4 => :Line,
		:Column5 => :Sex,
		:Column6 => :BirthYear,
		:Column7 => :Line2,
		:Column8 => :Genotype]);

# print head of file
first(data_geno, 5)

#------------------------------------------------------------------------------#
# Process genotypes
#------------------------------------------------------------------------------#

# number of SNPs and Inds
n_SNPs = length(data_geno[:, :Genotype][1])
n_Inds, n_Cols = size(data_geno)

# print number of SNPs and Animals
println("Number of SNPs: $n_SNPs")
println("Number of Animals: $n_Inds")

# message
println("Extract Genotypes from DataFrame")

# vector of genotypes as a string "01200100"
@time geno_vec = data_geno[:, :Genotype]

# message
println("Convert genotype string into a matrix of Float64")

# include geno_string2float function to convert genotype string into a matrix of 0/1/2/missing
include("geno_string2float.jl")

# convert string vector of genotypes into a Float64 matrix
geno_matrix = geno_string2float(geno_vec)

#------------------------------------------------------------------------------#
# Extract sub DataFrames by Year
#------------------------------------------------------------------------------#

# extract list of birth years
lines       = sort(unique(data_geno[:, :Line]))
birth_years = sort(unique(data_geno[:, :BirthYear]))

# include F_Meuwissen Function
include("F_Meuwissen.jl")

# calculate F
results = F_Meuwissen(geno_matrix, data_geno, lines, birth_years)

# write out CSV
CSV.write("results_F.csv", results)

aaaaa

#------------------------------------------------------------------------------#
# Subset genotype files
#------------------------------------------------------------------------------#

# subset to each different line
data_geno_C   = data_geno[data_geno.Line.=="C",:]

# separate genotype matrix by line
geno_mat_C   = geno_matrix[data_geno[:, :Line] .== "C", :]

# subset line + birth year
geno_mat_C_2017 = geno_matrix[((data_geno[:, :Line] .== "C") .* (data_geno[:, :BirthYear] .== "2017")), :]
geno_mat_C_2018 = geno_matrix[((data_geno[:, :Line] .== "C") .* (data_geno[:, :BirthYear] .== "2018")), :]
geno_mat_C_2019 = geno_matrix[((data_geno[:, :Line] .== "C") .* (data_geno[:, :BirthYear] .== "2019")), :]
geno_mat_C_2020 = geno_matrix[((data_geno[:, :Line] .== "C") .* (data_geno[:, :BirthYear] .== "2020")), :]
geno_mat_C_2021 = geno_matrix[((data_geno[:, :Line] .== "C") .* (data_geno[:, :BirthYear] .== "2021")), :]
geno_mat_C_2022 = geno_matrix[((data_geno[:, :Line] .== "C") .* (data_geno[:, :BirthYear] .== "2022")), :]

#------------------------------------------------------------#
# Allele Freqs
#------------------------------------------------------------#

# calculate allele freqs (has a ton of missing values)
#Statistics.mean(geno_mat_C, dims=1)

# calculate allele freqs
p_C_2017 = mean.(skipmissing.(eachcol(geno_mat_C_2017))) ./ 2
p_C_2022 = mean.(skipmissing.(eachcol(geno_mat_C_2022))) ./ 2

# concat all allele freqs together
p_C_mat = hcat(p_C_2017, p_C_2022)

# add q to the matrix
p_C_mat = [p_C_mat (1 .- p_C_mat[:, 1])]
p_C_mat = [p_C_mat (1 .- p_C_mat[:, 2])]

# correlation of allele freqs
cor(p_C_mat)

# histogram of allele freqs (C line 2017)
histogram(p_C_mat[:, 1], nbins=20)

#------------------------------------------------------------#
# Track changes in allele freqs
#------------------------------------------------------------#

# estimate change between 2017 and 2022
p_change_2017_2022 = p_C_mat[:,1] .- p_C_mat[:,2]

# histogram of allele freq changes - C Line - 2017 to 2022
histogram(p_change_2017_2022, nbins=20)

#------------------------------------------------------------#
# Calculate F_homozygosity
#------------------------------------------------------------#

# calculate F_homozygosity between 2022 and 2017 for C Line

# calculate 2pq for current year and first year
vec_top    = 2 .* p_C_mat[:, 2] .* (1 .- p_C_mat[:, 2])   # for 2022
vec_bottom = 2 .* p_C_mat[:, 1] .* (1 .- p_C_mat[:, 1])   # for 2017
vec_ratio  = vec_top ./ vec_bottom

# find problem SNPs
vec9 = vec_ratio .> 17
p_C_mat[vec9, :]

# find low values in 2pq
p_C_mat[vec_top .< 0.0001, :]
p_C_mat[vec_bottom .< 0.0001, :]

# set high values to missing to calculate instead 
vec_ratio  = allowmissing(vec_ratio)
vec_ratio  = map(x -> x > 2 || isnan(x) ? missing : x, vec_ratio)

# subset vector to only contain real values
vec_ratio_float = convert.(Float64, skipmissing(vec_ratio))

# histogram of this vector
histogram(vec_ratio_float)

# calculate F_homozygosity
F_hom = 1 - (sum(skipmissing(vec_ratio)) / n_SNPs)

# cutting > 2   => 0.043406274468048345
# cutting > 100 => 0.006929297991662309

# 0.1 / 0  = Inf
# 0   / 0  = NaN
# 0   / 10 = 0.0

# contains NaN values
F_hom = 1 - sum(vec_top ./ vec_bottom) / n_SNPs

#------------------------------------------------------------#
# Calculate F_drift
#------------------------------------------------------------#

# allele freq diffs squared
vec_top    = (p_C_mat[:, 6] .- p_C_mat[:, 1]).^2
vec_bottom = p_C_mat[:, 1] .* p_C_mat[:, 7]
vec_ratio  = vec_top ./ vec_bottom
vec_ratio  = allowmissing(vec_ratio)
vec_ratio  = map(x -> x > 2 || isnan(x) ? missing : x, vec_ratio)

vec_ratio_float = convert.(Float64, skipmissing(vec_ratio))

# plot vector of ratios
histogram(vec_ratio_float)

# calculate F_drift
F_drift = sum(skipmissing(vec_ratio)) / n_SNPs

# cutting at 2   => 0.024526265781856033
# cutting at 100 => 0.024526265781856033















