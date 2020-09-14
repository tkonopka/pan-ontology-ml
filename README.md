# pan-ontology-ml

This repository holds an analysis of the landscape of ontologies used in 
biomedical research. The analysis considers relationships between ontology
terms defined through ontology hierarchies and through implicit semantic 
similarity measures as captured by machine-learning models. 


## Setup

This repository can be used to perform an analysis from scratch, or in 
conjunction with a prepared dataset.

### Analysis from scratch

After cloning the analysis repository, set up the following files and 
directories.

 - `crossmap` script - bash script that executes the [crossmap](https://github.com/tkonopka/crossmap) program. 
 - `crossprep` script - bash script that executes the [crossprep](https://github.com/tkonopka/crossmap/tree/master/crossprep) python utility.
 - `data` directory - a directory that will hold data files and processed items.
 - a mongodb database compatible with 
 [crossmap](https://github.com/tkonopka/crossmap)
 
With the software and database in place, the next phases are to download 
ontology datasets and run analyses. These steps are described in the README in
 the `scripts` directory. 
 
The whole procedure utilizes more than 200 ontologies and performs several 
calculations on each ontology. The total running time may well exceed 100 hours.
  

### Analysis using prepared data

A snapshot of required datasets is available at 
[zenodo](https://zenodo.org/record/4029258). 
Download the snapshot zip file into the repository root and uncompress it. 
That should create a directory `data` with all raw and processed files.


### Visualizations

Visualizations are achieved via rmarkdown vignettes. To create
these, navigate into the `vignettes` directory, launch R, and render the vignettes.

```{r}
library(rmarkdown)
render("OntoML.Rmd")        
render("OntoML_Supplementary.Rmd")
```

During the first rendering, the vignettes will generate several files that will 
be stored under `vignettes/cache`. The first render will also require several 
minutes of compute and have a moderate memory footprint (16GB of RAM). 
Subsequent renders will be faster and more frugal with memory. 


## Repository structure

 - `R` directory - collection of functions for data processing and 
 visualization.
 - `scripts` directory - collection of scripts for downloading and processing
 data, see the `README` in that directory for details.
 - `vignettes` directory - location of Rmarkdown vignettes. The primary files
 are `OntoML.Rmd` and `OntoML_Supplementary.Rmd`. Other files are sourced
 from within those vignettes.
 
