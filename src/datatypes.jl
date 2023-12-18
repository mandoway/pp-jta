"""
    GraphicalModel(g, labels, probs)

TODO
"""
struct GraphicalModel
  g::SimpleDiGraph
  labels::Vector{String}
  probs::Vector{Array}
end

"""
    Bag(nodes, potential)

TODO
"""
struct Bag{N}
  nodes::BitSet
  potential::Array{N, Float64}
end

"""
    JunctionTree(tree, bags)

TODO
"""
struct JunctionTree
  tree::SimpleGraph
  bags::Vector{Bag}
end
