#!/usr/bin/python
#
# -*- coding: utf-8 -*-
""" Sistema para comparar duas saidas de erro (RMSE ou BIAS)
 
    Este modulo permite gerar um grafico com as diferencas entre dois
    arquivos CSV de saida do BRAMS que mostram o RMSE e BIAS de cada uma
    da rodadas.
     
    versao do Python em que foi testada: Python 3.7.5

     
"""
 
__author__ = "Luiz Flavio Rodrigues"
__copyright__ = "CPTEC INPE BR"
__credits__ = "BRAMS - Brazilian developments on the Regional Atmospheric Modeling System"
__license__ = "GNU General Public License"
__version__ = "1.0.0"
__maintainer__ = "Luiz Flavio Rodrigues"
__email__ = "luiz.rodrigues@inpe.br"
__status__ = "Prototype"

import csv
import matplotlib.pyplot as plt
import numpy as np
from scipy.ndimage.filters import gaussian_filter
import sys, getopt

def main(argv):

  try:
    opts, args = getopt.getopt(argv,"ha:b:t:k:",
      ["afile=","bfile=","time=","ticks="])
  except getopt.GetoptError:
    err=printHelp()
    sys.exit(2)
  
  #Reading the arguments from system call
  (arq1,arq2,totaltime,ticksTime)=readArgs(opts, args)

  arquivo1 = open(arq1)
  linhas1 = csv.reader(arquivo1,delimiter=";")
  cabec=True
  valTime1 =[]
  valCampo1=[]
  lev1=[]
  for linha1 in linhas1:
    if cabec:
      xlabel1=linha1[0]
      ylabel1=linha1[1:]
      for i in range(len(ylabel1)):
        lev1.append(float(ylabel1[i]))
        valCampo1.append([])
      cabec=False
      totalFields1=len(ylabel1)
      continue
    valTime1.append(float(linha1[0]))
    for i in range(totalFields1):
      valCampo1[i].append(float(linha1[i+1]))
  
  arquivo2 = open(arq2)
  linhas2 = csv.reader(arquivo2,delimiter=";")
  cabec=True
  valTime2 =[]
  valCampo2=[]
  lev2=[]
  for linha2 in linhas2:
    if cabec:
      xlabel2=linha2[0]
      ylabel2=linha2[1:]
      for i in range(len(ylabel2)):
        lev2.append(float(ylabel2[i]))
        valCampo2.append([])
      cabec=False
      totalFields2=len(ylabel2)
      continue
    valTime2.append(float(linha1[0]))
    for i in range(totalFields1):
      valCampo2[i].append(float(linha2[i+1]))
  
  if len(lev1)!=len(lev2):
    print("Number of levels are different. Please check files!")
    sys.exit()
  
  for i in range(len(lev1)):
    if lev1[i]!=lev2[i]:
      print("Leves are different. Please check!")
      sys.exit()
  
  #diffCampo=map(operator.sub, valCampo2, valCampo1)
  diffCampo=np.subtract(valCampo2,valCampo1)
  
  cmap = plt.get_cmap("rainbow")
  colors = [cmap(i) for i in np.linspace(0, 1, totalFields1)]
  #for i in range(totalFields):
  #  plt.plot(valTime,valCampo[i][:],color=colors[i])
  
  valCampo=gaussian_filter(diffCampo, 1.5)
  plt.contourf(valTime1,lev1,diffCampo)
  plt.colorbar()
  
  plt.title("BRAMS - Compare two CSV: \n"+arq1+"\n"+arq2) 
  plt.ylabel("Levels")
  plt.xlabel("Time [Seconds]")
  plt.minorticks_on()
  plt.xticks(rotation=45)
  plt.xticks(np.arange(0,            totaltime, ticksTime))
  plt.grid(b=True, which="major", color="#666666", linestyle="-")
  plt.grid(b=True, which="minor", color="#666666", linestyle=":")
  #plt.legend(ylabel,loc=7,ncol=2,bbox_to_anchor=(1.1, 0.5))
  plt.show()

def readArgs(opts, args):
  for opt, arg in opts:
    if opt == '-h':
      err=printHelp()
      sys.exit()    
    elif opt in ("-a", "--afile"):
      arq1 = arg
      if arq1=="":
        err=printHelp()
        sys.exit()      
    elif opt in ("-b", "--bfile"):
      arq2 = arg
      if arq2=="":
        err=printHelp()
        sys.exit()
    elif opt in ("-t", "--time"):
      totaltime = float(arg)
      if totaltime==0.0:
        err=printHelp()
        sys.exit()
    elif opt in ("-k", "--ticks"):
      ticksTime = float(arg)
      if ticksTime==0.0:
        err=printHelp()
        sys.exit()  
  return arq1,arq2,totaltime,ticksTime
  

def printHelp():
  print ('')
  print ('python compare.py -a {arquivo_1} -b {arquivo_2} -t {totaltime} -k {ticksTime}')
  print ('   Calcula e plota a diferenca dos arquivos de RMSE ou BIAS (b - a) ')
  print ('Onde:')
  print ('  -a : arquivo original')
  print ('  -b : novo arquivo')
  print ('  -t : tempo total mostrado no grafico [s]')
  print ('  -k : subdivisoes do grafico em [s]')
  print ('')
  print ('Exemplo: ')
  print ('')
  print ('python compare.py -a /home/lufla/run/meteo-only/dataout/BRAMS_TST-PP.RMSE.csv -b /home/lufla/run/meteo-only/dataout/BRAMS_RK-PP.RMSE.csv -t 86400 -k 3600')
  return


if __name__ == "__main__":
   main(sys.argv[1:])