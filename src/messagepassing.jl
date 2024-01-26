"""
Get traversal order for message passing protocol

TODO
"""
function traversal_order(jt::JunctionTree)
	n = nv(jt.tree)
	order = Tuple{Int64, Int64}[]
	levels = fill(-1, n)

	root = 1
	queue = [root]
	levels[root] = 0
	while !isempty(queue)
		curr = popfirst!(queue)
		for u in neighbors(jt.tree, curr)
			if levels[u] != -1
				continue
			end

			levels[u] = levels[curr] + 1
			push!(queue, u)
		end
	end

	curr_level = maximum(levels)
	while curr_level > 0
		for curr_node in findall(x -> x == curr_level, levels)
			for u in neighbors(jt.tree, curr_node)
				if levels[u] < curr_level
					push!(order, (curr_node, u))
				end
			end
		end
		curr_level -= 1
	end

	queue = [root]
	while !isempty(queue)
		curr = popfirst!(queue)
		for u in neighbors(jt.tree, curr)
			if levels[u] <= levels[curr]
				continue
			end

			push!(order, (curr, u))
			push!(queue, u)
		end
	end

	return order
end


function message_passing(jt::JunctionTree)
	println(traversal_order(jt))

	messages = Dict{Tuple{Int64, Int64}, Array}()
	sep_set_of_message = Dict{Tuple{Int64, Int64}, Vector{Int64}}()

	for (u, v) in traversal_order(jt)
		source_bag = jt.bags[u]
		target_bag = jt.bags[v]

		separator_set = intersect(source_bag.nodes, target_bag.nodes)
		sep_set_of_message[(u, v)] = separator_set

		source_without_sep_nodes = setdiff(source_bag.nodes, separator_set)

		


		pot = source_bag.potential
		for neighbor in neighbors(jt.tree, u)
			neighbor == v && continue
			
			slice_dims = [indexin(idx, source_bag.nodes)[] for idx in sep_set_of_message[(neighbor, u)]]

			pot = mapslices(slice -> slice .* messages[(neighbor, u)], pot, dims=slice_dims)
		end


		message_dims = [indexin(idx, source_bag.nodes)[] for idx in source_without_sep_nodes]

		# sum of source potentials without separator nodes
		message = dropdims(sum(pot, dims=Tuple(message_dims)), dims=Tuple(message_dims))

		messages[(u, v)] = message
	end
	return messages
end


function run_test()
	bag_a = Bag{3}([1, 2, 3], rand(Float64, (2, 2, 2)))
	bag_b = Bag{3}([2, 3, 4], rand(Float64, (2, 2, 2)))
	bag_c = Bag{3}([3, 4, 5], rand(Float64, (2, 2, 2)))
	bag_d = Bag{3}([4, 5, 6], rand(Float64, (2, 2, 2)))

	g = SimpleGraph(4)
	add_edge!(g, 1, 2)
	add_edge!(g, 2, 3)
	add_edge!(g, 3, 4)

	jt = JunctionTree(g, [bag_a, bag_b, bag_c, bag_d])
	
	messages = message_passing(jt)
end


const Messages = Dict{Tuple{Int, Int}, Array}

function marginalized_dists(
	model::GraphicalModel,
	jt::JunctionTree,
	messages::Messages
)
	for m in messages
		
	end
end
