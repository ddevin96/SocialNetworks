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
        for v in active[i-1]
            for u in all_neighbors(G,v)
                if u in active[i-1]
                    continue
                end
                intersection = intersect(active[i-1], Set(all_neighbors(G,u)))
                # println("intersection ", length(intersection))
                # println("thresholds ", thresholds[u])
                if length(intersection) >= thresholds[u]
                    push!(active[i], u)
                end
            end
            # println(v)
            # if v in active[i-1]
            #     continue
            # end
            # println(active[i])
            # println(active[i-1])
            # intersection = intersect(active[i-1], Set(all_neighbors(G,v)))
            # println("intersection ", length(intersection))
            # if length(intersection) >= thresholds[v]
            #     push!(active[i], v)
            # end
        end
        if length(active[i]) == length(vertices(G))
            println("Diffusion completed!")
            break
        end
        if length(active[i]) == length(active[i-1])
            println("similar len in diffusion -- break at step $i")
            break
        end
        i += 1
    end
    if i > 2
        println("converged at step $i")
    end
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

# g = loadGraph("data/ca-AstroPh.txt")
g = load_my_graph("data/ca-AstroPh.txt")
# g = load_my_graph("data/karate.txt")

V = Set()
for v in vertices(g)
    push!(V, v)
end

S = Set{Int64}()
L = Set{Int64}()
ActiveS = Set{Int64}()
sigmaV = Dict()
kV = Dict()
thresholds = Dict()

for v in vertices(g)
    thresholds[v] = degree(g, v) / 2
end

for v in vertices(g)
    sigmaV[v] = degree(g, v)
    kV[v] = Float64(thresholds[v])
end

l = length(vertices(g)) / 2

while length(ActiveS) < l
    println("S size: $(length(S))")
    pool = setdiff(setdiff(V, ActiveS), L)
    v = -1
    max_value = -1
    for u in pool
        value = kV[u] / (sigmaV[u] * (sigmaV[u]+1))
        if value > max_value
            max_value = value
            v = u
        end
    end
    # println("after max")
    if v == -1 || max_value == -1
        println("error: vertex with max not found")
        break
    end
    # println(v)
    push!(L, v)
    for u in all_neighbors(g,v)
        # if length(all_neighbors(g,u)) == 1
        #     println("len neighbors", length(all_neighbors(g,u)))
        # end
        intersection = intersect(union(L, ActiveS), Set(all_neighbors(g,u)))
        # println("intersection ", length(intersection))
        # println("before sigmaV ", sigmaV[u])
        sigmaV[u] = degree(g, u) - length(intersection)
        # println("after sigmaV ", sigmaV[u])
        # println(L)
        # println(ActiveS)
        # println(Set(all_neighbors(g,u)))
        # println(intersection)
        # println(union(L, ActiveS))
        # break
    end
    remains = setdiff(V, ActiveS)
    # println("after remains - $(length(remains))")
    # break
    for u in remains
        # println(sigmaV[u], " ", kV[u])
        if sigmaV[u] < kV[u]
            push!(S, u)
            # println("hello")
            # println(S)
            # println("S: ", length(S))
            ActiveS = diffusionMia(g, S, thresholds)
            
            for w in all_neighbors(g,u)
                intersection = intersect(union(L, ActiveS), Set(all_neighbors(g,w)))
                sigmaV[w] = degree(g, w) - length(intersection)
                kV[w] = max(0.0, thresholds[w] - length(intersect(ActiveS, Set(all_neighbors(g,w)))))
            end
        end
    end

end

length(S)