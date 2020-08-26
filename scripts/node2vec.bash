#!/bin/bash -l
# transform edge/graphs into node2vec embeddings
# (requires an executable node2vec script/link)

cd ../data/instances
NODE2VEC=../../../node2vec

OBOSET=${1:-_instances.txt}
for OBONAME in $(cat $OBOSET)
do
  echo ""
  echo $OBONAME
  cd $OBONAME
  EDGESFILE=$OBONAME-edges.txt
  N2VFILE=$OBONAME-node2vec.txt
  if [ ! -f "$N2VFILE" ]
  then
    $NODE2VEC -i:$EDGESFILE -o:$N2VFILE -d:2
  else
    echo "$N2VFILE exists"
  fi
  cd ../
done

