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