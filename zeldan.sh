#!/bin/bash

# Cargamos funciones utilitarias
source ./scripts/util.sh

# Declaracion de variable utilitarias referencias a ficheros y directorios
declare -r DIRECTORIO_DATOS="./datos/"
declare -r NOMBRE_FICHERO_DATOS_DEFECTO="datos.txt"
declare -r RUTA_FICHERO_DATOS_DEFECTO=${DIRECTORIO_DATOS}${NOMBRE_FICHERO_DATOS_DEFECTO}

declare -r DIRECTORIO_RANGOS="./rangos/"
declare -r NOMBRE_FICHERO_RANGOS_DEFECTO="datosrangos.txt"
declare -r RUTA_FICHERO_RANGOS_DEFECTO=${DIRECTORIO_RANGOS}${NOMBRE_FICHERO_RANGOS_DEFECTO}

declare -r DIRECTORIO_REPORTES="./informes/"
declare -r NOMBRE_FICHERO_REPORTES_COLOR="informeCOLOR.txt"
declare -r NOMBRE_FICHERO_REPORTES_NEGRO="informeBN.txt"
declare -r RUTA_FICHERO_REPORTES_NEGRO=${DIRECTORIO_REPORTES}${NOMBRE_FICHERO_REPORTES_NEGRO}
declare -r RUTA_FICHERO_REPORTES_COLOR=${DIRECTORIO_REPORTES}${NOMBRE_FICHERO_REPORTES_COLOR}

#Constantes
declare -r EN_MEMORIA="En Memoria"
declare -r EN_EJECUCION="En Ejecucion"
declare -r EN_ESPERA="En Espera"
declare -r TERMINADO="Terminado"
declare -r FUERA_SISTEMA="Fuera del Sistema"
declare -r EN_PAUSA="En Pausa"

#Colores
#Fin de color
declare -r NC='\e[0m'        # no color
declare -r _DEFAULT='\e[49m' #Color por defecto
#Colores de texto
declare -r RED='\e[31m'
declare -r GREEN='\e[32m'
declare -r YELLOW='\e[33m'
declare -r BLUE='\e[34m'
declare -r MAGENTA='\e[35m'
declare -r CYAN='\e[36m'
declare coloresLetras=("$RED" "$GREEN" "$YELLOW" "$BLUE" "$MAGENTA" "$CYAN")

#Colores de FONDO:
declare -r _RED='\e[41m'
declare -r _GREEN='\e[42m'
declare -r _YELLOW='\e[43m'
declare -r _BLUE='\e[44m'
declare -r _MAGENTA='\e[45m'
declare -r _CYAN='\e[46m'
declare coloresFondo=("$_RED" "$_GREEN" "$_YELLOW" "$_BLUE" "$_MAGENTA" "$_CYAN")

#Datos Entrada (describen el proceso)
declare memTotal=0
declare nombreProceso=()
declare tiempoLlegada=()
declare tiempoEjecucion=()
declare memProceso=()

#Calculos En cuanto a procesos
declare colorFondoProceso=() #array con los colores de cada proceso
declare colorProceso=()      #array con los colores de cada proceso
declare estadoProc=()        # array que almacena el estatus actual de cada proceso "strings"
declare tRestante=()         #Tiempo restante hasta que finalice cada proceso, inicialmente el tiempo de CPU que necesite
declare tEspera=()           #Resultado: Tiempo de espera del proceso, inicialmente "Fueradelsistema"
declare tRetorno=()          #Resultado: Tiempo de retorno del proceso, inicialmente "Fueradelsistema"
declare posMemInicial=()     #Resultado: Valor de t cuando inicia el proceso, inicialmente "Fueradelsistema"
declare posMemFinal=()       #Resultado: Valor de t cuando termina el proceso, inicialmente "Fueradelsistema"
declare memLibre=-1          #variable auxiliar para calcular en todo momento la memoria libre
declare numeroProcesos=0
tEsperaMedio=0
tRetornoMedio=0
declare lineaTemporal=() # Array utilizado para pintar la  varra de tiempos en el resumen

declare formaVolcado           # flag para almacenar la forma de volcado seleccionada
declare volcadoAtomaticoTiempo # flag para almacenar unidad de tiempo de volcado
declare tiempoEsperaVolcado    # almacenar tiempo de espera entre volcados

declare nombreficheroGruadarDatos

#Array que almacena las posiciones de memorias utilizadas -1=posicion no utilizada Cualquier otro numero indica el numero de proceso que ocupa esa posicion
# su largo es igual al tamano de la memoria total
declare bloquesMemoria=()

function inicializaVariables() {
    local i
    local j
    local numeroColor=0

    memLibre=$memTotal                  # en el instante 0 la memoria libre es igual a la memoria total
    numeroProcesos=${#nombreProceso[@]} # almacenamos en una variable el numero de proceso total

    for i in $(seq 0 $((numeroProcesos - 1))); do

        estadoProc[$i]="$FUERA_SISTEMA"      # todos los proceso inician en el estado "fuera del sistema"
        tEspera[$i]="-"                      # al inicio ponemos un "-" para indicar que aun no ha entrado ese proceso
        tRetorno[$i]="-"                     # al inicio ponemos un "-" para indicar que aun no ha entrado ese proceso
        posMemInicial[$i]="-"                # al inicio ponemos un "-" para indicar que aun no ha entrado ese proceso
        posMemFinal[$i]="-"                  # al inicio ponemos un "-" para indicar que aun no ha entrado ese proceso
        tRestante[$i]=${tiempoEjecucion[$i]} # iniciamos los tiempos restantes con el mismo valor de tiempos de ejecucion

        # Seteamos el color con uno de los que tenemos disponible en el array
        if [[ numeroColor -ge $((${#coloresLetras[@]} - 1)) ]]; then
            numeroColor=0 #reset de color
        else
            numeroColor=$((numeroColor + 1))
        fi
        colorProceso[$i]=${coloresLetras[$numeroColor]}
        colorFondoProceso[$i]=${coloresFondo[$numeroColor]}
    done

    for j in $(seq 0 $((memTotal - 1))); do
        bloquesMemoria[$j]=-1 # -1 indica posicion no utilizada
    done
}

# Nombre ordenaPorTiempoLLegada
# Descripcion: Ordena los procesos por tiempo de llegada mediante el algoritmo de ordenacion por seleccion.
function ordenaPorTiempoLLegada() {
    local i
    local j
    local aux
    local menor
    local tam
    tam=${#nombreProceso[@]}

    for i in $(seq 0 $((tam - 1))); do
        menor=$i
        for j in $(seq $((i + 1)) $((tam - 1))); do
            if [ "${tiempoLlegada[$menor]}" -gt "${tiempoLlegada[$j]}" ]; then
                menor=$j
            fi
        done
        aux=${nombreProceso[$menor]}
        nombreProceso[$menor]=${nombreProceso[$i]}
        nombreProceso[$i]=$aux

        aux=${memProceso[$menor]}
        memProceso[$menor]=${memProceso[$i]}
        memProceso[$i]=$aux

        aux=${tiempoLlegada[$menor]}
        tiempoLlegada[$menor]=${tiempoLlegada[$i]}
        tiempoLlegada[$i]=$aux

        aux=${tiempoEjecucion[$menor]}
        tiempoEjecucion[$menor]=${tiempoEjecucion[$i]}
        tiempoEjecucion[$i]=$aux

        aux=${colorProceso[$menor]}
        colorProceso[$menor]=${colorProceso[$i]}
        colorProceso[$i]=$aux

        aux=${colorFondoProceso[$menor]}
        colorFondoProceso[$menor]=${colorFondoProceso[$i]}
        colorFondoProceso[$i]=$aux
    done
}

#####CALCULOS ALGORITMO

function lleganProcesos() {
    local i
    local t=$1 #tiempo de ejecucion actual del programa

    for ((i = 0; i < numeroProcesos; i++)); do
        if [[ "${tiempoLlegada[$i]}" == "$t" ]]; then
            haHabidoUnCambio=0
            estadoProc[$i]="$EN_ESPERA"
            tEspera[$i]=0
            tRetorno[$i]=0
            msg+=("Ha llegado el proceso ${nombreProceso[$i]} y espera entrar en la MP")
        fi
    done
}

# Nombre: vaciarMemoria
# Funcinamiento: Vacía la memoria, o la pone en su estado por defecto.
function vaciarMemoria() {
    local i
    for ((i = 1; i <= memTotal; i++)); do
        bloquesMemoria[$i]=-1
        bloquesMemoria[$i]=-1
    done
}

function encontrarHuecoEnMemoria() {
    local i
    local memoriaProcesoActual=$1                     # tamano de memoria del proceso que se quiere introducir
    local numeroPosicionesMemoriaLibresConsecutivas=0 # Contador de posiciones vacias consecutivas
    local posicionInicioMemoria=-1                    # variable utilizaria almacen temporal de la posicion inical de memoria
    local -i cabeEnMemoria=-1                         # flag que indica si el se encontraron suficientes espacios para meter el proceso -1 = false 0= true

    for i in $(seq 0 $((${#bloquesMemoria[@]} - 1))); do
        if [[ ${bloquesMemoria[$i]} -eq -1 ]]; then #-1 indica que el hueco esta vacio

            ((numeroPosicionesMemoriaLibresConsecutivas++))

            if [[ $posicionInicioMemoria -eq -1 ]]; then # -1 indica que no se ha seteado ninguna posicion como la inicial
                posicionInicioMemoria=$i
            fi

            if [[ $numeroPosicionesMemoriaLibresConsecutivas -eq $memoriaProcesoActual ]]; then
                cabeEnMemoria=0 # flag que nos indica que este proceso si cabe en memoria
                break           #Salimos del bucle ya que el proceso pudo encontrar espacio consecutivo suficiente
            fi
        else # El proceso no cabe completo en los espacios vacios consecutivos, reiniciamos conteo
            numeroPosicionesMemoriaLibresConsecutivas=0
            posicionInicioMemoria=-1
        fi
    done

    if [[ $cabeEnMemoria -eq 0 ]]; then
        echo $posicionInicioMemoria
    else
        echo -1 # no cabe en los espacios consecutibos necesitamos rehubicar
    fi
}

function cargaEnMP() {
    #hacemos que las variables de los buques sean locales ya que si no son globales y conservan su valor para todas las demas funciones
    local i
    local j
    local h
    local k
    local t=$1                                        #tiempo de ejecucion actual del programa
    local numeroPosicionesMemoriaLibresConsecutivas=0 # Contador de posiciones vacias consecutivas
    local posicionInicioMemoria=-1                    # variable utilizaria almacen temporal de la posicion inical de memoria
    local ultimoIndiceEncontrado="/"                  # variable utilizaria almacen temporal de la posicion de memoria a rehubicar

    # Buffer destinado a guardar los elementos que se encuentran en este momento en memoria
    # Almacenará: Un puntero a la fila de la tabla correspondiente a cada proceso
    # Leerá dicho puntero/indice de la tabla de memoria, de la capa MEM_INDICE
    local bufferReubicacion

    for ((i = 0; i < numeroProcesos; i++)); do

        #Solo intentamos introducir en memoria los procesos en estado = en espera
        if [[ "${estadoProc[$i]}" == "$EN_ESPERA" ]]; then

            #si hay suficiente memoria introduzco el proceso
            if [[ "$memLibre" -ge "${memProceso[$i]}" ]]; then

                ####################
                # Intentamos hubicar el proceso en algun hueco en la memoria
                ####################

                posicionInicioMemoria=$(encontrarHuecoEnMemoria "${memProceso[$i]}")

                ####################
                #### Rehubicar Memoria
                ####################
                if [[ $posicionInicioMemoria -eq -1 ]]; then # -1 indica que no se ha seteado ninguna posicion como la inicial

                    #Almacenamos los procesos que están en memoria
                    for j in $(seq 0 $((${#bloquesMemoria[@]} - 1))); do
                        #Si el índice que hay en i posición de memoria NO es NI el indice vacío, ni el último indice encontrado, guardamos el índice en un array
                        if [[ ${bloquesMemoria[$j]} != "$ultimoIndiceEncontrado" ]] && [[ ${bloquesMemoria[$j]} != -1 ]]; then
                            bufferReubicacion+=("${bloquesMemoria[$j]}") #Guardamos el proceso que encotramos en un array
                            ultimoIndiceEncontrado=${bloquesMemoria[$j]}
                        fi
                    done

                    vaciarMemoria

                    local -i ultimaPosicionMemoria=0 #Variable que almacenará la última posición en la que se ha "creado" memoria

                    #Rellenamos la memoria!
                    for indice in "${bufferReubicacion[@]}"; do

                        posMemInicial[$indice]=$ultimaPosicionMemoria #actualizamos la posicion inicial para este proceso reubicado

                        #Para i iteraciones siendo i = tamaño del proceso
                        for ((k = 0; k < ${memProceso[$indice]}; k++)); do
                            #añadimos el indice
                            bloquesMemoria[$ultimaPosicionMemoria]=$indice

                            if ((ultimaPosicionMemoria > memTotal)); then
                                echo "Colega, tenemos un problemón en reubicarProcesos(), te has salido del array de memoria"
                                return 1
                            fi
                            ((ultimaPosicionMemoria++))
                        done
                        posMemFinal[$indice]=$((ultimaPosicionMemoria - 1)) #actualizamos la ultima posicion para este proceso reubicado
                        # Decimos que la ultima posicion luego de la reubicacion sera el punto de inicio de la siguiente asignacion
                        # ojo: asumimos que en este punto la memoria cabe en los espacios libres restantes
                        posicionInicioMemoria=$ultimaPosicionMemoria
                    done
                fi

                ####################
                ## Rellenamos array bloques memoria y variables de estado con la nueva posicion
                ####################
                local ultimaPosicionMemoriaProceso=$((posicionInicioMemoria + ${memProceso[$i]}))

                #Rellenamos bloques de memoria desde la posicion inicial previamente calculada
                for ((h = posicionInicioMemoria; h < ultimaPosicionMemoriaProceso; h++)); do
                    #añadimos el indice
                    bloquesMemoria[$h]=$i

                    if [[ $h -gt $memTotal ]]; then
                        echo "Amigo, tenemos un problemón en la función aniadirAMemoria(), has añadido a más memoria de la existente || PROGRAMACIÓN DEFENSIVA"
                        return 1
                    fi
                done

                # guardamos posiciones en el array de posiciones y actualizamos estados
                posMemInicial[$i]=$posicionInicioMemoria
                posMemFinal[$i]=$((ultimaPosicionMemoriaProceso - 1))
                estadoProc[$i]="$EN_MEMORIA"
                memLibre=$((memLibre - ${memProceso[$i]}))

                # Guardamos mensaje
                msg+=("$(printf "%s %s %s %d\n" "El proceso" "${nombreProceso[$i]}" "ha sido introducido en memoria en el instante" "$tiempo")")

                haHabidoUnCambio=0
            fi

        fi
    done
}

# Nombre: srptAlgorithm
# Descripcion   : Algoritmo SRPT para saber el siguiente proceso a ejecutar.
function srptAlgorithm() {
    local i
    local aux1=$procesoEjecucion #Variable auxiliar que almacena el actual proceso :en ejecución

    for ((i = 0; i < numeroProcesos; i++)); do
        #Solo intentamos introducir en memoria los procesos en estado = en memoria o en pausa
        if [[ "${estadoProc[$i]}" == "$EN_MEMORIA" ]] || [[ "${estadoProc[$i]}" == "$EN_PAUSA" ]]; then
            if [[ "$procesoEjecucion" = -1 ]]; then #Si no hay ninguno en ejecución
                procesoEjecucion=$i                 #Se asigna
            elif [[ "${tRestante[$i]}" -lt "${tRestante[$procesoEjecucion]}" ]]; then
                #Sino se comprueba si el proceso tiene menor tiempo de ejecución que el que se esta ejecutando
                estadoProc[$procesoEjecucion]="$EN_PAUSA" #El proceso en ejecucion pasa a en pausa
                procesoEjecucion=$i                       # el proceso i pasa a ejecucion
            fi
        fi
    done

    if test "$procesoEjecucion" != "$aux1" -a "$procesoEjecucion" != -1; then
        #Si ha habido cambios y hay un nuevo proceso en ejecución
        haHabidoUnCambio=0
        estadoProc[$procesoEjecucion]="$EN_EJECUCION"
        tRestante[$procesoEjecucion]="${tiempoEjecucion[$procesoEjecucion]}"
        #se guarda mensaje de evento
        msg+=("El proceso ${nombreProceso[$procesoEjecucion]} se hace con el control de la CPU y comienza a ejecutarse")
    fi
}

function liberarMemoria() {
    local i
    local -i estabaEnMemoria=0

    for i in $(seq 0 $((${#bloquesMemoria[@]} - 1))); do
        if [[ ${bloquesMemoria[$i]} -eq $procesoEjecucion ]]; then #-1 indica que el hueco esta vacio
            estabaEnMemoria=1
            bloquesMemoria[$i]=-1
        fi
    done

    if ((estabaEnMemoria == 1)); then
        #El proceso cambia su estado a finalizado
        estadoProc[$procesoEjecucion]="$TERMINADO"
        posMemInicial[$procesoEjecucion]="-"
        posMemFinal[$procesoEjecucion]="-"

        memLibre=$((memLibre + ${memProceso[$procesoEjecucion]}))
    fi
}

# Nombre: comprobarSiElProcesoEnCPUHaTerminado
# Descripción: Si un proceso ha termiando en CPU -> Actualiza su línea en la tabla y lo saca de CPU y memoria
function comprobarSiProcesoATerminado() {
    if [[ ${tRestante[$procesoEjecucion]} -eq 0 ]]; then
        #Libera su particion de memoria:
        liberarMemoria
        #Bandera se activa y se guarda mensaje de evento
        haHabidoUnCambio=0
        msg+=("El proceso ${nombreProceso[$procesoEjecucion]} ha terminado de ejecutarse")
        #Abandona procesador
        procesoEjecucion=-1
        #numProcFin	se incrementa en uno
        numeroProcesosFinalizados=$((numeroProcesosFinalizados + 1))
    fi

}

function calculaTiempos() {
    local i
    for i in $(seq 0 $((numeroProcesos - 1))); do
        #Incremento de ESPERA y tiempo de retorno = tiempo espera
        if [[ ${estadoProc[$i]} == "$EN_MEMORIA" ]] || [[ ${estadoProc[$i]} == "$EN_ESPERA" ]]; then
            if [[ ${tEspera[$i]} == "-" ]]; then
                tEspera[$i]=1
            else
                tEspera[$i]=$((${tEspera[$i]} + 1))
            fi
            tRetorno[$i]=${tEspera[$i]}
        fi
        #Incremento de tiempos cuando un proceso está en pausa
        if [[ ${estadoProc[$i]} == "$EN_PAUSA" ]]; then
            if [[ ${tEspera[$i]} == "-" ]]; then
                tEspera[$i]=1
            else
                tEspera[$i]=$((${tEspera[$i]} + 1))
            fi
            if [[ ${tRetorno[$i]} == "-" ]]; then
                tRetorno[$i]=1
            else
                tRetorno[$i]=$((${tRetorno[$i]} + 1))
            fi
        fi
        #Incremento de retorno durante la ejecución
        if [[ ${estadoProc[$i]} == "$EN_EJECUCION" ]]; then
            if [[ ${tRetorno[$i]} == "-" ]]; then
                tRetorno[$i]=1
            else
                tRetorno[$i]=$((${tRetorno[$i]} + 1))
            fi
        fi
    done
}

function calculoTiemposMedios() {
    #TIEMPOS MEDIOS
    local sumaEsp=0 #Sumatorio de los tiempos de espera de cada proceso
    local sumaRet=0 #Sumatorio de los tiempos de respuesta de cada proceso
    local procmem=0 #Numero de procesos que están en ejecución o en memoria

    for ((i = 0; i < numeroProcesos; i++)); do
        if [[ ${estadoProc[$i]} != "$FUERA_SISTEMA" ]]; then
            sumaEsp=$((sumaEsp + ${tEspera[$i]}))
            sumaRet=$((sumaRet + ${tRetorno[$i]}))
            procmem=$((procmem + 1))
        fi
    done

    if [[ $procmem -ne 0 ]]; then
        tEsperaMedio2=$((sumaEsp / procmem))
        tEsperaMedio=$(echo "scale=2;$sumaEsp/$procmem" | bc)
        if [[ $tEsperaMedio2 -eq 0 ]]; then
            if [[ "$tEsperaMedio" != "0" ]]; then
                tEsperaMedio="0$tEsperaMedio"
            fi
        fi
        tRetornoMedio2=$(($sumaRet / $procmem))
        tRetornoMedio=$(echo "scale=2;$sumaRet/$procmem" | bc)
        if [[ $tRetornoMedio2 -eq 0 ]]; then
            if [[ "$tRetornoMedio" != "0" ]]; then
                tRetornoMedio="0$tRetornoMedio"
            fi
        fi
    else
        tEsperaMedio=0
        tRetornoMedio=0
    fi
}

function mainAlgoritmo() {
    local tiempo=0 # tiempo actual de ejecucion del programa
    local contadorAutomatioco
    numeroProcesosFinalizados=0
    procesoEjecucion=-1 # varible auxiliar que almacena el proceso que se esta ejecutando en el instante actual
    haHabidoUnCambio=-1 #indicador que utilizamos para saber cuando hay a ocurrido un evento y pintar la tabla
    msg=()              #array utilitario que almacena los mensajes producidos en un determinado cilco de cpu

    contadorAutomatioco=$volcadoAtomaticoTiempo
    while [[ $numeroProcesosFinalizados -ne $numeroProcesos ]]; do
        msg=() # Vaciamos los posibles mensajes antiguos

        #Si hay proceso en ejecucion
        if [[ "$procesoEjecucion" != -1 ]]; then
            #actualizamos tiempo restante del proceso en ejecucion
            tRestante[$procesoEjecucion]=$((${tRestante[$procesoEjecucion]} - 1))
            comprobarSiProcesoATerminado
        fi

        #Comrpobar qué procesos entran a la tabla de procesos (procesos  nuevos "n")
        lleganProcesos "$tiempo"
        #Comprobar qué procesos nuevos entran a MP (procesos listos "r"), FIFO
        cargaEnMP "$tiempo"
        #Comprobar qué proceso listo entra a CPU (proceso en ejecucion "x") mediante SRPT
        srptAlgorithm

        actualizaLineaTiempo "$tiempo" # Array utilizado para pintar la  varra de tiempos en el resumen

        # imprimimos la visualizacion dependiendo de la opcion de volcado
        case "${formaVolcado}" in
        "POR_EVENTOS")
            #Si ha habido un cambio/evento en el estado de algún proceso -> Salida por pantalla
            if [[ $haHabidoUnCambio -ne -1 ]] || [[ $tiempo -eq 0 ]]; then
                imprimirTablaProcesos "$tiempo" | tee -a "$RUTA_FICHERO_REPORTES_COLOR"
                #Esperar interaccion del usuario
                read -ers -p "Pulse [enter] para continuar "
                clear
            fi
            ;;
        "AUTOMATICO")
            #Si ha habido un cambio/evento en el estado de algún proceso -> Salida por pantalla
            if [[ $haHabidoUnCambio -ne -1 ]] || [[ $tiempo -eq 0 ]]; then
                imprimirTablaProcesos "$tiempo" | tee -a "$RUTA_FICHERO_REPORTES_COLOR"
                #Esperar interaccion del usuario
                sleep $tiempoEsperaVolcado
                clear
            fi
            ;;
        "TIEMPO")
            #Imprimimos
            if [[ $tiempo -eq $contadorAutomatioco ]]; then
                imprimirTablaProcesos "$tiempo" | tee -a "$RUTA_FICHERO_REPORTES_COLOR"
                contadorAutomatioco=$((contadorAutomatioco + volcadoAtomaticoTiempo))
                #Esperar interaccion del usuario
                read -ers -p "Pulse [enter] para continuar "
            fi
            clear
            ;;
        "COMPLETO")
            #Si ha habido un cambio/evento en el estado de algún proceso -> Salida por pantalla
            if [[ $haHabidoUnCambio -ne -1 ]] || [[ $tiempo -eq 0 ]]; then
                imprimirTablaProcesos "$tiempo" | tee -a "$RUTA_FICHERO_REPORTES_COLOR"
            fi
            ;;
        *)
            echo "Algo a ido mal en el volcado de datos!! :("
            exit 0
            ;;
        esac

        #aumenta el tiempo de espera de los procesoso en memoria y en cola
        calculaTiempos
        calculoTiemposMedios

        tiempo=$((tiempo + 1)) #incrementamos el tiempo, para ejecutar el siguiente ciclo
        haHabidoUnCambio=-1    #resetemos flag
    done
}

function actualizaLineaTiempo() {
    local tiempo=$1

    lineaTemporal[$tiempo]=-1

    for ((i = 0; i < numeroProcesos; i++)); do
        if [[ ${estadoProc[$i]} == "$EN_EJECUCION" ]]; then
            lineaTemporal[$tiempo]=$i # solo puede estar un unico proceso en ejecucion en cada ciclo lo alamacenamos en aray
            break
        fi
    done
}

# Nombre: imprimeCabeceraTablaProcesos
# Descripcion: imprime por pantalla la cabecera de la tabla de resultados
# @param $1: valor del tiempo actual de ejecucion del programa
function imprimeCabeceraTablaProcesos() {
    printf "\n"
    local tiempo=$1
    echo "-- SRPT-SN-C-R --"
    imprimeMensajesEventos
    printf " T = %d          MT = %d\n" "$tiempo" "$memTotal"
    printf " ┌─────┬─────┬─────┬─────┬──────┬──────┬──────┬──────┬──────┬──────────────────────┐\n"
    printf " │ Ref │ Tll │ Tej │ Mem │ Tesp │ Tret │ Trej │ Mini │ Mfin │ ESTADO               │\n"
    printf " ├─────┼─────┼─────┼─────┼──────┼──────┼──────┼──────┼──────┼──────────────────────┤\n"

}

# Nombre: imprimePieTablaProcesos
# Descripcion: imprime por pantalla el pie de la tabla de resultados
# @param $1: valor del tiempo medio de espera a imprimier
# @param $2: valor del tiempo medio de retorno a imprimier
function imprimePieTablaProcesos() {
    local tiempoMedioEspera=$1
    local tiempoMedioRetorno=$2

    printf " └─────┴─────┴─────┴─────┴──────┴──────┴──────┴──────┴──────┴──────────────────────┘\n"
    printf " Tiempo Medio Espera = %.2f\t" "$tiempoMedioEspera"
    printf " Tiempo Medio Retorno = %.2f\n" "$tiempoMedioRetorno"
}

function imprimeMensajesEventos() {
    local i
    for ((i = 0; i < ${#msg[*]}; i++)); do
        echo -e " * ${msg[$i]}"
    done
}

# @param $1: estado del proceso actual
# @param $2: valor del tiempo restante que se desea imprimir
function imprimeTiempoRestante() {
    local estadoProceso=${1}
    local tiempoRes="${2}"

    #Para estos casos necesitamos imprimir "-" en lugar de su valor
    if [[ "$estadoProceso" == "$FUERA_SISTEMA" ]] || [[ "$estadoProceso" == "$TERMINADO" ]]; then
        tiempoRes="-"
    fi
    echo "$tiempoRes"
}

# Nombre: imprimeProcesos
# Descripcion: imprime por pantalla los procesos
function imprimeProcesos() {
    local i
    local tiempoRestante

    for ((i = 0; i < numeroProcesos; i++)); do
        tiempoRestante=$(imprimeTiempoRestante "${estadoProc[$i]}" "${tRestante[$i]}") # corregimos el valore del tiempo restante
        color=${colorProceso[$i]}
        printf " │ ${color}%3s${NC}" "${nombreProceso[$i]}"                                                                                    #nombre del proceso
        printf " │ ${color}%3s${NC} │ ${color}%3s${NC} │ ${color}%3s${NC}" "${tiempoLlegada[$i]}" "${tiempoEjecucion[$i]}" "${memProceso[$i]}" #datos de partida
        printf " │ ${color}%4s${NC} │ ${color}%4s${NC} │ ${color}%4s${NC}" "${tEspera[$i]}" "${tRetorno[$i]}" "$tiempoRestante"                #Tiempos
        printf " │ ${color}%4s${NC} │ ${color}%4s${NC}" "${posMemInicial[$i]}" "${posMemFinal[$i]}"                                            #Memoria
        printf " │ ${color}%-20s${NC} │\n" "${estadoProc[$i]}"                                                                                 #estado
    done
}

# @param $1: valor del tiempo actual de ejecucion del programa
function imprimirTablaProcesos() {
    local tiempo=$1

    imprimeCabeceraTablaProcesos "$tiempo"
    imprimeProcesos
    imprimePieTablaProcesos "$tEsperaMedio" "$tRetornoMedio"
    pintaMP
    pintaCPU "$tiempo"
}

#Funcion pintaMP
#Desc   : Pinta la  MP en un instante de tiempo.
function pintaMP() {
    local tamBloque=3
    local barraNombres=""       #Cadena resultado que muestra el nombre de los procesos que residen en cada particion
    local barraMem=""           #Cadena resultado que muestra la proporcion de cada particion
    local barraPosicionesMem="" #Cadena resultado que muestra las direcciones de la MP
    local lineasTotales=0       #Numero de lineas que se tienen que dibujar
    local anchoMaxPorLinea=0    #numero maximo de columanas por lina
    local bloquesRellenar       #numero de bloques que se tienen que rellenar
    local anchoTotal=0          #numero de columas de la terminal actual
    local i                     # iterador
    local l                     # iterador
    local procesoActual         # auxiliar para almacenar el numero del proceso dentro del bucle que es ta ocupando ese bloque
    local textAux
    local contadorBloques=0 # variable auxiliar para contar en que bloque de memoria estamos iterando se persiste a lo largo del bucle de lineas

    anchoTotal=$(tput cols)

    #Una vez que lleguemos a la memoria anchoMaxPorLinea, saltamos de lineas, así hasta llegar a lineasTotales
    anchoMaxPorLinea=$((anchoTotal - 4))
    anchoMaxPorLinea=$((anchoMaxPorLinea / tamBloque - 1))
    lineasTotales=$((memTotal / anchoMaxPorLinea + 1))

    bloquesRellenar=$anchoMaxPorLinea

    if [[ $bloquesRellenar -gt $memTotal ]]; then
        bloquesRellenar=$memTotal
    fi
    # Hacemos los calculos por cada liene
    for ((l = 1; l <= lineasTotales; l++)); do
        #reseteamos las variables para comenzar la linea de cero, y no mesclar con lo de la linea anterior
        barraNombres=""
        barraMem=""
        barraPosicionesMem=""

        # Creamos las cadenas correspondientes para esta linea
        for i in $(seq 0 $((bloquesRellenar))); do
            if [[ contadorBloques -ge $((${#bloquesMemoria[@]})) ]]; then # verificamos que solo se cuente hasta el ultimo bloque de moemoria solo
                break
            fi
            procesoActual=${bloquesMemoria[$contadorBloques]}
            # Verificamos cada posicion de bloques de memoria y miramos si hay algun proceso ocupando esa posicion
            if ((procesoActual != -1)); then

                #Averiguamos is es el ultimo bloque de ese proceso
                if ((procesoActual != ${bloquesMemoria[$((contadorBloques - 1))]})); then
                    #Toca imprimir el nombre
                    textAux=$(printf "%-${tamBloque}s" "${nombreProceso[$procesoActual]}")
                    barraNombres="${barraNombres}${colorProceso[$procesoActual]}${textAux}${NC}"
                else
                    textAux=$(printf "%-${tamBloque}s" " ")
                    barraNombres="${barraNombres}${colorProceso[$procesoActual]}${textAux}${NC}" # agregamos 3 espacios vacios
                fi
                textAux=$(printf "%-${tamBloque}s" " " | tr ' ' '*')
                barraMem="${barraMem}${colorFondoProceso[$procesoActual]}${colorProceso[$procesoActual]}${textAux}${NC}"

            else # este bloque no tiene ningun proceso
                textAux=$(printf "%-${tamBloque}s" "")
                barraNombres="${barraNombres}${textAux}" # agregamos 3 espacios vacios

                textAux=$(printf "%-${tamBloque}s" " " | tr ' ' '#')
                barraMem="${barraMem}\e[48;5;7m${textAux}${NC}"

            fi

            #Posiciones de memoria solo se pintan cuando hay cambio de procesos
            if [[ $procesoActual -ne ${bloquesMemoria[$((contadorBloques - 1))]} ]] || [[ $l -eq 0 && $i -eq 0 ]]; then
                #Toca imprimir el posicion
                textAux=$(printf "%${tamBloque}s" "$contadorBloques")
                barraPosicionesMem="${barraPosicionesMem}$textAux" #FIXME que pasa con memoria +2 digitos
            else
                textAux=$(printf "%${tamBloque}s" " ") #remove
                barraPosicionesMem="${barraPosicionesMem}$textAux"    # agregamos 3 espacios vacios
            fi

            contadorBloques=$((contadorBloques + 1))

        done

        local anchoUltimaLinea="${#barraPosicionesMem}"
        anchoUltimaLinea=$((anchoUltimaLinea / tamBloque))

        local anchoStrMem=$(echo "$memTotal" | wc -l)
        anchoStrMem=$((anchoStrMem + 6))
        anchoStrMem=$((anchoStrMem / tamBloque + 1)) #cuantos bloques necesitamos para el texto 'MT = XXX'

        anchoUltimaLinea=$((anchoUltimaLinea + anchoStrMem))

        if [[ $lineasTotales -eq 1 ]]; then # si todo cabe en una linea

            if [[ $anchoMaxPorLinea -ge $anchoUltimaLinea ]]; then
                echo -e "    |$barraNombres|"
                echo -e " BM |$barraMem| MT = $memTotal"
                echo -e "    |$barraPosicionesMem|"
            else
                echo -e "    |$barraNombres"
                echo -e " BM |$barraMem"
                echo -e "    |$barraPosicionesMem"

                echo -e "    |"
                echo -e "    | MT = $memTotal"
                echo -e "    |"
            fi
        else                        # Si son varias lineas las dividimos
            if [[ $l -eq 1 ]]; then # primera linea
                echo -e "    |$barraNombres"
                echo -e " BM |$barraMem"
                echo -e "    |$barraPosicionesMem"
            elif [[ $l -eq $lineasTotales ]]; then # ultima linea imprimimos el total de memoria
                if [[ $anchoMaxPorLinea -ge $anchoUltimaLinea ]]; then
                    echo -e "     $barraNombres|"
                    echo -e "     $barraMem| MT = $memTotal"
                    echo -e "     $barraPosicionesMem|"
                else
                    echo -e "     $barraNombres"
                    echo -e "     $barraMem"
                    echo -e "     $barraPosicionesMem"

                    echo -e "    |"
                    echo -e "    | MT = $memTotal"
                    echo -e "    |"
                fi

            else
                #sin total
                echo -e "     $barraNombres"
                echo -e "     $barraMem"
                echo -e "     $barraPosicionesMem"
            fi
        fi

    done

}

#Funcion pintaCPU
#Desc   : Pinta la  CPU en un instante de tiempo.
function pintaCPU() {
    local tiempo=$1 # tiempo de ejecucion actual
    local tamBloque=3
    local barraNombres=""        #Cadena resultado que muestra el nombre de los procesos que residen en cada particion
    local barraTiempo=""         #Cadena resultado que muestra la proporcion de cada particion
    local barraPosicionTiempo="" #Cadena resultado que muestra las direcciones de la MP
    local lineasTotales=0        #Numero de lineas que se tienen que dibujar
    local anchoMaxPorLinea=0     #numero maximo de columanas por lina
    local anchoTotal=0           #numero de columas de la terminal actual
    local i                      # iterador
    local j                      # iterador
    local procesoActual          # auxiliar para almacenar el numero del proceso dentro del bucle que es ta ocupando ese bloque
    local textAux
    local contadorBloques=0 # variable auxiliar para contar en que bloque de memoria estamos iterando se persiste a lo largo del bucle de lineas

    anchoTotal=$(tput cols)

    #Una vez que lleguemos a la memoria anchoMaxPorLinea, saltamos de lineas, así hasta llegar a lineasTotales
    anchoMaxPorLinea=$((anchoTotal - 4))
    anchoMaxPorLinea=$((anchoMaxPorLinea / tamBloque))
    lineasTotales=$((tiempo / anchoMaxPorLinea + 1))

    # Hacemos los calculos por cada liene
    for ((l = 0; l < lineasTotales; l++)); do
        #reseteamos las variables para comenzar la linea de cero, y no mesclar con lo de la linea anterior
        barraNombres=""
        barraTiempo=""
        barraPosicionTiempo=""

        # Creamos las cadenas correspondientes para esta linea
        for i in $(seq 0 $((anchoMaxPorLinea - 1))); do
            if [[ contadorBloques -gt $((tiempo)) ]]; then # verificamos que solo se cuente hasta el ultimo bloque de moemoria solo
                break
            fi
            procesoActual=${lineaTemporal[$contadorBloques]}
            # Verificamos cada posicion de tiempo y miramos si hay algun proceso ocupando esa posicion
            if ((procesoActual != -1)); then

                #Averiguamos is es el ultimo bloque de ese proceso
                if ((procesoActual != ${lineaTemporal[$((contadorBloques - 1))]})); then
                    #Toca imprimir el nombre
                    textAux=$(printf "%-${tamBloque}s" "${nombreProceso[$procesoActual]}")
                    barraNombres="${barraNombres}${colorProceso[$procesoActual]}${textAux}${NC}"
                else
                    textAux=$(printf "%-${tamBloque}s" " ")
                    barraNombres="${barraNombres}${colorProceso[$procesoActual]}${textAux}${NC}" # agregamos 3 espacios vacios
                fi

                if [[ $tiempo -eq $contadorBloques ]]; then
                    textAux=$(printf "%-${tamBloque}s" " ")
                    barraTiempo="${barraTiempo}${textAux}"
                else
                    textAux=$(printf "%-${tamBloque}s" " " | tr ' ' '*')
                    barraTiempo="${barraTiempo}${colorFondoProceso[$procesoActual]}${colorProceso[$procesoActual]}${textAux}${NC}"
                fi

            else
                if [[ $contadorBloques -eq $((tiempo)) ]] && [[ $tiempo != 0 ]]; then
                    break #si el ultimo bloque es igual al tiempo y esta vacio actual no imprimimos nada
                fi
                # este bloque no tiene ningun proceso
                textAux=$(printf "%-${tamBloque}s" " ")
                barraNombres="${barraNombres}${textAux}" # agregamos 3 espacios vacios

                if [[ $tiempo -eq 0 ]]; then
                    textAux=$(printf "%-${tamBloque}s" " ")
                    barraTiempo="${textAux}${NC}"
                else
                    textAux=$(printf "%-${tamBloque}s" " " | tr ' ' '#')
                    barraTiempo="${barraTiempo}\e[48;5;7m${textAux}${NC}"
                fi
            fi

            #Posiciones de memoria solo se pintan cuando hay cambio de procesos
            if [[ $procesoActual -ne ${lineaTemporal[$((contadorBloques - 1))]} ]] || [[ $i -eq 0 ]]; then
                #Toca imprimir el posicion
                textAux=$(printf "%${tamBloque}s" "$contadorBloques")
                barraPosicionTiempo="${barraPosicionTiempo}$textAux"

            else
                textAux=$(printf "%${tamBloque}s" "")
                barraPosicionTiempo="${barraPosicionTiempo}$textAux" # agregamos 3 espacios vacios
            fi

            contadorBloques=$((contadorBloques + 1))

        done

        local anchoUltimaLinea="${#barraPosicionTiempo}"
        anchoUltimaLinea=$((anchoUltimaLinea / tamBloque))
        local anchoStrMem=$(echo "$tiempo" | wc -l)
        anchoUltimaLinea=$((anchoUltimaLinea + anchoStrMem))
        anchoUltimaLinea=$((anchoUltimaLinea + 6))

        if [[ $lineasTotales -eq 1 ]]; then # si todo cabe en una linea
            if [[ $anchoMaxPorLinea -ge $anchoUltimaLinea ]]; then
                echo -e "    |$barraNombres|"
                echo -e " BM |$barraTiempo| T = $tiempo"
                echo -e "    |$barraPosicionTiempo|"
            else
                echo -e "    |$barraNombres"
                echo -e " BM |$barraTiempo"
                echo -e "    |$barraPosicionTiempo"

                echo -e "    |"
                echo -e "    | T = $tiempo"
                echo -e "    |"
            fi
        else
            if [[ $l -eq 0 ]]; then # primera linea
                echo -e "    |$barraNombres"
                echo -e " BM |$barraTiempo"
                echo -e "    |$barraPosicionTiempo"
            elif [[ $l -eq $((lineasTotales - 1)) ]]; then # ultima linea imprimimos el total de memoria

                if [[ $anchoMaxPorLinea -ge $anchoUltimaLinea ]]; then
                    echo -e "     $barraNombres|"
                    echo -e "     $barraTiempo| T = $tiempo"
                    echo -e "     $barraPosicionTiempo|"
                else
                    echo -e "     $barraNombres"
                    echo -e "     $barraTiempo"
                    echo -e "     $barraPosicionTiempo"

                    echo -e "    |"
                    echo -e "    | T = $tiempo"
                    echo -e "    |"
                fi

            else #sin total
                echo -e "     $barraNombres"
                echo -e "     $barraTiempo"
                echo -e "     $barraPosicionTiempo"

            fi
        fi
    done

}

############### Menu Principal

# Nombre: creacionDeDirectorios()
# Descripción: Crea los directorios para los ficheros de entrada y los informes si no existen
# Date: 21/03/2020
function creacionDeDirectorios() {
    if [[ ! -d $DIRECTORIO_DATOS ]]; then
        mkdir $DIRECTORIO_DATOS
    fi

    if [[ ! -d $DIRECTORIO_RANGOS ]]; then
        mkdir $DIRECTORIO_RANGOS
    fi

    if [[ ! -d $DIRECTORIO_REPORTES ]]; then
        mkdir $DIRECTORIO_REPORTES
        touch $RUTA_FICHERO_REPORTES_COLOR
    fi
}

# Nombre: imprirCabecera
# Descripción: Imprime la cabecera del programa
function imprirCabecera() {
    clear
    echo -e "
            ${CYAN}**********************************************************************************${NC}
            ${CYAN}*                  SISTEMAS OPERATIVOS - PRÁCTICA DE CONTROL                     *${NC}
            ${CYAN}*                               Curso 2021-22                                    *${NC}
            ${CYAN}*                                                                                *${NC}
            ${CYAN}*                                                                                *${NC}
            ${CYAN}*              SRPT-SEGÚN NECESIDADES-MEMORIA CONTINUA-REUBICABLE                *${NC}
            ${CYAN}*                                                                                *${NC}
            ${CYAN}*                              Alumnos 2022:                                     *${NC}
            ${CYAN}*                       · Zeldan Javier Campos Cordero                           *${NC}
            ${CYAN}*                                                                                *${NC}
            ${CYAN}*                              Alumnos Anteriores:                               *${NC}
            ${CYAN}*                          · Daniel Puente Ramírez                               *${NC}
            ${CYAN}*                                                                                *${NC}
            ${CYAN}**********************************************************************************${NC}"
}

# Nombre: imprimeMenuOpciones
# Descripción: Imprime el menu de opciones
function imprimeMenuOpciones() {
    echo -e "
            
     ─────────────────────────────────────────────────────────
                   M E N Ú   P R I N C I P A L
     ─────────────────────────────────────────────────────────
     1) Manual
     2) Fichero datos de ultima ejecucion (datos.txt)
     3) Otros ficheros de datos
     4) Aleatorio Manual
     5) Fichero Rangos Ultima ejecucion (datosRangos.txt)
     6) Otros ficheros rangos 
     7) Salir
     ─────────────────────────────────────────────────────────
   
     ${CYAN}Introduce una opcion:${NC} "
}

################# FICHEROS

# Nombre: listaDeFicheros
# Descripción: Muestra la lista de ficheros de datos disponibles y pide que se seleccione una.
function listaDeFicheros() {
    local f
    local contador=1

    clear
    ficheros=("$DIRECTORIO_DATOS"*.txt)
    echo " "
    echo " Selecciona un fichero:"
    echo " ─────────────────────────────────────────────────────────"

    for f in "${ficheros[@]}"; do
        echo " ${contador}) ${f}"
        ((contador++))
    done

    echo " $contador) Salir"
    echo " ─────────────────────────────────────────────────────────"
    echo " "
    echo -e " ${CYAN}Introduce una opcion:${NC} "

    local num=0
    local continuar="SI" # Cuando termine la entrada de datos, continuamos
    while [ $num -ne "$contador" ] && [ "$continuar" == "SI" ]; do
        read num
        if [ "$num" -lt "$contador" ]; then
            posicion=$(expr "$num" - 1)
            echo "${ficheros[$posicion]}"
            source leerProcesosDesdeFichero.sh "${ficheros[$posicion]}"
            continuar=NO
        elif [ "$num" -eq "$contador" ]; then
            exit 0
        else
            num=0
            echo "Opción errónea, vuelva a introducir"
        fi

    done
}

############### OPCION 1 Manual

# Nombre: imprimeMenuNombreFichero
# Descripción: Imprime el menu de seleccion de fichero
function imprimeMenuNombreFicheroDatos() {
    echo -e "

     Donde quieres guardar los datos:
     ─────────────────────────────────────────────────────────
     1) Fichero de datos ultima ejecucion (${1})
     2) otro fichero de datos
     3) Salir
     ─────────────────────────────────────────────────────────
    
     ${CYAN}Introduce una opcion:${NC} "
}

# Nombre: imprimeMenuNombreFichero
# Descripción: Imprime el menu de seleccion de fichero
function imprimeMenuNombreFicheroRangos() {
    echo -e "

     Donde quieres guardar los rangos:
     ─────────────────────────────────────────────────────────
     1) Fichero de rangos ultima ejecucion (${1})
     2) otro fichero de rangos
     3) Salir
     ─────────────────────────────────────────────────────────
    
     ${CYAN}Introduce una opcion:${NC} "
}

function leerNombreFichero() {
    echo " Introduzca el nombre de fichero"
    echo " Recordatorio: Es necesario añadir el formato (.txt) y evitar usar Slashes [ / ], ya que son tomadas como un directorio"
    scanfString " Nombre de fichero: " nuevoNombreFichero "^.+\.txt"
}

function imprimeCabeceraTablaRevision() {
    cecho " REF  TLL  TEJ  MEM" "$YELLOW"
}

function imprimeProcesosTemporal() {
    local n=${1}
    local i
    local numeroColor=0
    # imprime valores de cada proceso
    for ((i = 0; i < n; i++)); do
        # Seteamos el color con uno de los que tenemos disponible en el array
        if [[ numeroColor -ge $((${#coloresLetras[@]} - 1)) ]]; then
            numeroColor=0 #reset de color
        else
            numeroColor=$((numeroColor + 1))
        fi
        colorProceso[$i]=${coloresLetras[$numeroColor]}
        colorFondoProceso[$i]=${coloresFondo[$numeroColor]}

        printf " ${colorProceso[$i]}%3s${NC}" "${nombreProceso[$i]}"
        printf " "
        printf " ${colorProceso[$i]}%3s${NC}" "${tiempoLlegada[$i]}"
        printf " "
        printf " ${colorProceso[$i]}%3s${NC}" "${tiempoEjecucion[$i]}"
        printf " "
        printf " ${colorProceso[$i]}%3s${NC}" "${memProceso[$i]}"
        printf "\n"
    done
    printf "\n"
}

function guardarDatosEnFichero() {
    local rutaFichero=$1

    echo "$memTotal" >"${rutaFichero}"
    # guardamos en el fichero entrada.dat
    for ((i = 0; i < ${#nombreProceso[@]}; i++)); do
        echo "${tiempoLlegada[$i]}:${tiempoEjecucion[$i]}:${memProceso[$i]}" >>"${rutaFichero}"
    done
}

function introducirProcesosTeclado() {

    local continuar='s'
    local n=-1
    local numeroColor=0

    clear
    ###################### Memoria total ######################
    scanfNum "${CYAN}  Introduzca el tamaño total de la memoria" memTotal 0

    clear
    # Bucle que pide al usuario que confirme los datos introducidos
    while [[ $continuar == s ]]; do
        ordenaPorTiempoLLegada
        n=$((n + 1))

        ###################### Tiempo llegada ######################
        printf " Memoria total: %s\n" "$memTotal"
        imprimeCabeceraTablaRevision
        imprimeProcesosTemporal "$((n + 1))"

        scanfNum "${CYAN} Introduzca Tiempo de llegada del proceso $(("$n" + 1))" tiempoLlegada[$n] 0

        #Nos Guardamos en el array "procesos[]" el nombre del proceso
        if [[ $((n + 1)) -lt 10 ]]; then
            nombreProceso[$n]="P0"$((n + 1)) # Los procesos se llamarán P01, P02,...
        else
            nombreProceso[$n]="P"$((n + 1)) # Los procesos se llamarán P10, P11, P12,...
        fi

        clear

        ###################### Tiempo ejecucion ######################
        printf " Memoria total: %s\n" "$memTotal"
        imprimeCabeceraTablaRevision
        imprimeProcesosTemporal "$((n + 1))"

        scanfNum "${CYAN} Introduzca Tiempo de ejecución del proceso $(("$n" + 1))" tiempoEjecucion[$n] 1
        clear

        ###################### Tamano memoria ######################
        printf " Memoria total: %s\n" "$memTotal"
        imprimeCabeceraTablaRevision
        imprimeProcesosTemporal "$((n + 1))"

        scanfNum "${CYAN} Introduzca tamaño de memoria del proceso $(("$n" + 1))" memProceso[$n] 1
        clear

        ###################### Resumen final de datos ######################
        printf " Memoria total: %s\n" "$memTotal"
        imprimeCabeceraTablaRevision
        imprimeProcesosTemporal "$((n + 1))"

        ###################### Guardar en fichero datos ######################

        cecho " ¿Continuar introduciendo procesos? [ s/n ]" "$CYAN"
        read -r continuar

        while ! [[ $continuar =~ ^[sn]$ ]]; do
            cecho " Error, introduzca otra vez [ s/n ]" "$RED"
            read -r continuar
        done

        echo " Hay $n procesos"

        numeroProcesos=$((numeroProcesos + 1))

        clear
    done
}

function imprimeResumen() {
    cecho " ─────────────────────────────────────────────────────────"
    cecho " -                   R E S U M E N                       -"
    cecho " ─────────────────────────────────────────────────────────"
    printf "\n"
    cecho " Estos son los datos de partida:"
    printf "\n"

    imprimeCabeceraTablaRevision
    imprimeProcesosTemporal "$numeroProcesos"

    printf "\n\n"
    cecho " MEMORIA TOTAL: $memTotal M" "$CYAN"
    cecho " ─────────────────────────────────────────────────────────"
}

function revisionDatosIntroducidos() {

    local datosValidos="false"
    local contador

    imprimeResumen

    while [[ "$datosValidos" == "false" ]]; do
        local contador=0
        #Permite la modificacion del tamaño de la memoria de dicho proceso
        for ((contador = 0; contador <= numeroProcesos; ++contador)); do #Bucle que comprueba que todos los tamaños de memoria de los procesos son menores que la memoria total.
            while [[ ${memProceso[$contador]} -gt $memTotal ]]; do
                cecho " El proceso $((contador + 1)) no cabe en memoria. Vuelva a introducir datos." "$RED"
                echo " Introduzca un nuevo valor para la memoria que va a ocupar el ${nombreProceso[$contador]}. "
                read -r memProceso["$contador"]
            done
        done
        datosValidos="true"
    done

    local ok
    read -ers -p " Pulse [enter] para continuar "
    clear
    sleep 1
}

function mainIntroducirProcesosManual() {
    local rutaFicheroDatos=$1

    introducirProcesosTeclado
    ordenaPorTiempoLLegada
    revisionDatosIntroducidos
    guardarDatosEnFichero "$rutaFicheroDatos"
    cecho " Datos correctos. Comienza." "$YELLOW"
    sleep 1
}

# Nombre: seleccionarNombreFichero
# Descripción: Muestra por la salida el menu de nombre de ficheros y pide al usuario que introduzca una opcion
function seleccionarNombreFichero() {
    clear
    imprimeMenuNombreFicheroDatos "$NOMBRE_FICHERO_DATOS_DEFECTO"
    declare nuevoNombreFichero # variable utilitaria global
    local num=0
    local continuar="SI" # Cuando termine la entrada de datos, continuamos

    while [ $num -ne 7 ] && [ "$continuar" == "SI" ]; do
        read -r num
        case $num in
        "1")
            mainIntroducirProcesosManual "$RUTA_FICHERO_DATOS_DEFECTO"
            continuar=NO
            ;;
        "2")
            clear
            leerNombreFichero
            mainIntroducirProcesosManual "${DIRECTORIO_DATOS}${nuevoNombreFichero}"
            continuar=NO
            ;;
        *)
            num=0
            printf " ${RED}Opcion errónea, vuelva a introducir${NC}"
            ;;
        esac
    done
}

################### LEER DESDE FICHERO

# Nombre: leerFichero
# Descripción: lee los datos del fichero de entrada y almacena sus valores en varios arrays
function leerFichero() {
    local rutaFichero=$1
    local n=-1
    local tLllegada
    local tEjecucion
    local memoria

    numeroProcesos=-1 # reseteamos variable global contaror de numero de procesoso

    while IFS=":" read -r tLllegada tEjecucion memoria; do

        # Guardamos cada campo en su array correspondiente
        if [[ $n -eq -1 ]]; then
            memTotal=$tLllegada # primera linea fichreo tamano total de memoria
        else
            tiempoLlegada[$n]=$tLllegada
            tiempoEjecucion[$n]=$tEjecucion
            memProceso[$n]=$memoria

            #Nos Guardamos en el array "procesos[]" el nombre del proceso
            if [[ $((n + 1)) -lt 10 ]]; then
                nombreProceso[$n]="P0"$((n + 1)) # Los procesos se llamarán P01, P02,...
            else
                nombreProceso[$n]="P"$((n + 1)) # Los procesos se llamarán P10, P11, P12,...
            fi

        fi
        n=$((n + 1))
        numeroProcesos=$((numeroProcesos + 1))
    done <"$rutaFichero"
}

function leerProcesosDesdeFichero() {
    local fichero=$1
    local ok

    clear

    printf "\n"
    leerFicheroRangos "$fichero"
    printf "\n"
    leerFichero "$fichero"

    imprimeResumen

    read -ers -p " Pulse [enter] para continuar "
    clear
    sleep 1
}

# Nombre: listaDeFicheros
# Descripción: Muestra la lista de ficheros de datos disponibles y pide que se seleccione una.
function listaDeFicheros() {
    local listaFicheros
    local contador=1
    local f
    local posicion

    clear

    listaFicheros=("$DIRECTORIO_DATOS"*.txt)
    printf "\n"
    cecho " Selecciona un fichero:"
    cecho " ─────────────────────────────────────────────────────────"
    for f in "${listaFicheros[@]}"; do
        cecho " ${contador}) ${f}" "$YELLOW"
        ((contador++))
    done
    cecho " $contador) Salir" "$YELLOW"
    cecho " ─────────────────────────────────────────────────────────"
    echo " "
    cecho " Introduce una opcion: " "$CYAN"

    local num=0
    local continuar="SI" # Cuando termine la entrada de datos, continuamos
    while [ $num -ne "$contador" ] && [ "$continuar" == "SI" ]; do
        read -r num
        if [ "$num" -lt "$contador" ]; then
            posicion=$((num - 1))
            echo "${listaFicheros[$posicion]}"
            leerProcesosDesdeFichero "${listaFicheros[$posicion]}"
            continuar=NO
        elif [ "$num" -eq "$contador" ]; then
            exit 0
        else
            num=0
            cecho " Opción errónea, vuelva a introducir" "$RED"
        fi

    done
}

#### DATOS ALEATORIOS_RANGOS
rangoMemTotal=()
rangoTiempoLLegada=()
rangoTiempoEjecucion=()
rangosTamMemoria=()
rangoNumeroProcesos=()

function resumenRangos() {
    printf "\n"
    cecho " Generacion de datos aletorios." "${YELLOW}"
    printf "\n"
    cecho " Rango memoria total: [${rangoMemTotal[0]}-${rangoMemTotal[1]}] - Valor final: $memTotal"
    cecho " Rango numero procesos: [${rangoNumeroProcesos[0]}-${rangoNumeroProcesos[1]}] - Valor final: $numeroProcesos"
    cecho " Rango tiempo llegada: [${rangoTiempoLLegada[0]}-${rangoTiempoLLegada[1]}]"
    cecho " Rango tiempo ejecucion: [${rangoTiempoEjecucion[0]}-${rangoTiempoEjecucion[1]}]"
    cecho " Rango tamano proceos: [${rangosTamMemoria[0]}-${rangosTamMemoria[1]}]"
}

function ingresarRangosManual() {
    local min
    local max

    local ok

    clear
    continuar=SI
    resumenRangos
    printf "\n"
    cecho " Introduzca un rango para el ${YELLOW}total de memoria${NC}: Ejemplo [0-10] ~ donde 0 seria minimo y 10  maximo"
    scanfNum " ${CYAN}Minimo rango${NC} ${YELLOW}total de memoria:${NC}" min 0
    scanfNum " ${CYAN}Maxiomo rango${NC} ${YELLOW}total de memoria:${NC}" max "$min"
    rangoMemTotal[0]=$min
    rangoMemTotal[1]=$max

    numAleatorio memTotal "${rangoMemTotal[0]}" "${rangoMemTotal[1]}"

    ok=x
    clear
    resumenRangos
    printf "\n"
    cecho " Introduzca un rango para el ${YELLOW}Numero de Procesos a ejecutar${NC}: Ejemplo [0-10] ~ donde 0 seria minimo y 10  maximo"
    scanfNum " ${CYAN}Minimo rango${NC} ${YELLOW}Numero de Procesos:${NC}" min 0
    scanfNum " ${CYAN}Maxiomo rango${NC} ${YELLOW}Numero de Procesos:${NC}" max "$min"
    rangoNumeroProcesos[0]=$min
    rangoNumeroProcesos[1]=$max

    numAleatorio numeroProcesos "${rangoNumeroProcesos[0]}" "${rangoNumeroProcesos[1]}"

    ok=x
    clear
    continuar=SI
    resumenRangos
    printf "\n"
    cecho " Introduzca un rango para el ${YELLOW}tiempo llegada${NC}: Ejemplo [0-10] ~ donde 0 seria minimo y 10  maximo"
    scanfNum " ${CYAN}Minimo rango${NC} ${YELLOW}tiempo llegada:${NC}" min 0
    scanfNum " ${CYAN}Maxiomo rango${NC} ${YELLOW}tiempo llegada:${NC}" max "$min"
    rangoTiempoLLegada[0]=$min
    rangoTiempoLLegada[1]=$max

    ok=x
    clear
    continuar=SI
    resumenRangos
    printf "\n"
    cecho " Introduzca un rango para el ${YELLOW}tiempo ejecucion${NC}: Ejemplo [0-10] ~ donde 0 seria minimo y 10  maximo"
    scanfNum " ${CYAN}Minimo rango${NC} ${YELLOW}tiempo ejecucion:${NC}" min 0
    scanfNum " ${CYAN}Maxiomo rango${NC} ${YELLOW}tiempo ejecucion:${NC}" max "$min"
    rangoTiempoEjecucion[0]=$min
    rangoTiempoEjecucion[1]=$max

    ok=x
    clear
    continuar=SI
    resumenRangos
    printf "\n"
    cecho " Introduzca un rango para el ${YELLOW}tamano proceos${NC}: Ejemplo [0-10] ~ donde 0 seria minimo y 10  maximo"
    scanfNum " ${CYAN}Minimo rango${NC} ${YELLOW}tamano proceos:${NC}" min 0
    scanfNum " ${CYAN}Maxiomo rango${NC} ${YELLOW}tamano proceos:${NC}" max "$min"
    rangosTamMemoria[0]=$min
    rangosTamMemoria[1]=$max

    guardarRangosEnFichero $RUTA_FICHERO_RANGOS_DEFECTO
}

function guardarRangosEnFichero() {
    local rutaFichero=$1
    {
        echo "${rangoNumeroProcesos[0]}-${rangoNumeroProcesos[1]}"
        echo "${rangoMemTotal[0]}-${rangoMemTotal[1]}"
        echo "${rangoTiempoLLegada[0]}-${rangoTiempoLLegada[1]}"
        echo "${rangoTiempoEjecucion[0]}-${rangoTiempoEjecucion[1]}"
        echo "${rangosTamMemoria[0]}-${rangosTamMemoria[1]}"
    } >"${rutaFichero}"

}

# Nombre: seleccionarNombreFichero2
# Descripción: Muestra por la salida el menu de nombre de ficheros y pide al usuario que introduzca una opcion
function seleccionarNombreFichero2() {
    clear
    imprimeMenuNombreFicheroDatos "$NOMBRE_FICHERO_DATOS_DEFECTO"
    declare nuevoNombreFichero # variable utilitaria global
    local num=0
    local continuar="SI" # Cuando termine la entrada de datos, continuamos

    while [ $num -ne 7 ] && [ "$continuar" == "SI" ]; do
        read -r num
        case $num in
        "1")
            nombreficheroGruadarDatos=$RUTA_FICHERO_DATOS_DEFECTO
            continuar=NO
            ;;
        "2")
            clear
            leerNombreFichero
            nombreficheroGruadarDatos="${DIRECTORIO_DATOS}${nuevoNombreFichero}"
            continuar=NO
            ;;
        *)
            num=0
            printf " ${RED}Opcion errónea, vuelva a introducir${NC}"
            ;;
        esac
    done
}

# Nombre: seleccionarNombreFichero
# Descripción: Muestra por la salida el menu de nombre de ficheros y pide al usuario que introduzca una opcion
function seleccionarNombreFicheroRangos() {
    clear
    imprimeMenuNombreFicheroRangos "$NOMBRE_FICHERO_RANGOS_DEFECTO"
    local nuevoNombreFicheroRangos # variable utilitaria global
    local num=0
    local continuar="SI" # Cuando termine la entrada de datos, continuamos

    while [ $num -ne 7 ] && [ "$continuar" == "SI" ]; do
        read -r num
        case $num in
        "1")
            mainAleatorioManual "$RUTA_FICHERO_RANGOS_DEFECTO"
            continuar=NO
            ;;
        "2")
            clear
            leerNombreFichero
            mainAleatorioManual "${DIRECTORIO_RANGOS}${nuevoNombreFichero}"
            continuar=NO
            ;;
        *)
            num=0
            printf " ${RED}Opcion errónea, vuelva a introducir${NC}"
            ;;
        esac
    done
}

function revisionRangosIntroducidos() {
    clear
    cecho " ─────────────────────────────────────────────────────────"
    cecho " -                    R E S U M E N                      -"
    cecho " ─────────────────────────────────────────────────────────"
    printf "\n"
    resumenRangos
    printf "\n\n"
    cecho " ─────────────────────────────────────────────────────────"
    local ok
    read -ers -p "Pulse [enter] para continuar "
    clear
    sleep 1

}

function calculosAleatorios() {
    local i
    local valida=-1

    for ((i = 0; i < numeroProcesos; i++)); do
        numAleatorio tiempoLlegada["$i"] "${rangoTiempoLLegada[0]}" "${rangoTiempoLLegada[1]}"
        numAleatorio tiempoEjecucion["$i"] "${rangoTiempoEjecucion[0]}" "${rangoTiempoEjecucion[1]}"

        while [ $valida -lt 0 ] || [ $valida -gt "$memTotal" ]; do
            numAleatorio valida "${rangosTamMemoria[0]}" "${rangosTamMemoria[1]}"
        done
        memProceso[$i]=$valida
        valida=-1 #reseteamos variable auxiliar para el siente bucle
        #Nos Guardamos en el array "procesos[]" el nombre del proceso
        if [[ $((i + 1)) -lt 10 ]]; then
            nombreProceso[$i]="P0"$((i + 1)) # Los procesos se llamarán P01, P02,...
        else
            nombreProceso[$i]="P"$((i + 1)) # Los procesos se llamarán P10, P11, P12,...
        fi
    done

}

function mainAleatorioManual() {

    local rutaFicheroDatos=$1
    seleccionarNombreFichero2
    ingresarRangosManual
    revisionRangosIntroducidos
    guardarRangosEnFichero "$rutaFicheroDatos"
    cecho " Datos guardados correctamente. Comienza Calculo aleatorios." "$YELLOW"
    sleep 1
    clear
    calculosAleatorios
    ordenaPorTiempoLLegada
    guardarDatosEnFichero "$nombreficheroGruadarDatos"
    imprimeResumen
    read -ers -p " Pulse [enter] para continuar "
    clear

}

function leerFicheroRangos() {
    local rutaFichero=$1
    local n=-1
    local min
    local max

    while IFS="-" read -r min max; do
        # Guardamos cada campo en su array correspondiente
        if [[ $n -eq -1 ]]; then # primera linea rango numero procesos
            rangoNumeroProcesos[0]=$min
            rangoNumeroProcesos[1]=$max
        elif [[ $n -eq 0 ]]; then # segunda linea rango memoria total
            rangoMemTotal[0]=$min
            rangoMemTotal[1]=$max
        elif [[ $n -eq 1 ]]; then # Tercera linea rango tiempo llegada
            rangoTiempoLLegada[0]=$min
            rangoTiempoLLegada[1]=$max
        elif [[ $n -eq 2 ]]; then # cuanta linea rango tiempo ejecucion
            rangoTiempoEjecucion[0]=$min
            rangoTiempoEjecucion[1]=$max
        elif [[ $n -eq 3 ]]; then # quinta linea rango tam memoria
            rangosTamMemoria[0]=$min
            rangosTamMemoria[1]=$max
        else
            break
        fi
        n=$((n + 1))
    done <"$rutaFichero"
}

function leerProcesosDesdeFicheroRangos() {
    local fichero=$1
    local ok

    clear

    printf "\n"
    validaSiFicheroExiste "$fichero"
    printf "\n"
    seleccionarNombreFichero2
    leerFicheroRangos "$fichero"
    revisionRangosIntroducidos
    clear
    calculosAleatorios
    ordenaPorTiempoLLegada
    guardarDatosEnFichero "$nombreficheroGruadarDatos"
    imprimeResumen
    #Esperar interaccion del usuario
    read -ers -p " Pulse [enter] para continuar "
    clear
    sleep 1

}

function validaSiFicheroExiste() {
    if [ -s "$1" ]; then
        cecho " Leyedo datos desde el fichero: ${fichero}:" "$YELLOW"
    else
        echo " El archivo $1 esta vacio. Cerrando programa"
        exit 1
    fi

}

function listaDeFicherosRangos() {
    local listaFicheros
    local contador=1
    local f
    local posicion

    clear

    listaFicheros=("$DIRECTORIO_RANGOS"*.txt)
    printf "\n"
    cecho " Selecciona un fichero:"
    cecho " ─────────────────────────────────────────────────────────"
    for f in "${listaFicheros[@]}"; do
        cecho " ${contador}) ${f}" "$YELLOW"
        ((contador++))
    done
    cecho " $contador) Salir" "$YELLOW"
    cecho " ─────────────────────────────────────────────────────────"
    echo " "
    cecho " Introduce una opcion: " "$CYAN"

    local num=0
    local continuar="SI" # Cuando termine la entrada de datos, continuamos
    while [ $num -ne "$contador" ] && [ "$continuar" == "SI" ]; do
        read -r num
        if [ "$num" -lt "$contador" ]; then
            posicion=$((num - 1))
            echo "${listaFicheros[$posicion]}"
            leerProcesosDesdeFicheroRangos "${listaFicheros[$posicion]}"
            continuar=NO
        elif [ "$num" -eq "$contador" ]; then
            exit 0
        else
            num=0
            cecho " Opción errónea, vuelva a introducir" "$RED"
        fi

    done
}

# Nombre: leeOpcionMenu
# Descripción: Pide al usuario que introduzca una opcion del menu y ejecuta la opcion seleccionada.
function leeOpcionMenu() {
    local num=0
    local continuar="SI" # Cuando termine la entrada de datos, continuamos

    while [ $num -ne 7 ] && [ "$continuar" == "SI" ]; do
        read -r num
        case $num in
        "1")
            # Cargamos los datos por teclado
            seleccionarNombreFichero
            continuar=NO
            ;;
        "2")
            # Cargamos el fichero de entrada por defecto
            leerProcesosDesdeFichero "$RUTA_FICHERO_DATOS_DEFECTO"
            continuar=NO
            ;;
        "3")
            # listado de ficheros
            listaDeFicheros
            continuar=NO
            ;;
        "4")
            seleccionarNombreFicheroRangos
            continuar=NO
            ;;
        "5")
            # Cargamos el fichero de entrada por defecto
            leerProcesosDesdeFicheroRangos "$RUTA_FICHERO_RANGOS_DEFECTO"
            continuar=NO
            ;;
        "6")
            # listado de ficheros rangos
            listaDeFicherosRangos
            continuar=NO
            ;;
        "7")
            exit 0
            ;;
        *)
            num=0
            cecho " Opción errónea, vuelva a introducir" "$RED"
            ;;
        esac
    done
}

function seleccionFormaVolcado() {
    local continuar="SI" # Cuando termine la entrada de datos, continuamos
    local numAux
    printf "\n"
    cecho " Selecciona un opcion de volcado de datos:"
    cecho " ─────────────────────────────────────────────────────────"
    cecho " 1) Por eventos" "$YELLOW"
    cecho " 2) Automatico (tiempo de espera entre volcados definido por usuario)" "$YELLOW"
    cecho " 3) Completo" "$YELLOW"
    cecho " 4) Por unidad de tiempo (CPU)" "$YELLOW"
    cecho " ─────────────────────────────────────────────────────────"
    echo " "
    cecho " Introduce una opcion: " "$CYAN"

    while [ "$continuar" == "SI" ]; do
        read -r numAux
        case $numAux in
        "1")
            formaVolcado='POR_EVENTOS'
            continuar=NO
            ;;
        "2")
            scanfNum " ${CYAN}Indica tiempo de espera entre volcados:${NC}" tiempoEsperaVolcado "1"
            formaVolcado='AUTOMATICO'
            continuar=NO
            ;;
        "3")
            formaVolcado='COMPLETO'
            continuar=NO
            ;;
        "4")
            scanfNum " ${CYAN}Cada cuanto tiempo (CPU) deseas realizar el volcado:${NC}" volcadoAtomaticoTiempo "1"
            formaVolcado='TIEMPO'
            continuar=NO
            ;;
        *)
            num=0
            cecho " Opción errónea, vuelva a introducir" "$RED"
            ;;
        esac
    done
    clear
}

############################# VISUALIZACIONES REPORTES
function menuVisualizacion() {
    clear
    cecho " ─────────────────────────────────────────────────────────" "$RED"
    cecho "          V I S U A L I Z A C I Ó N " "$YELLOW"
    cecho " ─────────────────────────────────────────────────────────" "$RED"
    cecho " 1) Leer el fichero ${RUTA_FICHERO_REPORTES_NEGRO} en el terminal" "$YELLOW"
    cecho " 2) Leer el fichero ${RUTA_FICHERO_REPORTES_NEGRO} en el editor gedit" "$YELLOW"
    cecho " 3) Leer el fichero ${RUTA_FICHERO_REPORTES_COLOR} en el terminal" "$YELLOW"
    cecho " 4) Salir y terminar" "$YELLOW"
    cecho " ─────────────────────────────────────────────────────────" "$RED"
    cecho " "
    cecho " Introduce una opcion: "

    local num=0
    local continuar="SI"

    while [ $num -ne 4 ] && [ "$continuar" == "SI" ]; do
        read num
        case $num in
        "1")
            clear
            cat ${RUTA_FICHERO_REPORTES_NEGRO}
            exit 0
            ;;

        "2")
            clear
            gedit ${RUTA_FICHERO_REPORTES_NEGRO}
            exit 0
            ;;

        "3")
            clear
            cat ${RUTA_FICHERO_REPORTES_COLOR}
            exit 0
            ;;

        "4")
            exit 0
            ;;
        *)
            num=0
            cecho "Opción errónea, vuelva a introducir:" "$RED"
            ;;
        esac
    done

}

# Nombre: convertirFicheroColorEnBlancoNegro
# Descripción: Lee un fichero formateado con ASCII Color Schemes y lo convierte en Blanco y negro
# 		Elimina los colores usados en este script y otros chars de escape para poder ser visualizados en cualquier editor de texto
# Date: 29/02/2020
# Documentation: https://stackoverflow.com/questions/19296667/remove-ansi-color-codes-from-a-text-file-using-bash
# @Param $1: Direccion del fichero 1 a convertir
# @Param $2: Dirección del fichero 2 en el que se volcará el resultado
# @Param $3: String boolano ("true"), en el que se indica si se quiere borrar el fichero original
convertirFicheroColorEnBlancoNegro() {

    sed -r "s,\x1B\[[0-9;]*[a-zA-Z],,g;s,\x0D\x0A,\x0A,g" "$1" >"$2"

    if [[ $3 = "true" ]]; then

        rm "$1" && echo "El fichero $1 ha sido borrado"
    fi
}

function main() {

    creacionDeDirectorios

    imprirCabecera | tee "$RUTA_FICHERO_REPORTES_COLOR"

    imprimeMenuOpciones

    leeOpcionMenu

    inicializaVariables

    ordenaPorTiempoLLegada

    seleccionFormaVolcado

    mainAlgoritmo

    #Esperar interaccion del usuario
    read -ers -p "Pulse [enter] para continuar "
    clear

    convertirFicheroColorEnBlancoNegro $RUTA_FICHERO_REPORTES_COLOR $RUTA_FICHERO_REPORTES_NEGRO "false"

    menuVisualizacion
}

main
