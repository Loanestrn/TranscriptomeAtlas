#!/bin/bash
#télécharger ceux qui ont que l'id dans le nom
while read GEOID; do
    wget -O "csv/${GEOID}.csv.gz" "https://www.ncbi.nlm.nih.gov/geo/download/?acc=${GEOID}&format=file&file=${GEOID}_data.csv.gz"
    gunzip -f "csv/${GEOID}.csv.gz"
done < geoid.txt 

