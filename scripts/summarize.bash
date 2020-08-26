#!/bin/bash -l
# create summary docs for all ontologies

cd ../data/instances
CM=../../../crossmap

OBOSET=${1:-_instances.txt}
for OBONAME in $(cat $OBOSET)
do
  echo ""
  echo $OBONAME
  cd $OBONAME  
  if [ ! -f "summary-crossmap-obo-$OBONAME.json" ]
  then
    $CM summary --config config-obo-$OBONAME.yaml \
                --pretty > summary-crossmap-obo-$OBONAME.json
  else
    echo "summary crossmap-obo-$OBONAME exists"
  fi
  cd ../
done

