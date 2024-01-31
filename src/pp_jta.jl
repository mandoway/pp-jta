module pp_jta

using Graphs

export jta_from, jta

include("datatypes.jl")
include("parse.jl")
include("junctiontree.jl")
include("messagepassing.jl")

const DistributionByLabel = Dict{String, Vector{Float64}}

const TREE_DECOMPOSITION_TIMEOUT_S = 25

function jta_from(path::String, evidence::Dict{Int, Int}=Dict{Int, Int}())::DistributionByLabel
  model = read_graphicalmodel(path)
  return jta(model)
end

function jta(model::GraphicalModel, evidence::Dict{Int, Int}=Dict{Int, Int}())::DistributionByLabel
  model_with_evidence = add_evidence_simple(model, evidence)
  jt = compute_jt(model_with_evidence)
  messages = message_passing(jt)
  return marginalized_dists(model, jt, messages)
end

end # module pp_jta
