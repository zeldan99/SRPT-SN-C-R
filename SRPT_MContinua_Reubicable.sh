#!/bin/bash

# =============================================
# Titulo: SRPT-SN-C-R
# Descripcion: Script que realiza la simulación de un SO usando los siguiente algoritmos
# Gestion de procesos: SRPT(Shortest Remaining Process Time First), Memoria: Segun Necesidades,
# Memoria Continua y reubicable.
#
# Autores : Zeldan Javier Campos, Daniel Puente Ramírez, Miguel Arroyo Pérez y Adrián Pineda Miñón
# Fecha : 23/04/2022
#
# =============================================

# -----------------------------------------------------------------------------
#                         Tablas de trabajo (CAMBIAR ARRAYS Y VARIABLES)
# -----------------------------------------------------------------------------
# Declaramos los arrays y variables con los que trabajaremos en el script.
# Los procesos tendrán casi todos los elementos de cada una de estas tablas.
# A cada proceso se le asocia un índice, que será el mismo en todas las tablas,
# es decir, el proceso 1 tendrá la primera posición de cada array.
#
#     En nprocesos tendremos el número total de procesos.
#     En procesos() daremos un nombre al proceso.
#     En entradas() tendremos el tiempo de llegada de los procesos.
#     En ejecucion() tendremos el tiempo de ejecución de los procesos
#     En tamemory() tendremos cuánta memoria necesita cada proceso.
#     En temp_wait() iremos acumulando el tiempo de espera.
#     En temp_exec() iremos acumulando el tiempo de ejecución.
#
#     En pos_inicio() tendremos la posicion de inicio en memoria.
#     En pos_final() tendremos la posicion de final en memoria.
#
#     Para estos dos arrays (que deberán ser dinámicos) tendrémos los valores
#     de la memoria que están ocupados por un proceso, el valor de inicio en
#     memoria y el valor al final.
#
#     En mem_total tendremos el tamaño total de la memoria que se va a usar.
#
#     En encola() tendremos qué procesos pueden entrar en memoria.
#     Los valores son:
#	   	0 : El proceso no ha entrado en la cola (no ha "llegado")
#         	1 : El proceso está en la cola
#
#     En enmemoria() tendremos los procesos que se encuentran en memoria.
#     Los valores son:
#		0 : El proceso no está en memoria
#		1 : El proceso está en memoria esperando a ejecutarse
#
#     En ejecucion tendremos el número de proceso que está ejecutándose
#
#     En tiempo tendremos el instante de tiempo que se está tratando en el
#     programa.
#
# Cada array tendrá de tamaño el valor de nprocesos, excepto los relacionados
# con la memoria que serán dinámicos.

# Cargamos la función utilizada para colorear lo impreso en pantalla.
source color-echo.sh

# Declaracion de ficheros y directorios
declare -r directorioDatos="./datos/"
declare -r ficheroDatosEntrada=${directorioDatos}datosEntrada.dat

declare -r directorioInformes="./informes/"

# Declaración de los arrays:
declare -a numeroProcesos
declare -a procesos
declare -a entradas
declare -a ejecucion
declare -a tamemory
declare -a temp_exec
declare -a temp_wait
declare -a pos_inicio        #Cambiar a vector dinámico
declare -a pos_final         #Cambiar a vector dinámico
declare -a ordenEntrada      #Añadir al comentario principal
declare -a entradaAuxiliar   #Añadir al comentario principal
declare -a ejecucionAuxiliar #Añadir al comentario principal
declare -a tamemoryAuxiliar  #Añadir al comentario principal
declare -a nollegado         #Añadir al comentario principal
declare -a encola
declare -a enmemoria
declare -a enejecucion #Añadir al comentario principal
declare -a bloqueados  #Añadir al comentario principal
declare -a terminados  #Añadir al comentario principal
declare -a pausados    #Añadir al comentario principal

declare -A estado #Añadir al comentario principal

# Nombre: imprimirCabecera
# Descripción: Imprime la cabecera del programa
imprimeCabecera() {
    clear
    cecho "**********************************************************************************" $FCYN
    cecho "*                  SISTEMAS OPERATIVOS - PRÁCTICA DE CONTROL                     *" $FCYN
    cecho "*                               Curso 2021-22                                    *" $FCYN
    cecho "*                                                                                *" $FCYN
    cecho "*                                                                                *" $FCYN
    cecho "*              SRPT-SEGÚN NECESIDADES-MEMORIA CONTINUA-REUBICABLE                *" $FCYN
    cecho "*                                                                                *" $FCYN
    cecho "*                              Alumnos 2022:                                     *" $FCYN
    cecho "*                       · Zeldan Javier Campos Cordero                           *" $FCYN
    cecho "*                                                                                *" $FCYN
    cecho "*                              Alumnos 2020:                                     *" $FCYN
    cecho "*                          · Daniel Puente Ramírez                               *" $FCYN
    cecho "*                                                                                *" $FCYN
    cecho "**********************************************************************************" $FCYN
}

imprimeCabecera

# Nombre: imprimeCabeceraEnFichero
# Descripción: Imprime la cabecera del programa en fichero
imprimeCabeceraEnFichero() {
    >salida.txt

    echo "**********************************************************************************" >>salida.txt
    echo "*                  SISTEMAS OPERATIVOS - PRÁCTICA DE CONTROL                     *" >>salida.txt
    echo "*                               Curso 2021-22                                    *" >>salida.txt
    echo "*                                                                                *" >>salida.txt
    echo "*                                                                                *" >>salida.txt
    echo "*              SRPT-SEGÚN NECESIDADES-MEMORIA CONTINUA-REUBICABLE                *" >>salida.txt
    echo "*                                                                                *" >>salida.txt
    echo "*                                                                                *" >>salida.txt
    echo "*                              Alumnos 2022:                                     *" >>salida.txt
    echo "*                       · Zeldan Javier Campos Cordero                           *" >>salida.txt
    echo "*                                                                                *" >>salida.txt
    echo "*                              Alumnos 2020:                                     *" >>salida.txt
    echo "*                          · Daniel Puente Ramírez                               *" >>salida.txt
    echo "*                                                                                *" >>salida.txt
    echo "**********************************************************************************" >>salida.txt
    echo " " >>salida.txt
    echo " " >>salida.txt
}

imprimeCabeceraEnFichero

# Nombre: imprimeCabeceraEnFichero
# Descripción: Imprime la cabecera del programa en fichero color
imprimeCabeceraEnFicheroColor() {
    >salidacolor.txt

    cecho "**********************************************************************************" $FCYN >>salidacolor.txt
    cecho "*                  SISTEMAS OPERATIVOS - PRÁCTICA DE CONTROL                     *" $FCYN >>salidacolor.txt
    cecho "*                               Curso 2021-22                                    *" $FCYN >>salidacolor.txt
    cecho "*                                                                                *" $FCYN >>salidacolor.txt
    cecho "*                                                                                *" $FCYN >>salidacolor.txt
    cecho "*              SRPT-SEGÚN NECESIDADES-MEMORIA CONTINUA-REUBICABLE                *" $FCYN >>salidacolor.txt
    cecho "*                                                                                *" $FCYN >>salidacolor.txt
    cecho "*                                                                                *" $FCYN >>salidacolor.txt
    cecho "*                              Alumnos 2022:                                     *" $FCYN >>salidacolor.txt
    cecho "*                       · Zeldan Javier Campos Cordero                           *" $FCYN >>salidacolor.txt
    cecho "*                                                                                *" $FCYN >>salidacolor.txt
    cecho "*                              Alumnos 2020:                                     *" $FCYN >>salidacolor.txt
    cecho "*                          · Daniel Puente Ramírez                               *" $FCYN >>salidacolor.txt
    cecho "*                                                                                *" $FCYN >>salidacolor.txt
    cecho "**********************************************************************************" $FCYN >>salidacolor.txt
    echo " " >>salidacolor.txt
    echo " " >>salidacolor.txt
}

imprimeCabeceraEnFicheroColor

# Nombre: imprimeMenuOpciones
# Descripción: Imprime el menu de opciones
imprimeMenuOpciones() {
    echo " "
    echo " "
    cecho "---------------------------------------------" $FRED
    cecho "                 M E N Ú " $FYEL
    cecho "---------------------------------------------" $FRED
    cecho "1) Introducir datos por teclado" $FYEL
    cecho "2) Leer datos desde el fichero entrada.dat" $FYEL
    cecho "3) Salir" $FYEL
    cecho "---------------------------------------------" $FRED
    echo " "
    cecho "Introduce una opcion: "
}

imprimeMenuOpciones

# Nombre: leeOpcionMenu
# Descripción: Pide al usuario que introduzca una opcion del menu y ejecuta la opcion seleccionada.
leeOpcionMenu() {
    local num=0
    local continuar="SI" # Cuando termine la entrada de datos, continuamos

    while [ $num -ne 3 ] && [ "$continuar" == "SI" ]; do
        read num
        case $num in
        "1")
            # Cargamos los datos por teclado
            source leerProcesosDesdeTeclado.sh
            continuar=NO
            ;;

        "2")
            # Cargamos el fichero de entrada
            source leerProcesosDesdeFichero.sh
            continuar=NO
            ;;

        "3")
            exit 0
            ;;

        *)
            num=0
            cecho "Opción errónea, vuelva a introducir" $FRED
            ;;
        esac
    done
}
leeOpcionMenu
clear

# Cargamos el fichero donde se realizan los calculos de la simulacion
source simulacion.sh

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

# -----------------------------------------------------------------------------
# Inicilizamos las tablas indicadoras de la situación del proceso
# -----------------------------------------------------------------------------
for ((i = 1; i < $nprocesos; i++)); do
    posMemInicial[$i]=0
    posMemFinal[$i]=0
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
done
for ((i = 0; i < $mem_total; i++)); do
    #posMem[$i]=0
    if [[ ${posMem[$i]} -eq $mem_total-1 ]]; then
        posMem[$i]=1
    fi
done
for ((i = 0; i < 1000; i++)); do
    procTiempo[$i]=0
done
let lastMemPos=0
let flag=1
let tiempoAnterior=-1
procesoTiempo=""
imprimirYa="NO"
enterLuego=0

#------------------------------------------------------------------------------
#    O R D E N     P A R A    E N T R A R    E N    M E M O R I A
#
# Bucle que ordena según el tiempo de llegada todos los procesos.
#
#
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
    terminados[$i]=0
    nollegado[$i]=0
    estado[$i]=0
    temp_wait[$i]=0
    temp_resp[$i]=0
    temp_ret[$i]=0
    #procTerminado[$i]=0 #### No tiene nada que ver las posiciones de este vector, con las reales, este vector almacena el orden en el que los procesos terminan.
done
procTerminado=()

# Los siguientes bucles for ordenan los procesos y todos sus datos en función del tiempo de llegada. Nos encontramos esta misma secuencia en todos los ficheros que van junto con el código.
for ((i = 0; i < $nprocesos; i++)); do #Bucle que reordena por tiempo de llegada todos los arrays.
    for ((j = $i; j < $nprocesos; j++)); do
        if [[ ${entradaAuxiliar[$j]} -le ${entradaAuxiliar[$i]} ]]; then #Probar con -ge si falla
            if [[ ${ordenEntrada[$j]} -lt ${ordenEntrada[$i]} ]]; then   #Probar con -gt si falla
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

for ((i = 0; i < $nprocesos; i++)); do
    tejecucion[$i]=${ejecucionAuxiliar[$i]}
done

for ((i = 0; i < ${#ordenEntrada[@]}; i++)); do
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

mem_libre66=$mem_total
mem_total66=$mem_total
mem_libre=$mem_total
mem_aux=$mem_libre
mem=$mem_total

reubica=0
nprocTerminados=0

echo ""

echo " "

clear

echo " "
echo "Pulse enter para comenzar el proceso de visualización..."

read enter

# ----------------------------------------------------------------------------
#   C A B E C E R A   I N I C I A L    T = 0
#   Caberea de inicio en la que mostramos todos los procesos en T=0
#
# ----------------------------------------------------------------------------
for ((i = 0; i < $nprocesos; i++)); do
    if [[ ${entradaAuxiliar[$i]} -eq 0 ]]; then
        let flag=0
    fi
done
if [[ flag -eq 1 ]]; then

    echo " "
    echo " T = 0          MT = $mem_libre"
    echo " T = 0          MT = $mem_libre" >>salida.txt
    echo " T = 0          MT = $mem_libre" >>salidacolor.txt

    cecho " Ref Tll Tej Mem Tesp Tret Trej Mini Mfin ESTADO "

    for ((i = 0; i < $nprocesos; i++)); do
        printf " ${colores[$i]}${ordenEntrada[$i]}"
        printf " "
        printf "%3s" "${entradaAuxiliar[$i]}"
        printf " "
        printf "%3s" "${tejecucion[$i]}"
        printf " "
        printf "%3s" "${tamemoryAuxiliar[$i]}"
        printf " "
        printf "%4s" "-"
        printf " "
        printf "%4s" "-"
        printf " "
        printf "%4s" "-"
        printf " "
        printf "%4s" "-"
        printf " "
        printf "%4s" "-"
        printf " "
        printf "%-20s\n" "Fuera del sistema"
        printf " ${ordenEntrada[$i]}" >>salida.txt
        printf " " >>salida.txt
        printf "%3s" "${entradaAuxiliar[$i]}" >>salida.txt
        printf " " >>salida.txt
        printf "%3s" "${tejecucion[$i]}" >>salida.txt
        printf " " >>salida.txt
        printf "%3s" "${tamemoryAuxiliar[$i]}" >>salida.txt
        printf " " >>salida.txt
        printf "%4s" "-" >>salida.txt
        printf " " >>salida.txt
        printf "%4s" "-" >>salida.txt
        printf " " >>salida.txt
        printf "%4s" "-" >>salida.txt
        printf " " >>salida.txt
        printf "%4s" "-" >>salida.txt
        printf " " >>salida.txt
        printf "%4s" "-" >>salida.txt
        printf " " >>salida.txt
        printf "%-20s\n" "Fuera del sistema" >>salida.txt
        printf " ${colores[$i]}${ordenEntrada[$i]}" >>salidacolor.txt
        printf " " >>salidacolor.txt
        printf "%3s" "${entradaAuxiliar[$i]}" >>salidacolor.txt
        printf " " >>salidacolor.txt
        printf "%3s" "${tejecucion[$i]}" >>salidacolor.txt
        printf " " >>salidacolor.txt
        printf "%3s" "${tamemoryAuxiliar[$i]}" >>salidacolor.txt
        printf " " >>salidacolor.txt
        printf "%4s" "-" >>salidacolor.txt
        printf " " >>salidacolor.txt
        printf "%4s" "-" >>salidacolor.txt
        printf " " >>salidacolor.txt
        printf "%4s" "-" >>salidacolor.txt
        printf " " >>salidacolor.txt
        printf "%4s" "-" >>salidacolor.txt
        printf " " >>salidacolor.txt
        printf "%4s" "-" >>salidacolor.txt
        printf " " >>salidacolor.txt
        printf "%-20s\n" "Fuera del sistema" >>salidacolor.txt
    done

    cecho " Tiempo Medio Espera = 0         Tiempo Medio de Retorno = 0" $FWHT
    cecho " Tiempo Medio Espera = 0         Tiempo Medio de Retorno = 0" >>salida.txt
    cecho " Tiempo Medio Espera = 0         Tiempo Medio de Retorno = 0" >>salidacolor.txt

    columns=$(tput cols)
    memAImprimir=$((mem_total66 * 3))
    memAImprimir=$((memAImprimir + 5))
    if [[ $memAImprimir -lt $columns ]]; then
        cecho "    |" $FWHT
        printf " BM |"
        cecho "    |" >>salida.txt
        printf " BM |" >>salida.txt
        cecho "    |" $FWHT >>salidacolor.txt
        printf " BM |" >>salidacolor.txt
        for ((i = 0; i < $mem_libre; i++)); do
            printf ""$blanco███""
            printf "|||" >>salida.txt
            printf ""$blanco███"" >>salidacolor.txt
        done
        printf "\n"
        printf "\n" >>salida.txt
        printf "\n" >>salidacolor.txt
        for ((i = 0; i < $mem_libre; i++)); do
            if [[ $i -eq 0 ]]; then
                printf "    |  0"
                printf "    |  0" >>salida.txt
                printf "    |  0" >>salidacolor.txt
            else
                if [[ $i -eq $mem_libre-1 ]]; then
                    printf "%-3s" " $mem_libre"
                    printf "%-3s" " $mem_libre" >>salida.txt
                    printf "%-3s" " $mem_libre" >>salidacolor.txt
                else
                    printf "   "
                    printf "   " >>salida.txt
                    printf "   " >>salidacolor.txt
                fi
            fi
        done
    else
        memRestante=$memAImprimir
        saltos=0

        #Determinamos el numero de saltos que tiene que realizar, completando el tamaño del terminal y dejando un espacio a la derecha
        while [[ $memRestante -gt $columns ]]; do
            memRestante=$(($memRestante - $columns))
            saltos=$((saltos + 1))
            #echo "memRestante = $memRestante -> saltos = $saltos"
        done
        memRestante=$(($memRestante - 3))
        memRestante=$(($memRestante / 3))

        columns1=$(($columns - 6))
        ggg=$(($columns1 % 3))
        if [[ $ggg -eq 0 ]]; then
            longitud=$(($columns1 / 3))
        else
            longitud=$(($columns1 / 3))
            longitud=$(($longitud - 1))
        fi
        for ((i = 0; i <= $saltos; i++)); do
            printf "\n"
            cecho "    |" $FWHT
            printf "\n" >>salida.txt
            cecho "    |" >>salida.txt
            printf "\n" >>salidacolor.txt
            cecho "    |" $FWHT >>salidacolor.txt
            if [[ $i -eq 0 ]]; then
                #statements
                printf " BM |"
                printf " BM |" >>salida.txt
                printf " BM |" >>salidacolor.txt
            else
                printf "     "
                printf "     " >>salida.txt
                printf "     " >>salidacolor.txt
            fi
            if [[ $i -eq $saltos ]]; then
                for ((t = 0; t < $memRestante; t++)); do
                    printf ""$blanco███""
                    printf "|||" >>salida.txt
                    printf ""$blanco███"" >>salidacolor.txt
                done
                printf "███  $mem_total"
                printf "|||  $mem_total" >>salida.txt
                printf "███  $mem_total" >>salidacolor.txt
            else
                for ((t = 0; t < $longitud; t++)); do
                    printf ""$blanco███""
                    printf "|||" >>salida.txt
                    printf ""$blanco███"" >>salidacolor.txt
                done
            fi
            printf "\n"
            printf "\n" >>salida.txt
            printf "\n" >>salidacolor.txt
            for ((t = 0; t < $longitud; t++)); do
                if [[ $t -eq 0 ]] && [[ $i -eq 0 ]]; then
                    printf "    |  0"
                    printf "    |  0" >>salida.txt
                    printf "    |  0" >>salidacolor.txt
                else
                    if [[ $t -eq 0 ]]; then
                        printf "    |"
                        printf "    |" >>salida.txt
                        printf "    |" >>salidacolor.txt

                    else
                        if [[ $t -eq $longitud-1 ]] && [[ $i -eq $saltos-1 ]]; then
                            printf "%3s" " "
                            printf "%3s" " " >>salida.txt
                            printf "%3s" " " >>salidacolor.txt
                        else
                            printf "   "
                            printf "   " >>salida.txt
                            printf "   " >>salidacolor.txt
                        fi
                    fi
                fi
            done
        done
    fi

    echo " "
    printf "\n"
    echo "    |"
    cecho " BT | " $FWHT
    cecho "    |  0" $FWHT
    echo " " >>salida.txt
    printf "\n" >>salida.txt
    echo "    |" >>salida.txt
    cecho " BT | " >>salida.txt
    cecho "    |  0" >>salida.txt
    echo " " >>salidacolor.txt
    printf "\n" >>salidacolor.txt
    echo "    |" >>salidacolor.txt
    cecho " BT | " $FWHT >>salidacolor.txt
    cecho "    |  0" $FWHT >>salidacolor.txt

    read enter
fi

# -----------------------------------------------------------------------------
#     B U C L E       P R I N C I P A L     D E L       A L G O R I T M O
#
# Bucle principal, desde tiempo=0 hasta que finalice la ejecución
# del último proceso, cuando la variable finalprocesos sea 0.
#
# -----------------------------------------------------------------------------

tiempo=0
ordenTiempo=0
parar_proceso="NO"
cpu_ocupada="NO"

finalprocesos=$nprocesos

temp_wait=0
temp_resp=0
temp_ret=0

realizadoAntes=0

while [ "$parar_proceso" == "NO" ]; do
    imprimirYa="NO"
    timepoAux=$(expr $tiempo + 1)

    let memVacia=0
    for ((i = 0; i < ${#posMem[@]}; i++)); do
        if [[ "${posMem[$i]}" == "0" ]]; then
            memVacia=$((memVacia + 1))
            #echo $i
        fi
    done

    printf "\n"
    imprimirYa="NO"
    imprimirT="NO"

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
            if [[ ${evento[$tiempo]} -eq 1 ]]; then
                procesoTiempo="${ordenEntrada[$i]}"
                imprimirYa="SI"
                if [[ "$imprimirT" == "NO" ]]; then
                    cecho " T = $tiempo            MT = $memVacia" $FWHT
                    echo " " >>salida.txt
                    echo " T = $tiempo            MT = $memVacia" >>salida.txt
                    echo " " >>salidacolor.txt
                    cecho " T = $tiempo            MT = $memVacia" $FYEL >>salidacolor.txt
                    imprimirT="SI"
                fi
                cecho " El proceso ${ordenEntrada[$i]} ha entrado en la cola." $FWHT
                printf " El proceso %s ha entrado en la cola.\n" $tiempo ${ordenEntrada[$i]} >>salida.txt
                cecho " El proceso ${ordenEntrada[$i]} ha entrado en la cola." $FWHT >>salidacolor.txt
            fi
        elif [[ ${entradaAuxiliar[$i]} -lt $tiempo ]]; then
            nollegado[$i]=0
        else
            nollegado[$i]=1
        fi
    done

    # ------------------------------------------------------------
    #    G U A R D A D O      E N       M E M O R I A
    # ------------------------------------------------------------
    # Si un proceso está encola(), intento guardarlo en memoria
    # si cabe.
    # Si lo consigo, lo marco como listo enmemoria().
    # ------------------------------------------------------------

    #Comprobamos si ha terminado un proceso de ejecutarse

    for ((i = 0; i < $nprocesos; i++)); do #Bucle que comprueba si el proceso en ejecución ha finalizado.
        if [[ ${enejecucion[$i]} -eq 1 ]]; then
            if [ ${ejecucionAuxiliar[$i]} -eq 0 ]; then
                enejecucion[$i]=0
                enmemoria[$i]=0
                mem_libre=$(expr $mem_libre + ${tamemoryAuxiliar[$i]}) #Recuperamos la memoria que ocupaba el proceso
                mem_libre66=$((mem_libre66 + ${tamemoryAuxiliar[$i]}))
                if [[ ${evento[$tiempo]} -eq 1 ]]; then
                    # cecho "procTiempo = ${procTiempo[$ordenTiempo]}" $FRED
                    procesoTiempo="${ordenEntrada[$i]}"
                    if [[ "$imprimirT" == "NO" ]]; then
                        cecho " T = $tiempo            MT = $memVacia" $FWHT
                        echo " " >>salida.txt
                        echo " T = $tiempo            MT = $memVacia" >>salida.txt
                        echo " " >>salidacolor.txt
                        cecho " T = $tiempo            MT = $memVacia" $FYEL >>salidacolor.txt
                        imprimirT="SI"
                    fi
                    cecho " El proceso ${ordenEntrada[$i]} ha terminado su ejecución. $mem_libre M restantes" $FBLE
                    for ((p = 0; p < ${#posMem[@]}; p++)); do
                        if [[ "${posMem[$p]}" == "${ordenEntrada[$i]}" ]]; then
                            posMem[$p]=0
                        fi
                    done
                    posMemInicial[$i]=0
                    posMemFinal[$i]=0
                    procTerminado[$nprocTerminados]="${ordenEntrada[$i]}"
                    nprocTerminados=$((nprocTerminados + 1))
                    printf " El proceso %s ha terminado su ejecución.\n" ${ordenEntrada[$i]} >>salida.txt
                    cecho " El proceso ${ordenEntrada[$i]} ha terminado su ejecución. $mem_libre M restantes" $FBLE >>salidacolor.txt
                    imprimirYa="SI"
                fi
                cpu_ocupada=NO
                finalprocesos=$(expr $finalprocesos - 1)
                terminados[$i]=1
                enejecucion[$i]=0

                #Miramos ahora que ha acabado un proceso el siguiente que se ejecutará
                indice_aux=-1
                temp_aux=9999999

                for ((j = 0; j < $nprocesos; j++)); do
                    if [[ ${enmemoria[$j]} -eq 1 ]]; then
                        if [ ${ejecucionAuxiliar[$j]} -lt $temp_aux ]; then
                            indice_aux=$j                     #Proceso de ejecución más corta hasta ahora
                            temp_aux=${ejecucionAuxiliar[$j]} #Tiempo de ejecución menor hasta ahora
                        fi
                    fi
                done

                if ! [ "$indice_aux" -eq -1 ]; then #Hemos encontrado el proceso más corto
                    enejecucion[$indice_aux]=1      #Marco el proceso para ejecutarse
                    pausados[$indice_aux]=0         #Quitamos el estado pausado si el proceso lo estaba anteriormente
                    cpu_ocupada=SI                  #La CPU está ocupada por un proceso
                fi

                realizadoAntes=1

                #temp_waitAux=`expr $temp_waitAux + ${temp_wait[$i]}`
                #temp_retAux=`expr $temp_retAux + ${temp_ret[$i]}`
            fi
        fi
    done

    for ((i = 0; i < $nprocesos; i++)); do
        if [[ ${encola[$i]} -eq 1 ]] && [[ ${bloqueados[$i]} -eq 0 ]]; then
            mem_libre=$(expr $mem_libre - ${tamemoryAuxiliar[$i]})
            if [[ $mem_libre -lt "0" ]]; then
                reubica=0
                if [[ ${evento[$tiempo]} -eq 1 ]]; then
                    procesoTiempo="${ordenEntrada[$i]}"
                    if [[ "$imprimirT" == "NO" ]]; then
                        cecho " T = $tiempo            MT = $memVacia" $FWHT
                        echo " " >>salida.txt
                        echo " T = $tiempo            MT = $memVacia" >>salida.txt
                        echo " " >>salidacolor.txt
                        cecho " T = $tiempo            MT = $memVacia" $FYEL >>salidacolor.txt
                        imprimirT="SI"
                    fi
                    cecho " El proceso ${ordenEntrada[$i]} no cabe en memoria en este momento." $FRED
                    printf " El proceso %s no cabe en memoria en este momento.\n" ${ordenEntrada[$i]} >>salida.txt
                    cecho " El proceso ${ordenEntrada[$i]} no cabe en memoria en este momento." $FRED >>salidacolor.txt
                    imprimirYa="SI"
                fi
                mem_libre=$(expr $mem_libre + ${tamemoryAuxiliar[$i]})
                for ((j = $i; j < $nprocesos; j++)); do #Bucle para bloquear los procesos
                    bloqueados[$j]=1
                done
                if [[ ${evento[$tiempo]} -eq 1 ]]; then
                    procesoTiempo="${ordenEntrada[$i]}"
                    if [[ "$imprimirT" == "NO" ]]; then
                        cecho " T = $tiempo            MT = $memVacia" $FWHT
                        echo " " >>salida.txt
                        echo " T = $tiempo            MT = $memVacia" >>salida.txt
                        echo " " >>salidacolor.txt
                        cecho " T = $tiempo            MT = $memVacia" $FYEL >>salidacolor.txt
                        imprimirT="SI"
                    fi
                    cecho " Se bloquean todos los procesos siguientes, para que el siguiente en entrar a memoria sea ${ordenEntrada[$i]}." $FRED
                    printf " Se bloquean todos los procesos siguientes, para que el siguiente en entrar a memoria sea %s. \n" ${ordenEntrada[$i]} >>salida.txt
                    cecho " Se bloquean todos los procesos siguientes, para que el siguiente en entrar a memoria sea ${ordenEntrada[$i]}." $FRED >>salidacolor.txt
                    imprimirYa="SI"
                fi
            elif [[ ${bloqueados[$i]} -eq 0 ]]; then
                reubica=1
                if [[ ${evento[$tiempo]} -eq 1 ]]; then
                    metido="NO"
                    hueco="NO"
                    espacioEncontrado="NO"
                    counter=0

                    #Buscamos el hueco donde lo vamos a meter

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
                    #echo "counter = $counter"
                    let espacioLibre=0
                    let k=$counter
                    #Calculamos el espacio disponible en el hueco.

                    while [[ "$espacioEncontrado" == "NO" ]] && [[ "$hueco" == "SI" ]]; do
                        while [[ "${posMem[$k]}" == "0" ]]; do
                            espacioLibre=$((espacioLibre + 1))
                            k=$((k + 1))

                        done

                        #Comprobamos si el hueco encontrado posee le tamaño suficiente para albergar al proceso
                        if [[ $espacioLibre -ge ${tamemoryAuxiliar[$i]} ]]; then
                            #echo "libre: $espacioLibre - Mem: ${tamemoryAuxiliar[$i]}"
                            espacioEncontrado="SI"

                        elif [[ $espacioLibre -lt ${tamemoryAuxiliar[$i]} ]]; then
                            hueco="NO"
                        fi

                    done
                    #Comprobamos si reubicando entraría en memoria
                    let mem_libreR=0
                    for ((r = 0; r < ${#posMem[@]}; r++)); do
                        if [[ "${posMem[$r]}" == "0" ]]; then
                            mem_libreR=$((mem_libreR + 1))
                        fi
                    done
                    if [[ $mem_libreR -ge ${tamemoryAuxiliar[$i]} ]] && [[ "$hueco" == "NO" ]]; then
                        let counterAux=0
                        #Ordenamos el vector
                        puntero=0
                        new_array=()
                        new_array1=()

                        for value in "${posMem[@]}"; do
                            [[ $value != 0 ]] && new_array+=($value)
                        done
                        posMem=("${new_array[@]}")
                        for value in "${posMem[@]}"; do
                            [[ $value != 1 ]] && new_array1+=($value)
                        done
                        posMem=("${new_array1[@]}")
                        #Volvemos a poner 0 en las posiciones vacias
                        for ((r = ${#posMem[@]}; r < $mem_total + 1; r++)); do
                            posMem[$r]=0
                        done
                        #Ponemos un 1 en la primera posicion fuera del array de memoria
                        let posMem[-1]=1

                        #Buscamos el hueco
                        let y=0
                        let espacioLibre=0
                        while [[ "${posMem[$y]}" != "0" ]]; do
                            y=$((y + 1))
                            #echo 4
                        done

                        pos1="$y"

                        for ((r = $y; r < ${#posMem[@]}; r++)); do
                            espacioLibre=$((espacioLibre + 1))
                        done

                        #Colocamos las nuevas posiciones de inicio y fin de cada proceso
                        let counterAux=0
                        let controlPrimerP=0
                        for ((r = 0; r < ${#posMem[@]}; r++)); do
                            if [[ "${posMem[$r]}" == "${posMem[$r + 1]}" ]]; then
                                counterAux=$((counterAux + 1))
                            else
                                for ((u = 0; u < $nprocesos; u++)); do
                                    if [[ "${posMem[$r]}" == "${ordenEntrada[$u]}" ]]; then
                                        posMemFinal[$u]=$((counterAux))
                                        counterAux=$((counterAux + 1))
                                        if [[ $controlPrimerP -eq 0 ]]; then
                                            posMemInicial[$u]=$((${posMemFinal[$u]} - ${tamemoryAuxiliar[$u]}))
                                            let controlPrimerP=1
                                        else
                                            posMemInicial[$u]=$((${posMemFinal[$u]} - ${tamemoryAuxiliar[$u]} + 1))
                                        fi
                                    fi
                                done
                            fi

                        done
                    fi
                    for ((r = 0; r < $nprocesos; r++)); do
                        if [[ "${posMemInicial[$r]}" == "-1" ]]; then
                            posMemInicial[$r]=0
                        fi
                    done

                    #Comprobamos si el hueco encontrado posee le tamaño suficiente para albergar al proceso
                    if [[ $espacioLibre -ge ${tamemoryAuxiliar[$i]} ]]; then
                        posMemInicial[$i]=$pos1
                        posMemFinal[$i]=$((posMemInicial[$i] + tamemoryAuxiliar[$i] - 1))
                        tamannno=$((posMemFinal[$i] - posMemFinal[$i]))
                        for ((b = $pos1; b < $pos1 + ${tamemoryAuxiliar[$i]}; b++)); do
                            posMem[$b]=${ordenEntrada[$i]}
                        done
                        mem_libre66=$((mem_libre66 - ${tamemoryAuxiliar[$i]}))
                        metido="SI"
                    fi

                    procesoTiempo="${ordenEntrada[$i]}"
                    if [[ "$imprimirT" == "NO" ]]; then
                        cecho " T = $tiempo            MT = $memVacia" $FWHT
                        echo " " >>salida.txt
                        echo " T = $tiempo            MT = $memVacia" >>salida.txt
                        echo " " >>salidacolor.txt
                        cecho " T = $tiempo            MT = $memVacia" $FYEL >>salidacolor.txt
                        imprimirT="SI"
                    fi
                    cecho " El proceso ${ordenEntrada[$i]} entra en memoria. $mem_libre M restante." $FCYN

                    printf " El proceso %s entra en memoria. %s M restante.\n" ${ordenEntrada[$i]} $mem_libre >>salida.txt
                    cecho " El proceso ${ordenEntrada[$i]} entra en memoria. $mem_libre M restante." $FCYN >>salidacolor.txt
                    imprimirYa="SI"
                fi
                enmemoria[$i]=1
                realizadoAntes=0
                for ((j = 0; j < $nprocesos; j++)); do #Reestablecemos cual es el proceso que debe entrar a ejecucion
                    enejecucion[$j]=0
                done
                encola[$i]=0                           #Este proceso ya solo estará en memoria, ejecutandose o habrá acabado
                for ((j = 0; j < $nprocesos; j++)); do #Bucle para desbloquear los procesos
                    bloqueados[$j]=0
                done
            fi
        fi
    done

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

    if [[ $realizadoAntes -eq 0 ]]; then
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
            enejecucion[$indice_aux]=1      #Marco el proceso para ejecutarse
            pausados[$indice_aux]=0         #Quitamos el estado pausado si el proceso lo estaba anteriormente
            cpu_ocupada=SI                  #La CPU está ocupada por un proceso
        fi
    fi
    # ----------------------------------------------------------------
    # Bucle que establece si un proceso estaba en ejecución y ha
    # pasado a estar en espera, pausado.
    # ----------------------------------------------------------------

    for ((i = 0; i < $nprocesos; i++)); do
        if [[ ${enmemoria[$i]} -eq 1 ]] && [[ ${ejecucionAuxiliar[$i]} -lt ${tejecucion[$i]} ]] && [[ ${enejecucion[$i]} -eq 0 ]]; then
            pausados[$i]=1
            enejecucion[$i]=0

            if [[ ${evento[$tiempo]} -eq 1 ]]; then
                if [[ "$imprimirT" == "NO" ]]; then
                    cecho " T = $tiempo            MT = $memVacia" $FWHT
                    echo " " >>salida.txt
                    echo " T = $tiempo            MT = $memVacia" >>salida.txt
                    echo " " >>salidacolor.txt
                    cecho " T = $tiempo            MT = $memVacia" $FYEL >>salidacolor.txt
                    imprimirT="SI"
                fi
                cecho " El proceso ${ordenEntrada[$i]} está pausado." $FMAG
                procesoTiempo="${ordenEntrada[$i]}"
                printf " El proceso ${ordenEntrada[$i]} está pausado.\n" $i >>salida.txt
                cecho " El proceso ${ordenEntrada[$i]} está pausado." $FMAG >>salidacolor.txt
                imprimirYa="SI"
            fi
        fi
    done

    #ESTADO DE CADA PROCESO
    #Modificamos los valores de los arrays, restando de lo que quede<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    #ESTADO DE CADA PROCESO EN EL TIEMPO ACTUAL Y HALLAMOS LAS VARIABLES. (Las cuentas se realizaran tras imprimir.)

    for ((i = 0; i < $nprocesos; i++)); do
        if [[ ${nollegado[$i]} -eq 1 ]]; then
            estado[$i]="Fuera del sistema"
            #temp_wait[$i]=`expr ${temp_wait[$i]} + 0` #No hace falta poner la suma, es solo para una mejor interpretación
        fi

        if [[ ${encola[$i]} -eq 1 ]] && [[ ${bloqueados[$i]} -eq 1 ]]; then
            estado[$i]="En espera"
            #temp_wait[$i]=`expr ${temp_wait[$i]} + 1`
            #temp_ret[$i]=`expr ${temp_ret[$i]} + 1`
        fi

        if [[ ${enmemoria[$i]} -eq 1 ]] && [[ ${enejecucion[$i]} -eq 1 ]]; then
            estado[$i]="En ejecucion"
        elif [[ ${enmemoria[$i]} -eq 1 ]] && [[ ${pausados[$i]} -eq 1 ]]; then
            estado[$i]="Pausado"
        elif [[ ${enmemoria[$i]} -eq 1 ]]; then
            estado[$i]="En memoria"
        fi

        if [[ ${terminados[$i]} -eq 1 ]]; then
            estado[$i]="Terminado"
        fi
    done

    #Ponemos el estado del siguiente que se vaya a ejecutar (si algún proceso ha terminado) "En ejecucion"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    #SUMAR EL SEGUNDO DEL CICLO ANTES DE PONER ESTE ESTADO
    if [ "$finalprocesos" -eq 0 ]; then #En caso de que finalprocesos sea 0, se termina con el programa.
        parar_proceso=SI
    fi

    # --------------------------------------------------------------------
    #   D I B U J O    D E    L A    T A B L A    D E    D A T O S
    # --------------------------------------------------------------------

    #PARA QUE EN EL PROGRAMA SE REALICE EL DIBUJO DEBE SUCEDER UN EVENTO.
    #Los eventos suceden cuando se realiza un cambio en los estados de cualquiera de los procesos.

    #Además de esto, los tiempos T.ESPERA, T.RESPUESTA y T.RESTANTE solo se mostrarán en la tabla cuando el estado del proceso sea distinto de "No ha llegado".
    #Para realizar esto hacemos un bucle que pase por todos los procesos que compruebe si el estado nollegado() es 0 y para cada uno de los tiempos, si se debe mostrar se guarda el tiempo, si no se mostrará un guión

    #CUADRAR LAS TABLAS.

    if [[ ${evento[$tiempo]} -eq 1 && "$imprimirYa" == "SI" ]]; then
        #Nos aseguramos de no imprimir niongun proceso que ya haya terminado.
        for ((i = 0; i < $nprocesos; i++)); do
            if [[ "${estado[$i]}" == "Terminado" ]]; then
                for ((p = 0; p < ${#posMem[@]}; p++)); do
                    if [[ "${posMem[$p]}" == "${ordenEntrada[$i]}" ]]; then
                        posMem[$p]=0
                    fi
                done
            fi
        done

        #cecho "---------------------------------------------" $FRED
        #cecho "|    PROCESOS   |    T.LLEG.    |     T.EJEC.   |     MEMORIA   |    T.ESPERA   |   T.RETORNO   |  T.RESTANTE   |    ESTADO     |" $FYEL
        cecho " Ref Tll Tej Mem Tesp Tret Trej Mini Mfin ESTADO "

        for ((i = 0; i < $nprocesos; i++)); do
            if [[ ${nollegado[$i]} -eq 1 ]]; then
                printf " ${colores[$i]}${ordenEntrada[$i]}"
                printf " "
                printf "%3s" "${entradaAuxiliar[$i]}"
                printf " "
                printf "%3s" "${tejecucion[$i]}"
                printf " "
                printf "%3s" "${tamemoryAuxiliar[$i]}"
                printf " "
                printf "%4s" "-"
                printf " "
                printf "%4s" "-"
                printf " "
                printf "%4s" "-"
                printf " "
                printf "%4s" "-"
                printf " "
                printf "%4s" "-"
                printf " "
                printf "%-20s\n" "${estado[$i]}"
            elif [[ ${nollegado[$i]} -eq 0 ]] && [[ ${enejecucion[$i]} -eq 1 ]]; then
                printf " ${colores[$i]}${ordenEntrada[$i]}"
                printf " "
                printf "%3s" "${entradaAuxiliar[$i]}"
                printf " "
                printf "%3s" "${tejecucion[$i]}"
                printf " "
                printf "%3s" "${tamemoryAuxiliar[$i]}"
                printf " "
                printf "%4s" "${temp_wait[$i]}"
                printf " "
                printf "%4s" "${temp_ret[$i]}"
                printf " "
                printf "%4s" "${ejecucionAuxiliar[$i]}"
                printf " "
                printf "%4s" "${posMemInicial[$i]}"
                printf " "
                printf "%4s" "${posMemFinal[$i]}"
                printf " "
                printf "%-20s\n" "${estado[$i]}"
                procEnEjecucion="${ordenEntrada[$i]}"
                procTiempo[$tiempo]="${ordenEntrada[$i]}"
                #printf "${colores[$i]} ${ordenEntrada[$i]}   ${entradaAuxiliar[$i]}    ${tejecucion[$i]}    ${tamemoryAuxiliar[$i]}   ${temp_wait[$i]}     ${temp_ret[$i]}    ${ejecucionAuxiliar[$i]}   ${posMemInicial[$i]}    ${posMemFinal[$i]}    ${estado[$i]}\n"
            elif [[ ${terminados[$i]} -eq 1 ]]; then
                printf " ${colores[$i]}${ordenEntrada[$i]}"
                printf " "
                printf "%3s" "${entradaAuxiliar[$i]}"
                printf " "
                printf "%3s" "${tejecucion[$i]}"
                printf " "
                printf "%3s" "${tamemoryAuxiliar[$i]}"
                printf " "
                printf "%4s" "${temp_wait[$i]}"
                printf " "
                printf "%4s" "${temp_ret[$i]}"
                printf " "
                printf "%4s" "${ejecucionAuxiliar[$i]}"
                printf " "
                printf "%4s" "-"
                printf " "
                printf "%4s" "-"
                printf " "
                printf "%-20s\n" "${estado[$i]}"
                #printf "${colores[$i]} ${ordenEntrada[$i]}   ${entradaAuxiliar[$i]}    ${tejecucion[$i]}    ${tamemoryAuxiliar[$i]}   ${temp_wait[$i]}     ${temp_ret[$i]}    ${ejecucionAuxiliar[$i]}   0    0    ${estado[$i]}\n"
            elif [[ ${enmemoria[$i]} -eq 1 ]] && [[ ${pausados[$i]} -eq 1 ]]; then
                printf " ${colores[$i]}${ordenEntrada[$i]}"
                printf " "
                printf "%3s" "${entradaAuxiliar[$i]}"
                printf " "
                printf "%3s" "${tejecucion[$i]}"
                printf " "
                printf "%3s" "${tamemoryAuxiliar[$i]}"
                printf " "
                printf "%4s" "${temp_wait[$i]}"
                printf " "
                printf "%4s" "${temp_ret[$i]}"
                printf " "
                printf "%4s" "${ejecucionAuxiliar[$i]}"
                printf " "
                printf "%4s" "${posMemInicial[$i]}"
                printf " "
                printf "%4s" "${posMemFinal[$i]}"
                printf " "
                printf "%-20s\n" "${estado[$i]}"
                #printf "${colores[$i]} ${ordenEntrada[$i]}   ${entradaAuxiliar[$i]}    ${tejecucion[$i]}    ${tamemoryAuxiliar[$i]}   ${temp_wait[$i]}     ${temp_ret[$i]}    ${ejecucionAuxiliar[$i]}   ${posMemInicial[$i]}    ${posMemFinal[$i]}      ${estado[$i]}\n"
            elif [[ ${enmemoria[$i]} -eq 1 ]] || [[ ${encola[$i]} -eq 1 ]]; then
                printf " ${colores[$i]}${ordenEntrada[$i]}"
                printf " "
                printf "%3s" "${entradaAuxiliar[$i]}"
                printf " "
                printf "%3s" "${tejecucion[$i]}"
                printf " "
                printf "%3s" "${tamemoryAuxiliar[$i]}"
                printf " "
                printf "%4s" "${temp_wait[$i]}"
                printf " "
                printf "%4s" "${temp_ret[$i]}"
                printf " "
                printf "%4s" "${ejecucionAuxiliar[$i]}"
                printf " "
                printf "%4s" "${posMemInicial[$i]}"
                printf " "
                printf "%4s" "${posMemFinal[$i]}"
                printf " "
                printf "%-20s\n" "${estado[$i]}"
                #printf "${colores[$i]} ${ordenEntrada[$i]}   ${entradaAuxiliar[$i]}    ${tejecucion[$i]}    ${tamemoryAuxiliar[$i]}   ${temp_wait[$i]}     ${temp_ret[$i]}    ${ejecucionAuxiliar[$i]}   ${posMemInicial[$i]}    ${posMemFinal[$i]}    ${estado[$i]}\n"
            fi
            enterLuego=1
        done
        #printf ""$blanco"---------------------------------------------------------------------------------------------------------------------------------\n"
        mediaTEspera=0
        mediaTRetorno=0
        nprocT=0
        nprocR=0
        printf ""$blanco""

        # Los tiempos de ejecucion los hace mal, no muestra correctamente los decimales, unicamente los redondea.
        for ((i = 0; i < $nprocesos; i++)); do
            if ! [[ ${temp_wait[$i]} -eq 0 ]]; then
                nprocT=$((nprocT + 1))
                mediaTEspera=$((mediaTEspera + ${temp_wait[$i]}))
            fi
            if ! [[ ${temp_ret[$i]} -eq 0 ]]; then
                nprocR=$((nprocT + 1))
                mediaTRetorno=$((mediaTRetorno + ${temp_ret[$i]}))
            fi
        done
        if [[ $nprocT -eq 0 ]]; then
            printf " Tiempo Medio Espera = 0\t"
        else
            printf ' Tiempo Medio Espera = %.2f\t' $((mediaTEspera / $nprocT))
        fi
        if [[ $nprocR -eq 0 ]]; then
            printf " Tiempo Medio de Retorno = 0\n"
        else
            printf ' Tiempo Medio Retorno = %.2f\n' $((mediaTRetorno / $nprocR))
        fi

        echo " "

        j=0
        k=0
        cont=0
        posPrevia=0

        for ((i = $posPrevia; i < $nprocesos; i++)); do
            if [[ ${enmemoria[$i]} -eq 1 ]]; then
                enmemoriavec[$cont]=$i
                cont=$((cont + 1))
                if [[ $reunbica -eq 1 ]]; then
                    if [[ ${guardados[0]} -eq $i ]]; then
                        pos_inicio[$i]=0
                        pos_final[$i]=$((${tamemoryAuxiliar[$i]}))
                        mem_aux=$(expr $mem_aux - ${tamemoryAuxiliar[$i]})
                        pos_aux=${pos_final[$i]}
                    else
                        pos_inicio[$i]=$((pos_aux + 1))
                        pos_final[$i]=$(expr $mem_aux - ${tamemoryAuxiliar[$i]})
                        pos_aux=${pos_final[$i]}
                    fi
                fi
            fi
        done

        j=0
        k=0
        columns=$(tput cols)
        memAImprimir=$((mem_total66 * 3))
        memAImprimir=$((memAImprimir + 10))
        if [[ $memAImprimir -lt $columns ]]; then
            todoOK="SI"
        else
            todoOK="NO"
            let aImprimir=$memAImprimir/$columns
        fi
        partirImpresion="NO"
        if [[ $memAImprimir -lt $columns ]]; then
            partirImpresion="NO"
            printf "    |"
            for ((i = $posPrevia; i < ${#posMem[@]} - 1; i++)); do
                if [[ "${posMem[$i]}" = "0" ]]; then
                    printf "   "
                else
                    if [[ "${posMem[$i]}" != "${posMem[$i - 1]}" ]]; then
                        for ((t = 0; t < $nprocesos; t++)); do
                            if [[ "${posMem[$i]}" == "${ordenEntrada[$t]}" ]]; then
                                colorProcesoAImprimir=${colores[$t]}
                            fi
                        done
                        printf "$colorProcesoAImprimir${posMem[$i]}"
                    else
                        printf "   "
                    fi
                fi
            done

            printf "\n"

            col=0
            aux=0

            printf "$FWHT BM |"
            for ((i = $posPrevia; i < $mem_total; i++)); do
                if [[ "${posMem[$i]}" == "0" ]]; then
                    printf "$blanco███"
                else
                    colorProcesoAImprimir=""
                    for ((t = 0; t < $nprocesos; t++)); do
                        if [[ "${posMem[$i]}" == "${ordenEntrada[$t]}" ]]; then
                            colorProcesoAImprimir=${colores[$t]}
                        fi
                    done
                    printf "$colorProcesoAImprimir███"
                fi
            done

            printf " $blanco$mem_total\n"

            memBMImprimir=0
            YA="NO"
            #Barra 3 - Posiciones de memoria dinales de cada proceso
            printf "$blanco    |"
            for ((i = 0; i < ${#posMem[@]} - 1; i++)); do #Sería -1 pero para cuadrar el valor final de la memoria, debemos de poner el -2. Sino sale descuadrado por una unidad = 3
                for ((o = 0; o < $nprocesos; o++)); do
                    if [[ "${posMem[$i]}" == "${ordenEntrada[$o]}" ]]; then
                        procImprimir=$o
                    fi
                done
                if [[ $i -eq 0 ]]; then
                    printf "  0"
                else
                    if [[ "${posMem[$i]}" == "0" ]]; then
                        if [[ "${posMem[$i]}" != "${posMem[$i - 1]}" && "$YA" = "NO" ]]; then
                            memBMImprimir=$((memBMImprimir + 1))
                            printf "%3s" "$memBMImprimir"
                            YA="SI"
                        else
                            memBMImprimir=$((memBMImprimir + 1))
                            printf "%3s" " "
                        fi
                    else
                        if [[ "${posMem[$i]}" == "${posMem[$i - 1]}" ]]; then
                            memBMImprimir=$((memBMImprimir + 1))
                            printf "   "
                        else
                            memBMImprimir=$((memBMImprimir + 1))
                            printf "%3s" "${posMemInicial[$procImprimir]}"
                            YA="NO"
                        fi
                    fi

                fi
            done

            #) | fmt -w$columns

            printf "\n"
            printf "\n"
        else
            partirImpresion="SI"
            posPrevia=0
            memRestante=$memAImprimir
            saltos=0

            #Determinamos el numero de saltos que tiene que realizar, completando el tamaño del terminal y dejando un espacio a la derecha
            while [[ $memRestante -gt $columns ]]; do
                memRestante=$(($memRestante - $columns))
                saltos=$((saltos + 1))
                #echo "memRestante = $memRestante -> saltos = $saltos"
            done
            memRestante=$(($memRestante))
            memRestante=$(($memRestante / 3))

            columns1=$(($columns - 6))
            ggg=$(($columns1 % 3))

            if [[ $ggg -eq 0 ]]; then
                longitud=$(($columns1 / 3))
                memRestante=$(($memRestante - 1))
            else
                memRestante=$(($memRestante + $ggg - 1))
                longitud=$(($columns1 / 3))
                longitud=$(($longitud - 1))
            fi
            #echo "longitud = $longitud"

            temp1=0
            temp2=0
            temp3=0
            memBMImprimir=0
            YA="NO"
            lastIMM="0"

            for ((p = 0; p <= $saltos; p++)); do

                if [[ $p -eq 0 ]]; then
                    printf "    |"
                else
                    printf "     "
                fi
                if [[ $p -eq $saltos ]]; then
                    for ((i = 0; i < $memRestante; i++)); do
                        if [[ "${posMem[$temp1]}" = "0" ]]; then
                            printf "   "
                        else
                            if [[ "${posMem[$temp1]}" != "${posMem[$temp1 - 1]}" ]]; then
                                for ((t = 0; t < $nprocesos; t++)); do
                                    if [[ "${posMem[$temp1]}" == "${ordenEntrada[$t]}" ]]; then
                                        colorProcesoAImprimir=${colores[$t]}
                                    fi
                                done
                                if ! [[ "${posMem[$temp1]}" == "1" ]]; then
                                    printf "$colorProcesoAImprimir${posMem[$temp1]}"
                                fi
                            else
                                printf "   "
                            fi
                        fi
                        temp1=$((temp1 + 1))
                    done
                else
                    for ((i = 0; i < $longitud; i++)); do
                        if [[ "${posMem[$temp1]}" = "0" ]]; then
                            printf "   "
                        else
                            if [[ "${posMem[$temp1]}" != "${posMem[$temp1 - 1]}" ]]; then
                                for ((t = 0; t < $nprocesos; t++)); do
                                    if [[ "${posMem[$temp1]}" == "${ordenEntrada[$t]}" ]]; then
                                        colorProcesoAImprimir=${colores[$t]}
                                    fi
                                done
                                if ! [[ "${posMem[$temp1]}" == "1" ]]; then
                                    printf "$colorProcesoAImprimir${posMem[$temp1]}"
                                fi
                            else
                                printf "   "
                            fi
                        fi
                        temp1=$((temp1 + 1))
                    done
                fi

                printf "\n"

                col=0
                aux=0
                if [[ $p -eq 0 ]]; then
                    printf "$FWHT BM |"
                else
                    printf "     "
                fi

                if [[ $p -eq $saltos ]]; then
                    for ((i = 0; i < $memRestante; i++)); do
                        if [[ "${posMem[$temp2]}" == "0" ]]; then
                            printf "$blanco███"
                        else
                            colorProcesoAImprimir=""
                            for ((t = 0; t < $nprocesos; t++)); do
                                if [[ "${posMem[$temp2]}" == "${ordenEntrada[$t]}" ]]; then
                                    colorProcesoAImprimir=${colores[$t]}
                                fi
                            done
                            printf "$colorProcesoAImprimir███"
                        fi
                        temp2=$((temp2 + 1))
                    done
                else
                    for ((i = 0; i < $longitud; i++)); do
                        if [[ "${posMem[$temp2]}" == "0" ]]; then
                            printf "$blanco███"
                        else
                            colorProcesoAImprimir=""
                            for ((t = 0; t < $nprocesos; t++)); do
                                if [[ "${posMem[$temp2]}" == "${ordenEntrada[$t]}" ]]; then
                                    colorProcesoAImprimir=${colores[$t]}
                                fi
                            done
                            printf "$colorProcesoAImprimir███"
                        fi
                        temp2=$((temp2 + 1))
                    done
                fi
                if [[ $p -eq $saltos ]]; then
                    printf "%4s" "$mem_total"
                fi
                printf "\n"

                #Barra 3 - Posiciones de memoria dinales de cada proceso
                if [[ $p -eq 0 ]]; then
                    printf "$blanco    |"
                else
                    printf "     "
                fi

                if [[ $p -eq $saltos ]]; then
                    for ((i = 0; i < $memRestante; i++)); do
                        for ((o = 0; o < $nprocesos; o++)); do
                            if [[ "${posMem[$temp3]}" == "${ordenEntrada[$o]}" ]]; then
                                procImprimir=$o
                            fi
                        done
                        if [[ $p -eq 0 ]] && [[ $i -eq 0 ]]; then
                            printf "  0"
                        else
                            if [[ "${posMem[$temp3]}" = "0" ]]; then
                                if [[ "${posMem[$temp3]}" != "${posMem[$temp3 - 1]}" ]]; then
                                    memBMImprimir=$((memBMImprimir + 1))
                                    printf "%3s" "$memBMImprimir"
                                else
                                    memBMImprimir=$((memBMImprimir + 1))
                                    printf "%3s" " "
                                fi
                            else
                                if [[ "${posMem[$temp3]}" == "${posMem[$temp3 - 1]}" ]]; then
                                    memBMImprimir=$((memBMImprimir + 1))
                                    printf "%3s" " "
                                else
                                    if ! [[ "$lastIMM" == "${posMemInicial[$procImprimir]}" ]]; then
                                        #statements
                                        memBMImprimir=$((memBMImprimir + 1))
                                        printf "%3s" "${posMemInicial[$procImprimir]}"
                                        lastIMM="${posMemInicial[$procImprimir]}"
                                    fi

                                fi

                            fi

                        fi
                        temp3=$((temp3 + 1))
                    done
                else
                    for ((i = 0; i < $longitud; i++)); do
                        for ((o = 0; o < $nprocesos; o++)); do
                            if [[ "${posMem[$temp3]}" == "${ordenEntrada[$o]}" ]]; then
                                procImprimir=$o
                            fi
                        done
                        if [[ $p -eq 0 ]] && [[ $i -eq 0 ]]; then
                            printf "  0"
                        else
                            if [[ "${posMem[$temp3]}" = "0" ]]; then
                                if [[ "${posMem[$temp3]}" != "${posMem[$temp3 - 1]}" ]]; then
                                    memBMImprimir=$((memBMImprimir + 1))
                                    printf "%3s" "$memBMImprimir"
                                else
                                    memBMImprimir=$((memBMImprimir + 1))
                                    printf "%3s" " "
                                fi
                            else
                                if [[ "${posMem[$temp3]}" == "${posMem[$temp3 - 1]}" ]]; then
                                    memBMImprimir=$((memBMImprimir + 1))
                                    printf "%3s" " "
                                else
                                    if ! [[ "$lastIMM" == "${posMemInicial[$procImprimir]}" ]]; then
                                        #statements
                                        memBMImprimir=$((memBMImprimir + 1))
                                        printf "%3s" "${posMemInicial[$procImprimir]}"
                                        lastIMM="${posMemInicial[$procImprimir]}"
                                    fi

                                fi

                            fi

                        fi
                        temp3=$((temp3 + 1))
                    done
                fi

                printf "\n"

            done

        fi

        empieza=${entradaAuxiliar[0]}

        #BARRA DE TIEMPO
        previoYa="NO"
        lastYa="NO"
        partirTiempo="NO"
        temp=0

        #####################################################################
        for ((i = 0; i < $nprocesos; i++)); do
            if [[ "${estado[$i]}" == "Terminado" ]]; then
                procQueMarcanComoTerminados[$temp]="${ordenEntrada[$i]}"
                temp=$((temp + 1))
            fi
        done

        for ((i = 0; i < $nprocesos; i++)); do
            tocaImprimir[$i]=0
        done
        for ((i = $empieza; i < $tiempo; i++)); do
            if [[ "${procTiempo[$i]}" == "0" && "$previoYa" == "NO" ]]; then
                procPrevio=$((i - 1))
                previoYa="SI"
            fi
        done
        for ((i = $tiempo; $empieza < i; i--)); do
            if [[ "${procTiempo[i]}" == "0" && "$lastYa" == "NO" ]]; then
                procLast=$((i + 1))
                lastYa="SI"
            fi
        done
        if [[ "$previoYa" == "SI" && "$lastYa" == "SI" ]]; then
            for ((i = $procPrevio; i < $procLast; i++)); do
                procTiempo[$i]="${procTiempo[$procPrevio]}"
            done
        fi
        arrayAux3=() #Inicializar array
        posAux=""
        #Buscamos si no ha terminado ningun proceso y no ha sido referenciado
        for ((i = 0; i < ${#procQueMarcanComoTerminados[@]}; i++)); do
            if [[ ! " ${procTerminado[@]} " =~ " ${procQueMarcanComoTerminados[$i]} " ]]; then
                posAux="${procQueMarcanComoTerminados[$i]}"
            fi
        done

        echo "" >diff.txt
        for ((k = 0; k < $nprocesos; k++)); do
            echo "procTerminadoOK - ${procTerminado[$k]} || procTerminadosTotal - ${procQueMarcanComoTerminados[$k]} || Diff - $posAux" >>diff.txt
        done
        #Si ha encontrado un proceso, la varible no esta vacia
        for ((i = 0; i < $nprocesos; i++)); do
            if [[ "$posAux" == "${ordenEntrada[$i]}" ]]; then
                for ((k = $tiempo - 1; k > ${temp_ret[$i]}; k--)); do
                    procTiempo[$k]=0
                done
            fi
        done

        #####################################################################

        tamannoTiempo=$((${#posProcesoTiempo[@]} * 3))
        tamannoTiempo=$(($tiempo * 3))
        tamannoTiempo=$(($tamannoTiempo + 5))
        procTiempo[-1]="$procesoTiempo"
        impreso=0
        if [[ $tamannoTiempo -lt $columns1 ]]; then
            #Primera linea
            echo " "
            printf "    |"
            for ((i = 0; i <= $tiempo; i++)); do
                if [[ "${procTiempo[$i]}" == "0" ]]; then
                    printf "   "
                else
                    if [[ "${procTiempo[$i]}" == "${procTiempo[$i - 1]}" ]]; then
                        printf "   "
                    else
                        for ((t = 0; t < $nprocesos; t++)); do
                            if [[ "${procTiempo[$i]}" == "${ordenEntrada[$t]}" ]]; then
                                colorProcTiempo=${colores[$t]}
                            fi
                        done
                        printf "$colorProcTiempo${procTiempo[$i]}"
                        tocaImprimir[$i]=1
                        lastTiempo="${procTiempo[$i]}"
                    fi
                fi
            done
            printf ""$blanco""
            printf "\n"

            #Segunda linea

            printf " BT |"
            for ((i = 0; i <= $tiempo; i++)); do
                if [[ "${procTiempo[$i]}" == "0" ]]; then
                    printf "$blanco███"
                else
                    for ((t = 0; t < $nprocesos; t++)); do
                        if [[ "${procTiempo[$i]}" == "${ordenEntrada[$t]}" ]]; then
                            colorProcTiempo=${colores[$t]}
                        fi
                    done
                    printf "$colorProcTiempo███"
                fi
            done
            printf ""$blanco""
            printf "\n"

            #Tercera linea
            re='^[1-9]+$'

            for ((i = $tiempoAnterior + 1; i <= $tiempo; i++)); do
                if [[ $i -lt $tiempo ]]; then
                    posProcesoTiempo[$i]=0
                else
                    posProcesoTiempo[$i]=$((tiempo))
                fi
                #echo $i
            done

            printf "    |"
            for ((i = 0; i < ${#posProcesoTiempo[@]}; i++)); do
                if [[ $i -eq 0 ]]; then
                    printf "%3s" "$i"
                else
                    if [[ ${tocaImprimir[$i]} -eq 0 ]]; then
                        printf "   "
                    else
                        if [[ ${tocaImprimir[$i]} -eq 1 ]]; then
                            printf "%3s" "${posProcesoTiempo[$i]}"
                        fi
                    fi
                fi
            done
            echo " "
            # for (( i = 0; i < ${#posProcesoTiempo[@]}; i++ )); do
            #     echo "T = $tiempo -> i: $i -> ${tocaImprimir[$i]}"
            # done
            tiempoAnterior=$tiempo
        else
            partirTiempo="SI"
            nIteraciones=1
            posPrevia=0
            tiempoRestante=$tamannoTiempo
            tiempoRRR=$tamannoTiempo
            saltos=0
            imprimirTiempoFinal=0
            #Determinamos el numero de saltos que tiene que realizar, completando el tamaño del terminal y dejando un espacio a la derecha
            columns1=$(($columns - 6)) #Ancho del que disponemos para imprimir
            while [[ $tiempoRestante -gt $columns1 ]]; do
                tiempoRestante=$(($tiempoRestante - $columns1))
                saltos=$((saltos + 1))
                #echo "memRestante = $memRestante -> saltos = $saltos"
            done

            calcTemp=$(($columns1 % 3))

            if [[ $calcTemp -eq 0 ]]; then
                longitud=$(($columns1 / 3))
                longitud=$(($longitud - 1))
                longitudExtra=$(($saltos * 3))
                tiempoRestante=$(($tiempoRestante + $longitudExtra))
                if [[ $tiempoRestante -gt $columns1 ]]; then
                    saltos=$((saltos + 1))
                    tiempoRestante=$(($tiempoRestante - $columns1))
                fi
            else
                columns1=$(($columns1 - $calcTemp))
                longitud=$(($columns1 / 3))
                longitud=$(($longitud - 1))
                longitudExtra=$(($saltos * 3))
                tiempoRestante=$(($tiempoRestante + $longitudExtra))
                if [[ $tiempoRestante -gt $columns1 ]]; then
                    saltos=$((saltos + 1))
                    tiempoRestante=$(($tiempoRestante - $columns1))
                fi
                tiempoRestante=$(($tiempoRestante - 9))

            fi

            calcTemp=$(($tiempoRestante % 3))
            if [[ $calcTemp -eq 0 ]]; then
                tiempoRestante=$(($tiempoRestante / 3))
                nIteraciones=$(($nIteraciones + 2))
                tiempoRestante=$(($tiempoRestante + $nIteraciones))
            else
                tiempoRestante=$(($tiempoRestante / 3))
                tiempoRestante=$(($tiempoRestante))
            fi
            for ((p = 0; p < $nprocesos; p++)); do
                if [[ "${estado[$p]}" == "En ejecucion" ]]; then
                    procEnEjecucion="${ordenEntrada[$p]}"
                fi
            done

            nblancos=$((${entradaAuxiliar[0]} + 1))
            nblancosImpresos=0
            temp1=0
            temp2=0
            temp3=0
            primera=0

            for ((p = 0; p <= $saltos; p++)); do
                echo " "

                if [[ $p -eq 0 ]]; then
                    printf "    |"
                else
                    printf "     "
                fi

                if [[ $p -eq $saltos ]]; then
                    for ((i = 0; i < $tiempoRestante; i++)); do
                        if [[ "${procTiempo[$temp1]}" == "0" ]]; then
                            printf "%3s" " "
                        else
                            if [[ "${procTiempo[$temp1]}" == "${procTiempo[$temp1 - 1]}" ]]; then
                                printf "%3s" " "

                            else
                                for ((t = 0; t < $nprocesos; t++)); do
                                    if [[ "${procTiempo[$temp1]}" == "${ordenEntrada[$t]}" ]]; then
                                        colorProcTiempo=${colores[$t]}
                                    fi
                                done

                                printf "$colorProcTiempo${procTiempo[$temp1]}"
                                ultimoImpresoTiempo="${procTiempo[$temp1]}"
                                tocaImprimir[$temp1]=1
                                lastTiempo="${procTiempo[$temp1]}"
                            fi
                        fi
                        temp1=$((temp1 + 1))
                        impreso=$((impreso + 1))
                    done
                    if [[ "$ultimoImpresoTiempo" != "$procEnEjecucion" ]]; then
                        for ((t = 0; t < $nprocesos; t++)); do
                            if [[ "$procEnEjecucion" == "${ordenEntrada[$t]}" ]]; then
                                colorProcTiempo=${colores[$t]}
                            fi
                        done
                        printf "$colorProcTiempo$procEnEjecucion"
                    fi
                else
                    for ((i = 0; i < $longitud; i++)); do
                        if [[ "${procTiempo[$temp1]}" == "0" ]]; then
                            printf "%3s" " "
                        else
                            if [[ "${procTiempo[$temp1]}" == "${procTiempo[$temp1 - 1]}" ]]; then
                                printf "%3s" " "

                            else
                                for ((t = 0; t < $nprocesos; t++)); do
                                    if [[ "${procTiempo[$temp1]}" == "${ordenEntrada[$t]}" ]]; then
                                        colorProcTiempo=${colores[$t]}
                                    fi
                                done

                                printf "$colorProcTiempo${procTiempo[$temp1]}"
                                tocaImprimir[$temp1]=1
                                lastTiempo="${procTiempo[$temp1]}"
                                ultimoImpresoTiempo="${procTiempo[$temp1]}"
                            fi
                        fi
                        temp1=$((temp1 + 1))
                        impreso=$((impreso + 1))
                    done
                fi
                printf ""$blanco""
                printf "\n"

                #Segunda linea

                if [[ $p -eq 0 ]]; then
                    printf " BT |"
                else
                    printf "     "
                fi
                if [[ $p -eq $saltos ]]; then
                    for ((i = 0; i < $tiempoRestante; i++)); do
                        if [[ "${procTiempo[$temp2]}" == "0" ]]; then
                            printf "$blanco███"
                            nblancosImpresos=$((nblancosImpresos + 1))
                            if [[ $nblancosImpresos -eq $nblancos+1 ]]; then
                                primera=$(($saltos * $longitud + $i))
                            fi
                        else
                            for ((t = 0; t < $nprocesos; t++)); do
                                if [[ "${procTiempo[$temp2]}" == "${ordenEntrada[$t]}" ]]; then
                                    colorProcTiempo=${colores[$t]}
                                fi
                            done
                            printf "$colorProcTiempo███"
                        fi
                        temp2=$((temp2 + 1))
                    done
                    if [[ "$ultimoImpresoTiempo" != "$procEnEjecucion" ]]; then
                        for ((t = 0; t < $nprocesos; t++)); do
                            if [[ "$procEnEjecucion" == "${ordenEntrada[$t]}" ]]; then
                                colorProcTiempo=${colores[$t]}
                            fi
                        done
                        printf "$colorProcTiempo███"
                        imprimirTiempoFinal=1
                    fi
                else
                    for ((i = 0; i < $longitud; i++)); do
                        if [[ "${procTiempo[$temp2]}" == "0" ]]; then
                            printf "$blanco███"
                            nblancosImpresos=$((nblancosImpresos + 1))
                            if [[ $nblancosImpresos -eq $nblancos+1 ]]; then
                                primera=$(($p * $longitud + $i))
                            fi
                        else
                            for ((t = 0; t < $nprocesos; t++)); do
                                if [[ "${procTiempo[$temp2]}" == "${ordenEntrada[$t]}" ]]; then
                                    colorProcTiempo=${colores[$t]}
                                fi
                            done
                            printf "$colorProcTiempo███"
                        fi
                        temp2=$((temp2 + 1))
                    done
                fi
                printf ""$blanco""
                printf "\n"

                #Tercera linea
                re='^[1-9]+$'

                for ((i = $tiempoAnterior + 1; i <= $tiempo; i++)); do
                    if [[ $i -lt $tiempo ]]; then
                        posProcesoTiempo[$i]=0
                    else
                        posProcesoTiempo[$i]=$((tiempo))
                    fi
                    #echo $i
                done

                if [[ $p -eq 0 ]]; then
                    printf "    |"
                else
                    printf "     "
                fi
                if [[ $p -eq $saltos ]]; then
                    for ((i = 0; i < $tiempoRestante; i++)); do
                        if [[ $i -eq 0 ]] && [[ $p -eq 0 ]]; then
                            printf "%3s" "$temp3"
                        else
                            if [[ ${tocaImprimir[$temp3]} -eq 0 ]]; then
                                if [[ $temp3+1 -eq $primera ]]; then
                                    primera=$((primera - 1))
                                    printf "%3s" "$primera"
                                else
                                    printf "   "
                                fi
                            else
                                if [[ ${tocaImprimir[$temp3]} -eq 1 ]]; then
                                    printf "%3s" "${posProcesoTiempo[$temp3]}"
                                fi
                            fi
                        fi
                        temp3=$((temp3 + 1))
                    done
                    if [[ $imprimirTiempoFinal -eq 1 ]]; then
                        printf "%3s" "$tiempo"
                    fi
                else
                    for ((i = 0; i < $longitud; i++)); do
                        if [[ $i -eq 0 ]] && [[ $p -eq 0 ]]; then
                            printf "%3s" "$temp3"
                        else
                            if [[ ${tocaImprimir[$temp3]} -eq 0 ]]; then
                                if [[ $temp3+1 -eq $primera ]]; then
                                    primera=$((primera - 1))
                                    printf "%3s" "$primera"
                                else
                                    printf "   "
                                fi
                            else
                                if [[ ${tocaImprimir[$temp3]} -eq 1 ]]; then
                                    printf "%3s" "${posProcesoTiempo[$temp3]}"
                                fi
                            fi
                        fi
                        temp3=$((temp3 + 1))
                    done
                fi
            done

            echo " "
            tiempoAnterior=$tiempo
        fi
        echo "procTiempo - ${procTiempo[$temp3]} -> procEnEjecucion - $procEnEjecucion" >impresion.txt
        for ((i = 0; i < ${#procTiempo[@]} / 3; i++)); do
            echo "$i - ${procTiempo[$i]}" >>impresion.txt
        done

        #########################################################################################################
        #
        #                    A  P A R T I R  D E  A Q U Í  T O D O  E S  D E  F I C H E R O S
        #
        #########################################################################################################

        if [[ ${evento[$tiempo]} -eq 1 ]]; then

            echo -e "\e[0m"
            echo " " >>salida.txt
            #cecho "|    PROCESOS   |    T.LLEG.    |     T.EJEC.   |     MEMORIA   |    T.ESPERA   |   T.RETORNO   |  T.RESTANTE   |    ESTADO     |" $FYEL
            echo " Ref Tll Tej Mem Tesp Tret Trej Mini Mfin ESTADO " >>salida.txt
            for ((i = 0; i < $nprocesos; i++)); do
                if [[ ${nollegado[$i]} -eq 1 ]]; then
                    printf " ${ordenEntrada[$i]}" >>salida.txt
                    printf " " >>salida.txt
                    printf "%3s" "${entradaAuxiliar[$i]}" >>salida.txt
                    printf " " >>salida.txt
                    printf "%3s" "${tejecucion[$i]}" >>salida.txt
                    printf " " >>salida.txt
                    printf "%3s" "${tamemoryAuxiliar[$i]}" >>salida.txt
                    printf " " >>salida.txt
                    printf "%4s" "-" >>salida.txt
                    printf " " >>salida.txt
                    printf "%4s" "-" >>salida.txt
                    printf " " >>salida.txt
                    printf "%4s" "-" >>salida.txt
                    printf " " >>salida.txt
                    printf "%4s" "-" >>salida.txt
                    printf " " >>salida.txt
                    printf "%4s" "-" >>salida.txt
                    printf " " >>salida.txt
                    printf "%-20s\n" "${estado[$i]}" >>salida.txt
                elif [[ ${nollegado[$i]} -eq 0 ]] && [[ ${enejecucion[$i]} -eq 1 ]]; then
                    printf " ${ordenEntrada[$i]}" >>salida.txt
                    printf " " >>salida.txt
                    printf "%3s" "${entradaAuxiliar[$i]}" >>salida.txt
                    printf " " >>salida.txt
                    printf "%3s" "${tejecucion[$i]}" >>salida.txt
                    printf " " >>salida.txt
                    printf "%3s" "${tamemoryAuxiliar[$i]}" >>salida.txt
                    printf " " >>salida.txt
                    printf "%4s" "${temp_wait[$i]}" >>salida.txt
                    printf " " >>salida.txt
                    printf "%4s" "${temp_ret[$i]}" >>salida.txt
                    printf " " >>salida.txt
                    printf "%4s" "${ejecucionAuxiliar[$i]}" >>salida.txt
                    printf " " >>salida.txt
                    printf "%4s" "${posMemInicial[$i]}" >>salida.txt
                    printf " " >>salida.txt
                    printf "%4s" "${posMemFinal[$i]}" >>salida.txt
                    printf " " >>salida.txt
                    printf "%-20s\n" "${estado[$i]}" >>salida.txt
                    #printf "${colores[$i]} ${ordenEntrada[$i]}   ${entradaAuxiliar[$i]}    ${tejecucion[$i]}    ${tamemoryAuxiliar[$i]}   ${temp_wait[$i]}     ${temp_ret[$i]}    ${ejecucionAuxiliar[$i]}   ${posMemInicial[$i]}    ${posMemFinal[$i]}    ${estado[$i]}\n"
                elif [[ ${terminados[$i]} -eq 1 ]]; then
                    printf " ${ordenEntrada[$i]}" >>salida.txt
                    printf " " >>salida.txt
                    printf "%3s" "${entradaAuxiliar[$i]}" >>salida.txt
                    printf " " >>salida.txt
                    printf "%3s" "${tejecucion[$i]}" >>salida.txt
                    printf " " >>salida.txt
                    printf "%3s" "${tamemoryAuxiliar[$i]}" >>salida.txt
                    printf " " >>salida.txt
                    printf "%4s" "${temp_wait[$i]}" >>salida.txt
                    printf " " >>salida.txt
                    printf "%4s" "${temp_ret[$i]}" >>salida.txt
                    printf " " >>salida.txt
                    printf "%4s" "${ejecucionAuxiliar[$i]}" >>salida.txt
                    printf " " >>salida.txt
                    printf "%4s" "${posMemInicial[$i]}" >>salida.txt
                    printf " " >>salida.txt
                    printf "%4s" "${posMemFinal[$i]}" >>salida.txt
                    printf " " >>salida.txt
                    printf "%-20s\n" "${estado[$i]}" >>salida.txt
                    #printf "${colores[$i]} ${ordenEntrada[$i]}   ${entradaAuxiliar[$i]}    ${tejecucion[$i]}    ${tamemoryAuxiliar[$i]}   ${temp_wait[$i]}     ${temp_ret[$i]}    ${ejecucionAuxiliar[$i]}   0    0    ${estado[$i]}\n"
                elif [[ ${enmemoria[$i]} -eq 1 ]] && [[ ${pausados[$i]} -eq 1 ]]; then
                    printf " ${ordenEntrada[$i]}" >>salida.txt
                    printf " " >>salida.txt
                    printf "%3s" "${entradaAuxiliar[$i]}" >>salida.txt
                    printf " " >>salida.txt
                    printf "%3s" "${tejecucion[$i]}" >>salida.txt
                    printf " " >>salida.txt
                    printf "%3s" "${tamemoryAuxiliar[$i]}" >>salida.txt
                    printf " " >>salida.txt
                    printf "%4s" "${temp_wait[$i]}" >>salida.txt
                    printf " " >>salida.txt
                    printf "%4s" "${temp_ret[$i]}" >>salida.txt
                    printf " " >>salida.txt
                    printf "%4s" "${ejecucionAuxiliar[$i]}" >>salida.txt
                    printf " " >>salida.txt
                    printf "%4s" "${posMemInicial[$i]}" >>salida.txt
                    printf " " >>salida.txt
                    printf "%4s" "${posMemFinal[$i]}" >>salida.txt
                    printf " " >>salida.txt
                    printf "%-20s\n" "${estado[$i]}" >>salida.txt
                    #printf "${colores[$i]} ${ordenEntrada[$i]}   ${entradaAuxiliar[$i]}    ${tejecucion[$i]}    ${tamemoryAuxiliar[$i]}   ${temp_wait[$i]}     ${temp_ret[$i]}    ${ejecucionAuxiliar[$i]}   ${posMemInicial[$i]}    ${posMemFinal[$i]}      ${estado[$i]}\n"
                elif [[ ${enmemoria[$i]} -eq 1 ]] || [[ ${encola[$i]} -eq 1 ]]; then
                    printf " ${ordenEntrada[$i]}" >>salida.txt
                    printf " " >>salida.txt
                    printf "%3s" "${entradaAuxiliar[$i]}" >>salida.txt
                    printf " " >>salida.txt
                    printf "%3s" "${tejecucion[$i]}" >>salida.txt
                    printf " " >>salida.txt
                    printf "%3s" "${tamemoryAuxiliar[$i]}" >>salida.txt
                    printf " " >>salida.txt
                    printf "%4s" "${temp_wait[$i]}" >>salida.txt
                    printf " " >>salida.txt
                    printf "%4s" "${temp_ret[$i]}" >>salida.txt
                    printf " " >>salida.txt
                    printf "%4s" "${ejecucionAuxiliar[$i]}" >>salida.txt
                    printf " " >>salida.txt
                    printf "%4s" "${posMemInicial[$i]}" >>salida.txt
                    printf " " >>salida.txt
                    printf "%4s" "${posMemFinal[$i]}" >>salida.txt
                    printf " " >>salida.txt
                    printf "%-20s\n" "${estado[$i]}" >>salida.txt
                    #printf "${colores[$i]} ${ordenEntrada[$i]}   ${entradaAuxiliar[$i]}    ${tejecucion[$i]}    ${tamemoryAuxiliar[$i]}   ${temp_wait[$i]}     ${temp_ret[$i]}    ${ejecucionAuxiliar[$i]}   ${posMemInicial[$i]}    ${posMemFinal[$i]}    ${estado[$i]}\n"
                fi

            done
            #echo "---------------------------------------------------------------------------------------------------------------------------------" >> salida.txt
            if [[ $nprocT -eq 0 ]]; then
                printf "Tiempo Medio Espera = 0\t" >>salida.txt
            else
                # total66=`echo $mediaTEspera / $nprocT | bc`
                # cecho $total66 $FRED
                printf 'Tiempo Medio Espera = %.2f\t' $((mediaTEspera / $nprocT)) >>salida.txt
            fi
            if [[ $nprocR -eq 0 ]]; then
                printf "Tiempo Medio de Retorno = 0\n" >>salida.txt
            else
                # total66=`echo $mediaTRetorno / $nprocR | bc`
                # cecho $total66 $FRED
                printf 'Tiempo Medio Retorno = %.2f\n' $((mediaTRetorno / $nprocR)) >>salida.txt
            fi
            printf "\n" >>salida.txt
            echo " " >>salida.txt

            j=0
            k=0

            for ((i = 0; i < $nprocesos; i++)); do
                if [[ ${enmemoria[$i]} -eq 1 ]]; then
                    guardados[$j]=$i              #Se guardan en cada posición el número del proceso correspondiente <<<<<<<<<<<F A L L O?
                    coloresAux[$k]=${colores[$i]} #<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<F A L L O? Cambiar por k?
                    j=$(expr $j + 1)
                fi
                k=$(expr $k + 1)
            done

            j=0
            k=0

            if [[ "$partirImpresion" == "NO" ]]; then
                # Primera línea, en la que mostramos el nombre del proceso, por debajo de ella se encuentra la representación gráfica de la memoria
                printf "    |" >>salida.txt
                for ((i = $posPrevia; i < ${#posMem[@]} - 1; i++)); do
                    if [[ "${posMem[$i]}" = "0" ]]; then
                        printf "   " >>salida.txt
                    else
                        if [[ "${posMem[$i]}" != "${posMem[$i - 1]}" ]]; then
                            for ((t = 0; t < $nprocesos; t++)); do
                                if [[ "${posMem[$i]}" == "${ordenEntrada[$t]}" ]]; then
                                    colorProcesoAImprimir=${colores[$t]}
                                fi
                            done
                            printf "${posMem[$i]}" >>salida.txt
                        else
                            printf "   " >>salida.txt
                        fi
                    fi
                done

                printf "\n" >>salida.txt

                col=0
                aux=0

                printf " BM |" >>salida.txt
                for ((i = $posPrevia; i < $mem_total; i++)); do
                    if [[ "${posMem[$i]}" == "0" ]]; then
                        printf "|||" >>salida.txt
                    else
                        colorProcesoAImprimir=""
                        for ((t = 0; t < $nprocesos; t++)); do
                            if [[ "${posMem[$i]}" == "${ordenEntrada[$t]}" ]]; then
                                colorProcesoAImprimir=${colores[$t]}
                            fi
                        done
                        printf "███" >>salida.txt
                    fi
                done

                printf " $mem_total" >>salida.txt
                printf "\n" >>salida.txt

                memBMImprimir=0
                YA="NO"
                #Barra 3 - Posiciones de memoria dinales de cada proceso
                printf "    |" >>salida.txt
                for ((i = 0; i < ${#posMem[@]} - 2; i++)); do #Sería -1 pero para cuadrar el valor final de la memoria, debemos de poner el -2. Sino sale descuadrado por una unidad = 3
                    for ((o = 0; o < $nprocesos; o++)); do
                        if [[ "${posMem[$i]}" == "${ordenEntrada[$o]}" ]]; then
                            procImprimir=$o
                        fi
                    done
                    if [[ $i -eq 0 ]]; then
                        printf "  0" >>salida.txt
                    else
                        if [[ "${posMem[$i]}" == "0" ]]; then
                            if [[ "${posMem[$i]}" != "${posMem[$i - 1]}" && "$YA" = "NO" ]]; then
                                memBMImprimir=$((memBMImprimir + 1))
                                printf "%3s" "$memBMImprimir" >>salida.txt
                                YA="SI"
                            else
                                memBMImprimir=$((memBMImprimir + 1))
                                printf "%3s" " " >>salida.txt
                            fi
                        else
                            if [[ "${posMem[$i]}" == "${posMem[$i - 1]}" ]]; then
                                memBMImprimir=$((memBMImprimir + 1))
                                printf "   " >>salida.txt
                            else
                                memBMImprimir=$((memBMImprimir + 1))
                                printf "%3s" "${posMemInicial[$procImprimir]}" >>salida.txt
                                YA="NO"
                            fi
                        fi

                    fi
                done
            fi
            if [[ "$partirImpresion" == "SI" ]]; then
                saltos=0
                memRestante=$memAImprimir
                while [[ $memRestante -gt $columns ]]; do
                    memRestante=$(($memRestante - $columns))
                    saltos=$((saltos + 1))
                    #echo "memRestante = $memRestante -> saltos = $saltos"
                done
                memRestante=$(($memRestante - 3))
                memRestante=$(($memRestante / 3))

                columns1=$(($columns - 6))
                ggg=$(($columns1 % 3))
                if [[ $ggg -eq 0 ]]; then
                    longitud=$(($columns1 / 3))
                else
                    longitud=$(($columns1 / 3))
                    longitud=$(($longitud - 1))
                fi
                #echo "longitud = $longitud"

                temp1=0
                temp2=0
                temp3=0
                memBMImprimir=0
                YA="NO"
                lastIMM="0"

                for ((p = 0; p <= $saltos; p++)); do

                    if [[ $p -eq 0 ]]; then
                        printf "    |" >>salida.txt
                    else
                        printf "     " >>salida.txt
                    fi
                    if [[ $p -eq $saltos ]]; then
                        for ((i = 0; i < $memRestante; i++)); do
                            if [[ "${posMem[$temp1]}" = "0" ]]; then
                                printf "   " >>salida.txt
                            else
                                if [[ "${posMem[$temp1]}" != "${posMem[$temp1 - 1]}" ]]; then
                                    for ((t = 0; t < $nprocesos; t++)); do
                                        if [[ "${posMem[$temp1]}" == "${ordenEntrada[$t]}" ]]; then
                                            colorProcesoAImprimir=${colores[$t]}
                                        fi
                                    done
                                    if ! [[ "${posMem[$temp1]}" == "1" ]]; then
                                        printf "${posMem[$temp1]}" >>salida.txt
                                    fi
                                else
                                    printf "   " >>salida.txt
                                fi
                            fi
                            temp1=$((temp1 + 1))
                        done
                    else
                        for ((i = 0; i < $longitud; i++)); do
                            if [[ "${posMem[$temp1]}" = "0" ]]; then
                                printf "   " >>salida.txt
                            else
                                if [[ "${posMem[$temp1]}" != "${posMem[$temp1 - 1]}" ]]; then
                                    for ((t = 0; t < $nprocesos; t++)); do
                                        if [[ "${posMem[$temp1]}" == "${ordenEntrada[$t]}" ]]; then
                                            colorProcesoAImprimir=${colores[$t]}
                                        fi
                                    done
                                    if ! [[ "${posMem[$temp1]}" == "1" ]]; then
                                        printf "${posMem[$temp1]}" >>salida.txt
                                    fi
                                else
                                    printf "   " >>salida.txt
                                fi
                            fi
                            temp1=$((temp1 + 1))
                        done
                    fi

                    printf "\n" >>salida.txt

                    col=0
                    aux=0
                    if [[ $p -eq 0 ]]; then
                        printf " BM |" >>salida.txt
                    else
                        printf "     " >>salida.txt
                    fi

                    if [[ $p -eq $saltos ]]; then
                        for ((i = 0; i < $memRestante; i++)); do
                            if [[ "${posMem[$temp2]}" == "0" ]]; then
                                printf "|||" >>salida.txt
                            else
                                colorProcesoAImprimir=""
                                for ((t = 0; t < $nprocesos; t++)); do
                                    if [[ "${posMem[$temp2]}" == "${ordenEntrada[$t]}" ]]; then
                                        colorProcesoAImprimir=${colores[$t]}
                                    fi
                                done
                                printf "███" >>salida.txt
                            fi
                            temp2=$((temp2 + 1))
                        done
                    else
                        for ((i = 0; i < $longitud; i++)); do
                            if [[ "${posMem[$temp2]}" == "0" ]]; then
                                printf "|||" >>salida.txt
                            else
                                colorProcesoAImprimir=""
                                for ((t = 0; t < $nprocesos; t++)); do
                                    if [[ "${posMem[$temp2]}" == "${ordenEntrada[$t]}" ]]; then
                                        colorProcesoAImprimir=${colores[$t]}
                                    fi
                                done
                                printf "███" >>salida.txt
                            fi
                            temp2=$((temp2 + 1))
                        done
                    fi
                    if [[ $p -eq $saltos ]]; then
                        printf "%4s" "$mem_total" >>salida.txt
                    fi
                    printf "\n" >>salida.txt

                    #Barra 3 - Posiciones de memoria dinales de cada proceso
                    if [[ $p -eq 0 ]]; then
                        printf "$blanco    |" >>salida.txt
                    else
                        printf "     " >>salida.txt
                    fi

                    if [[ $p -eq $saltos ]]; then
                        for ((i = 0; i < $memRestante; i++)); do
                            for ((o = 0; o < $nprocesos; o++)); do
                                if [[ "${posMem[$temp3]}" == "${ordenEntrada[$o]}" ]]; then
                                    procImprimir=$o
                                fi
                            done
                            if [[ $p -eq 0 ]] && [[ $i -eq 0 ]]; then
                                printf "  0" >>salida.txt
                            else
                                if [[ "${posMem[$temp3]}" = "0" ]]; then
                                    if [[ "${posMem[$temp3]}" != "${posMem[$temp3 - 1]}" ]]; then
                                        memBMImprimir=$((memBMImprimir + 1))
                                        printf "%3s" "$memBMImprimir" >>salida.txt
                                    else
                                        memBMImprimir=$((memBMImprimir + 1))
                                        printf "%3s" " " >>salida.txt
                                    fi
                                else
                                    if [[ "${posMem[$temp3]}" == "${posMem[$temp3 - 1]}" ]]; then
                                        memBMImprimir=$((memBMImprimir + 1))
                                        printf "%3s" " " >>salida.txt
                                    else
                                        if ! [[ "$lastIMM" == "${posMemInicial[$procImprimir]}" ]]; then
                                            #statements
                                            memBMImprimir=$((memBMImprimir + 1))
                                            printf "%3s" "${posMemInicial[$procImprimir]}" >>salida.txt
                                            lastIMM="${posMemInicial[$procImprimir]}"
                                        fi

                                    fi

                                fi

                            fi
                            temp3=$((temp3 + 1))
                        done
                    else
                        for ((i = 0; i < $longitud; i++)); do
                            for ((o = 0; o < $nprocesos; o++)); do
                                if [[ "${posMem[$temp3]}" == "${ordenEntrada[$o]}" ]]; then
                                    procImprimir=$o
                                fi
                            done
                            if [[ $p -eq 0 ]] && [[ $i -eq 0 ]]; then
                                printf "  0" >>salida.txt
                            else
                                if [[ "${posMem[$temp3]}" = "0" ]]; then
                                    if [[ "${posMem[$temp3]}" != "${posMem[$temp3 - 1]}" ]]; then
                                        memBMImprimir=$((memBMImprimir + 1))
                                        printf "%3s" "$memBMImprimir" >>salida.txt
                                    else
                                        memBMImprimir=$((memBMImprimir + 1))
                                        printf "%3s" " " >>salida.txt
                                    fi
                                else
                                    if [[ "${posMem[$temp3]}" == "${posMem[$temp3 - 1]}" ]]; then
                                        memBMImprimir=$((memBMImprimir + 1))
                                        printf "%3s" " " >>salida.txt
                                    else
                                        if ! [[ "$lastIMM" == "${posMemInicial[$procImprimir]}" ]]; then
                                            #statements
                                            memBMImprimir=$((memBMImprimir + 1))
                                            printf "%3s" "${posMemInicial[$procImprimir]}" >>salida.txt
                                            lastIMM="${posMemInicial[$procImprimir]}"
                                        fi

                                    fi

                                fi

                            fi
                            temp3=$((temp3 + 1))
                        done
                    fi

                    printf "\n" >>salida.txt

                done

            fi
            if [[ "$partirTiempo" == "NO" ]]; then
                echo " " >>salida.txt
                printf "    |" >>salida.txt
                for ((i = 0; i <= $tiempo; i++)); do
                    if [[ "${procTiempo[$i]}" == "0" ]]; then
                        printf "   " >>salida.txt
                    else
                        if [[ "${procTiempo[$i]}" == "${procTiempo[$i - 1]}" ]]; then
                            printf "   " >>salida.txt
                        else

                            printf "${procTiempo[$i]}" >>salida.txt
                            tocaImprimir[$i]=1
                        fi
                    fi
                done
                printf "\n" >>salida.txt

                #Segunda linea

                printf " BT |" >>salida.txt
                for ((i = 0; i <= $tiempo; i++)); do
                    if [[ "${procTiempo[$i]}" == "0" ]]; then
                        printf "|||" >>salida.txt
                    else

                        printf "███" >>salida.txt
                    fi
                done
                printf "\n" >>salida.txt

                printf "    |" >>salida.txt
                for ((i = 0; i < ${#posProcesoTiempo[@]}; i++)); do
                    if [[ $i -eq 0 ]]; then
                        printf "%3s" "$i" >>salida.txt
                    else
                        if [[ ${tocaImprimir[$i]} -eq 0 ]]; then
                            printf "   " >>salida.txt
                        else
                            if [[ ${tocaImprimir[$i]} -eq 1 ]]; then
                                printf "%3s" "${posProcesoTiempo[$i]}" >>salida.txt
                            fi
                        fi
                    fi
                done
                echo " " >>salida.txt
            fi

            if [[ "$partirTiempo" == "SI" ]]; then

                posPrevia=0
                tiempoRestante=$tamannoTiempo
                saltos=0

                #Determinamos el numero de saltos que tiene que realizar, completando el tamaño del terminal y dejando un espacio a la derecha
                while [[ $tiempoRestante -gt $columns ]]; do
                    tiempoRestante=$(($tiempoRestante - $columns))
                    saltos=$((saltos + 1))
                    #echo "memRestante = $memRestante -> saltos = $saltos"
                done
                tiempoRestante=$(($tiempoRestante - 3))
                tiempoRestante=$(($tiempoRestante / 3))

                columns1=$(($columns - 6))
                cgg=$(($columns1 % 3))
                if [[ $cgg -eq 0 ]]; then
                    longitud=$(($columns1 / 3))
                else
                    longitud=$(($columns1 / 3))
                    longitud=$(($longitud - 1))
                fi

                nblancos=$((${entradaAuxiliar[0]} + 1))
                nblancosImpresos=0
                temp1=0
                temp2=0
                temp3=0
                primera=0

                for ((p = 0; p <= $saltos; p++)); do
                    echo " " >>salida.txt

                    if [[ $p -eq 0 ]]; then
                        printf "    |" >>salida.txt
                    else
                        printf "     " >>salida.txt
                    fi

                    if [[ $p -eq $saltos ]]; then
                        for ((i = 0; i < $tiempoRestante; i++)); do
                            if [[ "${procTiempo[$temp1]}" == "0" ]]; then
                                printf "%3s" " " >>salida.txt
                            else
                                if [[ "${procTiempo[$temp1]}" == "${procTiempo[$temp1 - 1]}" ]]; then
                                    printf "%3s" " " >>salida.txt

                                else

                                    printf "${procTiempo[$temp1]}" >>salida.txt
                                    ultimoImpresoTiempo="${procTiempo[$temp1]}"
                                    tocaImprimir[$temp1]=1

                                fi
                            fi
                            temp1=$((temp1 + 1))
                            impreso=$((impreso + 1))
                        done
                        if [[ "$ultimoImpresoTiempo" != "$procEnEjecucion" ]]; then
                            for ((t = 0; t < $nprocesos; t++)); do
                                if [[ "$procEnEjecucion" == "${ordenEntrada[$t]}" ]]; then
                                    colorProcTiempo=${colores[$t]}
                                fi
                            done
                            printf "$procEnEjecucion" >>salida.txt
                        fi
                    else
                        for ((i = 0; i < $longitud; i++)); do
                            if [[ "${procTiempo[$temp1]}" == "0" ]]; then
                                printf "%3s" " " >>salida.txt
                            else
                                if [[ "${procTiempo[$temp1]}" == "${procTiempo[$temp1 - 1]}" ]]; then
                                    printf "%3s" " " >>salida.txt

                                else

                                    printf "${procTiempo[$temp1]}" >>salida.txt
                                    tocaImprimir[$temp1]=1

                                    ultimoImpresoTiempo="${procTiempo[$temp1]}"
                                fi
                            fi
                            temp1=$((temp1 + 1))
                            impreso=$((impreso + 1))
                        done
                    fi

                    printf "\n" >>salida.txt

                    #Segunda linea

                    if [[ $p -eq 0 ]]; then
                        printf " BT |" >>salida.txt
                    else
                        printf "     " >>salida.txt
                    fi
                    if [[ $p -eq $saltos ]]; then
                        for ((i = 0; i < $tiempoRestante; i++)); do
                            if [[ "${procTiempo[$temp2]}" == "0" ]]; then
                                printf "|||" >>salida.txt
                                nblancosImpresos=$((nblancosImpresos + 1))
                                if [[ $nblancosImpresos -eq $nblancos+1 ]]; then
                                    primera=$(($saltos * $longitud + $i))
                                fi
                            else
                                for ((t = 0; t < $nprocesos; t++)); do
                                    if [[ "${procTiempo[$temp2]}" == "${ordenEntrada[$t]}" ]]; then
                                        colorProcTiempo=${colores[$t]}
                                    fi
                                done
                                printf "███" >>salida.txt
                            fi
                            temp2=$((temp2 + 1))
                        done
                        if [[ "$ultimoImpresoTiempo" != "$procEnEjecucion" ]]; then
                            for ((t = 0; t < $nprocesos; t++)); do
                                if [[ "$procEnEjecucion" == "${ordenEntrada[$t]}" ]]; then
                                    colorProcTiempo=${colores[$t]}
                                fi
                            done
                            printf "███" >>salida.txt
                            imprimirTiempoFinal=1
                        fi
                    else
                        for ((i = 0; i < $longitud; i++)); do
                            if [[ "${procTiempo[$temp2]}" == "0" ]]; then
                                printf "|||" >>salida.txt
                                nblancosImpresos=$((nblancosImpresos + 1))
                                if [[ $nblancosImpresos -eq $nblancos+1 ]]; then
                                    primera=$(($p * $longitud + $i))
                                fi
                            else

                                printf "███" >>salida.txt
                            fi
                            temp2=$((temp2 + 1))
                        done
                    fi
                    printf "\n" >>salida.txt

                    #Tercera linea

                    if [[ $p -eq 0 ]]; then
                        printf "    |" >>salida.txt
                    else
                        printf "     " >>salida.txt
                    fi
                    if [[ $p -eq $saltos ]]; then
                        for ((i = 0; i < $tiempoRestante; i++)); do
                            if [[ $i -eq 0 ]] && [[ $p -eq 0 ]]; then
                                printf "%3s" "$temp3" >>salida.txt
                            else
                                if [[ ${tocaImprimir[$temp3]} -eq 0 ]]; then
                                    if [[ $temp3+1 -eq $primera ]]; then
                                        primera=$((primera - 1))
                                        printf "%3s" "$primera" >>salida.txt
                                    else
                                        printf "   " >>salida.txt
                                    fi
                                else
                                    if [[ ${tocaImprimir[$temp3]} -eq 1 ]]; then
                                        printf "%3s" "${posProcesoTiempo[$temp3]}" >>salida.txt
                                    fi
                                fi
                            fi
                            temp3=$((temp3 + 1))
                        done
                        if [[ $imprimirTiempoFinal -eq 1 ]]; then
                            printf "%3s" "$tiempo" >>salida.txt
                        fi
                    else
                        for ((i = 0; i < $longitud; i++)); do
                            if [[ $i -eq 0 ]] && [[ $p -eq 0 ]]; then
                                printf "%3s" "$temp3" >>salida.txt
                            else
                                if [[ ${tocaImprimir[$temp3]} -eq 0 ]]; then
                                    if [[ $temp3+1 -eq $primera ]]; then
                                        primera=$((primera - 1))
                                        printf "%3s" "$primera" >>salida.txt
                                    else
                                        printf "   " >>salida.txt
                                    fi
                                else
                                    if [[ ${tocaImprimir[$temp3]} -eq 1 ]]; then
                                        printf "%3s" "${posProcesoTiempo[$temp3]}" >>salida.txt
                                    fi
                                fi
                            fi
                            temp3=$((temp3 + 1))
                        done
                    fi
                done

                echo " " >>salida.txt
            fi

            #Metemos los mismos datos al fichero salidacolor.txt
            echo " " >>salidacolor.txt
            echo -e "\e[0m"

            #cecho "|    PROCESOS   |    T.LLEG.    |     T.EJEC.   |     MEMORIA   |    T.ESPERA   |   T.RETORNO   |  T.RESTANTE   |    ESTADO     |" $FYEL
            echo " Ref Tll Tej Mem Tesp Tret Trej Mini Mfin ESTADO " >>salidacolor.txt
            for ((i = 0; i < $nprocesos; i++)); do
                if [[ ${nollegado[$i]} -eq 1 ]]; then
                    printf " ${colores[$i]}${ordenEntrada[$i]}" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%3s" "${entradaAuxiliar[$i]}" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%3s" "${tejecucion[$i]}" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%3s" "${tamemoryAuxiliar[$i]}" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%4s" "-" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%4s" "-" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%4s" "-" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%4s" "-" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%4s" "-" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%-20s\n" "${estado[$i]}" >>salidacolor.txt
                elif [[ ${nollegado[$i]} -eq 0 ]] && [[ ${enejecucion[$i]} -eq 1 ]]; then
                    printf " ${colores[$i]}${ordenEntrada[$i]}" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%3s" "${entradaAuxiliar[$i]}" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%3s" "${tejecucion[$i]}" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%3s" "${tamemoryAuxiliar[$i]}" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%4s" "${temp_wait[$i]}" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%4s" "${temp_ret[$i]}" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%4s" "${ejecucionAuxiliar[$i]}" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%4s" "${posMemInicial[$i]}" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%4s" "${posMemFinal[$i]}" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%-20s\n" "${estado[$i]}" >>salidacolor.txt
                    #printf "${colores[$i]} ${ordenEntrada[$i]}   ${entradaAuxiliar[$i]}    ${tejecucion[$i]}    ${tamemoryAuxiliar[$i]}   ${temp_wait[$i]}     ${temp_ret[$i]}    ${ejecucionAuxiliar[$i]}   ${posMemInicial[$i]}    ${posMemFinal[$i]}    ${estado[$i]}\n"
                elif [[ ${terminados[$i]} -eq 1 ]]; then
                    printf " ${colores[$i]}${ordenEntrada[$i]}" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%3s" "${entradaAuxiliar[$i]}" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%3s" "${tejecucion[$i]}" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%3s" "${tamemoryAuxiliar[$i]}" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%4s" "${temp_wait[$i]}" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%4s" "${temp_ret[$i]}" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%4s" "${ejecucionAuxiliar[$i]}" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%4s" "${posMemInicial[$i]}" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%4s" "${posMemFinal[$i]}" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%-20s\n" "${estado[$i]}" >>salidacolor.txt
                    #printf "${colores[$i]} ${ordenEntrada[$i]}   ${entradaAuxiliar[$i]}    ${tejecucion[$i]}    ${tamemoryAuxiliar[$i]}   ${temp_wait[$i]}     ${temp_ret[$i]}    ${ejecucionAuxiliar[$i]}   0    0    ${estado[$i]}\n"
                elif [[ ${enmemoria[$i]} -eq 1 ]] && [[ ${pausados[$i]} -eq 1 ]]; then
                    printf " ${colores[$i]}{ordenEntrada[$i]}" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%3s" "${entradaAuxiliar[$i]}" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%3s" "${tejecucion[$i]}" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%3s" "${tamemoryAuxiliar[$i]}" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%4s" "${temp_wait[$i]}" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%4s" "${temp_ret[$i]}" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%4s" "${ejecucionAuxiliar[$i]}" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%4s" "${posMemInicial[$i]}" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%4s" "${posMemFinal[$i]}" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%-20s\n" "${estado[$i]}" >>salidacolor.txt
                    #printf "${colores[$i]} ${ordenEntrada[$i]}   ${entradaAuxiliar[$i]}    ${tejecucion[$i]}    ${tamemoryAuxiliar[$i]}   ${temp_wait[$i]}     ${temp_ret[$i]}    ${ejecucionAuxiliar[$i]}   ${posMemInicial[$i]}    ${posMemFinal[$i]}      ${estado[$i]}\n"
                elif [[ ${enmemoria[$i]} -eq 1 ]] || [[ ${encola[$i]} -eq 1 ]]; then
                    printf " ${colores[$i]}${ordenEntrada[$i]}" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%3s" "${entradaAuxiliar[$i]}" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%3s" "${tejecucion[$i]}" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%3s" "${tamemoryAuxiliar[$i]}" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%4s" "${temp_wait[$i]}" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%4s" "${temp_ret[$i]}" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%4s" "${ejecucionAuxiliar[$i]}" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%4s" "${posMemInicial[$i]}" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%4s" "${posMemFinal[$i]}" >>salidacolor.txt
                    printf " " >>salidacolor.txt
                    printf "%-20s\n" "${estado[$i]}" >>salidacolor.txt
                    #printf "${colores[$i]} ${ordenEntrada[$i]}   ${entradaAuxiliar[$i]}    ${tejecucion[$i]}    ${tamemoryAuxiliar[$i]}   ${temp_wait[$i]}     ${temp_ret[$i]}    ${ejecucionAuxiliar[$i]}   ${posMemInicial[$i]}    ${posMemFinal[$i]}    ${estado[$i]}\n"
                fi

            done
            #echo "---------------------------------------------------------------------------------------------------------------------------------" >> salidacolor.txt
            if [[ $nprocT -eq 0 ]]; then
                printf "Tiempo Medio Espera = 0\t" >>salidacolor.txt
            else
                # total66=`echo $mediaTEspera / $nprocT | bc`
                # cecho $total66 $FRED
                printf 'Tiempo Medio Espera = %.2f\t' $((mediaTEspera / $nprocT)) >>salidacolor.txt
            fi
            if [[ $nprocR -eq 0 ]]; then
                printf "Tiempo Medio de Retorno = 0\n" >>salidacolor.txt
            else
                # total66=`echo $mediaTRetorno / $nprocR | bc`
                # cecho $total66 $FRED
                printf 'Tiempo Medio Retorno = %.2f\n' $((mediaTRetorno / $nprocR)) >>salidacolor.txt
            fi
            printf "\n" >>salidacolor.txt
            echo " " >>salidacolor.txt

            j=0
            k=0

            for ((i = 0; i < $nprocesos; i++)); do
                if [[ ${enmemoria[$i]} -eq 1 ]]; then
                    guardados[$j]=$i              #Se guardan en cada posición el número del proceso correspondiente <<<<<<<<<<<F A L L O?
                    coloresAux[$k]=${colores[$i]} #<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<F A L L O? Cambiar por k?
                    j=$(expr $j + 1)
                fi
                k=$(expr $k + 1)
            done

            j=0
            k=0

            if [[ "$partirImpresion" == "NO" ]]; then
                # Primera línea, en la que mostramos el nombre del proceso, por debajo de ella se encuentra la representación gráfica de la memoria
                printf "    |" >>salidacolor.txt
                for ((i = $posPrevia; i < ${#posMem[@]} - 1; i++)); do
                    if [[ "${posMem[$i]}" = "0" ]]; then
                        printf "   " >>salidacolor.txt
                    else
                        if [[ "${posMem[$i]}" != "${posMem[$i - 1]}" ]]; then
                            for ((t = 0; t < $nprocesos; t++)); do
                                if [[ "${posMem[$i]}" == "${ordenEntrada[$t]}" ]]; then
                                    colorProcesoAImprimir=${colores[$t]}
                                fi
                            done
                            printf "$colorProcesoAImprimir${posMem[$i]}" >>salidacolor.txt
                        else
                            printf "   " >>salidacolor.txt
                        fi
                    fi
                done

                printf "\n" >>salidacolor.txt

                col=0
                aux=0

                printf "$FWHT BM |" >>salidacolor.txt
                for ((i = $posPrevia; i < $mem_total; i++)); do
                    if [[ "${posMem[$i]}" == "0" ]]; then
                        printf "$blanco███" >>salidacolor.txt
                    else
                        colorProcesoAImprimir=""
                        for ((t = 0; t < $nprocesos; t++)); do
                            if [[ "${posMem[$i]}" == "${ordenEntrada[$t]}" ]]; then
                                colorProcesoAImprimir=${colores[$t]}
                            fi
                        done
                        printf "$colorProcesoAImprimir███" >>salidacolor.txt
                    fi
                done

                printf " $blanco$mem_total" >>salidacolor.txt
                printf "\n" >>salidacolor.txt

                memBMImprimir=0
                YA="NO"
                #Barra 3 - Posiciones de memoria dinales de cada proceso
                printf "$blanco    |" >>salidacolor.txt
                for ((i = 0; i < ${#posMem[@]} - 2; i++)); do #Sería -1 pero para cuadrar el valor final de la memoria, debemos de poner el -2. Sino sale descuadrado por una unidad = 3
                    for ((o = 0; o < $nprocesos; o++)); do
                        if [[ "${posMem[$i]}" == "${ordenEntrada[$o]}" ]]; then
                            procImprimir=$o
                        fi
                    done
                    if [[ $i -eq 0 ]]; then
                        printf "  0" >>salidacolor.txt
                    else
                        if [[ "${posMem[$i]}" == "0" ]]; then
                            if [[ "${posMem[$i]}" != "${posMem[$i - 1]}" && "$YA" = "NO" ]]; then
                                memBMImprimir=$((memBMImprimir + 1))
                                printf "%3s" "$memBMImprimir" >>salidacolor.txt
                                YA="SI"
                            else
                                memBMImprimir=$((memBMImprimir + 1))
                                printf "%3s" " " >>salidacolor.txt
                            fi
                        else
                            if [[ "${posMem[$i]}" == "${posMem[$i - 1]}" ]]; then
                                memBMImprimir=$((memBMImprimir + 1))
                                printf "   " >>salidacolor.txt
                            else
                                memBMImprimir=$((memBMImprimir + 1))
                                printf "%3s" "${posMemInicial[$procImprimir]}" >>salidacolor.txt
                                YA="NO"
                            fi
                        fi

                    fi
                done
            fi

            if [[ "$partirImpresion" == "SI" ]]; then
                saltos=0
                memRestante=$memAImprimir
                while [[ $memRestante -gt $columns ]]; do
                    memRestante=$(($memRestante - $columns))
                    saltos=$((saltos + 1))
                    #echo "memRestante = $memRestante -> saltos = $saltos"
                done
                memRestante=$(($memRestante - 3))
                memRestante=$(($memRestante / 3))

                columns1=$(($columns - 6))
                ggg=$(($columns1 % 3))
                if [[ $ggg -eq 0 ]]; then
                    longitud=$(($columns1 / 3))
                else
                    longitud=$(($columns1 / 3))
                    longitud=$(($longitud - 1))
                fi
                #echo "longitud = $longitud"

                temp1=0
                temp2=0
                temp3=0
                memBMImprimir=0
                YA="NO"
                lastIMM="0"

                for ((p = 0; p <= $saltos; p++)); do

                    if [[ $p -eq 0 ]]; then
                        printf "    |" >>salidacolor.txt
                    else
                        printf "     " >>salidacolor.txt
                    fi
                    if [[ $p -eq $saltos ]]; then
                        for ((i = 0; i < $memRestante; i++)); do
                            if [[ "${posMem[$temp1]}" = "0" ]]; then
                                printf "   " >>salidacolor.txt
                            else
                                if [[ "${posMem[$temp1]}" != "${posMem[$temp1 - 1]}" ]]; then
                                    for ((t = 0; t < $nprocesos; t++)); do
                                        if [[ "${posMem[$temp1]}" == "${ordenEntrada[$t]}" ]]; then
                                            colorProcesoAImprimir=${colores[$t]}
                                        fi
                                    done
                                    if ! [[ "${posMem[$temp1]}" == "1" ]]; then
                                        printf "$colorProcesoAImprimir${posMem[$temp1]}" >>salidacolor.txt
                                    fi
                                else
                                    printf "   " >>salidacolor.txt
                                fi
                            fi
                            temp1=$((temp1 + 1))
                        done
                    else
                        for ((i = 0; i < $longitud; i++)); do
                            if [[ "${posMem[$temp1]}" = "0" ]]; then
                                printf "   " >>salidacolor.txt
                            else
                                if [[ "${posMem[$temp1]}" != "${posMem[$temp1 - 1]}" ]]; then
                                    for ((t = 0; t < $nprocesos; t++)); do
                                        if [[ "${posMem[$temp1]}" == "${ordenEntrada[$t]}" ]]; then
                                            colorProcesoAImprimir=${colores[$t]}
                                        fi
                                    done
                                    if ! [[ "${posMem[$temp1]}" == "1" ]]; then
                                        printf "$colorProcesoAImprimir${posMem[$temp1]}" >>salidacolor.txt
                                    fi
                                else
                                    printf "   " >>salidacolor.txt
                                fi
                            fi
                            temp1=$((temp1 + 1))
                        done
                    fi

                    printf "\n" >>salidacolor.txt

                    col=0
                    aux=0
                    if [[ $p -eq 0 ]]; then
                        printf "$FWHT BM |" >>salidacolor.txt
                    else
                        printf "     " >>salidacolor.txt
                    fi

                    if [[ $p -eq $saltos ]]; then
                        for ((i = 0; i < $memRestante; i++)); do
                            if [[ "${posMem[$temp2]}" == "0" ]]; then
                                printf "$blanco███" >>salidacolor.txt
                            else
                                colorProcesoAImprimir=""
                                for ((t = 0; t < $nprocesos; t++)); do
                                    if [[ "${posMem[$temp2]}" == "${ordenEntrada[$t]}" ]]; then
                                        colorProcesoAImprimir=${colores[$t]}
                                    fi
                                done
                                printf "$colorProcesoAImprimir███" >>salidacolor.txt
                            fi
                            temp2=$((temp2 + 1))
                        done
                    else
                        for ((i = 0; i < $longitud; i++)); do
                            if [[ "${posMem[$temp2]}" == "0" ]]; then
                                printf "$blanco███" >>salidacolor.txt
                            else
                                colorProcesoAImprimir=""
                                for ((t = 0; t < $nprocesos; t++)); do
                                    if [[ "${posMem[$temp2]}" == "${ordenEntrada[$t]}" ]]; then
                                        colorProcesoAImprimir=${colores[$t]}
                                    fi
                                done
                                printf "$colorProcesoAImprimir███" >>salidacolor.txt
                            fi
                            temp2=$((temp2 + 1))
                        done
                    fi
                    if [[ $p -eq $saltos ]]; then
                        printf "%4s" "$mem_total" >>salidacolor.txt
                    fi
                    printf "\n" >>salidacolor.txt

                    #Barra 3 - Posiciones de memoria dinales de cada proceso
                    if [[ $p -eq 0 ]]; then
                        printf "$blanco    |" >>salidacolor.txt
                    else
                        printf "     " >>salidacolor.txt
                    fi

                    if [[ $p -eq $saltos ]]; then
                        for ((i = 0; i < $memRestante; i++)); do
                            for ((o = 0; o < $nprocesos; o++)); do
                                if [[ "${posMem[$temp3]}" == "${ordenEntrada[$o]}" ]]; then
                                    procImprimir=$o
                                fi
                            done
                            if [[ $p -eq 0 ]] && [[ $i -eq 0 ]]; then
                                printf "  0" >>salidacolor.txt
                            else
                                if [[ "${posMem[$temp3]}" = "0" ]]; then
                                    if [[ "${posMem[$temp3]}" != "${posMem[$temp3 - 1]}" ]]; then
                                        memBMImprimir=$((memBMImprimir + 1))
                                        printf "%3s" "$memBMImprimir" >>salidacolor.txt
                                    else
                                        memBMImprimir=$((memBMImprimir + 1))
                                        printf "%3s" " " >>salidacolor.txt
                                    fi
                                else
                                    if [[ "${posMem[$temp3]}" == "${posMem[$temp3 - 1]}" ]]; then
                                        memBMImprimir=$((memBMImprimir + 1))
                                        printf "%3s" " " >>salidacolor.txt
                                    else
                                        if ! [[ "$lastIMM" == "${posMemInicial[$procImprimir]}" ]]; then
                                            #statements
                                            memBMImprimir=$((memBMImprimir + 1))
                                            printf "%3s" "${posMemInicial[$procImprimir]}" >>salidacolor.txt
                                            lastIMM="${posMemInicial[$procImprimir]}"
                                        fi

                                    fi

                                fi

                            fi
                            temp3=$((temp3 + 1))
                        done
                    else
                        for ((i = 0; i < $longitud; i++)); do
                            for ((o = 0; o < $nprocesos; o++)); do
                                if [[ "${posMem[$temp3]}" == "${ordenEntrada[$o]}" ]]; then
                                    procImprimir=$o
                                fi
                            done
                            if [[ $p -eq 0 ]] && [[ $i -eq 0 ]]; then
                                printf "  0" >>salidacolor.txt
                            else
                                if [[ "${posMem[$temp3]}" = "0" ]]; then
                                    if [[ "${posMem[$temp3]}" != "${posMem[$temp3 - 1]}" ]]; then
                                        memBMImprimir=$((memBMImprimir + 1))
                                        printf "%3s" "$memBMImprimir" >>salidacolor.txt
                                    else
                                        memBMImprimir=$((memBMImprimir + 1))
                                        printf "%3s" " " >>salidacolor.txt
                                    fi
                                else
                                    if [[ "${posMem[$temp3]}" == "${posMem[$temp3 - 1]}" ]]; then
                                        memBMImprimir=$((memBMImprimir + 1))
                                        printf "%3s" " " >>salidacolor.txt
                                    else
                                        if ! [[ "$lastIMM" == "${posMemInicial[$procImprimir]}" ]]; then
                                            #statements
                                            memBMImprimir=$((memBMImprimir + 1))
                                            printf "%3s" "${posMemInicial[$procImprimir]}" >>salidacolor.txt
                                            lastIMM="${posMemInicial[$procImprimir]}"
                                        fi

                                    fi

                                fi

                            fi
                            temp3=$((temp3 + 1))
                        done
                    fi

                    printf "\n" >>salidacolor.txt

                done
            fi
            if [[ "$partirTiempo" == "NO" ]]; then
                echo " " >>salidacolor.txt
                printf "    |" >>salidacolor.txt
                for ((i = 0; i <= $tiempo; i++)); do
                    if [[ "${procTiempo[$i]}" == "0" ]]; then
                        printf "   " >>salidacolor.txt
                    else
                        if [[ "${procTiempo[$i]}" == "${procTiempo[$i - 1]}" ]]; then
                            printf "   " >>salidacolor.txt
                        else
                            for ((t = 0; t < $nprocesos; t++)); do
                                if [[ "${procTiempo[$i]}" == "${ordenEntrada[$t]}" ]]; then
                                    colorProcTiempo=${colores[$t]}
                                fi
                            done
                            printf "$colorProcTiempo${procTiempo[$i]}" >>salidacolor.txt
                            tocaImprimir[$i]=1
                        fi
                    fi
                done
                printf ""$blanco"" >>salidacolor.txt
                printf "\n" >>salidacolor.txt

                #Segunda linea

                printf " BT |" >>salidacolor.txt
                for ((i = 0; i <= $tiempo; i++)); do
                    if [[ "${procTiempo[$i]}" == "0" ]]; then
                        printf "$blanco███" >>salidacolor.txt
                    else
                        for ((t = 0; t < $nprocesos; t++)); do
                            if [[ "${procTiempo[$i]}" == "${ordenEntrada[$t]}" ]]; then
                                colorProcTiempo=${colores[$t]}
                            fi
                        done
                        printf "$colorProcTiempo███" >>salidacolor.txt
                    fi
                done
                printf ""$blanco"" >>salidacolor.txt
                printf "\n" >>salidacolor.txt

                #Tercera linea

                printf "    |" >>salidacolor.txt
                for ((i = 0; i < ${#posProcesoTiempo[@]}; i++)); do
                    if [[ $i -eq 0 ]]; then
                        printf "%3s" "$i" >>salidacolor.txt
                    else
                        if [[ ${tocaImprimir[$i]} -eq 0 ]]; then
                            printf "   " >>salidacolor.txt
                        else
                            if [[ ${tocaImprimir[$i]} -eq 1 ]]; then
                                printf "%3s" "${posProcesoTiempo[$i]}" >>salidacolor.txt
                            fi
                        fi
                    fi
                done
                echo " " >>salidacolor.txt
            fi
            if [[ "$partirTiempo" == "SI" ]]; then

                posPrevia=0
                tiempoRestante=$tamannoTiempo
                saltos=0

                #Determinamos el numero de saltos que tiene que realizar, completando el tamaño del terminal y dejando un espacio a la derecha
                while [[ $tiempoRestante -gt $columns ]]; do
                    tiempoRestante=$(($tiempoRestante - $columns))
                    saltos=$((saltos + 1))
                    #echo "memRestante = $memRestante -> saltos = $saltos"
                done
                tiempoRestante=$(($tiempoRestante - 3))
                tiempoRestante=$(($tiempoRestante / 3))

                columns1=$(($columns - 6))
                cgg=$(($columns1 % 3))
                if [[ $cgg -eq 0 ]]; then
                    longitud=$(($columns1 / 3))
                else
                    longitud=$(($columns1 / 3))
                    longitud=$(($longitud - 1))
                fi

                nblancos=$((${entradaAuxiliar[0]} + 1))
                nblancosImpresos=0
                temp1=0
                temp2=0
                temp3=0
                primera=0

                for ((p = 0; p <= $saltos; p++)); do
                    echo " " >>salidacolor.txt

                    if [[ $p -eq 0 ]]; then
                        printf "    |" >>salidacolor.txt
                    else
                        printf "     " >>salidacolor.txt
                    fi

                    if [[ $p -eq $saltos ]]; then
                        for ((i = 0; i < $tiempoRestante; i++)); do
                            if [[ "${procTiempo[$temp1]}" == "0" ]]; then
                                printf "%3s" " " >>salidacolor.txt
                            else
                                if [[ "${procTiempo[$temp1]}" == "${procTiempo[$temp1 - 1]}" ]]; then
                                    printf "%3s" " " >>salidacolor.txt

                                else
                                    for ((t = 0; t < $nprocesos; t++)); do
                                        if [[ "${procTiempo[$temp1]}" == "${ordenEntrada[$t]}" ]]; then
                                            colorProcTiempo=${colores[$t]}
                                        fi
                                    done

                                    printf "$colorProcTiempo${procTiempo[$temp1]}" >>salidacolor.txt
                                    ultimoImpresoTiempo="${procTiempo[$temp1]}"
                                    tocaImprimir[$temp1]=1
                                fi
                            fi
                            temp1=$((temp1 + 1))
                            impreso=$((impreso + 1))
                        done
                        if [[ "$ultimoImpresoTiempo" != "$procEnEjecucion" ]]; then
                            for ((t = 0; t < $nprocesos; t++)); do
                                if [[ "$procEnEjecucion" == "${ordenEntrada[$t]}" ]]; then
                                    colorProcTiempo=${colores[$t]}
                                fi
                            done
                            printf "$colorProcTiempo$procEnEjecucion" >>salidacolor.txt
                        fi
                    else
                        for ((i = 0; i < $longitud; i++)); do
                            if [[ "${procTiempo[$temp1]}" == "0" ]]; then
                                printf "%3s" " " >>salidacolor.txt
                            else
                                if [[ "${procTiempo[$temp1]}" == "${procTiempo[$temp1 - 1]}" ]]; then
                                    printf "%3s" " " >>salidacolor.txt

                                else
                                    for ((t = 0; t < $nprocesos; t++)); do
                                        if [[ "${procTiempo[$temp1]}" == "${ordenEntrada[$t]}" ]]; then
                                            colorProcTiempo=${colores[$t]}
                                        fi
                                    done

                                    printf "$colorProcTiempo${procTiempo[$temp1]}" >>salidacolor.txt
                                    tocaImprimir[$temp1]=1
                                    ultimoImpresoTiempo="${procTiempo[$temp1]}"
                                fi
                            fi
                            temp1=$((temp1 + 1))
                            impreso=$((impreso + 1))
                        done
                    fi
                    printf ""$blanco"" >>salidacolor.txt
                    printf "\n" >>salidacolor.txt

                    #Segunda linea

                    if [[ $p -eq 0 ]]; then
                        printf " BT |" >>salidacolor.txt
                    else
                        printf "      " >>salidacolor.txt
                    fi
                    if [[ $p -eq $saltos ]]; then
                        for ((i = 0; i < $tiempoRestante; i++)); do
                            if [[ "${procTiempo[$temp2]}" == "0" ]]; then
                                printf "$blanco███" >>salidacolor.txt
                                nblancosImpresos=$((nblancosImpresos + 1))
                                if [[ $nblancosImpresos -eq $nblancos+1 ]]; then
                                    primera=$(($saltos * $longitud + $i))
                                fi
                            else
                                for ((t = 0; t < $nprocesos; t++)); do
                                    if [[ "${procTiempo[$temp2]}" == "${ordenEntrada[$t]}" ]]; then
                                        colorProcTiempo=${colores[$t]}
                                    fi
                                done
                                printf "$colorProcTiempo███" >>salidacolor.txt
                            fi
                            temp2=$((temp2 + 1))
                        done
                        if [[ "$ultimoImpresoTiempo" != "$procEnEjecucion" ]]; then
                            for ((t = 0; t < $nprocesos; t++)); do
                                if [[ "$procEnEjecucion" == "${ordenEntrada[$t]}" ]]; then
                                    colorProcTiempo=${colores[$t]}
                                fi
                            done
                            printf "$colorProcTiempo███" >>salidacolor.txt
                            imprimirTiempoFinal=1
                        fi
                    else
                        for ((i = 0; i < $longitud; i++)); do
                            if [[ "${procTiempo[$temp2]}" == "0" ]]; then
                                printf "$blanco███" >>salidacolor.txt
                                nblancosImpresos=$((nblancosImpresos + 1))
                                if [[ $nblancosImpresos -eq $nblancos+1 ]]; then
                                    primera=$(($p * $longitud + $i))
                                fi
                            else
                                for ((t = 0; t < $nprocesos; t++)); do
                                    if [[ "${procTiempo[$temp2]}" == "${ordenEntrada[$t]}" ]]; then
                                        colorProcTiempo=${colores[$t]}
                                    fi
                                done
                                printf "$colorProcTiempo███" >>salidacolor.txt
                            fi
                            temp2=$((temp2 + 1))
                        done
                    fi
                    printf ""$blanco"" >>salidacolor.txt
                    printf "\n" >>salidacolor.txt

                    #Tercera linea
                    re='^[1-9]+$'

                    for ((i = $tiempoAnterior + 1; i <= $tiempo; i++)); do
                        if [[ $i -lt $tiempo ]]; then
                            posProcesoTiempo[$i]=0
                        else
                            posProcesoTiempo[$i]=$((tiempo))
                        fi
                        #echo $i
                    done

                    if [[ $p -eq 0 ]]; then
                        printf "    |" >>salidacolor.txt
                    else
                        printf "     " >>salidacolor.txt
                    fi
                    if [[ $p -eq $saltos ]]; then
                        for ((i = 0; i < $tiempoRestante; i++)); do
                            if [[ $i -eq 0 ]] && [[ $p -eq 0 ]]; then
                                printf "%3s" "$temp3" >>salidacolor.txt
                            else
                                if [[ ${tocaImprimir[$temp3]} -eq 0 ]]; then
                                    if [[ $temp3+1 -eq $primera ]]; then
                                        primera=$((primera - 1))
                                        printf "%3s" "$primera" >>salidacolor.txt
                                    else
                                        printf "   " >>salidacolor.txt
                                    fi
                                else
                                    if [[ ${tocaImprimir[$temp3]} -eq 1 ]]; then
                                        printf "%3s" "${posProcesoTiempo[$temp3]}" >>salidacolor.txt
                                    fi
                                fi
                            fi
                            temp3=$((temp3 + 1))
                        done
                        if [[ $imprimirTiempoFinal -eq 1 ]]; then
                            printf "%3s" "$tiempo" >>salidacolor.txt
                        fi
                    else
                        for ((i = 0; i < $longitud; i++)); do
                            if [[ $i -eq 0 ]] && [[ $p -eq 0 ]]; then
                                printf "%3s" "$temp3" >>salidacolor.txt
                            else
                                if [[ ${tocaImprimir[$temp3]} -eq 0 ]]; then
                                    if [[ $temp3+1 -eq $primera ]]; then
                                        primera=$((primera - 1))
                                        printf "%3s" "$primera" >>salidacolor.txt
                                    else
                                        printf "   " >>salidacolor.txt
                                    fi
                                else
                                    if [[ ${tocaImprimir[$temp3]} -eq 1 ]]; then
                                        printf "%3s" "${posProcesoTiempo[$temp3]}" >>salidacolor.txt
                                    fi
                                fi
                            fi
                            temp3=$((temp3 + 1))
                        done
                    fi
                done

                echo " " >>salidacolor.txt

            fi

        fi

    fi

    # ----------------------------------------------------------------
    # Incrementamos el contador de tiempos de ejecución y de espera
    # de los procesos y decrementamos el tiempo de ejecución que
    # tiene el proceso que se encuentra en ejecución.
    # ----------------------------------------------------------------
    for ((i = 0; i < $nprocesos; i++)); do #Bucle que añade los tiempos de espera y ejecución a cada proceso. También quita el segundo del tiempo de ejecución
        if [[ ${enejecucion[$i]} -eq 1 ]]; then
            ejecucionAuxiliar[$i]=$(expr ${ejecucionAuxiliar[$i]} - 1)
            temp_ret[$i]=$(expr ${temp_ret[$i]} + 1) #Sumamos aquí para evitar que en el ultimo segundo de ejecucion no se sume el segundo de retorno
        fi
    done

    #ESTADO DE CADA PROCESO
    #Modificamos los valores de los arrays, restando de lo que quede<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    #ESTADO DE CADA PROCESO EN EL TIEMPO ACTUAL Y HALLAMOS LAS VARIABLES.

    for ((i = 0; i < $nprocesos; i++)); do
        if [[ ${nollegado[$i]} -eq 1 ]]; then
            #estado[$i]="No ha llegado"
            temp_wait[$i]=$(expr ${temp_wait[$i]} + 0) #No hace falta poner la suma, es solo para una mejor interpretación
        fi

        if [[ ${encola[$i]} -eq 1 ]] && [[ ${bloqueados[$i]} -eq 1 ]]; then
            #estado[$i]="Bloqueado"
            temp_wait[$i]=$(expr ${temp_wait[$i]} + 1)
            temp_ret[$i]=$(expr ${temp_ret[$i]} + 1)
        fi

        if [[ ${enmemoria[$i]} -eq 1 ]] && [[ ${enejecucion[$i]} -eq 1 ]]; then
            #estado[$i]="En ejecucion"
            temp_wait[$i]=$(expr ${temp_wait[$i]} + 0)
            #temp_ret[$i]=`expr ${temp_ret[$i]} + 1`   #Si está en ejecución se suma anteriormente.
        elif [[ ${enmemoria[$i]} -eq 1 ]] && [[ ${pausados[$i]} -eq 1 ]]; then
            #estado[$i]="Pausado"
            temp_wait[$i]=$(expr ${temp_wait[$i]} + 1)
            temp_ret[$i]=$(expr ${temp_ret[$i]} + 1)
        elif [[ ${enmemoria[$i]} -eq 1 ]]; then
            #estado[$i]="En memoria"
            temp_wait[$i]=$(expr ${temp_wait[$i]} + 1)
            temp_ret[$i]=$(expr ${temp_ret[$i]} + 1)
        fi

        if [[ ${terminados[$i]} -eq 1 ]]; then
            #estado[$i]="Terminado"
            temp_wait[$i]=$(expr ${temp_wait[$i]} + 0) #No hace falta poner la suma, es solo para una mejor interpretación
        fi
    done

    #Ponemos todas las posiciones del vector enejecucion a 0, se establecerá qué proceso está a 1 en cada ciclo del programa.

    for ((i = 0; i < $nprocesos; i++)); do
        bloqueados[$i]=0 #También se establecen los procesos bloqueados en cada ciclo.
    done
    if [[ ${evento[$tiempo]} -eq 1 && $enterLuego -eq 1 ]]; then
        cecho " Pulse enter para continuar..." $FWHT
        read enter
    fi
    enterLuego=0

    # Incrementamos el reloj
    tiempo=$(expr $tiempo + 1)

done

# -----------------------------------------------------------------------------
#             F I N       D E L       B U C L E
# -----------------------------------------------------------------------------
tiempofinal=$(expr $tiempo - 1)
echo " "
cecho " Tiempo: $tiempofinal  " $FYEL
cecho " Ejecución terminada." $FMAG
cecho "-----------------------------------------------------------" $FRED
echo " "

echo " "
echo "procTiempo - ${procTiempo[$temp3]} -> procEnEjecucion - $procEnEjecucion" >impresion.txt
for ((i = 0; i < ${#procTiempo[@]} / 3; i++)); do
    echo "$i - ${procTiempo[$i]}" >>impresion.txt
done
#Ahora lo metemos en el fichero

echo " " >>salida.txt
echo " Tiempo: $tiempofinal  " >>salida.txt
echo " Ejecución terminada." >>salida.txt
echo "-----------------------------------------------------------" >>salida.txt
echo " " >>salida.txt

echo " " >>salidacolor.txt
cecho " Tiempo: $tiempofinal  " $FYEL >>salidacolor.txt
cecho " Ejecución terminada." $FMAG >>salidacolor.txt
cecho "-----------------------------------------------------------" $FRED >>salidacolor.txt
echo " " >>salidacolor.txt

echo " "

cecho " Final del proceso, puede consultar la salida en el fichero salida.txt" $FMAG
echo " "
cecho " Pulse enter para las opciones de visualización del fichero salida.txt..." $FWHT
read enter

clear
cecho " -----------------------------------------------------" $FRED
cecho "          V I S U A L I Z A C I Ó N " $FYEL
cecho " -----------------------------------------------------" $FRED
cecho " 1) Leer el fichero salida.txt en el terminal" $FYEL
cecho " 2) Leer el fichero salida.txt en el editor gedit" $FYEL
cecho " 3) Leer el fichero salidacolor.txt en el terminal" $FYEL
cecho " 4) Salir y terminar" $FYEL
cecho " -----------------------------------------------------" $FRED
cecho " "
cecho " Introduce una opcion: "

num=0
continuar="SI"

while [ $num -ne 4 ] && [ "$continuar" == "SI" ]; do
    read num
    case $num in
    "1")
        cat salida.txt
        exit 0
        ;;

    "2")
        gedit salida.txt
        exit 0
        ;;

    "3")
        cat salidacolor.txt
        exit 0
        ;;

    "4")
        exit 0
        ;;
    *)
        num=0
        cecho "Opción errónea, vuelva a introducir:" $FRED
        ;;
    esac
done
