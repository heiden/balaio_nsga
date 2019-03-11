function parametros(arq)
	params = readlines(arq)
	it = tryparse(Int32,   params[1])
	sz = tryparse(Int32,   params[2])
	k  = tryparse(Int32,   params[3])
	β  = tryparse(Float32, params[4])
	cx = tryparse(Float32, params[5])
	mr = tryparse(Float32, params[6])

	return it, sz, k, β, cx, mr
end

function le_ativos()
	T, ativos = [], []
	dir = "./ativos/in-sample/"
	arqs = readdir(dir)

	for i in 2:length(arqs)
		df = CSV.read(dir * arqs[i])
		rename!(df, Symbol("Adj Close") => Symbol("Adj_Close"))
		append!(T, CSV.nrow(df))
		push!(ativos, df.Adj_Close)
	end

	return ativos, T
end

function μT(ativo, T)
	rj = 0.0
	for i in 2:T
		rj += (ativo[i] - ativo[i-1])
	end
	μj = (1 / (T-1)) * rj
	return μj
end

function cada_μ(ativo)
	retornos = [0.0 for i = 1:length(ativo)]
	retornos[1] = 0.0 # undefined value
	for i in length(ativo):-1:2
		retornos[i] = (ativo[i] - ativo[i-1]) / ativo[i-1]
	end
	return retornos[2:end]
end

function calcula_index(β, total)
	return ceil(Int, (1 - β/100) * total)
end

function calcula_risco(β, ativos, n_amostras)
	risco = []
	for i in 1:length(ativos)
		retornos = cada_μ(ativos[i])
		retornos_ordenados = sort!(retornos)
		total_count = n_amostras[i]
		index = calcula_index(β, total_count) # β deve ser 95, 99 ou 99.9
		# risco += retornos_ordenados[index] # VaR
		push!(risco, abs((1 / index) * sum(retornos_ordenados[1:index]))) # CVaR
	end
	return risco
end

function portfolio(β)
	ativos, n_amostras = le_ativos()
	risco = calcula_risco(β, ativos, n_amostras)
    μ = []
    for i in 1:length(ativos)
    	push!(μ, μT(ativos[i], n_amostras[i]))
    end
    return ativos, μ, risco
end

function plot(fronteira)
	file = "pontos"
	open(file, "a") do f # append = "a"
		for ponto in fronteira
			write(f, string(ponto[1]) * " " * string(ponto[2]) * "\n")
		end
	end
	# run(`gnuplot plot.gnu`)
	# run(`display portfolios.png`)
end