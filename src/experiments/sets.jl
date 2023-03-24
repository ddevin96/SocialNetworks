# using Distributed
# addprocs(1)
# @everywhere begin
#     using Pkg; Pkg.activate(".") 
#     Pkg.instantiate(); Pkg.precompile()
#     using .SocialNetworks
#     using Graphs
   
# end


using SocialNetworks
using Graphs
function diffusionMia(G, S, thresholds)
    active = Dict()
    active[1] = S
    i = 2
    while true
        # println("step $i: ")
        active[i] = deepcopy(active[i-1])
        # for v in vertices(G)
         for v in collect(active[i-1])
            for u in all_neighbors(G,v)
                if u in active[i-1] || u in active[i]
                    continue
                end
                intersection = intersect(active[i-1], Set(all_neighbors(G,u)))
                # println("intersection ", length(intersection))
                # println("thresholds ", thresholds[u])
                if length(intersection) >= thresholds[u]
                    # println("add $u to active at step $i")
                    push!(active[i], u)
                end
            end
        end
        if length(active[i]) == length(vertices(G)) || length(active[i]) == length(active[i-1])
            # println("similar len in diffusion -- break at step $i")
            break
        end
        i += 1
    end
    # if i > 2
    #     println("converged at step $i")
    # end
    # println("converged at step $i")
    return active[i]
end

function load_my_graph(path)
    edges = readlines(path)
    g = Graph()
    hm = Dict()
    index = 1
    for i in 1:length(edges)
        line = split(edges[i], ",")
        v1 = parse(Int64, line[1])
        v2 = parse(Int64, line[2])
        if !haskey(hm, v1)
            hm[v1] = index
            index += 1
            add_vertex!(g)
        end
        if !haskey(hm, v2)
            hm[v2] = index
            index += 1
            add_vertex!(g)
        end
        # add_vertex!(g, v2)
        add_edge!(g, hm[v1], hm[v2])
    end
    return g
end

function MTS(g, thresholds, l)
    S = Set{Int64}()
    L = Set{Int64}()
    ActiveS = Set{Int64}()
    sigmaV = Dict()
    kV = Dict()

    for v in vertices(g)
        sigmaV[v] = degree(g, v)
        kV[v] = Float64(thresholds[v])
    end
    
    while length(ActiveS) < l
        # println("=============================")
        # println("S size: $(length(S))")
        pool = setdiff(setdiff(V, ActiveS), L)
        # println(pool)
        # if length(pool) == 0
        #     break
        # end
        # v = -1
        max_value = -1
        maxs = Set()
        for u in pool
            value = kV[u] / (sigmaV[u] * (sigmaV[u]+1))
            # println("u $u, value $value")
            if value > max_value
                max_value = value
                maxs = Set()
                push!(maxs, u)
                # v = u
            else
                if value == max_value
                    push!(maxs, u)
                end
            end
        end
        
        v = rand(maxs)

        push!(L, v)
        # println("l: $L");
        for u in all_neighbors(g,v)
            intersection = intersect(union(L, ActiveS), Set(all_neighbors(g,u)))
            sigmaV[u] = degree(g, u) - length(intersection)
        end
        remains = setdiff(V, ActiveS)
        for u in remains
            if sigmaV[u] < kV[u]
                push!(S, u)
                # println("S $S")
                ActiveS = diffusionMia(g, S, thresholds)
                for w in all_neighbors(g,u)
                    intersection = intersect(union(L, ActiveS), Set(all_neighbors(g,w)))
                    sigmaV[w] = degree(g, w) - length(intersection)
                    kV[w] = max(0.0, thresholds[w] - length(intersect(ActiveS, Set(all_neighbors(g,w)))))
                end
            end
        end

        # println("ActiveS: $ActiveS")

    end
    return S, ActiveS
end

# g = loadGraph("data/ca-AstroPh.txt")
g = load_my_graph("data/wiki-Vote.edges")
# g = load_my_graph("data/karate.txt")

V = Set()
for v in vertices(g)
    push!(V, v)
end

thresholds = Dict()

for v in vertices(g)
    thresholds[v] = degree(g, v) / 2
end
#thresholds =[2,3,1,2,2]
l = length(vertices(g)) / 2
S, activeS = MTS(g, thresholds, l)
length(S)
