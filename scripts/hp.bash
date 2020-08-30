#!/bin/bash -l
# script to run crossmap followup calculations on the hp ontology
#
#
# USAGE:
# just run the script from within the prep directory without arguments


cd ../data/instances/hp
CM=../../../crossmap

# create features maps
$CM features --config config-obo-hp.yaml --pretty \
             | gzip > hp-features.json.gz

# create vector representations for certain ids
$CM vectors --config config-obo-hp.yaml --pretty \
            --ids HP:0020134,HP:0012085,HP:0011991 \
            | gzip > hp-vectors-HP_0020134.json.gz

# diffusion (requires pre-prepared small yaml files)
for HPID in HP_0020134
do
  for DIFF in 0 1
  do
    $CM diffuse --config config-obo-hp.yaml --pretty \
                --data $HPID-name.yaml \
                --diffusion "{\"parents\":$DIFF}" \
                | gzip > hp-diffusion-$HPID-diff-parents-$DIFF.json.gz
    done
done

