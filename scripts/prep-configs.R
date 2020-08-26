# convert obo files into yamls for crossmap

library(yaml)
library(data.table)


# read a definition of all foundry ontologies
data.dir = file.path("..", "data")
obo.dir = file.path(data.dir, "obo")
foundry.status.file = file.path(data.dir, "obofoundry-ontologies-status.tsv")
ols.status.file = file.path(data.dir, "ols-ontologies-status.tsv")
status = rbind(fread(foundry.status.file),
               fread(ols.status.file),
               use.names=TRUE)
status = status[available==TRUE & is_obsolete==FALSE]

# read configuration templates for the instances
template.file.type = "config-obo-OBONAME-TYPE.yaml"
template.file = "config-obo-OBONAME.yaml"

# output directory
instances.dir = file.path(data.dir, "instances")


# helper function - generates two config files for each ontology
prep.obo.config = function(oboname, obotype,
                           template.path=template.file.type) {
  cat(paste0("preparing configs:  ", oboname, " ", obotype, "\n"))
  i.dir = file.path(instances.dir, oboname)
  if (!dir.exists(i.dir)) {
    dir.create(i.dir)
  }
  template = readLines(template.path)
  template = gsub("AUXFILE", file.path("..", "wiktionary_10.yaml.gz"), template)
  configtext = gsub("TYPE", obotype,
                    gsub("OBONAME", oboname, template))
  configfile = gsub("TYPE", obotype,
                    gsub("OBONAME", oboname, template.path))
  write(configtext, file=file.path(i.dir, configfile))
}


for (i in seq_len(nrow(status))) {
  prep.obo.config(status$ontology[i], "plain", template.file.type)
  prep.obo.config(status$ontology[i], "", template.file)
}

cat(paste0("\ndone - ", nrow(status), " ontologies\n"))

# misc - also generate files for an exemplar ontology
misc.obo = c("mp-heartbeat", "fbdv-isa", "go-isa")
for (i.misc.obo in misc.obo) {
  prep.obo.config(i.misc.obo, "plain", template.file.type)
  prep.obo.config(i.misc.obo, "", template.file)
}

# write the names of all instance directories (for a bash script)
write(c(status$ontology, misc.obo),
      file.path(instances.dir, "_instances.txt"))

