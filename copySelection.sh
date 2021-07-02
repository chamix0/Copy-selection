#!/bin/bash
IFS='
'

ERRCODE=0;

#gestion de errores
function errorF(){
	if [[ $? -ne 0 ]]; then
		ERRCODE=$1
	fi
}


#Ayuda a manejar la cuenta de ficheros copiados
function countF(){
	AUR=`find  -maxdepth 1 -type f -name "*$1" | wc -l `; errorF 7
	FICHEROS=$((FICHEROS+AUR))
}

#funcion principal para la copia de archivos
function copy(){

for DIR in `find -type d`; do #saca una lista con todos los directorios y subdirectorios que interesan 			
	
	cd "$ORIGEN/$DIR" ;									errorF 3
	EXISTE=`find -type f -name "*$1"` ;					errorF 6
	#comprobacion de su en los subdirectorios por debajo del actual hay algun fichero ineteresante
	if [[ -n $EXISTE ]]; then
		#en el caso de que no este creado el directorio en el destino se crea y se suma a los directorios creados
		if ! [[ -e $DESTINO/$DIR  ]]; then
			mkdir $DESTINO/$DIR ; 						errorF 4
			DIRECTORIOS=$(($DIRECTORIOS+1))
		fi
			ART=`find  -maxdepth 1 -type f  -name "*$1"`	; errorF 6
		#comprobacion de que en el directorio actual hay ficheros interesantes para no lanzar un cp que no haga nada	
		if [[ -n $ART  ]]; then
			cp -r $ORIGEN/$DIR/*$1  $DESTINO/$DIR/ 	; 	errorF 1
			countF $1
		fi
	fi
done
}

#comprobacion de argumentos

#comprobacion del numero de argumentos
if [[ $# -ge 3 ]]; then
	#directorio actual
	AUX=`pwd` 	;	errorF 10
	#comprobacion de que el origen es un directorio
	if ! [[ -d $1 ]]; then
		echo ERROR: el directorio origen $1 no es un directorio válido.
		exit 2
	fi
	#comprobacion de que destino es un directorio
	if ! [[ -d $2 ]]; then
		echo ERROR: el directorio destino $2 no es un directorio válido.
		exit 2	
	fi

else 
	echo "ERROR: numero de parametros erroneo"
	exit 2
fi

#acceso a las rutas para mediante un pwd conseguir la ruta absoluta
cd "$1"
ORIGEN=`pwd`
cd "$AUX" #retorno al directorio del que partimos
cd "$2"
DESTINO=`pwd`
cd "$ORIGEN"	#como no hubo error me voy a origen

#variables que llevan la cuenta de los ficheros copiados y los directorios creados
FICHEROS=0
DIRECTORIOS=0

#salida de datos personales
DIA=`date +"%d/%m/%Y"`; 								errorF 9
HORA=`date +"%H:%M"`;									errorF 9
echo  -e "\nUSUARIO: $USER"; echo "FECHA Y HORA: $DIA $HORA"; echo "VERSION DEL BASH: $BASH_VERSION"

#bucle principal
COUNT=0

for EXT in $@; do #se itera sobre los argumentos de entrada del script
	
	COUNT=$(($COUNT + 1))
	if [[ $COUNT -gt 2 ]]
	then
		cd "$ORIGEN";	errorF 3
		copy $EXT 
	fi
	
done

#en el caso de que no se copiara ningun fichero, se indica y se termina con codigo 2
if [[ $FICHEROS -eq 0 ]]; then
	echo  -e "\nNo se ha podido copiar ningun fichero."
	exit 2;
fi

#en caso de que el script se ejecute con exito
echo  -e "\nFicheros copiados con exito."
echo $DIRECTORIOS Directorios copiados, $FICHEROS ficheros copiados.

exit $ERRCODE
#cd -> 3
#mkdir -> 4
#cp -> 2
#find -> 6
#wc -> 7 
#grep -> 8
#date -> 9
#pwd -> 10






