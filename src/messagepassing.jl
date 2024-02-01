# using Infiltrator

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

"""
	sumdrop(arr, dims)

Sum over `arr`s dimensions `dim`, drop those dimensions and return the result.
"""
sumdrop(arr, dims) = length(dims) > 0 ? dropdims(sum(arr; dims=dims); dims=Tuple(dims)) : arr

map_to_idx_in(arr::Vector{T}, vals::Vector{T}) where T = [findfirst(==(v), arr) for v in vals]

function message_passing(jt::JunctionTree)
	messages = Messages()

	for (u, v) in traversal_order(jt)
		source_bag = jt.bags[u]
		target_bag = jt.bags[v]

		separator_set = intersect(source_bag.nodes, target_bag.nodes)

		source_without_sep_nodes = setdiff(source_bag.nodes, separator_set)

		


		pot = source_bag.potential
		for neighbor in neighbors(jt.tree, u)
			neighbor == v && continue
			
			slice_dims = [indexin(idx, source_bag.nodes)[]
						  for idx in messages[(neighbor, u)].separator]

			pot = mapslices(slice -> slice .* messages[(neighbor, u)].vals, pot, dims=slice_dims)
		end


		message_dims = [indexin(idx, source_bag.nodes)[] for idx in source_without_sep_nodes]

		# sum of source potentials without separator nodes
		message = sumdrop(pot, message_dims)

		messages[(u, v)] = Message(separator_set, message)
	end
	return messages
end

function marginalized_dists(
	model::GraphicalModel,
	jt::JunctionTree,
	messages::Messages
)
	beliefs = Vector{Array}(undef, nv(jt.tree))
	for u in vertices(jt.tree)
		beliefs[u] = jt.bags[u].potential
		for neighbor in neighbors(jt.tree, u)
			slice_dims = [indexin(idx, jt.bags[u].nodes)[]
						  for idx in messages[(neighbor, u)].separator]

			beliefs[u] = mapslices(slice -> slice .* messages[(neighbor, u)].vals,
								   beliefs[u], dims=slice_dims)
		end
	end

	# For each variable find a bag that contains it.
	var_to_bag = [findfirst(u -> i in jt.bags[u].nodes, vertices(jt.tree))
				  for i in vertices(model.g)]

	# Compute the marginalized distribution for each variable.
	ps = Vector{Float64}[]
	for i in vertices(model.g)
		u = var_to_bag[i]
		slice_dims = map_to_idx_in(jt.bags[u].nodes, setdiff(jt.bags[u].nodes, [i]))
		push!(ps, sumdrop(beliefs[u], slice_dims))
	end

	return Dict(lbl => ps[i] ./ sum(ps[i]) for (i, lbl) in enumerate(model.labels))
end
