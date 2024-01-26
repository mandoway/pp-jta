"""
Get traversal order for message passing protocol

TODO
"""
function traversal_order(jt::JunctionTree)
	n = nv(jt.tree)
	order = Tuple{Int64, Int64}[]
	adj_list = [neighbors(jt.tree, u) for u in 1:nv(jt.tree)]
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
	curr_pos = 1
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


function send_message!(source::Int64, jt::JunctionTree)
	source_bag = jt.bags[source]
	for target in neighbors(jt.tree, source)
		target_bag = jt.bags[target]
		seperator_set = intersect(source_bag.nodes, target_bag.nodes)


		# sum of seperator set potentials
		seperator_potential = sum([])

		# sum of source potentials without separator nodes
		update_potential = sum([source_bag.potential[v] for v in setdiff(source_bag.nodes, seperator_set)])


	end
end

function message_passing(jt::JunctionTree)
	println(traversal_order(jt))
# 	for v in traversal_order(jt)
# 		println(v)
# 		send_message!(v, jt)
# 	end
end


function run_test()
	bag_a = Bag{3}(BitSet([1, 2, 3]), rand(Float64, (2, 2, 2)))
	bag_b = Bag{3}(BitSet([2, 3, 4]), rand(Float64, (2, 2, 2)))
	bag_c = Bag{3}(BitSet([3, 4, 5]), rand(Float64, (2, 2, 2)))
	bag_d = Bag{3}(BitSet([4, 5, 6]), rand(Float64, (2, 2, 2)))

	g = SimpleGraph(4)
	add_edge!(g, 1, 2)
	add_edge!(g, 2, 3)
	add_edge!(g, 3, 4)

	jt = JunctionTree(g, [bag_a, bag_b, bag_c, bag_d])
	
	message_passing(jt)
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
