# configuration variables for OntoML.Rmd



# ############################################################################
# libraries/packages

suppressMessages(library(data.table))
suppressMessages(library(igraph))
suppressMessages(library(shape))
suppressMessages(library(R.utils))
suppressMessages(library(viridis))
library(parallel)
library(yaml)
suppressMessages(library(jsonlite))
library(curl)
suppressMessages(library(Rcssplot))
library(shrt)
suppressMessages(library(glue))
suppressMessages(library(umap))



# ############################################################################
# paths to directories

# this assumes the script is executes from vignettes/
R.dir = file.path("..", "R")
scripts.dir = file.path("..", "scripts")
data.dir = file.path("..", "data")
instances.dir = file.path(data.dir, "instances")
tables.dir = file.path("tables")
if (!dir.exists(tables.dir)) {
  dir.create(tables.dir)
}


# ############################################################################
# custom functions from R directory

.rfiles = c("json", "read",
            "plot_general", "plot_graph",
            "plot_hist", "plot_bars", "plot_scatter", "plot_line",
            "plot_heattable", "plot_heatmap", "plot_ontologyterm",
            "plot_ontology_embedding",
            "plot_yaml")
for (.rfile in .rfiles) {
  source(file.path(R.dir, paste0(.rfile, ".R")))
}
rm(.rfile, .rfiles)




# ############################################################################
# constants, thesholds, paths, etc

# path to graphics styles
RcssDefaultStyle = Rcss("OntoML.css")

# labels to designate plot panels
panel.labels = LETTERS
show.panel.labels=TRUE

# cache directory
cachedir(paste0("cache"))


# templates for disk files
obodir.template = file.path(data.dir, "instances", "{oboname}")
file.templates = list(
  obo.summary = file.path(obodir.template,
                          "{oboname}-summary.json.gz"),
  crossmap.summary = file.path(obodir.template,
                            "summary-crossmap-obo-{oboname}.json"),
  metadata = file.path(obodir.template,
                       "{oboname}-metadata.yaml.gz"),
  search.results = file.path(obodir.template,
                             "search-{oboname}-{obotype}-data-{datatype}.tsv.gz"),
  searchk.results = file.path(obodir.template,
                             "search-{oboname}-{obotype}-data-{datatype}-k{k}.tsv.gz"),
  search.ids = "{oboname}.{obotype}.data.{datatype}.diff.{difftype}.{diffvalue}",
  searchdiff.results =
    file.path(obodir.template,
              "search-{oboname}-{obotype}-data-name-diff-{difftype}-{diffvalue}.tsv.gz"),
  parents.yaml = file.path(obodir.template, "{oboname}-parents.yaml.gz"),
  name.yaml = file.path(obodir.template, "{oboname}-name.yaml.gz"),
  node2vec = file.path(obodir.template, "{oboname}-node2vec.txt"),
  nodes = file.path(obodir.template, "{oboname}-nodes.txt")
)

