#Najde sidney a vypise 50 radku
awk '{ if ($0 ~ /sidney/) { for (x=0;x <= 50;x++) { print ; getline } } }' /misc/backup/hda.iso |tee ~/hda.filtered.sidney
