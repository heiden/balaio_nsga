include("dados.jl")
include("classe.jl")
include("fitness.jl")
include("populacao.jl")
include("operadores.jl")

it, tam_pop, cardinalidade, β, cx, mr = parametros("params.in")
ativos, μ, σ = portfolio(β)
qnt_ativos = length(ativos)
pop = []
for i in 1:tam_pop
	a = gera_ativos(cardinalidade, qnt_ativos)
	l = gera_lotes(cardinalidade, qnt_ativos, a)
	ind = Individuo(a, l)
	push!(pop, ind)
end

solver = NSGA(cx, mr, μ, σ, tam_pop, cardinalidade, pop)

@time for i in 1:it
	
	# atualiza cx e mr - o esquema do garcia tá zoadaço
	# classifica os caras
	# faz seleção
	# crossover ativos
	# crossover lotes
	# mutação ativos
	# mutação lotes
	# classifica os caras 2
	# filtra população

	# atualiza_parametros(solver, i, it) # comenta essa linha se quiser parâmetros fixos
	# println("cx: ", solver.cx, " mr: ", solver.mr)

	if i % 50 == 0	println(i)	end
	# println("============== : ", i)
	# for ind in solver.populacao
	# 	println(ind)
	# end

	pontos = fitness_populacao(solver)
	# for p in pontos println(pontos) end

	fronteiras, indices = nds(pontos)
	# for f in fronteiras println(f) end
	# for i in indices println(i) end

	selecao = torneio_binario(solver, fronteiras, indices)
	# println(selecao)
	# println("passei da selecao")
	# for x in solver.populacao println(x.ativos, " ", sum(x.lotes)) end
	# println(length(solver.populacao))
	# println(length(solver.populacao))
	# for x in solver.populacao println(x.ativos, " ", x.lotes, " ", sum(x.lotes)) end
	crossover(solver, selecao, solver.cardinalidade)
	# meu_crossover(solver, selecao)
	# println("passei do crossover")
	# println(length(solver.populacao))
	# for x in solver.populacao println(x.ativos, " ", x.lotes, " ", sum(x.lotes)) end

	# for x in solver.populacao println(x.ativos, " ", x.lotes, " ", sum(x.lotes)) end
	# println(length(solver.populacao))
	mutacao(solver)
	# minha_mutacao(solver, qnt_ativos)
	# println("passei da mutacao")
	# for x in solver.populacao println(x.ativos, " ", x.lotes, " ", sum(x.lotes)) end
	# println(length(solver.populacao))

	pontos = fitness_populacao(solver)
	fitness = copy(pontos)
	fronteiras, indices = nds(pontos)
	filtra_populacao(solver, fronteiras, indices, tam_pop, fitness)
	# println("passei do filtro")

	# for i in solver.populacao
	# 	println(i)
	# end

end
pontos = fitness_populacao(solver)
fronteiras, indices = nds(pontos)
# for i in indices[1]
# 	println(solver.populacao[i])
# end
# for f in fronteiras[1]
# 	println(f)
# end
println("caras na fronteira ótima: ", length(fronteiras[1]))
# plot(fronteiras[1], cardinalidade)
portfolios_resposta(solver.populacao, fronteiras[1], cardinalidade)

# for x in solver.populacao println(x.ativos, " : ", sum(x.lotes)) end




# dados sobre custos de transação:
# https://www.bb.com.br/pbb/pagina-inicial/compra-e-venda-de-acoes/guia-do-investidor/perguntas-frequentes#/
# > custos e liquidação > dúvidas

# capital disponível C de R$ 100.000,00 ; 

# TARIFA DE CORRETAGEM: R$ 20,00 para cada compra e venda
# se eu usar 1 como 100% e 100% for 100.000, então 20 será 0.00020

# EMOLUMENTOS, aplicar se movimentar o ativo
# 0.0345% do valor negociado // 0.000345 * lotes[i]

# TARIFA DE CUSTÓDIA
# de R$ 0 a 1.000.000,00 - 0.0130% // 0.000130


# ========================

# custos de transação
# como que vou manter a taxa total para cada indivíduo?
# não posso resetar a cada iteração
# ele pode ser usado em mais de um crossover, e ai faz o que?

# a ideia será que é usar um valor ao envés de porcentagens?
# daria pra manter o valor de cada portfólio até o final, atualizando a cada iteração?