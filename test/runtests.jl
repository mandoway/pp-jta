using pp_jta
using Test

include("expected_results.jl")

const INSTANCE_CANCER = "../instances/cancer.rda"
const INSTANCE_ASIA = "../instances/asia.rda"

@testset "moralisation passes" begin
    @test pp_jta.moralise(read_graphicalmodel(INSTANCE_CANCER).g) == CANCER_MORALISED_GRAPH
    
    @test pp_jta.moralise(read_graphicalmodel(INSTANCE_ASIA).g) == ASIA_MORALISED_GRAPH
end