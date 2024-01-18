module pp_jta

using Graphs

include("parse.jl")
include("datatypes.jl")
include("junctiontree.jl")
include("messagepassing.jl")

const JTA = Dict{String, Vector{Float64}}

function jta_from(path::String)::JTA
  model = read_graphicalmodel(path)
  return jt(model)
end

function jta(model::GraphicalModel)::JTA
  jt = compute_jt(model)
  messages = message_passing(jt)
  return marginalized_dists(model, jt, messages)
end

end # module pp_jta
