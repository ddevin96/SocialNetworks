function testSetWithDiffusion(G, S, thresholds, l)
    active = Dict()
    active[1] = S
    i = 2
    complete = false

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
                if length(intersection) >= thresholds[u]
                    push!(active[i], u)
                end
            end
        end
        if length(active[i]) >= l
            complete = true
            break
        end
        if length(active[i]) == length(active[i-1])
            break
        end
        i += 1
    end
    return complete
end

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

function diffusionMiaWithBool(G, S, thresholds, bools)
    active = Dict()
    active[1] = S
    i = 2
    while true
        # println("step $i: ")
        active[i] = deepcopy(active[i-1])
        # for v in vertices(G)
         for v in collect(active[i-1])
            for u in all_neighbors(G,v)
                if u in active[i-1] || u in active[i] || bools[u]
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

# Algo 3 identico solo che l'ordinamento e dato dai gradi decrescenti
function algoDegree(g, thresholds, l)
    
    S = Set{Int64}()
    L = Set{Int64}()
    ActiveS = Set{Int64}()
    V = Set()
    for v in vertices(g)
        push!(V, v)
    end
    
    # cast V into a list
    my_list = collect(V)
    # shuffle the list
    sort!(my_list, by = x -> degree(g, x), rev = true)

    my_list_size = length(my_list)
    pivot = my_list_size * 2 
    prev_pivot_min = 0
    prev_pivot_max = 0
    old_pivot = -1

    increase_size = false
    best_k = 0
    best_S = Set{Int64}()

    while true
        # println("counter $counter")
        S = Set{Int64}()
        L = Set{Int64}()
        ActiveS = Set{Int64}()

        if !increase_size
            pivot = (pivot - ((pivot - prev_pivot_min) / 2))
            # println("decrease pivot $pivot")
        else 
            pivot = (pivot + ((prev_pivot_max - pivot)/2))
            # println("increase pivot $pivot")
        end
   
        # cast pivot to int
        pivot = Int64(floor(pivot))
        
        if pivot == old_pivot
            break
        end

        for u in my_list[1:pivot]
            push!(S, u)
        end

        ActiveS = diffusionMia(g, S, thresholds)

        if length(ActiveS) < l
            increase_size = true
            prev_pivot_min = pivot
        else
            increase_size = false
            best_k = length(S)
            best_S = deepcopy(S)
            prev_pivot_max = pivot
        end
        old_pivot = pivot

    end

    return best_k, best_S
end

# Algo 2 Random, ordini in modo casuale tramite ricerca binaria, 
# se con la metà scendi sotto di l vai destra sinistra, trovare il valore k : 
# dopo la diffusione riesco ad attivare almeno l (trovare il piu piccolo k)
function algoRandom(g, thresholds, l)
    S = Set{Int64}()
    L = Set{Int64}()
    ActiveS = Set{Int64}()
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
    prev_pivot_min = 0
    prev_pivot_max = 0
    old_pivot = -1

    increase_size = false
    best_k = 0
    best_S = Set{Int64}()

    while true
        # println("counter $counter")
        S = Set{Int64}()
        L = Set{Int64}()
        ActiveS = Set{Int64}()

        if !increase_size
            pivot = (pivot - ((pivot - prev_pivot_min) / 2))
            # println("decrease pivot $pivot")
        else 
            pivot = (pivot + ((prev_pivot_max - pivot)/2))
            # println("increase pivot $pivot")
        end

        
        # cast pivot to int
        pivot = Int64(floor(pivot))
        
        if pivot == old_pivot
            break
        end

        for u in my_list[1:pivot]
            push!(S, u)
        end

        ActiveS = diffusionMia(g, S, thresholds)

        if length(ActiveS) < l
            increase_size = true
            prev_pivot_min = pivot
        else
            increase_size = false
            best_k = length(S)
            best_S = deepcopy(S)
            prev_pivot_max = pivot
        end
        old_pivot = pivot

    end

    # println("---- best k $best_k\n")

    # return S, ActiveS
    return best_k, best_S
end

# Algo 4 prendi il nodo di grado massimo, diffusione, se sei a l finito,
# altrimenti togli dal grafo tutti i nodi attivati e ricominci prendendo il nodo con grado massimo 
function algoMaxDegree(g, thresholds, l)
    # gr = deepcopy(g)
    S = Set{Int64}()
    ActiveS = Set{Int64}()
    V = Set()
    for v in vertices(g)
        push!(V, v)
    end

    
    # cast V into a list
    my_list = collect(V)
    # order the list by degree of nodes
    sort!(my_list, by = x -> degree(g, x), rev = true)
    # create a list of boolean
    my_list_bool = Dict{Int64, Bool}()
    my_list_degree = Dict{Int64, Int64}()
    for v in my_list
        my_list_bool[v] = false
        my_list_degree[v] = degree(g, v)
    end
    # my_list_index = 1

    while length(my_list) > 0

        # println("my_list_size $(length(my_list))")
        # println("g size $(nv(gr))")
        ActiveS = Set{Int64}()
        
        # pop the first element of my_list
        # sort by degree on residual graph
        # threshold decrease by 1 for each node that go missing
        u = popfirst!(my_list)
        max = 0
        for key in keys(my_list_degree)
            if my_list_degree[key] > max
                max = my_list_degree[key]
                u = key
            end
        end
        push!(S, u)

        ActiveS = diffusionMiaWithBool(g, S, thresholds, my_list_bool)
        # println("len ActiveS $(length(ActiveS))")
        if length(ActiveS) < l
            # remove node and actives from graph
            for v in ActiveS
                my_list_bool[v] = true
                deleteat!(my_list, findall(x -> x == v, my_list))
                for u in all_neighbors(g,v)
                    if thresholds[u] > 1
                        thresholds[u] -= 1
                    end
                    if my_list_degree[u] > 0
                        my_list_degree[u] -= 1
                    end
                end
            end
        else
            # found the l
            return S, ActiveS
        end

    end

    return S, ActiveS
end