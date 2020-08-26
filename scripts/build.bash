#!/bin/bash -l
# create crossmap instances for all ontologies

cd ../data/instances
CM=../../../crossmap

OBOSET=${1:-_instances.txt}
for OBONAME in $(cat $OBOSET)
do
  echo ""
  echo $OBONAME
  cd $OBONAME
  # build the crossmap instance
  if [ ! -d "crossmap-obo-$OBONAME" ]
  then
    $CM build --config config-obo-$OBONAME.yaml
  else
    echo "crossmap-obo-$OBONAME exists"
  fi
  cd ../
done

