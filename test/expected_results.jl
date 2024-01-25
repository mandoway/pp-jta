using Graphs

const CANCER_MORALISED_GRAPH = SimpleGraph(Edge.([
    (1, 3),
    (2, 3),
    (3, 4),
    (3, 5),
    # Added
    (1, 2),
]))


const ASIA_MORALISED_GRAPH = SimpleGraph(Edge.([
    (1, 2),
    (3, 4),
    (3, 5),
    (3, 4),
    (2, 6),
    (4, 6),
    (6, 7),
    (6, 8),
    (5, 8),
    # Added.
    (2, 4),
    (5, 6)
]))

const CANCER_BAGS = [
    pp_jta.Bag{2}(
        BitSet([3, 4]), 
        [0.9 0.1;
         0.2 0.8]
    )
    pp_jta.Bag{2}(
        BitSet([3, 5]), 
        [0.65 0.35;
         0.3 0.7]
    )
    pp_jta.Bag{3}(
        BitSet([1, 2, 3]),
        [0.0081 0.00063; 
        0.0015 0.0014;;; 
        
        0.2619 0.62937;
        0.028499999999999998 0.0686]
    )
]