# pp-jta

The junction tree algorithm implemented in Julia for the course Probabilistic Programming and AI @ TU Wien.

## Getting started

We used Julia 1.9.4 to implement the algorithm.
Assuming you have Julia installed, run `julia`.  
In the REPL go to package mode with `]`.  
Activate the current project using `activate`.  
And finally install all dependencies using `instantiate`.  

> If there are any errors like "flow_cutter not defined, variants: flow_cutter(g::LabeledGraph)",
> Julia installed the wrong package for QXGraphDecompositions
> Use the following to resolve (in REPL):  
> `] add https://github.com/jovarga/QXGraphDecompositions.jl`  


> ARM Mac:
> Use x64 Julia for this package since the underlying graph decomposition library uses a binary not available for ARM
> Download `juliaup` and install `release~x64`, then set it as default

## Usage

The module exposes the main function `jta_from(path, evidence, flow_cutter_timeout)` to obtain the marginalized distributions from a bayesian network.
It takes the following parameters:
- `path`
    - string
    - The path to an instance file (we currently only support .rda files)
    - Instances used in benchmarking are provided in the `instances` folder (obtained from [bnlearn](https://www.bnlearn.com/bnrepository/))
- `evidence`
    - dict{int, int}
    - A simple way to introduce evidence in the model
    - Maps the variable (same index as in the rda file, can be inspected by calling RData.load()) to its value (index in the value array, e.g. variable X with true and false would be 1=true, 2=false)
- `flow_cutter_timeout`
    - int
    - named parameter
    - The runtime of the flow cutter algorithm, responsible for obtaining the tree decomposition
    - Larger networks may require a higher timeout to find a better tree decomposition
    - Better decomposition may result in smaller overall runtime


You can also run the test with `] test`, which will run all small and medium networks.  
If you want to run other instances, you have to change the test in `test/runtests.jj`

We compared our results to the R package gRain.
We used the script in `test/grain_bnlearn.R` to evaluate the same instances with gRain.