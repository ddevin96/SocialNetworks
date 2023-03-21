using SocialNetworks
using Graphs

function diffusionMia(G, S, thresholds)
    active = Dict()
    active[1] = S
    i = 2
    while true
        println("step $i: ")
        active[i] = active[i-1]
        for v in vertices(G)
            if v in active[i-1]
                continue
            end
            intersection = intersect(active[i-1], Set(all_neighbors(G,v)))
            if length(intersection) >= thresholds[v]
                push!(active[i], v)
            end
        end
        if length(active[i]) == length(active[i-1]) || length(active[i]) == length(vertices(G))
            break
        end
        i += 1
    end
    println("converged at step $i")
    return active[i]
end

g = loadGraph("data/ca-AstroPh.txt")
V = Set(vertices(g))
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
    println("after max")
    if v == -1 || max_value == -1
        println("error: vertex with max not found")
        break
    end

    push!(L, v)
    for u in all_neighbors(g,v)
        intersection = intersect(union(L, ActiveS), Set(all_neighbors(g,u)))
        sigmaV[u] = degree(g, u) - length(intersection)
        println(L)
        println(ActiveS)
        println(Set(all_neighbors(g,u)))
        println(intersection)
        println(union(L, ActiveS))
        break
    end
    remains = setdiff(V, ActiveS)
    println("after remains - $(length(remains))")
    break
    for u in remains
        println(sigmaV[u], " ", kV[u])
        if sigmaV[u] < kV[u]
            push!(S, u)
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



