"""
	GraphicalModel(g, labels, probs)

  Represents the probabilistic graphical model imported from an RDA file without any modifications

  ## Params
  - `g`: A directed graph modeling a bayesian network
  - `labels`: The names of every node, index of node in `g` corresponds to index in labels
  - `probs`: The probability distributions of nodes, index in `g` corresponds to index in probs
			 Array at index i: 
			  - First index of  is the value range of the variable
			  - Rest are parents of i in the order of vertices in `g`
"""
struct GraphicalModel
	g::SimpleDiGraph
	labels::Vector{String}
	probs::Vector{Array}
end

"""
	Bag(nodes, potential)

	A single bag of nodes according to a tree composition

	N         The dimensionality of potentials
	nodes     A set of integers defining which nodes from the original graph are in this bag
	potential The factors of this bag
"""
struct Bag{N}
	nodes::Vector{Int64}
	potential::Array{Float64, N}
end

"""
	JunctionTree(tree, bags)

	tree      The result of a tree composition
	bags      A collection of bags, index corresponds to index in tree
"""
struct JunctionTree
	tree::SimpleGraph
	bags::Vector{Bag}
end

"""
	Message(separator, vals)

A single message from one node to another with the overlapping variables `separator` and the
values `vals`.
"""
struct Message
	separator::Vector{Int64}
	vals::Array
end

const Messages = Dict{Tuple{Int, Int}, Message}
