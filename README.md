# pp-jta

The junction tree algorithm implemented in Julia for the course Probabilistic Programming and AI @ TU Wien.

## Getting started

We used Julia 1.9.4 to implement the algorithm.
Assuming you have Julia installed, run `julia`.  
In the REPL go to package mode with `]`.  
Activate the current project using `activate`.  
And finally install all dependencies using `instantiate`.  

> CURRENTLY NOT WORKING ON ARM MACS

> If there are any errors like "flow_cutter not defined, variants: flow_cutter(g::LabeledGraph)",
> Julia installed the wrong package for QXGraphDecompositions
> Use the following to resolve (in REPL):  
> `]`  
> `remove QXGraphDecompositions`  
> `add https://github.com/jovarga/QXGraphDecompositions.jl`  

## Usage

> TODO