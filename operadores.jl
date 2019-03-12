function torneio_binario(solver::NSGA, fronteiras, indices)
	selecionados, melhores_ordenados = [], []
	for i in indices
		append!(melhores_ordenados, i)
	end

	rng = MersenneTwisters.MT19937()
	for i in 1:length(solver.populacao) / 2
		s = []
		while length(s) != 2
			a, b = sample(rng, melhores_ordenados, 2, replace = false)
			if findfirst(isequal(a), melhores_ordenados) < findfirst(isequal(b), melhores_ordenados) 
				melhor = a
			else
				melhor = b
			end
			if length(s) == 0
				push!(s, melhor)
			elseif melhor != s[1]
				push!(s, melhor)
			end
		end
		push!(selecionados, (s[1], s[2]))
	end
	return selecionados
end



function meu_crossover(solver::NSGA, selecao)
    # rng = MersenneTwisters.MT19937()
    l = []
    tam = length(solver.populacao[1].ativos)

    for s in selecao
    	pa_lotes,  pb_lotes  = solver.populacao[s[1]].lotes,  solver.populacao[s[2]].lotes
    	pa_ativos, pb_ativos = solver.populacao[s[1]].ativos, solver.populacao[s[2]].ativos
    	ω = rand()
    	if ω < solver.cx

			# ativos // pmx
    		fa_ativos, fb_ativos = [0 for x in 1:tam], [0 for x in 1:tam]
    		x, y = sort!(sample(1:tam, 2, replace = false))

    		secao_a = pa_ativos[x:y]
    		secao_b = pb_ativos[x:y]

    		# troca as seções entre os pontos e coloca nos filhos
    		pos = 1
    		for i in x:y
    			fa_ativos[i] = secao_b[pos]
    			fb_ativos[i] = secao_a[pos]
    			pos += 1
    		end

    		# cria a parte antes da seção nos filhos
    		for i in 1:x-1
    			aux_a = pa_ativos[i]
    			while aux_a in secao_b
    				aux_a = pa_ativos[x + findfirst(isequal(aux_a), secao_b) - 1]
    			end
    			fa_ativos[i] = aux_a

    			aux_b = pb_ativos[i]
    			while aux_b in secao_a
    				aux_b = pb_ativos[x + findfirst(isequal(aux_b), secao_a) - 1]
    			end
    			fb_ativos[i] = aux_b
    		end

    		# cria a parte depois da seção nos filhos
    		for i in y+1:tam
    			aux_a = pa_ativos[i]
    			while aux_a in secao_b
    				aux_a = pa_ativos[x + findfirst(isequal(aux_a), secao_b) - 1]
    			end
    			fa_ativos[i] = aux_a

    			aux_b = pb_ativos[i]
    			while aux_b in secao_a
    				aux_b = pb_ativos[x + findfirst(isequal(aux_b), secao_a) - 1]
    			end
    			fb_ativos[i] = aux_b
    		end

			# lotes // arithmetic
    		fa_lotes, fb_lotes = [0.0 for x in 1:tam], [0.0 for x in 1:tam]
			α = rand()
			for i in 1:tam
				fa_lotes[i] = α * pa_lotes[i] + (1 - α) * pb_lotes[i]
				fb_lotes[i] = (1 - α) * pa_lotes[i] + α * pb_lotes[i]
			end

			push!(solver.populacao, Individuo(fa_ativos, fa_lotes))
			push!(solver.populacao, Individuo(fb_ativos, fb_lotes))

		end
    end

end

function crossover(solver::NSGA, selecao, k)
	# uniforme pros lotes?
	# pros ativos vou implementar a do DEB

	tam = length(solver.populacao[1].ativos)
	for s in selecao
		# ativos
    	pa_lotes,  pb_lotes  = solver.populacao[s[1]].lotes,  solver.populacao[s[2]].lotes
    	pa_ativos, pb_ativos = copy(solver.populacao[s[1]].ativos), copy(solver.populacao[s[2]].ativos)
    	ω = rand()
    	if ω < solver.cx
	    	fa_ativos, fb_ativos = [0 for x in 1:tam], [0 for x in 1:tam]
	    	# se os dois forem 0, pega 0 // se os dois forem 1, pega 1
	    	cunt = 0
	    	for i in 1:tam
	    		if pa_ativos[i] == 1 && pb_ativos[i] == 1
	    			cunt += 1
	    			fa_ativos[i], fb_ativos[i] = 1, 1
	    			pa_ativos[i], pb_ativos[i] = -1, -1 # anula o indice i pra nao pegar dnv no sorteio depois
	    		elseif pa_ativos[i] == 0 && pb_ativos[i] == 0
	    			fa_ativos[i], fb_ativos[i] = 0, 0
	    			pa_ativos[i], pb_ativos[i] = -1, -1 # anula o indice i pra nao pegar dnv no sorteio depois
	    		end
	    	end
	    	# pega todos os indices que são 1 nos pais
	    	qnt = k - cunt
	    	uns = findall(isequal(1), pa_ativos)
	    	outros = findall(isequal(1), pb_ativos)
	    	uns_e_outros = [uns; outros]
	    	escolhas_fa = sample(uns_e_outros, qnt, replace = false)
	    	escolhas_fb = sample(uns_e_outros, qnt, replace = false)
	    	for i in 1:qnt
	    		fa_ativos[escolhas_fa[i]] = 1
	    		fb_ativos[escolhas_fb[i]] = 1
	    	end
	    
	    	# println("pa: ", solver.populacao[s[1]].ativos)
	    	# println("pb: ", solver.populacao[s[2]].ativos)
	    	# println("fa: Int32", fa_ativos)
	    	# println("fb: Int32", fb_ativos)
	    	# exit(0)

    		pa_lotes_atual, pb_lotes_atual = filter(x->x≠0, pa_lotes), filter(x->x≠0, pb_lotes)
	    	fa_lotes, fb_lotes = [0.0 for x in 1:tam], [0.0 for x in 1:tam]

	    	tam_lotes = length(pa_lotes_atual)
	    	for i in 1:tam_lotes
	    		valor = (pa_lotes_atual[i] + pb_lotes_atual[i]) / 2
	    		pa_lotes_atual[i], pb_lotes_atual[i] = valor, valor
	    	end

	    	cunt_a = 0
	    	cunt_b = 0
	    	for i in 1:tam
	    		if fa_ativos[i] == 1
	    			fa_lotes[i] = pa_lotes_atual[cunt_a+=1]
	    		else
	    			fa_lotes[i] = 0
	    		end
	    		if fb_ativos[i] == 1
	    			fb_lotes[i] = pb_lotes_atual[cunt_b+=1]
	    		else
	    			fb_lotes[i] = 0
	    		end
	    	end
	    	# ind.lotes /= sum(ind.lotes) # não precisa reparar do jeito que implementei

			push!(solver.populacao, Individuo(fa_ativos, fa_lotes))
			push!(solver.populacao, Individuo(fb_ativos, fb_lotes))

	    end
	end

end

function mutacao(solver::NSGA)
    # bit flip pros ativos, vai gerar indivíduos inválidos
    # reparar pegando um oposto e flipando ele tbm
    # ex: se o bit flip converter um 0 pra 1, precisa sortear um 1 e trocar pra 0
    # a ideia é manter a cardinalidade = k

	d = Normal(0.0, 1.0) # Normal(μ = 0.0, σ = 0.5), σ = 1.0 tbm deve funcionar
    tam = length(solver.populacao[1].ativos)
    for ind in solver.populacao
		bit0s = findall(isequal(0), ind.ativos)
		bit1s = findall(isequal(1), ind.ativos)
    	
    	# ativos
    	for i in 1:tam
    		ω = rand()
    		if ω < solver.mr
    			# x = rand(1:tam)
    			# if ind.ativos[x] == 0
    			# 	era = 0
    			# 	ind.ativos[x] = 1
    			# 	filter!(b -> b≠x, bit0s) # remove o indice x do vetor de zeros
    			# 	push!(bit1s, x) 		 # adiciona o indice x no vetor de uns
    			# else
    			# 	era = 1
    			# 	ind.ativos[x] = 0
    			# 	filter!(b -> b≠x, bit1s) # remove o indice x do vetor de uns
    			# 	push!(bit0s, x) 		 # adiciona o indice x no vetor de zeros
    			# end

    			# # reparar ativos
    			# if era == 0
    			# 	y = sample(bit1s)
    			# 	ind.ativos[y] = 0
    			# 	filter!(b -> b≠y, bit1s) # remove o indice y do vetor de uns
    			# 	push!(bit0s, y) 		 # adiciona o indice y no vetor de zeros
    			# else
    			# 	y = sample(bit0s)
    			# 	ind.ativos[y] = 1
    			# 	filter!(b -> b≠y, bit0s) # remove o indice y do vetor de zeros
    			# 	push!(bit1s, y) 		 # adiciona o indice y no vetor de uns
    			# end

    			x = rand(1:tam)
				ind.ativos[i], ind.ativos[x] = ind.ativos[x], ind.ativos[i]
				ind.lotes[i], ind.lotes[x] = ind.lotes[x], ind.lotes[i]

    		end
    	end

    	# lotes
    	# a ideia eh perturbar apenas os lotes ≠ 0
    	lotes_atuais = filter(x->x≠0, ind.lotes)
    	for i in 1:length(lotes_atuais)
    		ω = rand()
    		if ω < solver.mr
				pert = rand(d) / 100.0
				if lotes_atuais[i] + pert >= 0	lotes_atuais[i] += pert	   end
    		end
    	end
    	cunt = 0
    	for i in 1:tam
    		if ind.ativos[i] == 1
    			ind.lotes[i] = lotes_atuais[cunt+=1]
    		else
    			ind.lotes[i] = 0
    		end
    	end
    	ind.lotes /= sum(ind.lotes) # reparo bom, implementar o nojento dps
    end
end

function minha_mutacao(solver::NSGA, qnt_ativos)
	d = Normal(0.0, 1.0) # Normal(μ = 0.0, σ = 0.5), σ = 1.0 tbm deve funcionar
	tam = length(solver.populacao[1].ativos)
	for ind in solver.populacao
		for i in 1:tam
			ω = rand()
			if ω < solver.mr
				# ativos
				# gera um ativo x que não está no indivíduo e troca o ativo no índice i
				x = ind.ativos[i]
				while x in ind.ativos	x = rand(1:qnt_ativos)	end
				ind.ativos[i] = x
				
				# lotes
				x = rand(1:tam)
				pert = rand(d) / 100.0
				if (ind.lotes[i] + pert <= 1.0 && ind.lotes[i] + pert >= 0.0 && ind.lotes[i] - pert <= 1.0 && ind.lotes[i] - pert >= 0.0
				&& ind.lotes[x] + pert <= 1.0 && ind.lotes[x] + pert >= 0.0 && ind.lotes[x] - pert <= 1.0 && ind.lotes[x] - pert >= 0.0)
					ind.lotes[i] += pert
					ind.lotes[x] -= pert
				end
			end
		end
	end

end

function atualiza_parametros(solver::NSGA, i, ng)
    # solver.cx = 0.85 + 0.1  * exp(-0.3 * i^2 / (2*ng)) # it = 0, cx = 0.95 // it = max_it, cx = 0.85
    # solver.mr = 0.03 + 0.02 * exp(-0.2 * i^2 / (2*ng)) # it = 0, mr = 0.05 // it = max_it, mr = 0.03

    # params cagados
    solver.cx = 0.9 - 8.8 * exp(-0.3 * i^2 / (2*ng))
    solver.mr = 0.9 - 8.8 * exp(-0.2 * i^2 / (2*ng))
end
