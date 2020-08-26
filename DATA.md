# Data files for the pan-ontology-ml project

The `data` folder holds data files associated with the OntoML project. 
The content can be used together with code in 
[pan-ontology-ml](www.github.com/tkonopka/pan-ontology-ml).


# `data` directory

 - `obo-db.yaml` - docker-compose configuration that launches a mongodb 
 instance. A database setup is only required if data files are used together 
 with the scripts in OntoML.
 - `obofoundry-ontologies.yaml` - summary of ontologies in the 
 [OBO foundry](www.obofoundry.org) (original download)
 - `obofoundry-ontologies-status.tsv` - summary of ontologies in the Obo 
  foundry (processed table)
 - `ols-ontologies.json` - summary of ontologies in the 
 [Ontology Lookup Service](https://www.ebi.ac.uk/ols/index) (original download)
 - `ols-ontologies-status.tsv` - summary of ontologies in the Ontology Lookup 
 Service (processed table)
 

# `data/wiktionary` directory

Raw data from the English-language [wiktionary](www.wiktionary.org) and 
processed yaml.

The raw wiktionary file was downloaded from a publicly available 
[repository](https://dumps.wikimedia.org/). Please see the wiktionary 
[wiki](https://en.wiktionary.org/wiki/Help:FAQ#Downloading_Wiktionary) for 
terms of use.


# `data/owl` directory

Raw downloaded `.owl` files from the OBO foundry and the OLS. Note that `.owl` 
files were only downloaded when `.obo` files were not available.

All files were downloaded from publicly accessible APIs. Please see individual 
files for terms of use. This archive reproduces raw files to document the
data versions used to generate study results.


# `data/obo` directory

Most files are raw downloaded `.obo` files from the OBO foundry and from the 
OLS. Some files represent conversions from the `.owl` format.

All files were downloaded from publicly accessible APIs. Please see individual
files for terms of use. This archive reproduces raw files to document the data
version used to generate study results.


# `data/instances` directory

The `instances` directory holds one subdirectory for each ontology. Files 
represent processed ontology content and outputs from analyses.

 - `config-*` - configuration files for 
 [crossmap](www.github.com/tkonopka/crossmap) instances.
 - `*-feature-map.tsv.gz` - tables listing k-mers used in crossmap models
 and their weights. Weights were estimated using an inverse-document frequency
 approach using wiktionary entries and documents in 'plain' ontology datasets.
 - `summary-*` - objects summarizing the state of crossmap instances.
 - `*-name.yaml.gz, *-plain.yaml.gz, *-parents.yaml.gz` - data files that
 capture information from ontology terms in a format for crossmap analysis.
 - `*-metadata.yaml.gz` - similar in format to crossmap data files, but 
 containing only metadata for each ontology term.
 - `search-*` - tables with search results as output by crossmap. The format 
 has three columns: `query`, `target`, and `distance`. Different files capture 
 outputs from different search scenarios. The primary filename pattern is 
 `{obotype}-data-{datatype}`, which indicates that a nearest-neighbor index
 trained with `{obotype}` data had been searched with `{datatype}` queries. 
 Additional suffixes indicate diffusion settings, or the number of nearest 
 neighbors per query.
 
Note that archived data files contain configurations, input datasets, and search
results. The trained crossmap models used to generate search results are not 
included in the archive (because these would have to be synchronized with a 
database). However, the archived files are sufficient to recreate crossmap 
models and to generate search tables as those in the archive (c.f. 
[OntoML](www.github.com/tkonopka/OntoML)). Re-created search results may differ
slightly from archived results due to stochasticity in the training of 
approximate nearest-neighbor models.

