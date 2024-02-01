using pp_jta
using Test

include("expected_results.jl")

const INST_DIR = "../instances"
const INSTANCE_CANCER = joinpath(INST_DIR, "small/cancer.rda")
const INSTANCE_ASIA = joinpath(INST_DIR, "small/asia.rda")

const SMALL_INSTANCES = [
  INSTANCE_CANCER,
  INSTANCE_ASIA,
  joinpath(INST_DIR, "small/earthquake.rda"),
  joinpath(INST_DIR, "small/sachs.rda"),
  joinpath(INST_DIR, "small/survey.rda")
]

const MEDIUM_INSTANCES = joinpath.(Ref(INST_DIR), Ref("medium"), [
  "alarm.rda",
  "barley.rda",
  "child.rda",
  "insurance.rda",
  "mildew.rda",
  "water.rda"
])

const LARGE_INSTANCES = joinpath.(Ref(INST_DIR), Ref("large"), [
  "hailfinder.rda",
  "hepar2.rda",
  "win95pts.rda",
])

const VERYLARGE_INSTANCES = joinpath.(Ref(INST_DIR), Ref("verylarge"), [
  "andes.rda",
  "diabetes.rda",
  "link.rda",
  "munin1.rda",
  "pathfinder.rda",
  "pigs.rda",
])

const MASSIVE_INSTANCES = joinpath.(Ref(INST_DIR), Ref("massive"), [
  "munin.rda",
  "munin2.rda",
  "munin3.rda",
  "munin4.rda",
])

assert_moralisation(instance_file::String, result::SimpleGraph)::Bool = pp_jta.moralise(read_graphicalmodel(instance_file).g) == result

@testset "moralisation passes (CANCER, ASIA)" begin
    @test assert_moralisation(INSTANCE_CANCER, CANCER_MORALISED_GRAPH)
    
    @test assert_moralisation(INSTANCE_ASIA, ASIA_MORALISED_GRAPH)
end

is_eq(a::pp_jta.Bag, b::pp_jta.Bag) = a.nodes == b.nodes && a.potential == b.potential

@testset "junction tree correct (CANCER)" begin
    junction_tree = compute_jt(read_graphicalmodel(INSTANCE_CANCER))
    
    @test is_tree(junction_tree.tree)

    @test begin
        correct = true
        for i in 1:length(junction_tree.bags)
            correct = correct && is_eq(junction_tree.bags[i], CANCER_BAGS[i]) 
        end

        return correct
    end
end


# TODO
# @testset "message passing" begin
# 	bag_a = Bag{3}([1, 2, 3], rand(Float64, (2, 2, 2)))
# 	bag_b = Bag{3}([2, 3, 4], rand(Float64, (2, 2, 2)))
# 	bag_c = Bag{3}([3, 4, 5], rand(Float64, (2, 2, 2)))
# 	bag_d = Bag{3}([4, 5, 6], rand(Float64, (2, 2, 2)))
# 
# 	g = SimpleGraph(4)
# 	add_edge!(g, 1, 2)
# 	add_edge!(g, 2, 3)
# 	add_edge!(g, 3, 4)
# 
# 	jt = JunctionTree(g, [bag_a, bag_b, bag_c, bag_d])
# 	
# 	messages = message_passing(jt)
# end


function marginalize_brute_force(model::pp_jta.GraphicalModel,
                                 evidence::Dict{Int, Int} = Dict{Int, Int}())
  g = model.g

  # Probability for the values `x`.
  p(x) = prod(any(x[var] != val for (var, val) in evidence) ? 0.0 :
              model.probs[i][x[i], x[sort(inneighbors(g, i))]...]
              for i in vertices(g))
  range(n) = 1:n
  # Compute probabilities for all possible value combinations.
  ps = p.(Iterators.product(range.(size.(model.probs, 1))...))

  # Marginalize by, for each dimensions, summing over all other dimensions.
  dists = [pp_jta.sumdrop(ps, setdiff(vertices(g), [i]))
           for i in sort(vertices(g))]

  return Dict(model.labels[i] => dists[i] ./ sum(dists[i]) for i in vertices(g))
end

function is_sim(as::pp_jta.DistributionByLabel, bs::pp_jta.DistributionByLabel)
  return keys(as) == keys(bs) &&
         all(length(as[lbl]) == length(bs[lbl]) for lbl in keys(as)) && 
         all(a ≈ b
             for lbl in keys(as)
             for (a,b) in zip(as[lbl], bs[lbl]))
end

@testset "Junction Tree Algorithm: Small Instances" begin
  for inst_path in SMALL_INSTANCES
    model = read_graphicalmodel(inst_path)
    dists_jta = jta(model; flow_cutter_timeout=5)
    dists_brute_force = marginalize_brute_force(model)
    @test is_sim(dists_jta, dists_brute_force)
  end
end

@testset "Junction Tree Algorithm: Medium Instances" begin
  for inst_path in MEDIUM_INSTANCES
    model = read_graphicalmodel(inst_path)
    dists_jta = jta(model; flow_cutter_timeout=15)
  end
end

@testset "Junction Tree Algorithm with evidence: Small Instances" begin
  for inst_path in SMALL_INSTANCES
    model = read_graphicalmodel(inst_path)
    var = rand(1:nv(model.g))
    val = rand(1:size(model.probs[var], 1))
    evidence = Dict(var => val)
    dists_jta = jta(model, evidence; flow_cutter_timeout=5)
    dists_brute_force = marginalize_brute_force(model, evidence)
    @test is_sim(dists_jta, dists_brute_force)
  end
end
