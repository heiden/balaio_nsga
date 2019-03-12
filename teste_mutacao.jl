function mutacao(a)
    # bit flip pros ativos, vai gerar indivíduos inválidos
    # reparar pegando um oposto e flipando ele tbm
    # ex: se o bit flip converter um 0 pra 1, precisa sortear um 1 e trocar pra 0
    # a ideia é manter a cardinalidade = k

	# d = Normal(0.0, 1.0) # Normal(μ = 0.0, σ = 0.5), σ = 1.0 tbm deve funcionar
    tam = length(a[1])
	bit0s = findall(isequal(0), a[2])
	bit1s = findall(isequal(1), a[2])
	
	# ativos

	x = 4 #rand(1:tam)
	if a[2][x] == 0
		era = 0
		a[2][x] = 1
		filter!(b -> b≠x, bit0s) # remove o indice x do vetor de zeros
		push!(bit1s, x) 		 # adiciona o indice x no vetor de uns
	else
		era = 1
		a[2][x] = 0
		filter!(b -> b≠x, bit1s) # remove o indice x do vetor de uns
		push!(bit0s, x) 		 # adiciona o indice x no vetor de zeros
	end

	# reparar ativos
	if era == 0
		y = 7 #sample(bit1s)
		a[2][y] = 0
		filter!(b -> b≠y, bit1s) # remove o indice y do vetor de uns
		push!(bit0s, y) 		 # adiciona o indice y no vetor de zeros
	else
		y = 7 # sample(bit0s)
		a[2][y] = 1
		filter!(b -> b≠y, bit0s) # remove o indice y do vetor de zeros
		push!(bit1s, y) 		 # adiciona o indice y no vetor de uns
	end


    # lotes
    # a ideia eh perturbar apenas os lotes ≠ 0
    lotes_atuais = filter(x->x≠0, a[1])

    i = 2
   	pert = -0.0053 #rand(d) / 100.0
   	if lotes_atuais[i] + pert >= 0	lotes_atuais[i] += pert	   end

    cunt = 0
    for i in 1:tam
    	if a[2][i] == 1
    		a[1][i] = lotes_atuais[cunt+=1]
    	else
    		a[1][i] = 0
    	end
    end

    println(a[1], " : ", a[2])

    a[1] /= sum(a[1]) # reparo bom, implementar o nojento dps

    println(a[1], " : ", a[2])

end

mutacao([[0.1, 0.25, 0.25, 0.0, 0.0, 0.0, 0.4, 0.0], [1, 1, 1, 0, 0, 0, 1, 0]])