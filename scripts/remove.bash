#!/bin/bash -l
# remove crossmap instances for all ontologies

cd ../data/instances
CM=../../../crossmap

for OBONAME in $(cat _instances.txt)
do
  echo ""
  echo $OBONAME
  cd $OBONAME
  for TYPE in parents plain
  do
    $CM remove --config config-obo-$OBONAME-$TYPE.yaml
  done
  cd ../
done

