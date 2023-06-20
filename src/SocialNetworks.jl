module SocialNetworks

using Graphs
using GraphIO
using Random

export load_my_graph, write_graph_info
export testSet, testSetWithDiffusion
export diffusionMia
export MTS, algoDegree, algoRandom, algoMaxDegree

include("tools.jl")

end # module SocialNetworks
