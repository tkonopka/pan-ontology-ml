#!/bin/bash -l
# create archive of the data directory

cd ../

# raw data files
zip -ur archive.zip data/*yaml data/*tsv data/*json data/*md
zip -ur archive.zip data/obo data/owl data/wiktionary
# processed files in data/instances
INSTANCES=data/instances
zip -ur archive.zip $INSTANCES/_selected.txt $INSTANCES/_instances.txt
zip -ur archive.zip $INSTANCES/wiktionary*
zip -ur archive.zip $INSTANCES/*/config* $INSTANES/*/summary*
zip -ur archive.zip $INSTANCES/*/*txt
zip -ur archive.zip $INSTANCES/*/*json.gz $INSTANCES/*/*yaml.gz
zip -ur archive.zip $INSTANCES/*/*tsv.gz

mv archive.zip pan-ontology-ml-archive.zip

exit 0

