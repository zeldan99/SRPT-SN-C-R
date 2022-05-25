  #!/bin/bash
  #
  #
  # Cargamos los datos de los procesos de entrada
  #
  # Autores : Miguel Arroyo Pérez y Adrián Pineda Miñón
  # Fecha : 01/07/2017
  #


   n=-1
   blanco="\e[37m"
   col=1
   aux=0
   continuar="s"
   nprocesos=1
   pcounter=0 # Variable para controlar el numero de iteracciones que llevamos, y asi poder asignar el P0n
   cecho "Introduzca el tamaño total de la memoria" $FYEL
   echo "Introduzca el tamaño total de la memoria" >> salida.txt
   cecho "Introduzca el tamaño total de la memoria" $FYEL >> salidacolor.txt
   read mem_total
   echo "$mem_total" >> salida.txt
   echo "$mem_total" >> salidacolor.txt
   while ! [[ $mem_total =~ ^[0-9]+$ ]]
   do
       cecho "Tiene que ser un valor entero" $FRED
       echo "Tiene que ser un valor entero" >> salida.txt
       cecho "Tiene que ser un valor entero" $FRED >> salidacolor.txt
       read mem_total
       echo "$mem_total" >> salida.txt
       echo "$mem_total" >> salidacolor.txt
   done

   clear


    ############ PONEMOS LOS COLORES, SEGURO QUE HAY UNA IMPLEMENTACION MEJOR, PERO ESTAMOS EN MAYO Y NO COMO PARA PERDER EL TIEMPO

#for (( i = 30; i < 38; i++ )); do echo -e "\033[0;"$i"m Normal: (0;$i); \033[1;"$i"m Light: (1;$i)"; done
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




   while [[ $continuar = s ]]
   do
      pcounter=$(( $nprocesos - 1 ))
       n=$(( $n + 1 ))
      
        #####################################################################################
        #  C A B E C E R A
        #####################################################################################
          cecho " Ref Tll Tej Mem" $FYEL
          echo " Ref Tll Tej Mem" >> salida.txt
          cecho " Ref Tll Tej Mem" $FYEL >> salidacolor.txt

  for (( i=1; i<$n+2; i++ ))
      do
        printf " ${colores[$i]}${ordenEntrada[$i]}" 
        printf " "
        printf "%3s" "${entradaAuxiliar[$i]}" 
        printf " "
        printf "%3s" "${tejecucion[$i]}" 
        printf " "
        printf "%3s" "${tamemoryAuxiliar[$i]}"
        printf "\n" 
        printf " ${ordenEntrada[$i]}" >> salida.txt
        printf " " >> salida.txt
        printf "%3s" "${entradaAuxiliar[$i]}" >> salida.txt
        printf " " >> salida.txt
        printf "%3s" "${tejecucion[$i]}" >> salida.txt
        printf " " >> salida.txt
        printf "%3s" "${tamemoryAuxiliar[$i]}" >> salida.txt
        printf "\n" >> salida.txt
        printf " ${colores[$i]}${ordenEntrada[$i]}" >> salidacolor.txt
        printf " " >> salidacolor.txt
        printf "%3s" "${entradaAuxiliar[$i]}" >> salidacolor.txt
        printf " " >> salidacolor.txt
        printf "%3s" "${tejecucion[$i]}" >> salidacolor.txt
        printf " " >> salidacolor.txt
        printf "%3s" "${tamemoryAuxiliar[$i]}" >> salidacolor.txt
        printf "\n" >> salidacolor.txt
      done
  if [[ $[ nprocesos - 1 ] -gt 0 ]]; then
    if [[ $nprocesos -lt 10 ]]; then
     cecho " P0$nprocesos   "    $FWHT
     echo " P0$nprocesos   "    >> salida.txt
     cecho " P0$nprocesos   "    $FWHT >> salidacolor.txt
   else 
     cecho " P$nprocesos    "  $FWHT
     echo " P$nprocesos   "    >> salida.txt
     cecho " P$nprocesos   "    $FWHT >> salidacolor.txt
    fi

  fi
     
  

      
       cecho "Tiempo de llegada del proceso $[ n + 1 ]" $FYEL
       echo "Tiempo de llegada del proceso $[ n + 1 ]" >> salida.txt
       cecho "Tiempo de llegada del proceso $[ n + 1 ]" $FYEL >> salidacolor.txt
       read entrada
       echo "$entrada" >> salida.txt
       echo "$entrada" >> salidacolor.txt

       while ! [[ $entrada =~ ^[0-9]+$ ]]
       do
  	cecho "Tiene que ser un valor entero" $FRED
    echo "Tiene que ser un valor entero" >> salida.txt
    cecho "Tiene que ser un valor entero" $FRED >> salidacolor.txt
  	read entrada
    echo "$entrada" >> salida.txt
    echo "$entrada" >> salidacolor.txt
       done

       entradas[$n]=$entrada
       if [[ $nprocesos -lt 10 ]]; then
          procesos[$n]="P0"$[ n + 1 ]       # Los procesos se llamarán P01, P02,...
       else
          procesos[$n]="P"$[n + 1 ]       # Los procesos se llamarán P10, P11, P12,...
       fi

      
  clear

 #####################################################################################
#  C A B E C E R A
#####################################################################################
  cecho " Ref Tll Tej Mem" $FYEL

  for (( i=1; i<$n+2; i++ ))
      do
        printf " ${colores[$i]}${ordenEntrada[$i]}" 
        printf " "
        printf "%3s" "${entradaAuxiliar[$i]}" 
        printf " "
        printf "%3s" "${tejecucion[$i]}" 
        printf " "
        printf "%3s" "${tamemoryAuxiliar[$i]}"
        printf "\n" 
        printf " ${ordenEntrada[$i]}"  >> salida.txt
        printf " " >> salida.txt
        printf "%3s" "${entradaAuxiliar[$i]}"  >> salida.txt
        printf " " >> salida.txt
        printf "%3s" "${tejecucion[$i]}"  >> salida.txt
        printf " " >> salida.txt
        printf "%3s" "${tamemoryAuxiliar[$i]}" >> salida.txt
        printf "\n"  >> salida.txt
        printf " ${colores[$i]}${ordenEntrada[$i]}"  >> salidacolor.txt
        printf " " >> salidacolor.txt
        printf "%3s" "${entradaAuxiliar[$i]}"  >> salidacolor.txt
        printf " " >> salidacolor.txt
        printf "%3s" "${tejecucion[$i]}"  >> salidacolor.txt
        printf " " >> salidacolor.txt
        printf "%3s" "${tamemoryAuxiliar[$i]}" >> salidacolor.txt
        printf "\n"  >> salidacolor.txt
      done
      printf " $blanco${procesos[-1]}" 
        printf " "
        printf "%3s" "${entradas[-1]}" 
        printf "\n" 
       cecho "Tiempo de ejecución del proceso $[ n + 1 ]" $FYEL
       printf " ${procesos[-1]}" >> salida.txt
        printf " " >> salida.txt
        printf "%3s" "${entradas[-1]}" >> salida.txt
        printf "\n" >> salida.txt
       echo "Tiempo de ejecución del proceso $[ n + 1 ]" >> salida.txt
       printf " $blanco${procesos[-1]}" >> salidacolor.txt
        printf " " >> salidacolor.txt
        printf "%3s" "${entradas[-1]}"  >> salidacolor.txt
        printf "\n"  >> salidacolor.txt
       cecho "Tiempo de ejecución del proceso $[ n + 1 ]" $FYEL >> salidacolor.txt
       read entrada
       echo "$entrada" >> salida.txt
       echo "$entrada" >> salidacolor.txt
       while ! [[ $entrada =~ ^[0-9]+$ ]]
       do
  	cecho "Tiene que ser un valor entero" $FRED
     echo "Tiene que ser un valor entero" >> salida.txt
    cecho "Tiene que ser un valor entero" $FRED >> salidacolor.txt
  	read entrada
           echo "$entrada" >> salida.txt
       echo "$entrada" >> salidacolor.txt
       done

       ejecucion[$n]=$entrada
  clear

  #####################################################################################
#  C A B E C E R A
#####################################################################################
  cecho " Ref Tll Tej Mem" $FYEL

  for (( i=1; i<$n+2; i++ ))
      do
        printf " ${colores[$i]}${ordenEntrada[$i]}" 
        printf " "
        printf "%3s" "${entradaAuxiliar[$i]}" 
        printf " "
        printf "%3s" "${tejecucion[$i]}" 
        printf " "
        printf "%3s" "${tamemoryAuxiliar[$i]}"
        printf "\n" 
        printf " ${ordenEntrada[$i]}"  >> salida.txt
        printf " " >> salida.txt
        printf "%3s" "${entradaAuxiliar[$i]}"  >> salida.txt
        printf " " >> salida.txt
        printf "%3s" "${tejecucion[$i]}"  >> salida.txt
        printf " " >> salida.txt
        printf "%3s" "${tamemoryAuxiliar[$i]}" >> salida.txt
        printf "\n"  >> salida.txt
        printf " ${colores[$i]}${ordenEntrada[$i]}"  >> salidacolor.txt
        printf " " >> salidacolor.txt
        printf "%3s" "${entradaAuxiliar[$i]}"  >> salidacolor.txt
        printf " " >> salidacolor.txt
        printf "%3s" "${tejecucion[$i]}"  >> salidacolor.txt
        printf " " >> salidacolor.txt
        printf "%3s" "${tamemoryAuxiliar[$i]}" >> salidacolor.txt
        printf "\n"  >> salidacolor.txt
      done
            printf " ${procesos[-1]}"  >> salida.txt
        printf " " >> salida.txt
        printf "%3s" "${entradas[-1]}"  >> salida.txt
        printf " " >> salida.txt
        printf "%3s" "${ejecucion[-1]}"  >> salida.txt
        printf "\n"  >> salida.txt
      printf " $blanco${procesos[-1]}"  >> salida.txt
        printf " " >> salida.txt
        printf "%3s" "${entradas[-1]}"  >> salida.txt
        printf " " >> salida.txt
        printf "%3s" "${ejecucion[-1]}"  >> salida.txt
        printf "\n"  >> salida.txt
            printf " $blanco${procesos[-1]}"  >> salidacolor.txt
        printf " " >> salidacolor.txt
        printf "%3s" "${entradas[-1]}"  >> salidacolor.txt
        printf " " >> salidacolor.txt
        printf "%3s" "${ejecucion[-1]}"  >> salidacolor.txt
        printf "\n"  >> salidacolor.txt



       cecho "Cantidad de memoria que ocupa el proceso $[ n + 1 ]" $FYEL
       echo "Cantidad de memoria que ocupa el proceso $[ n + 1 ]" >> salida.txt
       cecho "Cantidad de memoria que ocupa el proceso $[ n + 1 ]" $FYEL >> salidacolor.txt
       read entrada
              echo "$entrada" >> salida.txt
       echo "$entrada" >> salidacolor.txt
       while ! [[ $entrada =~ ^[0-9]+$ ]]
       do
  	cecho "Tiene que ser un valor entero" $FRED
  	read entrada
           echo "$entrada" >> salida.txt
       echo "$entrada" >> salidacolor.txt
       done

       tamemory[$n]=$entrada
  clear

#####################################################################################
#  C A B E C E R A
#####################################################################################
  cecho " Ref Tll Tej Mem" $FYEL

for (( i=0; i<$n+1; i++ ))
      do
        printf " ${colores[$i]}${ordenEntrada[$i]}" 
        printf " "
        printf "%3s" "${entradaAuxiliar[$i]}" 
        printf " "
        printf "%3s" "${tejecucion[$i]}" 
        printf " "
        printf "%3s" "${tamemoryAuxiliar[$i]}"
        printf "\n" 
                printf " ${ordenEntrada[$i]}"  >> salida.txt
        printf " " >> salida.txt
        printf "%3s" "${entradaAuxiliar[$i]}"  >> salida.txt
        printf " " >> salida.txt
        printf "%3s" "${tejecucion[$i]}"  >> salida.txt
        printf " " >> salida.txt
        printf "%3s" "${tamemoryAuxiliar[$i]}" >> salida.txt
        printf "\n"  >> salida.txt
                printf " ${colores[$i]}${ordenEntrada[$i]}"  >> salidacolor.txt
        printf " " >> salidacolor.txt
        printf "%3s" "${entradaAuxiliar[$i]}"  >> salidacolor.txt
        printf " " >> salidacolor.txt
        printf "%3s" "${tejecucion[$i]}"  >> salidacolor.txt
        printf " " >> salidacolor.txt
        printf "%3s" "${tamemoryAuxiliar[$i]}" >> salidacolor.txt
        printf "\n"  >> salidacolor.txt
      done
        printf " $blanco${procesos[-1]}" 
        printf " "
        printf "%3s" "${entradas[-1]}" 
        printf " "
        printf "%3s" "${ejecucion[-1]}" 
        printf " "
        printf "%3s" "${tamemory[-1]}"
        printf "\n" 
        printf " ${procesos[-1]}" >> salida.txt
        printf " " >> salida.txt
        printf "%3s" "${entradas[-1]}"  >> salida.txt
        printf " " >> salida.txt
        printf "%3s" "${ejecucion[-1]}"  >> salida.txt
        printf " " >> salida.txt
        printf "%3s" "${tamemory[-1]}" >> salida.txt
        printf "\n" >> salida.txt
        printf " $blanco${procesos[-1]}"  >> salidacolor.txt
        printf " " >> salidacolor.txt
        printf "%3s" "${entradas[-1]}"  >> salidacolor.txt
        printf " " >> salidacolor.txt
        printf "%3s" "${ejecucion[-1]}"  >> salidacolor.txt
        printf " " >> salidacolor.txt
        printf "%3s" "${tamemory[-1]}" >> salidacolor.txt
        printf "\n" >> salidacolor.txt

###################################################################################
# GUARDADO EN FICHERO
###################################################################################
> entrada.dat

for (( i=0; i<$n+1; i++ ))
  do
     if [[ $i -eq 0 ]] ; then
        echo "$mem_total" >> entrada.dat
        echo "${entradas[$i]}:${ejecucion[$i]}:${tamemory[$i]}" >> entrada.dat
     else
        echo "${entradas[$i]}:${ejecucion[$i]}:${tamemory[$i]}" >> entrada.dat
     fi
  done

       cecho "¿Continuar introduciendo procesos? (s/n)" $FYEL
       echo "¿Continuar introduciendo procesos? (s/n)" >> salida.txt
       cecho "¿Continuar introduciendo procesos? (s/n)" $FYEL >> salidacolor.txt
       read continuar
       while ! [[ $continuar =~ ^[sn]$ ]]
       do
  	cecho "Error, introduzca otra vez (s/n)" $FRED
    echo "Error, introduzca otra vez (s/n)" >> salida.txt
    cecho "Error, introduzca otra vez (s/n)" $FRED >> salidacolor.txt
  	read continuar
    echo "$continuar" >> salida.txt
    echo "$continuar" >> salidacolor.txt
       done
  echo "Hay $nprocesos procesos"
  echo "Hay $nprocesos procesos" >> salida.txt
  echo "Hay $nprocesos procesos" >> salidacolor.txt

  	if [ $continuar = s ]
  	then
  	   nprocesos=$(( $nprocesos + 1 ))
  	fi
  	clear

       #ASIGNAMOS UN COLOR
       colores[$nprocesos-1]=${coloresTemp[$nprocesos-1]}



##########################################################################################################
#
#       ORDENAR PROCESOS SEGUN TIEMPO DE LLEGADA

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

# for (( i = 0; i < 20; i++ )); do
#   echo "$i -> ${procesos[$i]} - ${ordenEntrada[$i]}"
# done
# for (( i = 0; i < ${#colores[@]}; i++ )); do
#   colTemp[$i]="${colores[$i]}"
# done

# for (( i = 1; i < ${#ordenEntrada[@]}; i++ )); do
#   for (( i = 1; i < ${#ordenEntrada[@]}; i++ )); do
#     if [[ "${procesos[$i-1]}" == "${ordenEntrada[$j]}" ]]; then
#       colores[$j]="${colTemp[$i]}"
#     fi
#   done
# done

for (( i = 1; i < ${#ordenEntrada[@]}; i++ )); do
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

  # -----------------------------------------------------------------------------
  #  Mostramos los datos cargados y pedimos confirmación
  #  para realizar el proceso
  # -----------------------------------------------------------------------------
  printf "\n"
  cecho "Estos son los datos de partida:" $FBLE
  printf "\n"

  #####################################################################################
#  C A B E C E R A
#####################################################################################
  cecho " REF  TLL  TEJ  MEM" $FYEL

  for (( i=0; i<$n+1; i++ ))
      do
        printf " ${colores[$i]}${ordenEntrada[$i]}" 
        printf "  "
        printf "%3s" "${entradaAuxiliar[$i]}" 
        printf "  "
        printf "%3s" "${tejecucion[$i]}" 
        printf "  "
        printf "%3s" "${tamemoryAuxiliar[$i]}"
        printf "\n" 
      done


  printf "\n\n"
  cecho "MEMORIA TOTAL: $mem_total M" $FCYN
  cecho "---------------------------------------------" $FRED
  cecho "¿Está de acuerdo con estos datos? (s/n)" $FYEL
  read ok
  if ! [ "$ok" == "s" ] && ! [ "$ok" == "" ]
  then cecho "Programa cancelado, reinicie" $FRED
       exit 0
  fi
  cecho "---------------------------------------------" $FRED

  # -----------------------------------------------------------------------------
  #         VALIDACIÓN DE LOS DATOS DE ENTRADA
  # (COMPROBAR QUE TODOS LOS PROCESOS OCUPAN MENOS QUE EL TAMAÑO TOTAL)
  # -----------------------------------------------------------------------------
  #  Comprobamos que con los datos de los procesos a ejecutar, no tengamos uno
  #  cuya memoria sea mayor que el tamaño de la partición más grande definida
  # -----------------------------------------------------------------------------
  contador=0

  for (( contador=0; contador <= nprocesos; ++contador )) #Bucle que comprueba que todos los tamaños de memoria de los procesos son menores que la memoria total.
  do
     while [[ ${tamemory[$contador]} -gt $mem_total ]]
     do
  	cecho " El proceso $contador no cabe en memoria. Vuelva a introducir datos." $FRED
    echo " El proceso $contador no cabe en memoria. Vuelva a introducir datos." >> salida.txt
    cecho " El proceso $contador no cabe en memoria. Vuelva a introducir datos." $FRED >> salidacolor.txt
  	echo " Introduzca un nuevo valor para la memoria que va a ocupar el P$contador . "
    echo " Introduzca un nuevo valor para la memoria que va a ocupar el P$contador . " >> salida.txt
    echo " Introduzca un nuevo valor para la memoria que va a ocupar el P$contador . " >> salidacolor.txt
  	read tamemory[$contador]
    echo "${tamemory[$contador]}" >> salida.txt
    echo "${tamemory[$contador]}" >> salidacolor.txt

  	#Permite la modificacion del tamaño de la memoria de dicho proceso

#####################################################################################
#  C A B E C E R A
#####################################################################################
  # cecho " Ref Tll Tej  Mem" $FYEL

  # for (( i=0; i<$n+2; i++ ))
  # do
  #       printf " ${ordenEntrada[$i]}" 
  #       printf " "
  #       printf "%3s" "${entradaAuxiliar[$i]}" 
  #       printf " "
  #       printf "%3s" "${tejecucion[$i]}" 
  #       printf " "
  #       printf "%3s" "${tamemoryAuxiliar[$i]}"
  #       printf "\n" 
  # done

  # 		printf "\n\n"
  # 		cecho "MEMORIA TOTAL: $mem_total M" $FCYN
  # 		cecho "---------------------------------------------" $FRED
  #    done
  # done

  #------------------------------------------------------------
  # Movemos los datos de ejecución al fichero resumen de salida
  #------------------------------------------------------------

  echo "------------------------------------------------" >> salida.txt
  echo "-                R E S U M E N                 -" >> salida.txt
  echo "------------------------------------------------" >> salida.txt
  echo "Estos son los datos de partida:" >> salida.txt
  printf "\n" >> salida.txt

  cecho " Ref Tll Tej Mem" >> salida.txt

  for (( i=0; i<$nprocesos; i++ )) 
  do
        printf " ${ordenEntrada[$i]}"  >> salida.txt
        printf " " >> salida.txt
        printf "%3s" "${entradaAuxiliar[$i]}"  >> salida.txt
        printf " " >> salida.txt
        printf "%3s" "${tejecucion[$i]}"  >> salida.txt
        printf " " >> salida.txt
        printf "%3s" "${tamemoryAuxiliar[$i]}" >> salida.txt
        printf "\n"  >> salida.txt
  done


  printf "\n\n" >> salida.txt
  echo "MEMORIA TOTAL: $mem_total M" >> salida.txt
  echo "---------------------------------------------" >> salida.txt


  cecho "------------------------------------------------" >> salidacolor.txt $FBLE
  cecho "-                R E S U M E N                 -" >> salidacolor.txt $FBLE
  cecho "------------------------------------------------" >> salidacolor.txt $FBLE
  cecho "Estos son los datos de partida:" >> salidacolor.txt $FCYN
  printf "\n" >> salidacolor.txt

  cecho " Ref Tll Tej Mem" $FYEL >> salidacolor.txt

  for (( i=0; i<$nprocesos; i++ )) 
  do
        printf " ${colores[$i]}${ordenEntrada[$i]}"  >> salidacolor.txt
        printf " " >> salidacolor.txt
        printf "%3s" "${entradaAuxiliar[$i]}"  >> salidacolor.txt
        printf " " >> salidacolor.txt
        printf "%3s" "${tejecucion[$i]}"  >> salidacolor.txt
        printf " " >> salidacolor.txt
        printf "%3s" "${tamemoryAuxiliar[$i]}" >> salidacolor.txt
        printf "\n"  >> salidacolor.txt
  done
  echo "-----------------------------------------------------------------" >> salidacolor.txt

  printf "\n\n"
  cecho "MEMORIA TOTAL: $mem_total M" >> salidacolor.txt $FCYN
  cecho "---------------------------------------------" >> salidacolor.txt $FRED



  cecho "Datos correctos. Comienza." $FYEL
  echo "Datos correctos. Comienza." >> salida.txt
  cecho "Datos correctos. Comienza." $FYEL >> salidacolor.txt
