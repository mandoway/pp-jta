using QXGraphDecompositions; gd = QXGraphDecompositions

export compute_jt

function compute_jt(model::GraphicalModel)::JunctionTree
    moralised_graph = moralise(model.g)

    # Compute junction tree with given timeout
    junction_tree = flow_cutter(moralised_graph, TREE_DECOMPOSITION_TIMEOUT_S)

    # Map junction tree to internal graph structure
    tree = SimpleGraph(junction_tree[:num_bags])
    for edge in junction_tree[:edges]
        src = edge[1]
        dst = edge[2]

        add_edge!(tree, src, dst)
    end

    # Initialise helper variables
    # `uncovered_factors`, which factors of the original network were not yet assigned to a node in the tree
    uncovered_factors = BitSet(1:nv(model.g))
    bags = Vector{Bag}()

    # Loop over bags and calculate the potential per bag (by multiplying all factors assigned to the bag)
    for bag_index in 1:junction_tree[:num_bags]
        index = Symbol("b_$bag_index")
        bag_vertices = sort(junction_tree[index])
        
        # Initialise result with ones
        potentials = ones(size.(model.probs[bag_vertices], 1)...)

        # Not yet covered factors fitting in the current bag
        # The factor itself and all its parents must fit completely in the bag
        # i.e. the probabilistic variable and all variables it depends on
        factors = [f for f in uncovered_factors if union([f], inneighbors(model.g, f)) ⊆ bag_vertices]
        setdiff!(uncovered_factors, factors)

        # Compute product of all factors
        for f in factors
            # Find indices of node corresponding to factor `f` in the order of the bag
            indices = union([f], sort(inneighbors(model.g, f)))
            mapped_to_bag_indices = [indexin(idx, bag_vertices)[] for idx in indices]
            
            # Permute the factor array according to the order of appearance in `mapped_to_bag_indices`
            # since the factor index is different from the potential index
            # e.g. if A -> C <- B (C depends on A & B) and node indices are A=1, B=2, C=3
            # then factor indices are [3, 1, 2] and potential indices are [1, 2, 3]
            factor_prob = model.probs[f]
            permute_vector = sortperm(mapped_to_bag_indices)
            factor_prob = permutedims(factor_prob, permute_vector)

            # Map each slice of the potential according to the current dimensionality of the probability table `factor_prob`
            # Transforms the given dimensions by applying the mapping function to each slice of `potentials` of form `potentials[.., :, ..]` with `:` at each `d` in `dims`
            potentials = mapslices(slice -> slice .* factor_prob, potentials, dims=mapped_to_bag_indices)
        end

        bag = Bag(BitSet(bag_vertices), potentials)
        push!(bags, bag)
    end

    return JunctionTree(tree, bags)
end

function moralise(graph::SimpleDiGraph)::SimpleGraph
    moralised = SimpleGraph(graph)

    for node in Graphs.vertices(graph)
        parents = inneighbors(graph, node)

        for i in eachindex(parents)
            for j in i+1:lastindex(parents)
                add_edge!(moralised, parents[i], parents[j])
            end
        end
    end

    return moralised
end