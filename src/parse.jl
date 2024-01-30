using RData
using Graphs

export read_graphicalmodel

function read_graphicalmodel(path::String)::GraphicalModel
    raw_data = load(path)

	network = first(values(raw_data))

    labels = []
    probabilities = []
    graph = SimpleDiGraph(length(network))

    # Re-use indices of network in graph
	for (idx, key) in enumerate(network.index2name)
        current_node = network[key]
        push!(labels, key)

		parents = coerce_array(current_node["parents"])
		

        for parent in parents
            parent_index = network.name2index[parent]
            current_index = network.name2index[key]
            add_edge!(graph, parent_index, current_index)
        end

		sort_vector = sortperm([network.name2index[lbl] for lbl in parents])
		# array concatenation
		sort_vector = [[1]; sort_vector .+ 1]

		push!(probabilities, permutedims(current_node["prob"], sort_vector))
    end

    return GraphicalModel(graph, labels, probabilities)
end

coerce_array(value::Vector)::Vector = value

coerce_array(value::Any)::Vector = [value]
