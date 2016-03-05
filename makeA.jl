#==============================================================================#
# makeA.jl
#==============================================================================#
 

#==============================================================================#
# Description
#==============================================================================#

# Create the A matrix the old school way 

#==============================================================================#
# Description
#==============================================================================#
 
using DataFrames

animals = [1,2,3,4,5,6]
sires   = [0,0,1,1,4,5]
dams    = [0,0,2,0,3,2]

ped = DataFrame(ID = animals, s = sires, d = dams)

print(ped, "\n")

print("\n")

s = ped[2]
d = ped[3]

n = length(s)
N = n + 1
A = zeros(N, N)

s = (s == 0)*N + s
d = (d == 0)*N + d


for i in 1:n

	print("i is: ", i, "\n")

	if ((s[i] == 0) | (d[i] == 0))
		A[i, i] = 1
	else
		A[i, i] = 1 + (A[s[i], d[i]]/2)
	end

	for j in (i+1):n

		print("j is: ", j, "\n\n")

		if ((s[j] == 0) && (d[j] == 0))
			print("set 1", "\n")
			A[i, j] = 0
		elseif ((s[j] == 0) && (d[j] != 0))
			print("set 2", "\n")
			A[i, j] = (A[i, d[j]])/2
		elseif ((s[j] != 0) && (d[j] == 0))
			print("set 3", "\n")
			A[i, j] = (A[i, s[j]])/2
		else
			print("set 4", "\n\n")
			A[i, j] = (A[i, s[j]] + A[i, d[j]])/2
		end

		A[j , i] = A[i, j]

	end
end 

return A[1:n-1, 1:n-1]







