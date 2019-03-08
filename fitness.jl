function fitness(solver::NSGA, ind)
	risco, retorno = 0.0, 0.0
	for i in 1:length(ind.ativos)
		# custos de transação diminuindo o retorno?
		retorno += ind.lotes[i] * solver.μ[ind.ativos[i]] # - custo_transacao
		risco   += ind.lotes[i] * solver.σ[ind.ativos[i]]
	end
 	return risco, retorno
end

function fitness_populacao(solver::NSGA)
	# original
	pontos = []
	for ind in solver.populacao
		push!(pontos, fitness(solver::NSGA, ind))
	end

	# adaptado pra threads
	# pontos = [(-1, -1) for x in length(solver.populacao)]
	# Threads.@threads for i in 1:length(solver.populacao)
	# 	risco, retorno = fitness(solver::NSGA, solver.populacao[i])
	# 	pontos[i] = (risco, retorno)
	# end

	return pontos
end

insere_sem_duplicar!(v::Vector, x) = (splice!(v, searchsorted(v,x), [x]); v)

function domina(p, q)
    if p[1] < q[1] && p[2] > q[2] # (risco, retorno)
    	return true
    else
    	return false
    end
end

function nds(pontos)
    fronteiras, idxs = [], []
    pontos_originais = copy(pontos)
    while !isempty(pontos)
		pl = []
    	push!(pl, pontos[1])
        # for i in 2:length(pontos)
	    	# p = pontos[i]
	    for p in pontos[2:end]
	    	pushfirst!(pl, p)
	    	remove_esses = []
	    	for j in 2:length(pl)
	    		q = pl[j]
	    		if domina(p, q)
	    			insere_sem_duplicar!(remove_esses, j)
	    			# splice!(pl, j) # remove j-ésimo elemento (que é q) de pl
	    		else
	    			if domina(q, p)
	    				insere_sem_duplicar!(remove_esses, 1)
	    				# splice!(pl, 1) # remove primeiro elemento (que é p) de pl
	    			end
	    		end
	    	end
	    	deleteat!(pl, remove_esses)
	    end

	    # precisa manter os indices originais dos pontos em cada fronteira
	    indices = []
	    for p in pl
	    	push!(indices, findfirst(isequal(p), pontos_originais))
	    end
	    push!(idxs, indices)
	    
	    push!(fronteiras, pl)
	    filter!(x -> x ∉ pl, pontos)
	end
    return fronteiras, idxs
end