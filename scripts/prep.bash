#!/bin/bash -l
# transform obo files into yaml collections

cd ../data/instances
CM=../../../crossprep

OBOSET=${1:-_instances.txt}
for OBONAME in $(cat $OBOSET)
do
  echo ""
  echo $OBONAME
  cd $OBONAME
  # summarize content in the obo
  SUMMARYFILE=$OBONAME-summary.json.gz
  if [ ! -f "$SUMMARYFILE" ]
  then
    $CM obo_summary --obo ../../obo/$OBONAME.obo --name $OBONAME
  else
    echo "$SUMMARYFILE exists"
  fi
  # prepare crossmap data
  for TYPE in parents plain
  do
    DATAFILE=$OBONAME-$TYPE.yaml.gz
    if [ ! -f "$DATAFILE" ]
    then
      $CM obo --obo ../../obo/$OBONAME.obo \
	       --obo_aux top,comments,synonyms,$TYPE \
	       --name $OBONAME-$TYPE
    else
      echo "$DATAFILE exists"
    fi
  done
  # prepare crossmap data with just term names
  DATAFILE=$OBONAME-name.yaml.gz
  if [ ! -f "$DATAFILE" ]
  then
    $CM obo --obo ../../obo/$OBONAME.obo \
       --obo_aux nodef \
       --name $OBONAME-name
  else
    echo "$DATAFILE exists"
  fi
  cd ../
done

