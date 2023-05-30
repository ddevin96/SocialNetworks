# Algo 1 MTS
# Algo 2 Random, ordini in modo casuale tramite ricerca binaria, se con la meta scendi sotto di l vai destra sinistra, trovare il valore k : dopo la diffusione riesco ad attivare almeno l (trovare il piu piccolo k)
# Algo 3 identico solo che l'ordinamento e dato dai gradi decrescenti
# Algo 4 prendi il nodo di grado massimo, diffusione, se sei a l finito, altrimenti togli dal grafo tutti i nodi attivati e ricominci prendendo il nodo con grado massimo 
# N numero di nodi
# l 25,50,75 % di N 
# Proportional thresholds 0.25,0.5,0.75
# th = 0.25,0.50,0.75 degree
# Random thresholds where for each node v the threshold
# t(v) is chosen uniformly at random in the interval [1, d(v)];
# Experiments 4 (algo) x 3 (l) x 4 (th)
# 10 networks 

using Distributed
addprocs(2)
@everywhere begin
    using Pkg; Pkg.activate(".") 
    Pkg.instantiate(); Pkg.precompile()
    using SocialNetworks
    using Graphs
    using Random

# using SocialNetworks
# using Graphs
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
    V = Set()
    for v in vertices(g)
        push!(V, v)
    end

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

# Algo 2 Random, ordini in modo casuale tramite ricerca binaria, se con la metà scendi sotto di l vai destra sinistra, trovare il valore k : dopo la diffusione riesco ad attivare almeno l (trovare il piu piccolo k)
function algoDegree(g, thresholds, l)
    S = Set{Int64}()
    L = Set{Int64}()
    ActiveS = Set{Int64}()
    sigmaV_or = Dict()
    kV_or = Dict()
    V = Set()
    for v in vertices(g)
        push!(V, v)
    end

    # random order of V
    
    # cast V into a list
    my_list = collect(V)
    # order the list by degree of nodes
    sort!(my_list, by = x -> degree(g, x))
    my_list_size = length(my_list)
    pivot = my_list_size * 2
    for v in vertices(g)
        sigmaV_or[v] = degree(g, v)
        kV_or[v] = Float64(thresholds[v])
    end

    increase_size = false
    counter = 20
    best_k = 0
    while counter > 0
        println("counter $counter")
        S = Set{Int64}()
        L = Set{Int64}()
        ActiveS = Set{Int64}()
        sigmaV = deepcopy(sigmaV_or)
        kV = deepcopy(kV_or)

        if !increase_size
            pivot = pivot / 2
            println("dimezzo pivot $pivot")
        else 
            # pivot = (pivot + ((my_list_size - pivot)/ 2))
            pivot = (pivot + pivot/2)
            println("aumento $pivot")
        end
        # cast pivot to int
        pivot = Int64(floor(pivot))
        
        # v = rand(maxs)
        for u in my_list[1:pivot]
            push!(L, u)
        end
        # println("l: $L");
        for v in L
            for u in all_neighbors(g,v)
                intersection = intersect(union(L, ActiveS), Set(all_neighbors(g,u)))
                sigmaV[u] = degree(g, u) - length(intersection)
            end
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

        if length(ActiveS) < l
            increase_size = true
        else
            increase_size = false
            best_k = length(S)
        end

        # println("ActiveS: $ActiveS")
        counter -= 1
    end

    println("---- best k $best_k\n")

    # return S, ActiveS
    return best_k
end

function algoRandom(g, thresholds, l)
    S = Set{Int64}()
    L = Set{Int64}()
    ActiveS = Set{Int64}()
    sigmaV_or = Dict()
    kV_or = Dict()
    V = Set()
    for v in vertices(g)
        push!(V, v)
    end

    # random order of V
    
    # cast V into a list
    my_list = collect(V)
    # shuffle the list
    shuffle!(my_list)
    my_list_size = length(my_list)
    pivot = my_list_size * 2
    for v in vertices(g)
        sigmaV_or[v] = degree(g, v)
        kV_or[v] = Float64(thresholds[v])
    end

    increase_size = false
    counter = 20
    best_k = 0
    while counter > 0
        # println("counter $counter")
        S = Set{Int64}()
        L = Set{Int64}()
        ActiveS = Set{Int64}()
        sigmaV = deepcopy(sigmaV_or)
        kV = deepcopy(kV_or)

        if !increase_size
            pivot = pivot / 2
            # println("dimezzo pivot $pivot")
        else 
            # pivot = (pivot + ((my_list_size - pivot)/ 2))
            pivot = (pivot + pivot/2)
            # println("aumento $pivot")
        end
        # cast pivot to int
        pivot = Int64(floor(pivot))
        
        # v = rand(maxs)
        for u in my_list[1:pivot]
            push!(L, u)
        end
        # println("l: $L");
        for v in L
            for u in all_neighbors(g,v)
                intersection = intersect(union(L, ActiveS), Set(all_neighbors(g,u)))
                sigmaV[u] = degree(g, u) - length(intersection)
            end
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

        if length(ActiveS) < l
            increase_size = true
        else
            increase_size = false
            best_k = length(S)
        end

        # println("ActiveS: $ActiveS")
        counter -= 1
    end

    println("---- best k $best_k\n")

    # return S, ActiveS
    return best_k
end

#end distributed.jl
end

iter = 10
# graphs = ["karate.edges", "wiki-Vote.edges", "ca-AstroPh.edges", "email-EU-core.edges", "facebook.edges"]
graphs = ["karate.edges"]
#graphs = ["karate.edges","karate.edges","karate.edges","karate.edges"]
println("---- MTS\n")
result = @distributed (append!) for graph in graphs
    g = load_my_graph("data/$graph")
   
    thresholds = Dict()

    for v in vertices(g)
        thresholds[v] = degree(g, v) / 2
    end
    l = length(vertices(g)) / 2
    avg = 0.0
    #iterate 10 times
    for i in 1:iter
        S, activeS = MTS(g, thresholds, l)
        avg += length(S)
    end
    avg = avg / 10

    [avg]
end

println("---- Random\n")
result = @distributed (append!) for graph in graphs
    g = load_my_graph("data/$graph")
   
    thresholds = Dict()

    for v in vertices(g)
        thresholds[v] = degree(g, v) / 2
    end
    l = length(vertices(g)) / 2
    avg = 0.0
    #iterate 10 times
    for i in 1:iter
        best_k = algoRandom(g, thresholds, l)
        avg += best_k
    end
    avg = avg / 10

    [avg]
end

println("---- DEGREE\n")
result = @distributed (append!) for graph in graphs
    g = load_my_graph("data/$graph")
   
    thresholds = Dict()

    for v in vertices(g)
        thresholds[v] = degree(g, v) / 2
    end
    l = length(vertices(g)) / 2
    avg = 0.0
    #iterate 10 times
    for i in 1:iter
        best_k = algoDegree(g, thresholds, l)
        avg += best_k
    end
    avg = avg / 10

    [avg]
end

# for g in graphs
#     g = load_my_graph("data/$g")
#     V = Set()
#     for v in vertices(g)
#         push!(V, v)
#     end

#     thresholds = Dict()

#     for v in vertices(g)
#         thresholds[v] = degree(g, v) / 2
#     end
#     #thresholds =[2,3,1,2,2]
#     l = length(vertices(g)) / 2
#     S, activeS = MTS(g, thresholds, l)
#     length(S)
# end
# g = loadGraph("data/ca-AstroPh.txt")
# g = load_my_graph("data/karate.txt")