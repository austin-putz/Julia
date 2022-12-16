# Stream editor in Julia

# Author: Austin Putz
# Date: Dec 05, 2022
# Modified: Dec 16, 2022

# Description, will search and replace within a file using a dictionary

# Please use your own file names and dictionary below to stream edit
# instead of using back to back to back sed commands or something else. 

# genotypes.txt
# animal1 10120101002
# animal2 10120101002
# animal3 10120101002

# genotypes_replaced.txt
# animal1 65675656557
# animal2 65675656557
# animal3 65675656557

# open the file for reading (rename to your file names)
infile = open("genotypes.txt", "r")            # Replace file name!
outfile = open("genotypes_replaced.txt", "w")  # Replace file name!

# read each line in file
for line in eachline(infile)

	# split based on spaces, take last column (string of genotypes)
	split_line = split(line, " ")[end]

	# search for 0 and repalce it with 5
	line = replace(split_line, 
		"0" => "5", "1" => "6", "2" => "7"). # Replace with your own dictionary like this!

	# print updated line
	write(outfile, line, "\n")

end

# close the file
close(infile)
close(outfile)



