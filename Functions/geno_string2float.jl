
# geno_string2float

# This script will convert a single vector string into a full matrix
# of genotype codes 0/1/2, will convert values to missing > 2.5 by default

# Inputs:
#
#   x::Vector{String} is a string vector with genotypes "001201020" for 
#      each individual
#   threshold::Float64 is the threshold for which > is missing
#       most of the time we use 0/1/2 coding for genotypes with 5 = missing
#       so 2.5 is default to set 5's as missing values

# write function to extract this string vector into a Float64 matrix
function geno_string2float(x::Vector{String}; threshold=2.5)

	# get number of SNPs and ind
	n_SNPs = length(x[1,1])
	n_Inds = length(x)
	
	# initialize a matrix
	geno_matrix = allowmissing(fill(0.0, (n_Inds, n_SNPs)))

	# loop over the genotype string vector
	for i in 1:n_Inds
		
		# set genotype string for current animal ("12012010")
		local geno_string = x[i]
		
		# split vector into a string vector (turns this string into a column vector)
		local geno_vec_str = split(geno_string, "")

		# parse whole vector into Float64
		geno_vec_float = parse.(Float64, geno_vec_str)'

		# fill row of initialized matrix above
		geno_matrix[i, :] = geno_vec_float

	end
	
	# fill x > 2.5 as 'missing' value
	geno_matrix = map(x -> x > threshold ? missing : x, geno_matrix)
	
	# return matrix of genotypes
	return geno_matrix
	
end


