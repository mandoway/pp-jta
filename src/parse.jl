using RData
using Graphs

export read_graphicalmodel

function read_graphicalmodel(path::String)::GraphicalModel
    raw_data = load(path)
    root_element = "bn"

    network = raw_data[root_element]
    
    labels = []
    probabilities = []
    graph = SimpleDiGraph()

    # Re-use indices of network in graph
    for key in network.index2name
        current_node = network[key]

        push!(labels, key)

        add_vertex!(graph)

        for parent in coerce_array(current_node["parents"])
            parent_index = network.name2index[parent]
            current_index = network.name2index[key]
            add_edge!(graph, parent_index, current_index)
        end

        # todo calculate correct probabilities
        push!(probabilities, current_node["prob"])
    end

    return GraphicalModel(graph, labels, probabilities)
end

coerce_array(value::Vector)::Vector = value

coerce_array(value::Any)::Vector = [value]