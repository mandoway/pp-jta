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

    bags = Vector{Bag}()
    for i in 1:jt[:num_bags]
        index = Symbol("b_$i")
        bag_vertices = jt[index]
        
        # TODO
        potentials = []

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