function gera_ativos(k, qnt)
    rng = MersenneTwisters.MT19937()
    x = sample(rng, 1:qnt, k, replace = false)
    
    y = [0 for i in 1:qnt]
    for i in x
        y[i] = 1
    end

    return y
end

function gera_lotes(k, qnt, ativos)
    rng = MersenneTwisters.MT19937()
    # x = rand(rng, k)
    # x /= sum(x)
    x = [0.0 for i in 1:qnt]

    for i in 1:qnt
        if ativos[i] == 1
            x[i] = rand(rng)
        end
    end
    
    x /= sum(x) # reparo decente, tem que implementar o lixoso de decrementar
    return x
end

function filtra_populacao(solver::NSGA, frontiers, indexes, tam_pop, fitness)
	populacao_antiga = solver.populacao
	solver.populacao = []
	for is in indexes
		# println(is)
		if length(is) <= tam_pop
			for i in is
				push!(solver.populacao, populacao_antiga[i])
			end
			tam_pop -= length(is)
			if tam_pop == 0
				return
			end
		else # quantidade vai explodir, incluir os n pontos que faltam com a maior distância
			# println("pop has ", length(solver.population), " frontier has ", length(is))
			selecao = crowding_distance(fitness, is, tam_pop)
			for s in selecao
				push!(solver.populacao, populacao_antiga[s])
			end
			return
		end
	end
end

function crowding_distance(fitness, indexes, n)
    if n == 1
    	return [indexes[1]]
   	elseif n == 2
   		return [indexes[1], indexes[end]]
   	end

    obj = [[] for i in 1:length(fitness[1])]
    for i in 1:length(fitness[1])
    	for j in indexes
    		push!(obj[i], fitness[j][i])
    	end
    end

    # println("pop needs ", n)
    # println(obj)

    dist = [0.0 for i in 1:length(indexes)]
    dist[1], dist[end] = Inf, Inf
    for i in 1:length(obj)
    	sort!(obj[i])
    	for j in 2:length(indexes) - 1
    		dist[j] += (obj[i][j-1] - obj[i][j+1])
    	end
    end
    
    sorted = sort(dist)
    selected = [indexes[1], indexes[end]]
    for s in sorted[end-n+1:end-2]
    	push!(selected, indexes[findfirst(isequal(s), dist)])
    end
    # println(selected)
    return selected
end