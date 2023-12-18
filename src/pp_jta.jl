module pp_jta

using Graphs

include("datatypes.jl")
include("junctiontree.jl")
include("messagepassing.jl")

function read_graphicalmodel(path::String)::GraphicalModel
  # TODO
end

function jta(model::GraphicalModel)::Dict{String, Vector{Float64}}
  jt = compute_jt(model)
  messages = message_passing(jt)
  return marginalized_dists(model, jt, messages)
end

end # module pp_jta
