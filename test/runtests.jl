using pp_jta
using Test

include("expected_results.jl")

const INSTANCE_CANCER = "../instances/cancer.rda"
const INSTANCE_ASIA = "../instances/asia.rda"

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
