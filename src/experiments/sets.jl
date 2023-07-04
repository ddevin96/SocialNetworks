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
# ca-Astro too much slow
# graphs = ["karate.edges", "ca-AstroPh.edges", "ca-GrQc.edges", "ca-HepTh.edges", "CollegeMsg.edges", "email-EU-core.edges", "facebook.edges", "p2p.edges"]
graphs = ["karate.edges", "ca-GrQc.edges", "ca-HepTh.edges", "CollegeMsg.edges", "email-EU-core.edges", "facebook.edges", "p2p.edges"]
# graphs = ["karate.edges"]

# write_graph_info(graphs)

# test all th and l
result = @distributed (append!) for graph in graphs
    g = load_my_graph("data/$graph")
    my_g = split(graph, ".")[1]

    all_l = [length(vertices(g)) * 0.25, length(vertices(g)) * 0.5, length(vertices(g)) * 0.75, length(vertices(g))]
    # all_l = [length(vertices(g)) * 0.5]
    all_th = [0.25, 0.5, 0.75, 1.0]
    # all_th = [0.75]
    all_avg = []
    all_string = []
    for i in 1:length(all_l) # l
        for j in 1:length(all_th) # th
            thresholds = Dict()
            if j != 4
                for v in vertices(g)
                    thresholds[v] = degree(g, v) * all_th[j]
                end
                # println(thresholds)
            else
                for v in vertices(g)
                    thresholds[v] = rand(1:degree(g, v))
                end
            end
            l = all_l[i]
            avg = 0.0
            #iterate iter times
            for iteration in 1:iter
                println("MTS -- Graph $(graph) l: $(all_l[i]) th: $(all_th[j]) iteration: $iteration")
                S, activeS = MTS(g, thresholds, l)
                # println("S length: $(length(S))")
                # if !testSetWithDiffusion(g, S, thresholds, l)
                #     println("SET NOT OK -- MTS -- Graph $(graph) l: $(all_l[i]) th: $(all_th[j]) iteration: $iteration")
                # else
                #     println("SET OK -- MTS -- Graph $(graph) l: $(all_l[i]) th: $(all_th[j]) iteration: $iteration")
                # end
                avg += length(S)
            end
            avg = avg / iter
            append!(all_avg, [avg])
            # append!(all_string, "MTS \t| $(my_g) \t| $(all_l[i]) \t| $(all_th[j]) \t| $avg\n")
            append!(all_string, "MTS,$(my_g),$(all_l[i]),$(all_th[j]),$avg\n")


        end
    end
    # write all_string to file
    # open a file 
    f =  open("././results/mts/$(graph).txt", "w")
    write(f, "ALGO,GRAPH,l,th,avg\n")
    for i in 1:length(all_string)
        write(f, all_string[i])
    end
    close(f)
    # write(stream, all_string)
    all_avg
end

result = @distributed (append!) for graph in graphs
    g = load_my_graph("data/$graph")
    my_g = split(graph, ".")[1]
    all_l = [length(vertices(g)) * 0.25, length(vertices(g)) * 0.5, length(vertices(g)) * 0.75, length(vertices(g))]
    # all_l = [length(vertices(g)) * 0.25, length(vertices(g)) * 0.5, length(vertices(g)) * 0.75]
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
                println("RANDOM -- Graph $(graph) l: $(all_l[i]) th: $(all_th[j]) iteration: $iteration")

                best_k, best_S = algoRandom(g, thresholds, l)
                # if !testSetWithDiffusion(g, best_S, thresholds)
                #     println("SET NOT OK -- RANDOM -- Graph $(graph) l: $(all_l[i]) th: $(all_th[j]) iteration: $iteration")
                # else
                #     println("SET OK -- RANDOM -- Graph $(graph) l: $(all_l[i]) th: $(all_th[j]) iteration: $iteration")
                # end
                avg += length(best_S)
            end
            avg = avg / iter
            append!(all_avg, [avg])
            # append!(all_string, "RANDOM \t| $(my_g) \t| $(all_l[i]) \t| $(all_th[j]) \t | $avg\n")
            append!(all_string, "RANDOM,$(my_g),$(all_l[i]),$(all_th[j]),$avg\n")

        end
    end
    f =  open("././results/rand/$(graph).txt", "w")
    write(f, "ALGO,GRAPH,l,th,avg\n")
    for i in 1:length(all_string)
        write(f, all_string[i])
    end
    close(f)
    all_avg
end

result = @distributed (append!) for graph in graphs
    g = load_my_graph("data/$graph")
    my_g = split(graph, ".")[1]
    all_l = [length(vertices(g)) * 0.25, length(vertices(g)) * 0.5, length(vertices(g)) * 0.75, length(vertices(g))]
    # all_l = [length(vertices(g)) * 0.25, length(vertices(g)) * 0.5, length(vertices(g)) * 0.75]
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
                    println("DEGREE -- Graph $(graph) l: $(all_l[i]) th: $(all_th[j]) iteration: $iteration")

                best_k, best_S = algoDegree(g, thresholds, l)
                # if !testSetWithDiffusion(g, best_S, thresholds)
                #     println("SET NOT OK -- DEGREE -- Graph $(graph) l: $(all_l[i]) th: $(all_th[j]) iteration: $iteration")
                # else
                #     println("SET OK -- DEGREE -- Graph $(graph) l: $(all_l[i]) th: $(all_th[j]) iteration: $iteration")
                # end
                avg += length(best_S)
            end
            avg = avg / iter
            append!(all_avg, [avg])
            # append!(all_string, "DEG \t| $(my_g) \t| $(all_l[i]) \t| $(all_th[j]) \t | $avg\n")
            append!(all_string, "DEG,$(my_g),$(all_l[i]),$(all_th[j]),$avg\n")
        end
    end
    f =  open("././results/deg/$(graph).txt", "w")
    write(f, "ALGO,GRAPH,l,th,avg\n")
    for i in 1:length(all_string)
        write(f, all_string[i])
    end
    close(f)
    all_avg
end

result = @distributed (append!) for graph in graphs
    g = load_my_graph("data/$graph")
    my_g = split(graph, ".")[1]
    all_l = [length(vertices(g)) * 0.25, length(vertices(g)) * 0.5, length(vertices(g)) * 0.75, length(vertices(g))]
    # all_l = [length(vertices(g)) * 0.5]
    # all_l = [length(vertices(g)) * 0.25, length(vertices(g)) * 0.5, length(vertices(g)) * 0.75]
    all_th = [0.25, 0.5, 0.75, 1.0]
    # all_th = [0.75]
    all_avg = []
    all_string = []
    for i in 1:length(all_l) # l
        for j in 1:length(all_th) # th
            # println("MAX DEGREE -- Graph $(graph) l: $(all_l[i]) th: $(all_th[j])")
            thresholds = Dict()
            if j != 4
                for v in vertices(g)
                    thresholds[v] = degree(g, v) * all_th[j]
                end
                # println(thresholds)
            else
                for v in vertices(g)
                    thresholds[v] = rand(1:degree(g, v))
                end
            end
            l = all_l[i]
            avg = 0.0
            #iterate iter times
            for iteration in 1:iter
                println("MAX DEGREE -- Graph $(graph) l: $(all_l[i]) th: $(all_th[j]) iteration: $iteration")
            
                S, Active_S = algoMaxDegree(g, thresholds, l)
                # println("length S: $(length(S))")
                # println("S: $(S)")
                # println(all_neighbors(g, collect(S)[1]))
                # if !testSetWithDiffusion(g, S, thresholds, l)
                #     println("SET NOT OK -- MAX DEGREE -- Graph $(graph) l: $(all_l[i]) th: $(all_th[j]) iteration: $iteration")
                # else
                #     println("SET OK -- MAXDEGREE -- Graph $(graph) l: $(all_l[i]) th: $(all_th[j]) iteration: $iteration")
                # end
                avg += length(S)
            end
            avg = avg / iter
            append!(all_avg, [avg])
            # append!(all_string, "MAX DEG \t| $(my_g) \t| $(all_l[i]) \t| $(all_th[j]) \t | $avg\n")
            append!(all_string, "MAX DEG,$(my_g),$(all_l[i]),$(all_th[j]),$avg\n")
        end
    end
    f =  open("././results/maxdeg/$(graph).txt", "w")
    write(f, "ALGO,GRAPH,l,th,avg\n")
    for i in 1:length(all_string)
        write(f, all_string[i])
    end
    close(f)
    all_avg
end 