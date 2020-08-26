#!/bin/bash -l
# create feature maps

cd ../data/instances
CM=../../../crossmap

OBOSET=${1:-_instances.txt}
for OBONAME in $(cat $OBOSET)
do
  echo ""
  echo $OBONAME
  cd $OBONAME
  # build a feature map from plain documents
  MAPFILE=$OBONAME-plain-feature-map.tsv
  if [ ! -f "$MAPFILE.gz" ]
  then
    $CM build --config config-obo-$OBONAME-plain.yaml
    cp crossmap-obo-$OBONAME-plain/crossmap-obo-$OBONAME-plain-feature-map.tsv $MAPFILE
    gzip $MAPFILE
  fi
  cd ../
done

