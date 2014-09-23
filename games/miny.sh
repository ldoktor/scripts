#!/bin/bash
function generuj_plochu()
{
    POMOC=$POLICEK
    for I in $(seq 0 $IPOLICEK); do
        PLOCHA[$I]=0
        MASKA[$I]=0
    done
    echo "Generuji miny:"
    while [ $POMOC -gt $(expr $POLICEK - $MIN) ]; do
        MINA=$(random $IPOLICEK)
        [ ${PLOCHA[$MINA]} == 'M' ] && continue
        PLOCHA[$MINA]='M'
        let POMOC--
        echo -n "$(expr $POLICEK - $POMOC) "
    done
    echo
    echo "Přepočítávám plochu:"
    for I in $(seq 0 $IPOLICEK); do
    	POCET_MIN=0
        [ ${PLOCHA[$I]} == 'M' ] && continue
        MODULO=$(expr $I % $SLOUPCU)
        #reseni aktuálního řádku
        [ $MODULO -ne 0 ] && [ ${PLOCHA[$I-1]} == 'M' ] && let POCET_MIN++
        [ $MODULO -ne $ISLOUPCU ] && [ ${PLOCHA[$I+1]} == 'M' ] && let POCET_MIN++
        if [ $I -gt $ISLOUPCU ]; then
            [ ${PLOCHA[$I-$SLOUPCU]} == 'M' ] && let POCET_MIN++
            [ $MODULO -ne 0 ] && [ ${PLOCHA[$I-1-$SLOUPCU]} == 'M' ] && let POCET_MIN++
            [ $MODULO -ne $ISLOUPCU ] && [ ${PLOCHA[$I+1-$SLOUPCU]} == 'M' ] && let POCET_MIN++
        fi

        if [ $I -lt $(expr $POLICEK - $SLOUPCU) ]; then
            [ ${PLOCHA[$I+$SLOUPCU]} == 'M' ] && let POCET_MIN++
            [ $MODULO -ne 0 ] && [ ${PLOCHA[$I-1+$SLOUPCU]} == 'M' ] && let POCET_MIN++
            [ $MODULO -ne $ISLOUPCU ] && [ ${PLOCHA[$I+1+$SLOUPCU]} == 'M' ] && let POCET_MIN++
        fi
        PLOCHA[$I]=$POCET_MIN
        echo -n "$I "
    done
    echo
    echo
}


function random() {
    echo $(expr $RANDOM % $1)
}


function zobraz_plochu()
{
    echo -ne "\e[01;37m  "
    for I in $(seq 1 $SLOUPCU); do
        echo -n "$I "
    done
    echo -e "\e[00m"
    for I in $(seq 0 $IRADKU); do
        echo -en "\e[01;37m$(expr $I + 1) \e[00m"
        for J in $(seq 0 $ISLOUPCU); do
            if [ ${MASKA[$SLOUPCU*$I+$J]} -eq  1 ];then
                if [ ${PLOCHA[$SLOUPCU*$I+$J]} == 'M' ]; then
                    echo -en "\e[00;31mM\e[00m "
                else
                    echo -n "${PLOCHA[$SLOUPCU*$I+$J]} "
                fi
            else
                echo -n '. '
            fi
        done
        echo
    done
}


function dalsi_volba()
{
    echo
    echo -n "Vyber další radek: "
    while [ true ]; do
        read RADEK
        [ $RADEK -ge 1 ] && [ $RADEK -le $RADKU ] && break
        echo "Chybná volba!"
    done
    let RADEK--
    echo -n "Vyber další sloupec: "
    while [ true ]; do
        read SLOUPEC
        [ $SLOUPEC -ge 1 ] && [ $SLOUPEC -le $SLOUPCU ] && break
        echo "Chybná volba!"
    done
    let SLOUPEC--
}


function analyza_vysledku()
{
    POLICKO=$(expr $(expr $SLOUPCU \* $RADEK) + $SLOUPEC)
    if [ ${PLOCHA[$POLICKO]} == 'M' ]; then
        echo "Prohrál jsi"
        return 1
    fi
    if [ ${MASKA[$POLICKO]} -eq 0 ]; then
        let POMOC--
        MASKA[$POLICKO]=1
    fi
    if [ $POMOC -eq 0 ]; then
        echo "Vyhrál jsi"
        return 1
    fi
}


function navrhni_plochu() {
    echo -n "Zadej pocet radku: "
    read RADKU
    echo -n "Zadej pocet sloupcu: "
    read SLOUPCU
    [ $RADKU -lt 2 ] && RADKU=2
    [ ! $SLOUPCU ] && SLOUPCU=$RADKU
    [ $SLOUPCU -lt 2 ] && SLOUPCU=$RADKU
    IRADKU=$(expr $RADKU - 1)
    ISLOUPCU=$(expr $SLOUPCU - 1)
    POLICEK=$(expr $RADKU \* $SLOUPCU)
    IPOLICEK=$(expr $POLICEK - 1)
    echo -n "Zadej počet min: "
    read MIN
    [ $MIN -lt 1 ] && MIN=1
}


echo "Vítám Vás v programu miny"
navrhni_plochu

generuj_plochu
#echo ${PLOCHA[*]}
declare -i RADKU
declare -i SLOUPCU
declare -i RADEK
declare -i SLOUPEC

EXIT=0
while [ $EXIT == 0 ]
do
    zobraz_plochu
    dalsi_volba
    analyza_vysledku
    EXIT=$?
done

for I in $(seq 0 $IPOLICEK); do
    MASKA[$I]=1
done
zobraz_plochu
