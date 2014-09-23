#!/bin/bash
#Pomocné proměnné
# zobraz adresáře v současné složce
LS_DIR="find . -maxdepth 1 -xtype d" # xtype aby zobrazil adresáře i symlinky
ROOT=$(pwd)


# Funkce

# Vypíše na obrazovku soubor story.txt z aktuálního adresáře
function read_page() {
    cat story.txt
}


# Změním aktuální adresář a uložím aktuální stránku (pro příští spuštění)
function change_dir() {
    cd -P $1
    echo $PWD > $ROOT/state
}


# Ověří, jestli existují soubory name.txt a story.txt v prvním parametru fce.
function is_page() {
    [ $1 == '.' ] && return 1   # Adresáře . a .. nechceme
    [ $1 == '..' ] && return 1  # (dopředu, zpátky ni krok)
    if [ -f $1/name.txt ] && [ -f $1/story.txt ]; then
        return 0
    else
        return 1
    fi
}


# Vypíše možnosti přechodu
function show_choices() {
    I=0
    for NAME in $($LS_DIR); do
        let I++
        is_page $NAME
        if [ $? -eq 0 ]; then
            echo -n "$I: "
            cat $NAME/name.txt
        fi
    done
    [ $I -le 2 ] && return 1
    return 0
}


# Vypíše možné volby a zpracuje uživatelovu volbu
function change_page() {
    false   # Zaručím vstup do cyklu
    while [ $? -eq 1 ]; do
        echo
        # Vypiš možnosti a pokud žádné nejsou, ukonči funkci a vrať 1
        show_choices || return 1
        echo -n "Vaše volba (?): "
        read choice
        # Zkus, jestli nejde o speciální volbu
        process_choice $choice
        # Pokud nebyla volba zpracována a je číselná, ověř její platnost
        if [ $? == 0 ] && [[ $choice = *[[:digit:]]* ]] && \
                [ $choice -le $($LS_DIR | wc -l) ]; then
            DIR=$($LS_DIR | head -n $choice | tail -n 1)
            is_page $DIR
        else
            false
        fi
    done
    # Získal jsem platnou stránku, přejdu na ní
    change_dir $DIR
}


# Vypíše aktuální adresář který odpovídá aktuální stránce
function print_state() {
    echo "Právě se nacházíš zde: $PWD"
}


# Pokud je $1 adresář stranou knihy, pak na ni přejde
function load_state() {
    [ $1 ] && STATE=$1 || { echo -n "Zadej pozici " ; read STATE ;}
    is_page $STATE && change_dir $STATE || echo "Strana neexistuje!"
    read_page
}


# Vypíše stav a zeptá se uživatele na ukončení
function ask_exit() {
    print_state
    echo -n "Opravdu chcete ukončit hru? (a/N) "
    read EXIT
    [ $EXIT == a ] && exit
}


# Vypíše čísla 1-požadované číslo
function random() {
    [ $1 ] && RANGE=$1 || { echo -n "Rozsah kostky:" ; read RANGE ;}
    echo Padla ti $(expr $RANDOM % $RANGE + 1)ka
}


# Vypíše nápovědu
function print_help() {
    echo -n 'Další postup je na tobě. Můžeš použít číslo odkazu, nebo jednu z'
    echo 'voleb:'
    echo '?, H, h: Nápověda'
    echo 'P, p: Znovu ukaž stránku'
    echo '6k, 10k, 12k: Hoď 6, 10, 12-ti stěnkou'
    echo '#, R, r: Generování náhodného čísla (může následovat počet stran)'
    echo 'home: začni znovu'
    echo 'S, s: Výpis aktuálního stavu postavy'
    echo 'L, l: Nahraj pozici'
    echo 'Q, q: Ukončit hru'
}


# Zkusí obsloužit volbu. Pokud obsloužím, vrátím 1
function process_choice() {
    case $1 in
    home)
        change_dir $ROOT
        read_page
        ;;
    6k)
        random 6
        ;;
    10k)
        random 10
        ;;
    12k)
        random 12
        ;;
    [?Hh]*)
        print_help
        ;;
    [#Rr]*)
        random $2
        ;;
    [Pp]*)
        read_page
        ;;
    [Ss]*)
        print_state
        ;;
    [Ll]*)
        load_state $2
        ;;
    [Qq]*)
        ask_exit
        ;;
    [a]*)
        add_page
        ;;
    [A]*)
        add_link_note
        ;;
    *)
        return 0
        ;;
    esac
    return 1
}


# Přidá stránku (umožní napsat i text)
function add_page() {
    # Změním oddělovač na celou řádku
    _IFS=$IFS
    export IFS=$(echo)
    echo -n "Zadej název nové stránky: "
    read NAME
    FILE_NAME=$(echo $NAME | cut -d ' ' -f 1)
    _FILE_NAME=$FILE_NAME
    I=0
    while [ -d $FILE_NAME ]; do
        let I++
        FILE_NAME="${_FILE_NAME}_$I"
    done
    mkdir $FILE_NAME
    echo $NAME > $FILE_NAME/name.txt

    echo "Napište příběh (ukončíte odesálním prázdného řádku)"
    read STORY
    while [ $STORY ]; do
        echo $STORY >> $FILE_NAME/story.txt
        # Two enters per entry
        echo >> $FILE_NAME/story.txt
        read STORY
    done
    # Opět nastavím oddělovač na mezery
    export IFS=$_IFS
}


# Přidá soubor do aktuálního adresáře se zadaným textem (pro poznámky např. o
# vytvoření symlinku na určitou stránku)
function add_link_note() {
    _IFS=$IFS
    export IFS=$(echo)
    echo -n "Zadej název odkazu: "
    read NAME
    FILE_NAME=$(echo $NAME | cut -d ' ' -f 1)
    _FILE_NAME=$FILE_NAME
    I=0
    while [ -f $FILE_NAME ]; do
        let I++
        FILE_NAME="${_FILE_NAME}_$I"
    done
    echo $NAME > $FILE_NAME
    export IFS=$_IFS
}


# Vlastní program
echo "Gamebook v0.01"
# Nahraj poslední stránku
[ -f $ROOT/state ] && change_dir $(cat state)

# Hlavní smyčka
while [ true ]; do
    # Vypiš stránku
    read_page

    # Přejdi na další
    change_page
    # Vrátí 1 když nejsou žádné další možnosti (konec knihy)
    if [ $? -eq 1 ]; then
        echo ".. zazvonil zvonec a pohádky byl konec."
        echo
        echo -n "Chceš začít znovu? (A/n/q) " # -n neodentruje nový řádek
        read EXIT
        case $EXIT in
        n)
            print_help
            read CHOICE
            process_choice $CHOICE
            ;;
        q)
            break
            ;;
        *)
            change_dir $ROOT
            ;;
        esac
    fi
done
