using QXGraphDecompositions; gd = QXGraphDecompositions

function compute_jt(model::GraphicalModel)::JunctionTree
    moralised_graph = moralise(model.g)

    jt = flow_cutter(moralised_graph)

    # TODO complete
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