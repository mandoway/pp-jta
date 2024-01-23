using QXGraphDecompositions; gd = QXGraphDecompositions

function compute_jt(model::GraphicalModel)::JunctionTree
    moralised_graph = moralise(model.g)

    jt = flow_cutter(moralised_graph)

    # TODO complete
    tree = SimpleGraph()
    for edge in jt[:edges]
        src = edge[1]
        dst = edge[2]

        add_edge!(tree, src, dst)
    end

    uncovered_factors = BitSet(1:nv(model.g))

    bags = Vector{Bag}()
    for i in 1:jt[:num_bags]
        index = Symbol("b_$i")
        bag_vertices = sort(jt[index])
        
        # Initialise result with ones
        potentials = ones(size.(model.probs[bag_vertices], 1)...)

        # Not yet covered factors fitting in the current bag
        factors = [f for f in uncovered_factors if union([f], inneighbors(model.g, f)) ⊆ bag_vertices]
        setdiff!(uncovered_factors, factors)

        #
        prob = model.probs
        indices = [union([f], sort(inneighbors(model.g, f))) for f in factors]
        mapped_to_bag_indices = [[indexin(i, bag_vertices)[] in indices[f]] for f in factors]
        for idxs in CartesianIndex()
            # TODO
        end

        # Try 1
        # for f in factors
        #     prob = model.probs[f]
        #     indices = union([f], sort(inneighbors(model.g, f)))
        #     mapped_to_bag_indices = [indexin(i, bag_vertices)[] in indices]

        #     #
        # end

        bag = Bag(BitSet(bag_vertices), potentials)
        push!(bags, bag)
    end

    return JunctionTree(tree, bags)
end

function moralise(graph::SimpleDiGraph)::SimpleGraph
    # TODO improved efficiency: move this to parsing
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