#!/bin/bash
#
#
# Lee el fichero de datos de entrada y almacena los datos
# leidos en una serie de arrays.
# Los datos del fichero vienen separados por ":"
# conforme al esquema siguiente:
#
#
#     t.llegada : nombre : t.ejecución : memoria
#
# El nombre tiene que ser Pn, siendo n un número
#

# Autores: Daniel Puente Ramírez
# Fecha: 11/05/2020
#
#-----------------------------------------------------------------
OIFS=$IFS               #Guardamos el separador de campos inicial
IFS=":"                 #Carácter que separa los campos en el fichero
n=-1
nprocesos=0
mem_total=0
    coloresTemp[0]=$FRED
    coloresTemp[1]=$FGRN
    coloresTemp[2]=$FYEL
    coloresTemp[3]=$FBLE
    coloresTemp[4]=$FMAG
    coloresTemp[5]=$FCYN
    coloresTemp[6]=$FRED
    coloresTemp[7]=$FGRN
    coloresTemp[8]=$FYEL
    coloresTemp[9]=$FBLE
    coloresTemp[10]=$FMAG
    coloresTemp[11]=$FCYN
    coloresTemp[12]=$FRED
    coloresTemp[13]=$FGRN
    coloresTemp[14]=$FYEL
    coloresTemp[15]=$FBLE
    coloresTemp[16]=$FMAG
    coloresTemp[17]=$FCYN
    coloresTemp[18]=$FRED
    coloresTemp[19]=$FGRN
    coloresTemp[20]=$FYEL


while read line; do
     # Convertimos el registro leído en un array
     lineArray=($line)

     # Guardamos cada campo en su array correspondiente
     if [[ $n -eq -1 ]]; then
         mem_total=${lineArray[0]}
         mem_total1=${lineArray[0]}
     else
     entradas[$n]=${lineArray[0]}
     ejecucion[$n]=${lineArray[1]}
     tamemory[$n]=${lineArray[2]}
     entradas1[$n]=${lineArray[0]}
     ejecucion1[$n]=${lineArray[1]}
     tamemory1[$n]=${lineArray[2]}
     fi

     if ! [[ $n -eq -1 ]]; then
        nprocesos=$(( $nprocesos + 1 ))
        temp=$(( n + 1 ))
        if [[ $nprocesos -lt 10 ]]; then
          procesos[$n]="P0"$temp      # Los procesos se llamarán P01, P02,...
       else
          procesos[$n]="P"$temp      # Los procesos se llamarán P10, P11, P12,...
       fi
     fi
     n=$(( $n + 1  ))
done < entrada.dat

nprocesos=$n
pcounter=$(( $nprocesos - 1 ))
IFS=$OIFS               # Recuperamos el separador de campos inicial


for(( i=0; i<$nprocesos; i++)) #Copia de todas las listas para luego ponerlas en orden
do
  numeroProcesos[$i]=$i
  ordenEntrada[$i]=${procesos[$i]}
  entradaAuxiliar[$i]=${entradas[$i]}
  ejecucionAuxiliar[$i]=${ejecucion[$i]}
  tamemoryAuxiliar[$i]=${tamemory[$i]}
  encola[$i]=0
    enmemoria[$i]=0
    enejecucion[$i]=0
    bloqueados[$i]=0
    pausados[$i]=0
    terminados[$i]=0
    nollegado[$i]=0
    estado[$i]=0
    temp_wait[$i]=0
    temp_resp[$i]=0
    temp_ret[$i]=0
done



for (( i=0; i<$nprocesos; i++ )) #Bucle que reordena por tiempo de llegada todos los arrays.
do
 for (( j=$i; j<$nprocesos; j++ ))
 do
      if [[ ${entradaAuxiliar[$j]} -le ${entradaAuxiliar[$i]} ]] ; then #Probar con -ge si falla
    if [[ ${ordenEntrada[$j]} -lt ${ordenEntrada[$i]} ]] ; then #Probar con -gt si falla
            auxiliar1=${ordenEntrada[$i]}
        auxiliar2=${entradaAuxiliar[$i]}
        auxiliar3=${ejecucionAuxiliar[$i]}
        auxiliar4=${tamemoryAuxiliar[$i]}
        auxiliar5=${encola[$i]}
        auxiliar6=${enmemoria[$i]}
        auxiliar7=${enejecucion[$i]}
        auxiliar8=${bloqueados[$i]}
        auxiliar9=${numeroProcesos[$i]}
        ordenEntrada[$i]=${ordenEntrada[$j]}
        entradaAuxiliar[$i]=${entradaAuxiliar[$j]}
        ejecucionAuxiliar[$i]=${ejecucionAuxiliar[$j]}
        tamemoryAuxiliar[$i]=${tamemoryAuxiliar[$j]}
        encola[$i]=${encola[$j]}
        enmemoria[$i]=${enmemoria[$j]}
        enejecucion[$i]=${enejecucion[$j]}
        bloqueados[$i]=${bloqueados[$j]}
        numeroProcesos[$i]=${numeroProcesos[$j]}
        ordenEntrada[$j]=$auxiliar1
        entradaAuxiliar[$j]=$auxiliar2
        ejecucionAuxiliar[$j]=$auxiliar3
        tamemoryAuxiliar[$j]=$auxiliar4
        encola[$j]=$auxiliar5
        enmemoria[$j]=$auxiliar6
        enejecucion[$j]=$auxiliar7
        bloqueados[$j]=$auxiliar8
        numeroProcesos[$j]=$auxiliar9
    fi
    auxiliar1=${ordenEntrada[$i]}
    auxiliar2=${entradaAuxiliar[$i]}
    auxiliar3=${ejecucionAuxiliar[$i]}
    auxiliar4=${tamemoryAuxiliar[$i]}
    auxiliar5=${encola[$i]}
    auxiliar6=${enmemoria[$i]}
    auxiliar7=${enejecucion[$i]}
    auxiliar8=${bloqueados[$i]}
    auxiliar9=${numeroProcesos[$i]}
    ordenEntrada[$i]=${ordenEntrada[$j]}
    entradaAuxiliar[$i]=${entradaAuxiliar[$j]}
    ejecucionAuxiliar[$i]=${ejecucionAuxiliar[$j]}
    tamemoryAuxiliar[$i]=${tamemoryAuxiliar[$j]}
    encola[$i]=${encola[$j]}
    enmemoria[$i]=${enmemoria[$j]}
    enejecucion[$i]=${enejecucion[$j]}
    bloqueados[$i]=${bloqueados[$j]}
    numeroProcesos[$i]=${numeroProcesos[$j]}
    ordenEntrada[$j]=$auxiliar1
    entradaAuxiliar[$j]=$auxiliar2
    ejecucionAuxiliar[$j]=$auxiliar3
    tamemoryAuxiliar[$j]=$auxiliar4
    encola[$j]=$auxiliar5
    enmemoria[$j]=$auxiliar6
    enejecucion[$j]=$auxiliar7
    bloqueados[$j]=$auxiliar8
    numeroProcesos[$j]=$auxiliar9
fi
done
done


for (( i=0; i<$nprocesos; i++ ))
do
 for (( j=$i; j<$nprocesos; j++ ))
 do
   if [[ ${entradaAuxiliar[$i]} -eq ${entradaAuxiliar[$j]} ]] ; then
    if [[ ${numeroProcesos[$i]} -gt ${numeroProcesos[$j]} ]] ; then
        auxiliar1=${ordenEntrada[$i]}
        auxiliar2=${entradaAuxiliar[$i]}
        auxiliar3=${ejecucionAuxiliar[$i]}
        auxiliar4=${tamemoryAuxiliar[$i]}
        auxiliar5=${encola[$i]}
        auxiliar6=${enmemoria[$i]}
        auxiliar7=${enejecucion[$i]}
        auxiliar8=${bloqueados[$i]}
        auxiliar9=${numeroProcesos[$i]}
        ordenEntrada[$i]=${ordenEntrada[$j]}
        entradaAuxiliar[$i]=${entradaAuxiliar[$j]}
        ejecucionAuxiliar[$i]=${ejecucionAuxiliar[$j]}
        tamemoryAuxiliar[$i]=${tamemoryAuxiliar[$j]}
        encola[$i]=${encola[$j]}
        enmemoria[$i]=${enmemoria[$j]}
        enejecucion[$i]=${enejecucion[$j]}
        bloqueados[$i]=${bloqueados[$j]}
        numeroProcesos[$i]=${numeroProcesos[$j]}
        ordenEntrada[$j]=$auxiliar1
        entradaAuxiliar[$j]=$auxiliar2
        ejecucionAuxiliar[$j]=$auxiliar3
        tamemoryAuxiliar[$j]=$auxiliar4
        encola[$j]=$auxiliar5
        enmemoria[$j]=$auxiliar6
        enejecucion[$j]=$auxiliar7
        bloqueados[$j]=$auxiliar8
        numeroProcesos[$j]=$auxiliar9
    fi
fi
done
done

for (( i=0; i<$nprocesos; i++ ))
do
 tejecucion[$i]=${ejecucionAuxiliar[$i]}
done

for (( i = 0; i < ${#ordenEntrada[@]}; i++ )); do
  if [[ "${ordenEntrada[$i]}" == "P01" ]]; then
    colores[$i]="${coloresTemp[1]}"
  fi  
  if [[ "${ordenEntrada[$i]}" == "P02" ]]; then
    colores[$i]="${coloresTemp[2]}"
  fi  
  if [[ "${ordenEntrada[$i]}" == "P03" ]]; then
    colores[$i]="${coloresTemp[3]}"
  fi  
  if [[ "${ordenEntrada[$i]}" == "P04" ]]; then
    colores[$i]="${coloresTemp[4]}"
  fi  
  if [[ "${ordenEntrada[$i]}" == "P05" ]]; then
    colores[$i]="${coloresTemp[5]}"
  fi  
  if [[ "${ordenEntrada[$i]}" == "P06" ]]; then
    colores[$i]="${coloresTemp[6]}"
  fi  
  if [[ "${ordenEntrada[$i]}" == "P07" ]]; then
    colores[$i]="${coloresTemp[7]}"
  fi  
  if [[ "${ordenEntrada[$i]}" == "P08" ]]; then
    colores[$i]="${coloresTemp[8]}"
  fi  
  if [[ "${ordenEntrada[$i]}" == "P09" ]]; then
    colores[$i]="${coloresTemp[9]}"
  fi  
  if [[ "${ordenEntrada[$i]}" == "P10" ]]; then
    colores[$i]="${coloresTemp[10]}"
  fi  
  if [[ "${ordenEntrada[$i]}" == "P11" ]]; then
    colores[$i]="${coloresTemp[11]}"
  fi  
  if [[ "${ordenEntrada[$i]}" == "P12" ]]; then
    colores[$i]="${coloresTemp[12]}"
  fi  
  if [[ "${ordenEntrada[$i]}" == "P13" ]]; then
    colores[$i]="${coloresTemp[13]}"
  fi  
  if [[ "${ordenEntrada[$i]}" == "P14" ]]; then
    colores[$i]="${coloresTemp[14]}"
  fi  
  if [[ "${ordenEntrada[$i]}" == "P15" ]]; then
    colores[$i]="${coloresTemp[15]}"
  fi  
  if [[ "${ordenEntrada[$i]}" == "P16" ]]; then
    colores[$i]="${coloresTemp[16]}"
  fi  
  if [[ "${ordenEntrada[$i]}" == "P17" ]]; then
    colores[$i]="${coloresTemp[17]}"
  fi  
  if [[ "${ordenEntrada[$i]}" == "P18" ]]; then
    colores[$i]="${coloresTemp[18]}"
  fi  
  if [[ "${ordenEntrada[$i]}" == "P19" ]]; then
    colores[$i]="${coloresTemp[19]}"
  fi
done

blanco="\e[37m"

mem_libre=$mem_total
mem_aux=$mem_libre






printf "\n"
cecho "Estos son los datos de partida:" $FBLE
printf "\n"

#####################################################################################
#  C A B E C E R A
#####################################################################################
  cecho " Ref Tll  Tej  Mem" $FYEL

for (( i=0; i<$n; i++ ))
      do
        printf " ${colores[$i]}${ordenEntrada[$i]}" 
        printf " "
        printf "%3s" "${entradaAuxiliar[$i]}" 
        printf " "
        printf "%3s" "${tejecucion[$i]}" 
        printf " "
        printf "%3s" "${tamemoryAuxiliar[$i]}"
        printf "\n"
      done


printf "\n\n"

cecho "MEMORIA TOTAL: $mem_total M" $FCYN
cecho "---------------------------------------------" $FRED
cecho "¿Está de acuerdo con estos datos? (s/n)" $FYEL
read ok
if ! [ "$ok" == "s" ] && ! [ "$ok" == "" ]
then cecho "Programa cancelado, modifique los valores desde entrada.dat y reinicie." $FRED
     exit 0
fi
cecho "---------------------------------------------" $FRED



echo "Estos son los datos de partida:" >> salida.txt
printf "\n" >> salida.txt

echo "-----------------------------------------------------------------" >> salida.txt
echo "|    PROCESOS   |    T.LLEG.    |     T.EJEC.   |     MEMORIA   |" >> salida.txt
echo "-----------------------------------------------------------------" >> salida.txt

   for (( i=0; i<$nprocesos; i++))
   do
	printf "|\t${procesos[$i]}\t|\t${entradas[$i]}\t|\t${ejecucion[$i]}\t|\t${tamemory[$i]}\t|\n" >> salida.txt
   done
echo "-----------------------------------------------------------------" >> salida.txt

printf "\n\n" >> salida.txt

echo "MEMORIA TOTAL: $mem_total M" >> salida.txt
echo "---------------------------------------------" >> salida.txt




cecho "Estos son los datos de partida:" >> salidacolor.txt $FBLE
printf "\n" >> salida.txt

cecho "-----------------------------------------------------------------" >> salidacolor.txt $FYEL
cecho "|    PROCESOS   |    T.LLEG.    |     T.EJEC.   |     MEMORIA   |" >> salidacolor.txt $FYEL
cecho "-----------------------------------------------------------------" >> salidacolor.txt $FYEL

   for (( i=0; i<$nprocesos; i++))
   do
	printf "|\t${procesos[$i]}\t|\t${entradas[$i]}\t|\t${ejecucion[$i]}\t|\t${tamemory[$i]}\t|\n" >> salidacolor.txt
   done
echo "-----------------------------------------------------------------" >> salidacolor.txt

printf "\n\n" >> salidacolor.txt

cecho "MEMORIA TOTAL: $mem_total M" >> salidacolor.txt $FCYN
cecho "---------------------------------------------" >> salidacolor.txt $FRED
