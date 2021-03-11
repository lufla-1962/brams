#!/bin/bash 
# Baixa os dados dos sensores de satelite necessarios para gerar os focos
# Author: Luiz Flávio Rodrigues
# 16 October 2020 (Friday)
# Baseado em script da Ariane Frassoni
#
# uso: 1) Ajuste os dados de diretorios
#      2) Coloque a APP_KEY obtida em https://urs.earthdata.nasa.gov/login
#      3) Rode o script passando ano, mes, dia e satelites: 
#         download-dados-sensores.sh 2020 09 26 1 1 1 0
#                                     ^    ^  ^ ^ ^ ^ ^
#                                     |    |  | | | | +- DSA on
#                                     |    |  | | | +--- Meteosat on
#                                     |    |  | | +----- Goes on
#                                     |    |  | +------- viirs on
#                                     |    |  +--------- dia
#                                     |    +------------ mes
#                                     +----------------- ano

############################################################
#                    AREA DO USUARIO
############################################################
# Corrija os caminhos abaixo para aqueles onde deverao
# ficar os arquivos com os dados dos sensores de satélites
# segundo o uso da operacao
############################################################

# Local to store downloaded data
dataoutgoes=/share/bramsrd/dist/BRAMS/data/EMISSIONS/GOES16
dataoutviirs=/share/bramsrd/dist/BRAMS/data/EMISSIONS/VIIRS
dataoutMeteosat=/share/bramsrd/dist/BRAMS/data/EMISSIONS/METEOSAT
dataoutDsa=/share/bramsrd/dist/BRAMS/data/EMISSIONS/DSA
#Conta e password no XC50
passwd="&Xplorer62"
user="luiz_flavio"
#Key to access NASA Earth system
APP_KEY=bHVmbGFyb2lzOmJIVnBlaTV5YjJSeWFXZDFaWE5BYVc1d1pTNWljZz09OjE2MDI4NDg5MTA6YmQ2MmJlMDczYmZmOWU2ZjFkMjcwOWU0OGZmMDZjZWI0ZGI2NmMwOA 
#############################################################
#                 FIM DA AREA DO USUARIO
#############################################################










server_url=https://ladsweb.modaps.eosdis.nasa.gov/archive/allData

_dia=$3
_mes=$2
_ano=$1

# Date settings
#Criando a data inicial 'tstart' 
tstart=${_ano}${_mes}${_dia}
echo ${tstart}
#Criando a data juliana 'jd'
jd=`date +%j --date="$_ano-$_mes-$_dia"`
echo ${jd}

dataoutMeteosat=${dataoutMeteosat}/${_ano}/${_mes}
dataoutviirs=${dataoutviirs}/${tstart}
dataoutgoes=${dataoutgoes}/${_ano}/${jd}

#Montando os diretorios para dados viirs, goes e meteosat
mkdir -p ${dataoutviirs}
mkdir -p ${dataoutgoes}
mkdir -p ${dataoutMeteosat}

if [ $4 -gt 0 ]
then
echo "## Downloading VIIRS data to ${dataoutviirs}"
wget -c -t0 ftp://ftp.star.nesdis.noaa.gov/pub/smcd/tsidulko/HRRR/${tstart}/*npp* -P ${dataoutviirs}
pwd
fi
if [ $5 -gt 0 ]
then
echo "## Downloading GOES data to ${dataoutgoes}"
wget -c -t0 ftp://ftp.ssec.wisc.edu/pub/abba/v65/goes-16/text/${_ano}${jd}/*FDCF* -P ${dataoutgoes}
fi
if [ $6 -gt 0 ]
then
	echo "## Downloading METEOSAT data here"
	for hora  in  "00" "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23"; do
   		for min in "00" "15" "30" "45"; do
      		echo "Baixando HDF5_LSASAF_MSG_FRP-PIXEL-ListProduct_MSG-Disk_${_ano}${_mes}${_dia}${hora}${min}.bz2"
      		lftp sftp://buinpe:buinpe890@safmil.ipma.pt  -e "get OperationalChain/LSASAF_Products/FRP-PIXEL/HDF5_LSASAF_MSG_FRP-PIXEL-ListProduct_MSG-Disk_${_ano}${_mes}${_dia}${hora}${min}.bz2; bye"
   		done
	done
	echo "## Moving METEOSAT data to ${dataoutMeteosat} "
	mv ./*.bz2 ${dataoutMeteosat}
fi
if [ $7 -gt 0 ]
then
	echo "## Downloading DSA data here"
	lftp ftp://cptec_focos:CP18tec@ftp-queimadas.dgi.inpe.br  -e "get /focos24h/focosINPE_24H_${_ano}${_mes}${_dia}.txt; bye"
	cat focosINPE_24H_${_ano}${_mes}${_dia}.txt | cut -d"," -f3,4,5,7,12 | tr "," " " >& Focos${_ano}${_mes}${_dia}.txt
        mv Focos${_ano}${_mes}${_dia}.txt ${dataoutDsa}
fi
tar -czvf 
