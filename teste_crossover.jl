using StatsBase

function crossover(a, b, k)
	# uniforme pros lotes?
	# pros ativos vou implementar a do DEB

	tam = length(a[1])
	# ativos
	pa_lotes,  pb_lotes  = a[1],  b[1]
	pa_ativos, pb_ativos = copy(a[2]), copy(b[2])

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
	# escolhas_fa = sample(uns_e_outros, qnt, replace = false)
	# escolhas_fb = sample(uns_e_outros, qnt, replace = false)
	escolhas_fa = [1, 7]
	escolhas_fb = [7, 6]
	for i in 1:qnt
		fa_ativos[escolhas_fa[i]] = 1
		fb_ativos[escolhas_fb[i]] = 1
	end

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

	println(fa_ativos, " : ", fa_lotes)
	println(fb_ativos, " : ", fb_lotes)

end

crossover([[0, 0.1, 0.2, 0.3, 0, 0.4, 0, 0], [0,1,1,1,0,1,0,0]], [[0.1, 0.3, 0.2, 0, 0, 0, 0.4, 0], [1,1,1,0,0,0,1,0]], 4)