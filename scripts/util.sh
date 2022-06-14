#!/bin/bash -e

# Descripción: Imprime el texto el color idicado
# @Param $1: String a imprmir
# @Param $2: Color en el que se quiere mostrar el texto
function cecho() {
    local default_msg="No message passed."

    local message=${1:-$default_msg} # Defaults to default message.
    local color=${2}                 # Defaults to white, if not specified.

    echo -en "$color"
    echo -e "$message"
    tput sgr0 # Reset text attributes to normal
}

# Nombre: scanfSiNo
# Descripcion: asigna un valor valido a una variable desde el teclado
# @param $1: texto a imprimir en pantalla para pedir si o no
# @param $2: variable al que se asigna si o no
function scanfSiNo() {
    local opcionSiNo
    cecho "$1"
    read -r opcionSiNo
    until [[ $opcionSiNo = s || $opcionSiNo = n || $opcionSiNo = S || $opcionSiNo = N ]]; do
        cecho "${RED}El valor '$opcionSiNo' introducido no válido, tiene que ser 's' o 'n'. Vuelve a intentarlo."
        cecho "$1"
        read -r opcionSiNo
    done
    eval "${2}"="$opcionSiNo" #asignamos la opcionSiNo valida al variable $2 pasado como parametro
}

# Nombre: numAleatorio
# Descripcion: genera un numero aleatorio de un rango de dos numeros pasado como parametro
# @param $1: variable a asignar el número aleatorio
# @param $2: número mmáximo del rango incluido
# @param $3: número máximo del rango incluido
function numAleatorio() {
    local num
    local numMinimo=$2
    local numMaximo=$3
    if [ "$numMinimo" -gt "$numMaximo" ]; then
        numMinimo=$3
        numMaximo=$2
    fi
    num=$((RANDOM % (numMaximo + 1 - numMinimo) + numMinimo))
    eval "${1}"=$num
}

# Nombre: scanfNum
# Descripcion: asigna un valor mayor que un numero pasado como parametro a una variable desde el teclado
# @param $1: texto a imprimir en pantalla para pedir
# @param $2: variable al que se asigna el numero valido
# @param $3: numero minimo valido
function scanfNum() {
    local opcionN
    cecho "$1"
    read -r opcionN
    #$opcionN -eq $opcionN comprueba si es un numero, si es una letra da error enviado al vacio
    until [ "$opcionN" -eq "$opcionN" -a "$opcionN" -ge "$3" ] 2>/dev/null; do
        cecho "${RED}El valor '$opcionN' introducido no válido, tiene que ser mayor que $3."
        cecho "$1"
        read -r opcionN
    done
    eval "${2}"="$opcionN"
}

# Nombre: scanfString
# Descripcion: asigna un valor cadena de caracteres a una variable pasado como parametro
# @param $1: texto a imprimir para pedir la cadena de caracteres
# @param $2: variable al que se asigna la cadena valida
# @param $3: variable al que contiene el patron a validar
function scanfString() {
    local opcionNombre
    local -i palabra
    local regex=$3

    cecho "$1"
    read -r opcionNombre
    palabra=$(echo "$opcionNombre" | wc -w)

    if [[ ¨¨"$(isEmptyString "${regex}")" = 'true' ]]; then
        while [[ "$palabra" -ne 1 ]]; do #comprueba si está vacío o tiene un espacio
            cecho "${RED}No puede ser vacío ni tener espacios."
            cecho "$1"
            read -r opcionNombre
            palabra=$(echo "$opcionNombre" | wc -w)
        done
    else
        while [[ "$palabra" -ne 1 || ! "$opcionNombre" =~ $3 ]]; do #comprueba si está vacío o tiene un espacio
            cecho "${RED}Valor no valido intente de nuevo."
            cecho "$1"
            read -r opcionNombre
            palabra=$(echo "$opcionNombre" | wc -w)
        done
    fi

    eval "${2}"="$opcionNombre"
}

function removeEmptyLines() {
    local -r content="${1}"

    echo -e "${content}" | sed '/^\s*$/d'
}

function isEmptyString() {
    local -r string="${1}"

    if [[ "$(trimString "${string}")" = '' ]]; then
        echo 'true' && return 0
    fi

    echo 'false' && return 1
}

function trimString() {
    local -r string="${1}"

    sed 's,^[[:blank:]]*,,' <<<"${string}" | sed 's,[[:blank:]]*$,,'
}

function repeatString() {
    local -r string="${1}"
    local -r numberToRepeat="${2}"

    if [[ "${string}" != '' && "$(isPositiveInteger "${numberToRepeat}")" = 'true' ]]; then
        local -r result="$(printf "%${numberToRepeat}s")"
        echo -e "${result// /${string}}"
    fi
}