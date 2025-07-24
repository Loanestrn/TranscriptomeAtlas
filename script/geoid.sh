#!/bin/bash
#telecharger ceux qui ont autre choses que l'id dans le nom 
while read FILENAME GEOID; do
  wget -q -O "csv/${FILENAME}.csv.gz" "https://www.ncbi.nlm.nih.gov/geo/download/?acc=${GEOID}&format=file&file=${FILENAME}.csv.gz"
  gunzip -f "csv/${FILENAME}.csv.gz"
done < geoid.txt