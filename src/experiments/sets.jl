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
end

iter = 10
# graphs = ["karate.edges", "wiki-Vote.edges", "ca-AstroPh.edges", "email-EU-core.edges", "facebook.edges"]
# graphs = ["karate.edges", "facebook.edges"]
graphs = ["karate.edges"]

println("---- MTS\n")
result = @distributed (append!) for graph in graphs
    g = load_my_graph("data/$graph")
   
    thresholds = Dict()
    for v in vertices(g)
        thresholds[v] = degree(g, v) / 2
    end

    l = length(vertices(g)) / 2
    avg = 0.0

    for i in 1:iter
        S, activeS = MTS(g, thresholds, l)
        if !testSetWithDiffusion(g, S, thresholds)
            println("S is not a real set")
            # println(S)
        end
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

    for i in 1:iter
        best_k, S = algoRandom(g, thresholds, l)
        if !testSetWithDiffusion(g, S, thresholds)
            println("S is not a real set")
            # println(S)
        end
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

    for i in 1:iter
        best_k = algoDegree(g, thresholds, l)
        avg += best_k
    end
    avg = avg / 10

    [avg]
end

# test all th and l
result = @distributed (append!) for graph in graphs
    g = load_my_graph("data/$graph")
    
    all_l = [length(vertices(g)) * 0.25, length(vertices(g)) * 0.5, length(vertices(g)) * 0.75, length(vertices(g))]
    all_th = [0.25, 0.5, 0.75, 1.0]
    for i in 1:4 # l
        for j in 1:4 # th
            println("MTS -- Graph $(graph) l: $(all_l[i]) th: $(all_th[j])")
            thresholds = Dict()
            if j != 4
                for v in vertices(g)
                    thresholds[v] = degree(g, v) * all_th[j]
                end
            else
                for v in vertices(g)
                    thresholds[v] = rand(1:degree(g, v))
                end
            end
            l = all_l[i]
            avg = 0.0
            #iterate 10 times
            for i in 1:iter
                S, activeS = MTS(g, thresholds, l)
                if !testSetWithDiffusion(g, S, thresholds)
                    println("S is not a real set")
                    # println(S)
                end
                avg += length(S)
            end
            avg = avg / 10
            println("avg: $avg")
            [avg]
        end
    end
    

    # [avg]
end

println("---- MAX DEGREE\n")
result = @distributed (append!) for graph in graphs
    g = load_my_graph("data/$graph")
   
    thresholds = Dict()
    for v in vertices(g)
        thresholds[v] = degree(g, v) / 2
    end

    l = length(vertices(g)) / 2
    avg = 0.0

    for i in 1:iter
        S, ActiveS = algoMaxDegree(g, thresholds, l)
        avg += length(S)
    end
    avg = avg / 10

    [avg]
end