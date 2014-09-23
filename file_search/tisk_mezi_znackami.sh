#!/bin/bash
#$1 zacatek, $2 konec, $3 v jakem souboru
sed n '/'$1'/,/'$2'/p' $3
