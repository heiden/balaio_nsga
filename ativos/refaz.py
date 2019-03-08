import os
import csv

atributos = ['Date', 'Open', 'High', 'Low', 'Close', 'Adj Close', 'Volume']

arqs = os.listdir('./original/')

for a in arqs:

	entradas_in_sample = []
	entradas_out_of_sample = []

	with open('./original/' + a, 'r') as arq:
		reader = csv.reader(arq)
		reader.next()
		for linha in reader:
			ano = int(linha[0].split('-')[0])
			if ano == 2010:
				entradas_in_sample.append(linha)
			else:
				entradas_out_of_sample.append(linha)

	with open('./in-sample/' + a, 'w') as arq:
		writer = csv.writer(arq)
		writer.writerow(atributos)
		for entrada in entradas_in_sample:
			writer.writerow(entrada)

	with open('./out-of-sample/' + a, 'w') as arq:
		writer = csv.writer(arq)
		writer.writerow(atributos)
		for entrada in entradas_out_of_sample:
			writer.writerow(entrada)
