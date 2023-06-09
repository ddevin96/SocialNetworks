using Distributed
# using CSV, Tables, DataFrames

addprocs(4)
@everywhere begin
    using Pkg; Pkg.activate(".") 
    Pkg.instantiate(); Pkg.precompile()
    using SocialNetworks
    using Graphs
    using Random
end

iter = 10
graphs = ["karate.edges", "wiki-Vote.edges", "ca-AstroPh.edges", "email-EU-core.edges", "facebook.edges"]
# graphs = ["karate.edges", "facebook.edges"]
# graphs = ["karate.edges"]
# open a file to write


# test all th and l
result = @distributed (append!) for graph in graphs
    g = load_my_graph("data/$graph")
    
    all_l = [length(vertices(g)) * 0.25, length(vertices(g)) * 0.5, length(vertices(g)) * 0.75, length(vertices(g))]
    all_th = [0.25, 0.5, 0.75, 1.0]
    all_avg = []
    all_string = []
    for i in 1:4 # l
        for j in 1:4 # th
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
            #iterate iter times
            for iteration in 1:iter
                S, activeS = MTS(g, thresholds, l)
                if !testSetWithDiffusion(g, S, thresholds)
                    println("SET NOT OK -- MTS -- Graph $(graph) l: $(all_l[i]) th: $(all_th[j]) iteration: $iteration")
                else
                    println("SET OK -- MTS -- Graph $(graph) l: $(all_l[i]) th: $(all_th[j]) iteration: $iteration")
                end

                avg += length(S)
            end
            avg = avg / iter
            append!(all_avg, [avg])
            # stream =  open("../../results/$(graph).txt","a")
            append!(all_string, "MTS \t| $(graph) | $(all_l[i]) \t| $(all_th[j]) \t | $avg\n")


        end
    end
    # write all_string to file
    # open a file 
    f =  open("././results/$(graph).txt", "w")
    write(f, "ALGO \t| GRAPH \t\t| l \t| th \t| avg\n")
    for i in 1:length(all_string)
        write(f, all_string[i])
    end
    close(f)
    # write(stream, all_string)
    all_avg
end

result = @distributed (append!) for graph in graphs
    g = load_my_graph("data/$graph")
    
    all_l = [length(vertices(g)) * 0.25, length(vertices(g)) * 0.5, length(vertices(g)) * 0.75, length(vertices(g))]
    all_th = [0.25, 0.5, 0.75, 1.0]
    all_avg = []
    all_string = []
    for i in 1:4 # l
        for j in 1:4 # th
            # println("RANDOM -- Graph $(graph) l: $(all_l[i]) th: $(all_th[j])")
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
            #iterate iter times
            for iteration in 1:iter
                best_k, best_S = algoRandom(g, thresholds, l)
                if !testSetWithDiffusion(g, best_S, thresholds)
                    println("SET NOT OK -- RANDOM -- Graph $(graph) l: $(all_l[i]) th: $(all_th[j]) iteration: $iteration")
                else
                    println("SET OK -- RANDOM -- Graph $(graph) l: $(all_l[i]) th: $(all_th[j]) iteration: $iteration")
                end
                avg += length(best_S)
            end
            avg = avg / iter
            append!(all_avg, [avg])
            append!(all_string, "RANDOM \t| $(graph) | $(all_l[i]) \t| $(all_th[j]) \t | $avg\n")

        end
    end
    f =  open("././results/$(graph).txt", "w")
    write(f, "ALGO \t| GRAPH \t\t| l \t| th \t| avg\n")
    for i in 1:length(all_string)
        write(f, all_string[i])
    end
    close(f)
    all_avg
end

result = @distributed (append!) for graph in graphs
    g = load_my_graph("data/$graph")
    
    all_l = [length(vertices(g)) * 0.25, length(vertices(g)) * 0.5, length(vertices(g)) * 0.75, length(vertices(g))]
    all_th = [0.25, 0.5, 0.75, 1.0]
    all_avg = []
    all_string = []
    for i in 1:4 # l
        for j in 1:4 # th
            # println("RANDOM -- Graph $(graph) l: $(all_l[i]) th: $(all_th[j])")
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
            #iterate iter times
            for iteration in 1:iter
                best_k, best_S = algoDegree(g, thresholds, l)
                if !testSetWithDiffusion(g, best_S, thresholds)
                    println("SET NOT OK -- DEGREE -- Graph $(graph) l: $(all_l[i]) th: $(all_th[j]) iteration: $iteration")
                else
                    println("SET OK -- DEGREE -- Graph $(graph) l: $(all_l[i]) th: $(all_th[j]) iteration: $iteration")
                end
                avg += length(best_S)
            end
            avg = avg / iter
            append!(all_avg, [avg])
            append!(all_string, "MTS \t| $(graph) | $(all_l[i]) \t| $(all_th[j]) \t | $avg\n")
        end
    end
    f =  open("././results/$(graph).txt", "w")
    write(f, "ALGO \t| GRAPH \t\t| l \t| th \t| avg\n")
    for i in 1:length(all_string)
        write(f, all_string[i])
    end
    close(f)
    all_avg
end

result = @distributed (append!) for graph in graphs
    g = load_my_graph("data/$graph")
    
    all_l = [length(vertices(g)) * 0.25, length(vertices(g)) * 0.5, length(vertices(g)) * 0.75, length(vertices(g))]
    all_th = [0.25, 0.5, 0.75, 1.0]
    all_avg = []
    all_string = []

    for i in 1:4 # l
        for j in 1:4 # th
            # println("MAX DEGREE -- Graph $(graph) l: $(all_l[i]) th: $(all_th[j])")
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
            #iterate iter times
            for iteration in 1:iter
                S, Active_S = algoMaxDegree(g, thresholds, l)
                if !testSetWithDiffusion(g, S, thresholds)
                    println("SET NOT OK -- MAX DEGREE -- Graph $(graph) l: $(all_l[i]) th: $(all_th[j]) iteration: $iteration")
                else
                    println("SET OK -- MAXDEGREE -- Graph $(graph) l: $(all_l[i]) th: $(all_th[j]) iteration: $iteration")
                end
                avg += length(S)
            end
            avg = avg / iter
            append!(all_avg, [avg])
            append!(all_string, "MTS \t| $(graph) | $(all_l[i]) \t| $(all_th[j]) \t | $avg\n")
        end
    end
    f =  open("././results/$(graph).txt", "w")
    write(f, "ALGO \t| GRAPH \t\t| l \t| th \t| avg\n")
    for i in 1:length(all_string)
        write(f, all_string[i])
    end
    close(f)
    all_avg
end