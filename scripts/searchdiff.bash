#!/bin/bash -l
# run search with diffusion (output as tsv)

cd ../data/instances
CM=../../../crossmap

OBOSET=${1:-_instances.txt}
for OBONAME in $(cat $OBOSET)
do
  echo ""
  echo $OBONAME
  cd $OBONAME
  for DIFF in 0 0.2 0.4 0.6 0.8 1 1.2 1.4 1.6 1.8 2
  do
    for TYPE1 in name plain
    do
      for DTYPE in plain parents
      do
        OUTSEARCH="search-$OBONAME-$TYPE1-data-name-diff-$DTYPE-$DIFF.tsv.gz"
        if [ ! -f "$OUTSEARCH" ]
        then
          $CM search --config config-obo-$OBONAME.yaml \
                     --pretty --tsv --n 5 \
                     --dataset $TYPE1 --diffusion "{\"$DTYPE\":$DIFF}" \
                     --data $OBONAME-name.yaml.gz \
              | gzip > $OUTSEARCH
        else
          echo "$OUTSEARCH exists"
        fi
      done
    done
  done
  cd ../
done

