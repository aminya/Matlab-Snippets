# Matlab-Snippets
Generate Matlab snippets for Atom and VSCode

Uses Matlab's original JSON and XML files to generate the snippets.

Snippets contain:
  - function description
  - function prototype
  - link to help
  - function toolbox name

# How to use
Snippets are available in snippets folder (Atom and VSCode)

# How to generate
You need to install Julia language, then:
```julia
# cd to this project then:
using Pkg; Pkg.activate("."); Pkg.instantiate();
include("matlab2atom.jl")
```
