#!/bin/bash
# ___  ___  ___
#(***)(***)(***)
# \1/  \2/  \3/
#
# ___  ___  ___
#(3  )(1  )(3  )
# \1/  \2/  \3/
#
#RUB=[1 2 3]
#LIC=[3 1 3]


# Pomocne funkce
function vygeneruj() {
    I=0
    for NAHODA in $(echo -e "$(seq $KARET)\n$(seq $KARET)" | shuf); do #shuf je opak sort = rozhodí karty
        _PEX[$I]=0
        PEX[$I]=$NAHODA
        let I++
    done
    for I in $(seq $I $(expr $I + $CAST_RADKU)); do _PEX[$I]=2; done

    # Zobrazit reseni
    #for I in ${PEX[*]}; do
    #    echo -n "$I "
    #done
    #echo
    #for I in ${_PEX[*]}; do
    #    echo -n "$I "
    #done
    #echo
}


function vykresli() {
    echo -n "     "
    for I in `seq $SLOUPCU`; do echo -n ' '; printf '%3d' $I; echo -n ' '; done
    echo
    for RADEK in $(seq 1 $RADKU); do
        # Cele je to rozdelene na 3 casti: ___, cisla a \_/
        FIRST=$(expr $SLOUPCU \* $(expr $RADEK - 1))
        LAST=$(expr $FIRST + $ISLOUPCU)
        # ___ ___ ___ ___
        echo -ne "     "
        for J in $(seq $FIRST $LAST); do
            if [ ${_PEX[$J]} -ne 2 ]; then
                echo -n " ___ "
            else
                echo -n "     "
            fi
        done
        echo

        # (...)(...)
        printf "%3s: " $RADEK
        for J in $(seq $FIRST $LAST); do
            case ${_PEX[$J]} in
            0)
                echo -n "(***)"
                ;;
            1)
                printf "(%3d)" ${PEX[$J]}
                ;;
            *)
                echo -n "  .  "
                ;;
            esac
        done
        echo

        # \_/ \_/
        echo -ne "     "
        for J in $(seq $FIRST $LAST); do
            if [ ${_PEX[$J]} -ne 2 ]; then
                echo -n " \_/ "
            else
                echo -n "     "
            fi
        done
        echo
    done
}


function volba () {
    while :; do
        echo -ne "Zadejte radek: "
        read RADEK
        let RADEK--
        echo -ne "Zadejte sloupec: "
        read SLOUPEC
        let SLOUPEC--
        KARTA=$(expr $(expr $RADEK \* $SLOUPCU) + $SLOUPEC)
        [ $KARTA -lt $DKARET ] && [ ${_PEX[$KARTA]} -eq 0 ] && _PEX[$KARTA]=1 \
                        && break
        echo "Chybné zadání"
    done
}


function dalsi_hrac () {
    if [ $A -ne $B ] && [ ${PEX[$A]} == ${PEX[$B]} ]; then
        let HRACI[$A_HRAC]++
        let TOTAL++
        _PEX[$A]=2
        _PEX[$B]=2
    else
        _PEX[$A]=0
        _PEX[$B]=0
        let A_HRAC++
        A_HRAC=`expr $A_HRAC % $HRACU`
    fi
    echo "Score: ${HRACI[*]}"
    if [ $TOTAL -eq $KARET ]; then
        A_HRAC=0
        for I in `seq 0 $IHRACU`; do
            [ ${HRACI[$A_HRAC]} -lt ${HRACI[$I]} ] && A_HRAC=$I
        done
        echo "Vyhrál hráč č. $A_HRAC s počtem karet ${HRACI[$A_HRAC]}"
        echo "Celkové skóre hráčů: ${HRACI[*]}"
        return 1
    else
        echo "Hraje hráč č. $A_HRAC"
    fi
}


function logo() {
    echo ' ____'
    echo '/\  _`\'
    echo '\ \ \L\ \ __   __  _    __    ____    ___'
    echo ' \ \ ,__/ __`\/\ \/ \ / __`\ / ,__\  / __`\'
    echo '  \ \ \/\  __/\/>  <//\  __//\__, `\/\ \L\ \'
    echo '   \ \_\ \____\/\_/\_\ \____\/\____/\ \____/'
    echo '    \/_/\/____/\//\/_/\/____/\/___/  \/___/'
    echo
}


# Zacatek
clear
echo "Hra pexeso; verze 0.01"
logo
# Úvodní výslech
declare -i KARET=8
declare -i HRACU=1
echo -n "Zadej počet karet: "
while [ true ]; do
    read KARET
    [ $KARET -gt 1 ] && [ $KARET -lt 1000 ] && break
    echo "1 > KARET < 1000"
done
echo -n "Zadej počet hráčů: "
while [ true ]; do
    read HRACU
    [ $HRACU -ge 1 ] && break
    echo "Zvol číslo >= 1"
done

# Proměnné
IKARET=`expr $KARET - 1`
DKARET=`expr $KARET \* 2`
IDKARET=`expr $DKARET - 1`
IHRACU=`expr $HRACU - 1`
A_HRAC=0
declare -a HRACI
for I in `seq 0 $IHRACU`; do HRACI[$I]=0; done
TOTAL=0 # konec když TOTAL == KARET

declare -a PEX  # 0=* 1=aktual 2=nic
declare -a _PEX
ZNAKU=$(tput cols)
SLOUPCU=$(expr $(expr $ZNAKU - 5) / 5)
[ $SLOUPCU -eq 0 ] && SLOUPCU=1
ISLOUPCU=`expr $SLOUPCU - 1`
RADKU=`expr $DKARET / $SLOUPCU`
CAST_RADKU=$(expr $SLOUPCU - $(expr $DKARET % $SLOUPCU))
[ $CAST_RADKU -ne 0 ] && let RADKU++


vygeneruj

echo "hraje hráč č. 0"
while [ $? -eq 0 ]; do
    vykresli
    volba
    A=$KARTA
    vykresli
    volba
    B=$KARTA
    vykresli
    echo -n "Stiskni enter pro pokračování"
    read
    clear
    logo
    dalsi_hrac
done
