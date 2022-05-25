#!/bin/bash -x



cecho "Se están realizando cálculos..."
# -----------------------------------------------------------------------------
# Inicilizamos las tablas indicadoras de la situación del proceso
# -----------------------------------------------------------------------------
for ((i = 0; i < $nprocesos; i++)); do
	temp_wait[$i]=0
	pos_inicio[$i]=0
	pos_final[$i]=0
	ordenEntrada[$i]=0
	entradaAuxiliar[$i]=0
	ejecucionAuxiliar[$i]=0
	tamemoryAuxiliar[$i]=0
	encola[$i]=0
	enmemoria[$i]=0
	enejecucion[$i]=0
	bloqueados[$i]=0
	terminados[$i]=0
	nollegado[$i]=0
	posMemFinal[$i]=0
	posMemInicial[$i]=0
done

#Asignamos un 1 a la posicion donde la memoria termina, posicion 1 + de donde se acaba
#Y un 0 a las posiciones de memoria que tenemos que usar, [0 - mem_total]
for ((i = 0; i < $mem_total + 1; i++)); do
	posMem[$i]=0
	if [[ $i -eq $mem_total ]]; then
		posMem[$i]=1
	fi
done

#------------------------------------------------------------------------------
# O R D E N     P A R A    E N T R A R    E N    M E M O R I A
# Bucle que ordena según el tiempo de llegada todos los procesos.
#------------------------------------------------------------------------------

for ((i = 0; i < $nprocesos; i++)); do #Copia de todas las listas para luego ponerlas en orden
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
done

for ((i = 0; i < $nprocesos; i++)); do #Bucle que reordena por tiempo de llegada todos los arrays.
	for ((j = $i; j < $nprocesos; j++)); do
		if [[ ${entradaAuxiliar[$j]} -le ${entradaAuxiliar[$i]} ]]; then #Probar con -ge si falla
			if [[ ${ordenEntrada[$j]} -lt ${ordenEntrada[$i]} ]]; then      #Probar con -gt si falla
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

for ((i = 0; i < $nprocesos; i++)); do
	for ((j = $i; j < $nprocesos; j++)); do
		if [[ ${entradaAuxiliar[$i]} -eq ${entradaAuxiliar[$j]} ]]; then
			if [[ ${numeroProcesos[$i]} -gt ${numeroProcesos[$j]} ]]; then
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

#for(( k=0; k<$nprocesos; k++)) PARA PRUEBAS
#	do
#		echo "La posicion $k contiene ${ordenEntrada[$k]}"
#	done
#	read enter

#Para imprimir el tiempo de ejecucion y hacer comparaciones en otros bucles e inicializar los vectores auxiliares o copias.

for ((i = 0; i < $nprocesos; i++)); do
	tejecucion[$i]=${ejecucionAuxiliar[$i]}
	encolacopia[$i]=0
	enmemoriacopia[$i]=0
	enejecucioncopia[$i]=0
	bloqueadoscopia[$i]=0
	pausadoscopia[$i]=0
	terminadoscopia[$i]=0
done

mem_libre=$mem_total

# -----------------------------------------------------------------------------
#     B U C L E       P R I N C I P A L     D E L       A L G O R I T M O
#
# Bucle principal, desde tiempo=0 hasta que finalice la ejecución
# del último proceso, cuando la variable finalprocesos sea 0.
#
# -----------------------------------------------------------------------------

tiempo=0
parar_proceso="NO"
cpu_ocupada="NO"

finalprocesos=$nprocesos

while [ "$parar_proceso" == "NO" ]; do
	# -----------------------------------------------------------
	#	E N T R A D A      E N       C O L A
	# -----------------------------------------------------------
	# Si el momento de entrada del proceso coincide con el reloj
	# marcamos el proceso como preparado en encola()
	# -----------------------------------------------------------

	for ((i = 0; i < $nprocesos; i++)); do #Bucle que pone en cola los procesos.
		if [[ ${entradaAuxiliar[$i]} == $tiempo ]]; then
			encola[$i]=1
			nollegado[$i]=0
			terminados[$i]=0
		elif [[ ${entradaAuxiliar[$i]} -lt $tiempo ]]; then
			nollegado[$i]=0
		else
			nollegado[$i]=1
			terminados[$i]=0
		fi

	done

	# ------------------------------------------------------------
	#    G U A R D A D O      E N       M E M O R I A
	# ------------------------------------------------------------
	# Si un proceso está encola(), intento guardarlo en memoria
	# si cabe.
	# Si lo consigo, lo marco como listo enmemoria().
	# ------------------------------------------------------------

	for ((i = 0; i < $nprocesos; i++)); do

		if [[ ${encola[$i]} -eq 1 ]] && [[ ${bloqueados[$i]} -eq 0 ]]; then #Para cada proceso en cola y no bloqueado
			#####################################################################################################################################
			metido="NO"
			hueco="NO"
			espacioEncontrado="NO"
			counter=0
			# for (( y = 0; y < $mem_total+1; y++ )); do
			# 	echo "${posMem[$y]}"
			# done
			# read enter

			#Buscamos el hueco donde lo vamos a meter
			while [[ $iterar -le $mem_total ]] && [[ "$metido" == "NO" ]]; do
				#Buscamos donde empieza el posible hueco
				while [[ "$hueco" == "NO" ]]; do
					if [[ "${posMem[$counter]}" == "0" ]]; then
						pos1=$counter
						hueco="SI"
						#echo "entra en hueco| counter = $counter "
					else
						counter=$((counter + 1))
					fi
				done

				let espacioLibre=0
				let k=$counter

				if [[ $hueco == "SI" ]]; then
					#Calculamos el espacio disponible en el hueco.
					salir="NO"
					while [[ "$espacioEncontrado" == "NO" ]] && [[ "$salir" == "NO" ]]; do
						if [[ ${posMem[$k]} -eq 0 ]]; then
							espacioLibre=$((espacioLibre + 1))
							k=$((k + 1))
							#echo "$espacioLibre"
							#echo "k = $k"

							#Comprobamos si podemos reubicar al no haber encontrado hueco
							if [[ "$hueco" == "NO" ]] && [[ $mem_libre -ge ${tamemoryAuxiliar[$i]} ]]; then
								#echo"Reubicamos"
								IFS=$'\n' sorted=($(sort <<<"${posMem[*]}"))
								unset IFS #Reordenamos el vector
								#Volvemos a buscar el hueco
								while [[ "$hueco" == "NO" ]]; do
									if [[ "${posMem[$counter]}" == "0" ]]; then
										pos1=$counter
										hueco="SI"
										#echo "entra en hueco| counter = $counter "
									else
										counter=$((counter + 1))
									fi
								done
							fi

						fi
						#Comprobamos si el hueco encontrado posee le tamaño suficiente para albergar al proceso
						if [[ $k -eq $mem_total ]] && [[ $espacioLibre -ge ${tamemoryAuxiliar[$i]} ]]; then
							#echo "libre: $espacioLibre - Mem: ${tamemoryAuxiliar[$i]}"
							espacioEncontrado="SI"
							#echo "espero 1"

						elif
							[[ $k -eq $mem_total ]] && [[ $espacioLibre -lt ${tamemoryAuxiliar[$i]} ]]
						then
							iterar=$((mem_total + 1))
							#echo "MT: $mem_total - Iterar: $iterar"
							#echo "libre: $espacioLibre - Mem: ${tamemoryAuxiliar[$i]}"
							#echo "espero 0.5"
							salir="SI"
						fi
					done

					if [[ $espacioLibre -ge ${tamemoryAuxiliar[$i]} ]]; then
						posMemInicial[$i]=$pos1
						posMemFinal[$i]=$((posMemInicial[$i] + tamemoryAuxiliar[$i] - 1))
						tamannno=$((posMemFinal[$i] - posMemFinal[$i]))
						#echo "antes || pos1 = $pos1 || tamMem = ${tamemoryAuxiliar[$i]}"
						for ((b = $pos1; b < $pos1 + ${tamemoryAuxiliar[$i]}; b++)); do
							posMem[$b]=${ordenEntrada[$i]}
							#echo "Memoria: ${posMem[$b]}"
						done
						#  echo "despues"
						metido="SI"
					fi
				fi

			done

			#####################################################################################################################################
			mem_libre=$(expr $mem_libre - ${tamemoryAuxiliar[$i]})
			if [[ $mem_libre -lt "0" ]]; then
				#echo no entra

				mem_libre=$(expr $mem_libre + ${tamemoryAuxiliar[$i]})
				for ((j = $i; j < $nprocesos; j++)); do #Bucle para bloquear los procesos
					#echo "aqui"
					bloqueados[$j]=1
					terminados[$j]=0

				done

			elif [[ ${bloqueados[$i]} -eq 0 ]]; then
				enmemoria[$i]=1
				encola[$i]=0 #Este proceso ya solo estará en memoria, ejecutandose, pausado o habrá acabado
				terminados[$i]=0
				for ((j = 0; j < $nprocesos; j++)); do #Bucle para desbloquear los procesos
					#echo "alli"
					bloqueados[$j]=0
				done
			fi
		fi
		#  echo "i = $i . nprocesos = $nprocesos"
	done
	#echo me sumo al bucle

	# ----------------------------------------------------------------
	#  P L A N I F I C A D O R    D E    P R O C E S O S   -  S R P T
	# ----------------------------------------------------------------
	#
	# Si tenemos procesos listos enmemoria(), ejecutamos el que
	# corresponde en función del criterio de planificación
	# que en este caso es el que tenga una ejecución más corta de
	# todos los procesos. Se puede expulsar a un proceso de la CPU
	# aunque no haya acabado.
	#
	# ----------------------------------------------------------------

	# ------------------------------------------------------------
	# Si un proceso finaliza su tiempo de ejecucion, lo ponemos a
	# 0 en la lista de enejecucion y liberamos la memoria que
	# estaba ocupando
	# ------------------------------------------------------------

	indice_aux=-1
	temp_aux=9999999

	for ((i = 0; i < $nprocesos; i++)); do #Establecemos que proceso tiene menor tiempo de ejecucion de todos los que se encuentran en memoria
		if [[ ${enmemoria[$i]} -eq 1 ]]; then
			if [ ${ejecucionAuxiliar[$i]} -lt $temp_aux ]; then
				indice_aux=$i                     #Proceso de ejecución más corta hasta ahora
				temp_aux=${ejecucionAuxiliar[$i]} #Tiempo de ejecución menor hasta ahora
			fi
		fi
	done

	if ! [ "$indice_aux" -eq -1 ]; then #Hemos encontrado el proceso más corto
		enejecucion[$indice_aux]=1         #Marco el proceso para ejecutarse
		pausados[$indice_aux]=0            #Quitamos el estado pausado si el proceso lo estaba anteriormente
		terminados[$indice_aux]=0
		cpu_ocupada=SI #La CPU está ocupada por un proceso
	fi

	# ----------------------------------------------------------------
	# Bucle que establece si un proceso estaba en ejecución y ha
	# pasado a estar en espera, pausado.
	# ----------------------------------------------------------------

	for ((i = 0; i < $nprocesos; i++)); do
		if [[ ${enmemoria[$i]} -eq 1 ]] && [[ ${ejecucionAuxiliar[$i]} -lt ${tejecucion[$i]} ]] && [[ ${enejecucion[$i]} -eq 0 ]]; then
			pausados[$i]=1
			terminados[$i]=0
		fi
	done

	# ----------------------------------------------------------------
	# Incrementamos el contador de tiempos de ejecución y de espera
	# de los procesos y decrementamos el tiempo de ejecución que
	# tiene el proceso que se encuentra en ejecución.
	# ----------------------------------------------------------------
	for ((i = 0; i < $nprocesos; i++)); do #Bucle que añade los tiempos de espera y ejecución a cada proceso. También quita el segundo del tiempo de ejecución
		#if [[ ${encola[$i]} -eq 1 ]] || [[ ${enmemoria[$i]} -eq 1 ]] PRUEBAS
		#then
		#    temp_ret[$i]=`expr ${temp_ret[$i]} + 1`
		#fi

		if [[ ${enejecucion[$i]} -eq 1 ]]; then
			ejecucionAuxiliar[$i]=$(expr ${ejecucionAuxiliar[$i]} - 1)
		fi
	done

	for ((i = 0; i < $nprocesos; i++)); do #Bucle que comprueba si el proceso en ejecución ha finalizado.
		if [[ ${enejecucion[$i]} -eq 1 ]]; then
			if [ ${ejecucionAuxiliar[$i]} -eq 0 ]; then
				enejecucion[$i]=0
				enmemoria[$i]=0
				mem_libre=$(expr $mem_libre + ${tamemoryAuxiliar[$i]}) #Recuperamos la memoria que ocupaba el proceso
				cpu_ocupada=NO
				finalprocesos=$(expr $finalprocesos - 1)
				#echo ${posMemInicial[$i]}
				for ((p = ${posMemInicial[$i]}; p <= ${posMemFinal[$i]}; p++)); do
					posMem[$p]=0
				done
				#echo "      $finalprocesos"
				terminados[$i]=1
			fi
		fi
	done

	#GUARDAR LOS ESTADOS DEL ULTIMO CICLO EN UNA COPIA EN CADA BUCLE DONDE SE PUEDA CAMBIAR UN ESTADO
	#COMPARAR AQUI

	#Hace falta poner a cero el evento cuando no suceda nada¿?

	for ((i = 0; i < $nprocesos; i++)); do
		if [[ ${terminados[$i]} -ne ${terminadoscopia[$i]} ]]; then
			evento[$tiempo]=1
			#echo "Tiempo $tiempo: Terminados --- ${terminados[$i]} -ne ${terminadoscopia[$i]} ---- ${ordenEntrada[$i]}"
		fi
		if [[ ${pausados[$i]} -ne ${pausadoscopia[$i]} ]]; then
			evento[$tiempo]=1
			#echo "Tiempo $tiempo: Pausados   --- ${pausados[$i]} -ne ${pausadoscopia[$i]} ---- ${ordenEntrada[$i]}"
		fi
		if [[ ${bloqueados[$i]} -ne ${bloqueadoscopia[$i]} ]]; then
			evento[$tiempo]=1
			#echo "Tiempo $tiempo: Bloqueados --- ${bloqueados[$i]} -ne ${bloqueadoscopia[$i]} ---- ${ordenEntrada[$i]}"
		fi
		if [[ ${enejecucion[$i]} -ne ${enejecucioncopia[$i]} ]]; then
			evento[$tiempo]=1
			#echo "Tiempo $tiempo: En ejecucion - ${enejecucion[$i]} -ne ${enejecucioncopia[$i]} ---- ${ordenEntrada[$i]}"
		fi
		if [[ ${enmemoria[$i]} -ne ${enmemoriacopia[$i]} ]]; then
			evento[$tiempo]=1
			#echo "Tiempo $tiempo: En memoria --- ${enmemoria[$i]} -ne ${enmemoriacopia[$i]} ---- ${ordenEntrada[$i]}"
		fi
		if [[ ${encola[$i]} -ne ${encolacopia[$i]} ]]; then
			evento[$tiempo]=1
			#echo "Tiempo $tiempo: En cola    --- ${encola[$i]} -ne ${encolacopia[$i]} ---- ${ordenEntrada[$i]}"
		fi

	done

	#COMPROBAMOS SI SUCEDE UN EVENTO EN EL PROGRAMA, PARA IMPRIMIR LA TABLA CON LOS DATOS.
	#PARA ELLO COMPARAMOS SI SON IGUALES EL ESTADO DE LA COPIA Y EL ACTUAL, SE COMPARA ANTES DE ESTABLECER LOS ESTADOS DEL TIEMPO ACTUAL

	for ((i = 0; i < $nprocesos; i++)); do
		encolacopia[$i]=${encola[$i]}
		enmemoriacopia[$i]=${enmemoria[$i]}
		enejecucioncopia[$i]=${enejecucion[$i]}
		terminadoscopia[$i]=${terminados[$i]}
		bloqueadoscopia[$i]=${bloqueados[$i]}
		pausadoscopia[$i]=${pausados[$i]}
	done

	#Declarar un vector eventos

	# Incrementamos el reloj
	tiempo=$(expr $tiempo + 1)

	if [ "$finalprocesos" -eq 0 ]; then #En caso de que finalprocesos sea 0, se termina con el programa.
		parar_proceso=SI
	fi

	# --------------------------------------------------------------------
	#   D I B U J O    D E    L A    B A R R A    D E    M E M O R I A
	# --------------------------------------------------------------------

	#Ponemos todas las posiciones del vector enejecucion a 0, se establecerá qué proceso está a 1 en cada ciclo del programa.

	for ((i = 0; i < $nprocesos; i++)); do
		enejecucion[$i]=0
		bloqueados[$i]=0 #También se establecen los procesos bloqueados en cada ciclo.
	done

	# echo "Parar Proceso = $parar_proceso"
	# for (( u = 0; u < ${#bloqueados[@]}; u++ )); do
	# 	echo Bloqueado $i = ${bloqueados[$u]}
	# done

done

for ((i = 0; i < $nprocesos; i++)); do
	temp_ret[$i]=$(expr ${tejecucion[$i]} + ${temp_resp[$i]} + ${temp_wait[$i]})
done

echo " "
cecho "Calculos realizados."
read enter

# -----------------------------------------------------------------------------
#             F I N       D E L       B U C L E
# -----------------------------------------------------------------------------
