#!/bin/bash -l
# script to run crossmap build for the mp-heartbeat dataset
#
#
# USAGE:
# just run the script from within the prep directory without arguments


cd ../data/instances/mp-heartbeat

CB=../../../crossprep
CM=../../../crossmap

# create data files
$CB obo --obo ../../obo/mp.obo --obo_root MP:0004085 \
        --obo_aux top,comments,synonyms,parents --name mp-heartbeat-parents
$CB obo --obo ../../obo/mp.obo --obo_root MP:0004085 \
        --obo_aux top,comments,synonyms --name mp-heartbeat-plain
$CB obo --obo ../../obo/mp.obo --obo_root MP:0004085 \
        --obo_aux nodef --name mp-heartbeat-name
$CB obo --obo ../../obo/mp.obo --obo_root MP:0004085 \
        --obo_only_meta --name mp-heartbeat-metadata
$CB obo_summary --obo ../../obo/mp.obo --obo_root MP:0004085 \
        --name mp-heartbeat


