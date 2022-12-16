# Julia

Julia code

Make sure to softlink your newest julia version to your ~/bin folder on Mac/Linux so you can access julia with simply 'julia' on the command line. Use the command line to add your bin folder if you haven't already. 

```bash
# if it doesn't exist:
mkdir bin 
# move into bin
cd bin
```
Soft link the Julia program in your bin, then you can run `julia` from anywhere. 

I think on Mac I used the following. 

```bash
# soft link
ln -s /Applications/Julia-0.4.5.app/Contents/Resources/julia/bin/julia julia
```

Of course change the path to your current version (i.e. not v0.4.5). 

On Linux (Ubuntu) I add this line to my `.bash_profile`:

```bash
alias julia='/home/amputz/bin/julia-0.7.0/bin/julia'
```

finally add this line to your .bash_profile if you haven't already (adds to your PATH so it can search executables):

```bash
export PATH=$HOME/bin:$PATH
```



## Stream Editing

I wrote a stream editor in the file `stream_editor.jl`. You can replace your file name and your dictionary to search and replace line by line with Julia. 



## Animal Breeding

### makeA.jl

Used to create the A matrix, adopted from Gota Morota's R function. 

### chapter3.jl

Code for chapter 3 of Mrodes book. Solve the basic animal model MME with Julia!





