#!/bin/bash
#$1 co hledam, $2 kolik nasledujicich rade vypsat, $3 v jakem souboru
awk '{ if ($0 ~ /'$1'/) { for (x=0;x <= '$2';x++) { print ; getline } } }' $3
