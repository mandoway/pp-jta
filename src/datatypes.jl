"""
    GraphicalModel(g, labels, probs)

    Represents the probabilistic graphical model imported from an RDA file without any modifications

    g         A directed graph modeling a bayesian network
    labels    The names of every node, index of node in g corresponds to index in labels
    probs     The probability distributions of nodes, index in g corresponds to index in probs
"""
struct GraphicalModel
  g::SimpleDiGraph
  labels::Vector{String}
  probs::Vector{Array}
end

"""
    Bag(nodes, potential)

    A single bag of nodes according to a tree composition

    N         The dimensionality of potentials        TODO can this be fixed?
    nodes     A set of integers defining which nodes from the original graph are in this bag
    potential The factors of this bag
"""
struct Bag{N}
  nodes::BitSet
  potential::Array{N, Float64}
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
