# download obo files from the obofoundry

library(data.table)
library(yaml)
library(curl)
source("download-tools.R")
source("obo.R")


# read a definition of all foundry ontologies
data.dir = file.path("..", "data")
obofoundry.file = file.path(data.dir, "obofoundry-ontologies.yaml")
foundry = suppressWarnings(read_yaml(obofoundry.file))

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

# prepare a summary table (some empty spots)
get.key = function(x, key="a") {
  if (!key %in% names(x)) return(NA)
  x[[key]]
}
result = data.table(core_ontology=sapply(foundry$ontologies, get.key, key="id"),
                    ontology=sapply(foundry$ontologies, get.key, key="id"),
                    filename=as.character(NA),
                    title=sapply(foundry$ontologies, get.key, key="title"),
                    status=sapply(foundry$ontologies, get.key, key="activity_status"),
                    obo_available=FALSE,
                    owl_available=FALSE,
                    available=FALSE,
                    file_size=as.integer(NA),
                    is_obsolete=as.logical(sapply(foundry$ontologies, get.key,
                                                  key="is_obsolete")))
result$is_obsolete[is.na(result$is_obsolete)] = FALSE


###############################################################################
# download files

# download all the owl and obo files
for (i in seq_along(foundry$ontologies)) {
  info = foundry$ontologies[[i]]
  cat(paste0("processing: ", info$id, "\n"))
  if (!"is_obsolete" %in% names(info)) {
    product.purl = sapply(info$products, function(x) { x$ontology_purl })
    owl.purl = grep("owl$", grep("http", product.purl, value=T), value=T)
    obo.purl = grep("obo$", grep("http", product.purl, value=T), value=T)
    owl.purl = owl.purl[!duplicated(basename(owl.purl))]
    obo.purl = obo.purl[!duplicated(basename(obo.purl))]
    if (length(obo.purl)>0) {
      obo.files = download.files(obo.purl)
      result$filename[i] = paste(basename(obo.files), collapse=",")
      result$obo_available[i] = TRUE
    } else if (length(owl.purl)>0) {
      owl.files = download.files(owl.purl)
      result$filename[i] = paste(basename(owl.files), collapse=",")
      result$owl_available[i] = TRUE
    }
  } else {
    cat("-- skipping, obsolete --\n")
  }
}

# redefine the table to place multiple files on separate lines
result = result[, list(filename=unlist(strsplit(filename, ","))),
                by=setdiff(colnames(result), "filename")]
result$ontology = gsub(".owl$", "", gsub(".obo$", "", result$filename))
setcolorder(result, c("core_ontology", "ontology", "title", "filename"))




###############################################################################
# convert from owl to obo

for (i in seq_len(nrow(result))) {
  i.file = result$filename[i]
  if (!is.na(i.file)) {
    if (endsWith(i.file, "owl")) {
      convert.owl(i.file)
      result$filename[i] = gsub(".owl$", ".obo", i.file)
    }
    result$available[i] = file.exists(file.path(obo.dir, result$filename[i]))
  }
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
       file=file.path(data.dir, "obofoundry-ontologies-status.tsv"),
       sep="\t")

