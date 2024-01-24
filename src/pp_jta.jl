module pp_jta

using Graphs

include("datatypes.jl")
include("parse.jl")
include("junctiontree.jl")
include("messagepassing.jl")

const DistributionByLabel = Dict{String, Vector{Float64}}

const TREE_DECOMPOSITION_TIMEOUT_S = 20

function jta_from(path::String)::DistributionByLabel
  model = read_graphicalmodel(path)
  return jt(model)
end

function jta(model::GraphicalModel)::DistributionByLabel
  jt = compute_jt(model)
  messages = message_passing(jt)
  return marginalized_dists(model, jt, messages)
end

end # module pp_jta
