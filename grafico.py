import matplotlib.pyplot as plt

fig = plt.figure()
ax = fig.add_subplot(111)
titulo = 'portfolios'
ax.set_title(titulo)
ax.set_xlabel('risco')
ax.set_ylabel('retorno')

with open('outro') as arq:
	linhas = arq.readlines()
	x = [float(linha.split()[0]) for linha in linhas]
	y = [float(linha.split()[1]) for linha in linhas]

ax.plot(x, y, 'x', c = '#871c83', label = 'nsga literatura')

leg = ax.legend()

# plt.show()
plt.savefig(titulo + '.png')