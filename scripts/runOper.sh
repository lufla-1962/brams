#!/bin/bash
mkdir ./$1$2$3
mkdir ./$1$2$3/datain
mkdir ./$1$2$3/dataout
mkdir ./$1$2$3/dataout/ANL
mkdir ./$1$2$3/dataout/HIS
mkdir ./$1$2$3/dataout/IVAR
mkdir ./$1$2$3/dataout/IC
mkdir ./$1$2$3/dataout/POST
mkdir ./$1$2$3/dataout/LOG
mkdir ./$1$2$3/dataout/SFC
mkdir ./$1$2$3/dataout/UMD
mkdir ./$1$2$3/datain/GRADS
mkdir ./$1$2$3/datain/QUEIMA
mkdir ./$1$2$3/datain/GOES16
mkdir ./$1$2$3/datain/DSA
mkdir ./$1$2$3/datain/VIIRS
mkdir ./$1$2$3/datain/METEOSAT
date=$1$2$3

_dia=$3
_mes=$2
_ano=$1
_NOVA_DATA="-1"
_NOVA_DATA=`echo $_NOVA_DATA | tr "-" " "`
ontem=`date +%Y%m%d --date="$_ano-$_mes-$_dia $_HORA $_NOVA_DATA day ago"`
expnme=oper
timmax=24
idate2=`date +%d --date="$_ano-$_mes-$_dia $_HORA $timmax hour"`
imonth2=`date +%m --date="$_ano-$_mes-$_dia $_HORA $timmax hour"`
iyear2=`date +%Y --date="$_ano-$_mes-$_dia $_HORA $timmax hour"`
itime2=00
imonth1=$2
idate1=$3
iyear1=$1
itime1=00
nnxp=370
nnyp=407
nnzp=45
deltax=20000.
deltay=20000.
dtlong=120.
polelat=-19.
polelon=-54.4
centlat=-19.
centlon=-54.4
chem_timestep=360.
chem_assim=1
aer_assim=1
srcmapfn="'.\/$date\/datain\/QUEIMA\/Queima_source'"
recycle_tracers=1
frqanl=10800.
hfilout="'.\/$date\/dataout\/ANL\/HOPQUE'"
afilout="'.\/$date\/dataout\/ANL\/OPQUE'"
pastfn="'.\/$ontem\/dataout\/ANL\/OPQUE-A-$1-$2-$3-000000-head.txt'"
topfiles="'.\/$date\/dataout\/sfc\/top_oq3g'"
sfcfiles="'.\/$date\/dataout\/sfc\/sfc_oq3g'"
sstfpfx="'.\/$date\/dataout\/sfc\/sst_oq3g'"
ndvifpfx="'.\/$date\/sfc\/ndv_oq3g'"
usdata_in="'\/lustre_xc50\/ioper\/data\/external\/"$date"00\/dataout\/umid_solo\/gl_sm_gpnr.'"
usmodel_in="'.\/$date\/dataout\/umid\/gl_sm_gpnr.'"
icprefix="'.\/$date\/datain\/grads\/ic'"
icgradsprefix="'.\/$date\/dataout\/ic\/icgrads'"
gprefix="'.\/$date\/dataout\/post\/chem'"
runtype="MAKESFC"
prepchemdir="\/lustre_xc50\/io\/models\/BRAMS\/ams_20km\/fix\/datafix\/BRAMS_5.4"
focos="\/lustre_xc50\/ioper\/data\/external\/BRAMS\/DSA\/2020\/Focos"
focossb="/lustre_xc50/ioper/data/external/BRAMS/DSA/2020/Focos"

#Preparando para filtrar os focos de dados dos sensores
#A data a ser usada eh o dia anteriorda rodada
anop=`echo ${ontem:0:4}`
mesp=`echo ${ontem:4:2}`
diap=`echo ${ontem:6:2}`
jd=`date +%j --date="$anop-$mesp-$diap"`
echo ${anop}
echo ${mesp}
echo ${diap}
echo ${jd}

#Copia os dados da DSA
cp ${focossb}${anop}${mesp}${diap}.txt ./$1$2$3/datain/DSA

#Pega os dados do GOES no ftp
cd ./$1$2$3/datain/GOES16
wget -r -np -nd --accept=GOES-16 http://ftp.cptec.inpe.br/pesquisa/bramsrd/BRAMS/data/EMISSIONS/GOES16/${anop}/${jd}/

#Pega os dados do VIIRS no ftp
cd ../VIIRS
wget -r -np -nd --accept=txt http://ftp.cptec.inpe.br/pesquisa/bramsrd/BRAMS/data/EMISSIONS/VIIRS/${ontem}/

#Pega os dados do METEOSAT no ftp
cd ../METEOSAT
wget -r -np -nd --accept=bz2 http://ftp.cptec.inpe.br/pesquisa/bramsrd/BRAMS/data/EMISSIONS/METEOSAT/${anop}/${mesp}/${diap}/

module swap PrgEnv-cray/6.0.4 PrgEnv-gnu

#Voltando para o diretorio datain
cd ..

#Rodando o script de geracao de emissoes filtradas
/lustre_xc50/luiz_flavio/models/BRAMS-5.5/auxProgs/firesTrad/bin/gera_only_3bem.bash ${anop} ${mesp} ${diap} 1 1 1 1

exit 100

# Criando RAMSINS!

cat < ./templates/RAMSIN_TEMPLATE \
     | sed "s/{EXPNME}/${expnme}/g" \
     | sed "s/{RUNTYPE}/${runtype}/g" \
     | sed "s/{TIMMAX}/${timmax}/g" \
     | sed "s/{IMONTH1}/${imonth1}/g" \
     | sed "s/{IDATE1}/${idate1}/g" \
     | sed "s/{IYEAR1}/${iyear1}/g" \
     | sed "s/{ITIME1}/${itime1}/g" \
     | sed "s/{NNXP}/${nnxp}/g"   \
     | sed "s/{NNYP}/${nnyp}/g"   \
     | sed "s/{NNZP}/${nnzp}/g"   \
     | sed "s/{DELTAX}/${deltax}/g"                  \
     | sed "s/{DELTAY}/${deltay}/g"                  \
     | sed "s/{DTLONG}/${dtlong}/g"                  \
     | sed "s/{POLELAT}/${polelat}/g"                \
     | sed "s/{POLELON}/${polelon}/g"                \
     | sed "s/{CENTLAT}/${centlat}/g"                \
     | sed "s/{CENTLON}/${centlon}/g"                \
     | sed "s/{CHEM_TIMESTEP}/${chem_timestep}/g"    \
     | sed "s/{CHEM_ASSIM}/${chem_assim}/g"          \
     | sed "s/{AER_ASSIM}/${aer_assim}/g"            \
     | sed "s/{DATE}/${date}/g" \
     | sed "s/{SRCMAPFN}/${srcmapfn}/g" \
     | sed "s/{RECYCLE_TRACERS}/${recycle_tracers}/g"\
     | sed "s/{FRQANL}/${frqanl}/g"                  \
     | sed "s/{HFILOUT}/${hfilout}/g"                 \
     | sed "s/{AFILOUT}/${afilout}/g"                 \
     | sed "s/{PASTFN}/${pastfn}/g"                  \
     | sed "s/{TOPFILES}/${topfiles}/g"               \
     | sed "s/{SFCFILES}/${sfcfiles}/g"               \
     | sed "s/{SSTFPFX}/${sstfpfx}/g"                \
     | sed "s/{NDVIFPFX}/${ndvifpfx}/g"              \
     | sed "s/{USDATA_IN}/${usdata_in}/g"            \
     | sed "s/{USMODEL_IN}/${usmodel_in}/g"          \
     | sed "s/{ICPREFIX}/${icprefix}/g"               \
     | sed "s/{ICGRADSPREFIX}/${icgradsprefix}/g"     \
     | sed "s/{GPREFIX}/${gprefix}/g"                 >  RAMSIN_SFC_$1$2$3
     
cat < RAMSIN_SFC_$1$2$3 \
     | sed "s/MAKESFC/MAKEVFILE/g" > RAMSIN_VFL_$1$2$3
     
cat < RAMSIN_VFL_$1$2$3 \
     | sed "s/MAKEVFILE/INITIAL/g" > RAMSIN_INI_$1$2$3     

dirbase="\/lustre_xc50\/luiz_flavio\/oper"
executable="$dirbase\/EXEC\/brams-5.5"

select=1
ncpus=1
mpiprocs=1
wall="01:00:00"
jobname=BRSF$2$3
nproc=1
ramsin=RAMSIN_SFC_$1$2$3

echo Criando Submit para o MAKESFC!

echo $select

echo $mpiprocs
echo $ncpus
echo $wall
echo $jobname
echo $dirbase
echo $nproc
echo $executable
echo $ramsin

cat < ./templates/XSUB_OPER_TEMPLATE \
     | sed "s/{SELECT}/${select}/g" \
     | sed "s/{MPIPROCS}/${mpiprocs}/g" \
     | sed "s/{NCPUS}/${ncpus}/g" \
     | sed "s/{WALL}/${wall}/g" \
     | sed "s/{JOBNAME}/${jobname}/g" \
     | sed "s/{DIRBASE}/${dirbase}/g" \
     | sed "s/{NPROC}/${nproc}/g" \
     | sed "s/{EXECUTABLE}/${executable}/g" \
     | sed "s/{RAMSIN}/${ramsin}/g" > xsub_sfc_$1$2$3.sh
     
chmod +x xsub_sfc_$1$2$3.sh

jobname=BRVF$2$3
ramsin=RAMSIN_VFL_$1$2$3

echo Criando Submit para o MAKEVFILE!

cat < ./templates/XSUB_OPER_TEMPLATE \
     | sed "s/{SELECT}/${select}/g" \
     | sed "s/{MPIPROCS}/${mpiprocs}/g" \
     | sed "s/{NCPUS}/${ncpus}/g" \
     | sed "s/{WALL}/${wall}/g" \
     | sed "s/{JOBNAME}/${jobname}/g" \
     | sed "s/{DIRBASE}/${dirbase}/g" \
     | sed "s/{NPROC}/${nproc}/g" \
     | sed "s/{EXECUTABLE}/${executable}/g" \
     | sed "s/{RAMSIN}/${ramsin}/g" > xsub_vfl_$1$2$3.sh
     
chmod +x xsub_vfl_$1$2$3.sh

select=20
ncpus=40
mpiprocs=40
wall="04:00:00"
jobname=BRIN$2$3
nproc=800
ramsin=RAMSIN_INI_$1$2$3

echo Criando Submit para o INITIAL!

cat < ./templates/XSUB_OPER_TEMPLATE \
     | sed "s/{SELECT}/${select}/g" \
     | sed "s/{MPIPROCS}/${mpiprocs}/g" \
     | sed "s/{NCPUS}/${ncpus}/g" \
     | sed "s/{WALL}/${wall}/g" \
     | sed "s/{JOBNAME}/${jobname}/g" \
     | sed "s/{DIRBASE}/${dirbase}/g" \
     | sed "s/{NPROC}/${nproc}/g" \
     | sed "s/{EXECUTABLE}/${executable}/g" \
     | sed "s/{RAMSIN}/${ramsin}/g" > xsub_ini_$1$2$3.sh

chmod +x xsub_ini_$1$2$3.sh

cams="$dirbase\/datafix\/CAMS\/"

echo Criando namelist para o Prep!

cat < ./templates/PRE_TEMPLATE \
     | sed "s/{IMONTH1}/${imonth1}/g" \
     | sed "s/{IDATE1}/${idate1}/g" \
     | sed "s/{IYEAR1}/${iyear1}/g" \
     | sed "s/{ITIME1}/${itime1}/g" \
     | sed "s/{IMONTH2}/${imonth2}/g" \
     | sed "s/{IDATE2}/${idate2}/g" \
     | sed "s/{IYEAR2}/${iyear2}/g" \
     | sed "s/{ITIME2}/${itime2}/g" \
     | sed "s/{DATE}/${date}/g" \
     | sed "s/{CAMS}/${cams}/g" \
     | sed "s/{DIRBASE}/${dirbase}/g" \
     > pre.nml

echo Criando namelist para o Prep-Chem!
 
  
cat < ./templates/PREP-CHEM_TEMPLATE \
     | sed "s/{IMONTH1}/${imonth1}/g" \
     | sed "s/{IDATE1}/${idate1}/g" \
     | sed "s/{IYEAR1}/${iyear1}/g" \
     | sed "s/{ITIME1}/${itime1}/g" \
     | sed "s/{DATE}/${date}/g" \
     | sed "s/{DIRBASE}/${dirbase}/g" \
     > /lustre_xc50/luiz_flavio/models/PREP-CHEM-SRC-1.8.3/bin/prep_chem_sources.inp 

module swap PrgEnv-cray/6.0.4 PrgEnv-gnu

aprun -n 1 -N 1 ./EXEC/prep_1.0

#echo $prep1out

#exit 300

cd /lustre_xc50/luiz_flavio/models/PREP-CHEM-SRC-1.8.3/bin

aprun -n 1 -N 1 ./prep_chem_sources_RELACS_TUV_.exe

module swap PrgEnv-gnu PrgEnv-cray/6.0.4

cd /lustre_xc50/luiz_flavio/oper/
echo `pwd`

rm *.gra *.ctl *.inv *.blow

qsub xsub_sfc_$1$2$3.sh
