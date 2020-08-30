# scripts

This folder contains scripts to be executed on the command line.


## download

First, download summaries of OBO Foundry and OLS ontologies. 

```
http://www.obofoundry.org/registry/ontologies.yml
https://www.ebi.ac.uk/ols/api/ontologies?size=1000
``` 

These data should be saved into `data/obofoundry-ontologies.yaml` and 
`data/ols-ontologies.json`. Then, run scripts to download raw ontology data.

```
R CMD BATCH download-foundry.R
R CMD BATCH download-ols.R
```

As a side effect, the scripts create tables summarizing all the ontologies and
filenames.



## Prepare files for analysis

Prepare configuration files for crossmap instances

```
R CMD BATCH prep-configs.R
```

The R script generates directory structures and configuration files for all
the ontologies. It also creates a simple list of ontology codes in a text 
file `data/instances/_instances.txt`.

Some of the follow-up analyses use a couple of derivative structures as 
examples. Files for those examples should be generated at this stage.

```
./heartbeat.bash             # generate files for a branch of the mp ontology
R CMD BATCH modifications.R  # generate modified ontologies (fbdv, go)
``` 
 
The preparation script create data collections for each ontology.

```
./prep.bash
./metadata.bash
```

 (These scripts may generate messages or errors for the mp-heartbeat ontology.
 Those messages can be ignored.)



## Build instances

After all the configurations and data collections are ready, the next stage
 is to build crossmap instances for each ontology.

```
./features.bash   # compute feature weights using plain data
./build.bash      # build instances with name, plain, parents collections
```

Once all the instances are build, another script can be used to estimate the
number of terms in each data collection, sparsity, and similar statistics.

```
./summarize.bash
```



## Perform search calculations

Search calculation use ontology data files. For each ontology, the terms are
 used as queries to check whether the instance can return the appropriate
  result back.

```
./search.bash
```

A separate script perform searches at various diffusion settings. Exploring
many diffusion settings can take a long time, so it is recommended to run
this on a subset of ontologies. The subset can be specified via a text file.

```
./searchdiff.bash _casestudies.txt
```


## Follow-up calculations

Follow-up calculations support visualizations in the manuscript. 

```
# vector representation of certain HP ontology terms
./hp.bash
# prepare inputs for node2vec
./prep-node2vec.R
./node2vec.bash
```

