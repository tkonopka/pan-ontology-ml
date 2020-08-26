#!/bin/bash -l
# run search (output as tsv)

cd ../data/instances
CM=../../../crossmap

OBOSET=${1:-_instances.txt}
for OBONAME in $(cat $OBOSET)
do
  echo ""
  echo $OBONAME
  cd $OBONAME
  # search with 5 neighbors
  for TYPE1 in parents plain name
  do
    for TYPE2 in parents plain name
    do
      # run search
      OUTSEARCH="search-$OBONAME-$TYPE1-data-$TYPE2.tsv.gz"
      if [ ! -f "$OUTSEARCH" ]
      then
        $CM search --config config-obo-$OBONAME.yaml \
                   --pretty --tsv --n 5 --dataset $TYPE1 \
                   --data $OBONAME-$TYPE2.yaml.gz \
            | gzip > $OUTSEARCH
      else
        echo "$OUTSEARCH exists"
      fi
    done
  done
  # search with 15 neighbors
  for TYPE2 in parents plain
  do
    OUTSEARCH="search-$OBONAME-plain-data-$TYPE2-k15.tsv.gz"
    if [ ! -f "$OUTSEARCH" ]
    then
      $CM search --config config-obo-$OBONAME.yaml \
                 --pretty --tsv --n 15 --dataset plain \
                 --data $OBONAME-$TYPE2.yaml.gz \
          | gzip > $OUTSEARCH
    else
      echo "$OUTSEARCH exists"
    fi
  done
  cd ../
done

