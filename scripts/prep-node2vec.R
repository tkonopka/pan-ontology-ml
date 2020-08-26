# create oboname-edges.txt and oboname-nodes.txt files for node2vec

library(yaml)
library(data.table)
library(glue)
source(file.path("..", "R", "read.R"))

# read a definition of all foundry ontologies
data.dir = file.path("..", "data")
instances.dir = file.path(data.dir, "instances")
foundry.status.file = file.path(data.dir, "obofoundry-ontologies-status.tsv")
ols.status.file = file.path(data.dir, "ols-ontologies-status.tsv")
status.cols = c("ontology", "title", "available", "is_obsolete")
status = rbind(fread(foundry.status.file, select=status.cols),
               fread(ols.status.file, select=status.cols),
               use.names=TRUE)
status = status[available==TRUE & is_obsolete==FALSE]

# template to files with metadata
template.metadata = file.path(instances.dir, "{oboname}",
                              "{oboname}-metadata.yaml.gz")

# helper function - generates nodes.txt and edges.txt files for an ontology
prep.node2vec = function(oboname) {
  cat(paste0("preparing node2vec:  ", oboname, "\n"))
  i.dir = file.path(instances.dir, oboname)
  parents = read.parents(oboname, template=template.metadata)
  if (nrow(parents)==0) return(NULL)
  # set up conversion between ids and integers
  ids.indexes = data.table(id=unique(parents$id))
  ids.indexes$id_index = seq_len(nrow(ids.indexes))
  parents.indexes = copy(ids.indexes)
  setnames(parents.indexes, c("id", "id_index"), c("parent", "parent_index"))
  parents.indexes = merge(merge(parents, ids.indexes, by="id"),
                          parents.indexes, by="parent")
  parents.indexes = parents.indexes[parent!=""][order(id_index)]
  # write out the files
  nodes = paste0(ids.indexes$id_index, "\t", ids.indexes$id)
  write(nodes, file=file.path(i.dir, paste0(oboname, "-nodes.txt")))
  edges = paste0(parents.indexes$id_index, "\t", parents.indexes$parent_index)
  write(edges, file=file.path(i.dir, paste0(oboname, "-edges.txt")))
}

for (i in seq_len(nrow(status))) {
  prep.node2vec(status$ontology[i])
}

cat(paste0("\ndone - ", nrow(status), " ontologies\n"))

