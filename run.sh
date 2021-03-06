#!/bin/bash

matrice="matrice.csv"
mfront="GursonTvergaardNeedleman1982"
salome="Ct.med"
mesh="CT_mesh.dgibi"
data_calcul="data_calcul.dgibi"
calcul="CT_calc.dgibi"
post="CT_post.dgibi"
procedur="procedur.tar"

OLDIFS=$IFS
IFS=";"

[ ! -f $matrice ] && { echo "$matrice file not found"; exit 99; }
#while read B0 DIME0 GTN LINEAR PHI
while read B0 a_0 DIME0 LINE0 BBAR0 REDU0 GTN PHI 
do
  echo "-- B, CT thickness (mm) : $B0"
  echo "-- a0, initial crack length (mm) : $a_0"
  echo "-- 2D / 3D : $DIME0"
  echo "-- Linear elements : $LINE0"
  echo "-- Selective integration elements : $BBAR0"
  echo "-- Reduced integration elements : $REDU0"
  echo "-- Damage : $GTN"
  echo "-- Thermal fluence : $PHI"
  PHI0=${PHI:0:3}

# Calcul
  sed -i "/B0/c\ $B0 B0" $data_calcul
  sed -i "/a_0/c\ $a_0 a_0" $data_calcul
  sed -i "/DIME0/c\ $DIME0 DIME0" $data_calcul
  sed -i "/LINE0/c\ $LINE0 LINE0" $data_calcul
  sed -i "/BBAR0/c\ $BBAR0 BBAR0" $data_calcul
  sed -i "/REDU0/c\ $REDU0 REDU0" $data_calcul
  sed -i "/GTN/c\ $GTN GTN" $data_calcul
  sed -i "/PHI/c\ $PHI0 PHI" $data_calcul

# Creer le repertoire de l essai
  B0=${B0//./_}
  mkdir -p CT"$B0"_phi$PHI0
  cd CT"$B0"_phi$PHI0
  cp ../$mfront".tar" .
  cp ../$data_calcul .
  cp ../$salome .
  cp ../$mesh .
  cp ../$calcul .
  cp ../$post .
  cp ../$procedur .

# MFront
  tar xvf $mfront".tar"
  mfront --obuild --interface=castem $mfront".mfront"

# Maillage
  if [[ $DIME0 == 3 && $REDU0 == 1 ]]
  then
    cp ../*eso .
    compilcast20 elquoi.eso
    essaicast20
  fi
  tar -xvf $procedur
  castem20 -u $mesh > out_mesh_CT$B0

# Calcul
  tar -xvf $procedur
  castem20 -u $calcul > out_calcul_CT$B0

# Post-traitement
  mkdir -p POST/
  cd POST/
  cp ../VisuPG_v7.procedur .
  cp ../*.sauv .
  cp ../$data_calcul .
  cp -r ../src/ .
  cp ../$post .
  castem20 -u $post > out_post_CT$B0

# Sortir du repertoire d essai
  cd ../..

done < $matrice
IFS=$OLDIFS
