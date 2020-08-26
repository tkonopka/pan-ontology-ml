# download obo files from the obofoundry

library(data.table)
library(jsonlite)
library(curl)
source("download-tools.R")
source("obo.R")


# read a definition of all ontologies stored in ols
data.dir = file.path("..", "data")
ols.file = file.path(data.dir, "ols-ontologies.json")
ols = data.table(fromJSON(ols.file)[["_embedded"]][[1]])
# the download will avoid foundry ontologies
foundry.file = file.path(data.dir, "obofoundry-ontologies-status.tsv")
foundry = fread(foundry.file)
foundry.small = data.table(ontology=foundry$ontology, foundry=TRUE)

# output directories
obo.dir = file.path(data.dir, "obo")
owl.dir = file.path(data.dir, "owl")
if (!dir.exists(obo.dir)) {
  dir.create(obo.dir)
}
if (!dir.exists(owl.dir)) {
  dir.create(owl.dir)
}


###############################################################################
# prepare a skeleton object for a status

# prepare a summary table and avoid items that overlap with the obo foundry
result = data.table(core_ontology=ols$ontologyId,
                    ontology=ols$ontologyId,
                    filename=ols$config.fileLocation,
                    title=ols$config.title,
                    status="NA",
                    obo_available=FALSE,
                    owl_available=FALSE,
                    available=FALSE,
                    file_size=NA,
                    is_obsolete=FALSE)
result = result[!ontology %in% foundry$ontology]


###############################################################################
# download files

# download all the owl and obo files
for (i in seq_len(nrow(result))) {
  cat(paste0("processing: ", result$ontology[i], "\n"))
  i.filename = result$filename[i]
  owl.files = download.files(i.filename,
                             local.dir=owl.dir,
                             local.filename=paste0(result$ontology[i], ".owl"))
  if (length(owl.files)>0) {
    result$filename[i] = basename(owl.files)
    result$owl_available[i] = TRUE
  } else {
    result$filename[i] = as.character(NA)
  }
}


###############################################################################
# convert from owl to obo

for (i in seq_len(nrow(result))) {
  i.file = result$filename[i]
  if (!is.na(i.file) & endsWith(i.file, "owl")) {
    convert.owl(i.file)
    result$filename[i] = gsub(".owl$", ".obo", i.file)
  }
  result$available[i] = file.exists(file.path(obo.dir, result$filename[i]))
}



###############################################################################
# add file metadata

# fill in the file size & release-date
result$file_size = as.integer(NA)
result$date = as.character(NA)
for (i in seq_len(nrow(result))) {
  i.file = file.path(obo.dir, result$filename[i])
  if (file.exists(i.file) & !dir.exists(i.file)) {
    result$file_size[i] = file.info(i.file)$size
    result$date[i] = obo.date(i.file)
  }
}


# wrap up
fwrite(result,
       file=file.path(data.dir, "ols-ontologies-status.tsv"),
       sep="\t")

