#!/bin/bash -l
# run crossprep obo to extract metadata from obo files

cd ../data/instances
CM=../../../crossprep

for OBONAME in $(cat _instances.txt)
do
  echo ""
  echo $OBONAME
  cd $OBONAME
  METADATA="$OBONAME-metadata.yaml.gz"
  if [ ! -f "$METADATA" ]
  then
    $CM obo --obo ../../obo/$OBONAME.obo --obo_only_meta \
	          --name $OBONAME-metadata
  else
    echo "$METADATA exists"
  fi
  cd ../
done


