#==============================================================================#
# makeA.jl
#==============================================================================#

# Created by:    Austin Putz
# Original date: 2016-05-01
# Last updated:  2018-09-12
# License:       GPLv2.0

#==============================================================================#
# Description
#==============================================================================#

# Create the A matrix the old school way (Henderson 1976)

#==============================================================================#
# Function
#==============================================================================#
 
# Load packages
# using DataFrames

# Begin Function
function makeA(ped, print=false)

 	s = ped[:,2]
	d = ped[:,3]

	n = length(s)
	N = n + 1
	A = zeros(N, N)

	s = (s == 0)*N .+ s
	d = (d == 0)*N .+ d

# Begin FOR loop
	for i in 1:n

	#	print("i is: ", i, "\n")

		if ((s[i] == 0) | (d[i] == 0))
			A[i, i] = 1
		else
			A[i, i] = 1 + (A[s[i], d[i]]/2)
		end

		for j in (i+1):n

	#		print("j is: ", j, "\n\n")

			if ((s[j] == 0) && (d[j] == 0))
	#			print("set 1", "\n")
				A[i, j] = 0
			elseif ((s[j] == 0) && (d[j] != 0))
	#			print("set 2", "\n")
				A[i, j] = (A[i, d[j]])/2
			elseif ((s[j] != 0) && (d[j] == 0))
	#			print("set 3", "\n")
				A[i, j] = (A[i, s[j]])/2
			else
	#			print("set 4", "\n\n")
				A[i, j] = (A[i, s[j]] + A[i, d[j]])/2
			end

		# Symmetric
		A[j, i] = A[i, j]

	end
end 

	# return the A matrix part
	return A[1:n, 1:n]

end



