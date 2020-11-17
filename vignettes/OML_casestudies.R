# script part of OntoML.Rmd
# Case studies - some bespoke calculations for named ontologies


#' combinations of obo data types used in the db and for querying
diff.configs = expand.grid(list(obotype=c("name", "plain"),
                                datatype="name",
                                difftype=c("plain", "parents"),
                                diffvalue=seq(0, 0.5, by=0.05)),
                           stringsAsFactors=FALSE)


#' load obo summary, simplify search results and performance results
#'
#' @param oboname character, id for ontology
#' @param read.diff logical, set TRUE to read both non-diffused and diffused
#' search results. Defaults to FALSE to read only non-diffused search
#'
#' @return list with $summary, $search, $performance, $graph
get.sspg = function(oboname, read.diff=FALSE) {
  result = list()
  terms = read_yaml(glue(file.templates$name.yaml))
  result$terms = data.table(id=names(terms),
                            name=sapply(terms, function(x) { x$title }))
  # information about all terms
  result$summary =
    read.pretty.json(glue(file.templates$obo.summary), excise=NULL)
  result$summary = data.table(result$summary)
  result$summary$node_type = "intermediate"
  result$summary[num_children==0, "node_type"] = "leaf"
  result$summary[num_parents==0, "node_type"] = "root"
  # search outcomes
  obo.pattern = paste0(oboname, "\\.")
  result$search = read.search.results(oboname,
                                      template=file.templates$search.results)
  if (read.diff) {
    result$search =
      c(result$search,
        read.search.results(oboname, configs=diff.configs,
                            template=file.templates$searchdiff.results))
  }
  names(result$search) = gsub(obo.pattern, "", names(result$search))
  # performance
  result$performance =
    search.performance[grep(obo.pattern, names(search.performance))]
  names(result$performance) = gsub(obo.pattern, "", names(result$performance))
  # graph
  parents = read.parents(oboname, template=file.templates$parents.yaml,
                         verbose=FALSE)
  result$graph = make.ontology.graph(parents)
  result
}


#' assess quality of a mapping onto ontology targets
#'
#' @param observed data table, must contain columns id, target, distances
#' @param ontograph igraph object
#' @param cores integers, number of cores for mclapply
#' This is used to score imperfect matches
#' @param by character vector, column in observed that characterize distinct
#' result sets
#'
#' @return list with tables, including $summary and $details
evaluate.search.distances = function(observed, ontograph, cores=4) {
  graph = ontograph$graph
  expected = data.table(ontograph$edges)
  setnames(expected, "target", "expected")
  temp = merge(observed[!is.na(distance), c("id", "target")], expected,
               by="id", allow.cartesian=TRUE)
  # precompute relevant path distances between expected and output nodes
  te.pairs = unique(temp[, c("target", "expected")])
  te.list = split(te.pairs, te.pairs$target)
  te.pairs = rbindlist(mclapply(te.list, function(x) {
    from = x$target[1]
    to = x$expected
    x$path = igraph::distances(graph, v=from, to=unique(to))[1, to]
    x
  }, mc.cores=cores))
  temp = merge(temp, te.pairs, by=c("target", "expected"))

  # look at mappings to items other than to self (i.e. avoid pathlen=0)
  temp = temp[id!=target, ]
  result =
    temp[, list(pathlen_bestN=as.integer(min(path)),
                pathlen_meanN=mean(path),
                pathlen_worstN=max(path)),
      by=c("id", "expected")]
  result[order(id)]
}


#' collapse output from evaluate.search.distances to one-row-per-id
#'
#' @param search.distances data table with id, expected, pathlen_bestN, etc.
#'
#' @return data table with same structure, but with only one row per id
collapse.search.distances = function(search.distances) {
  collapse = function(expected, bestN, meanN, worstN) {
    i = which.min(bestN)[1]
    list(expected=expected[i], pathlen_bestN=bestN[i],
         pathlen_meanN=meanN[i], pathlen_worstN=worstN[i])
  }
  search.distances[, collapse(expected, pathlen_bestN,
                              pathlen_meanN, pathlen_worstN),
                     by="id"]
}

#' wrapper to read search results, evaluate performance, summarize
make.search.diff.summary = function(oboname) {
  search.perf = make.search.perf(oboname, diff.configs,
                                 template=file.templates$searchdiff.results)
  make.search.perf.summary(oboname, search.perf,
                           configs=diff.configs)
}


#' create a square distance matrix from a long table of search results
#' @param d.raw data table with raw search results
#'
#' @return square matrix with rownames & colnames
make.dist.from.search = function(d.raw) {
  d.split = split(d.raw, d.raw$id)
  ids = names(d.split)
  d.dist = matrix(1, nrow=length(ids), ncol=length(ids))
  colnames(d.dist) = rownames(d.dist) = ids
  for (i in seq_along(ids)) {
    i.id = names(d.split)[i]
    d.dist[i.id, d.split[[i]]$target] = d.split[[i]]$distance
  }
  (d.dist + t(d.dist))/2
}


#' get distance matrices for one ontology
#'
#' @param oboname character, ontology name
#' @param k integer, used to fetch search results with many neighbors
#' @param obotype character
#' @param datatype character
#' @return list with search distances and graph distances
make.distance.matrices = function(oboname, obotype="plain",
                                  datatype="plain", k=15) {
  .configs = data.table(obotype=obotype, datatype=datatype,
                        difftype=NA, diffvalue=NA, k=k)
  .search = read.search.results(oboname, configs=.configs,
                                template=file.templates$searchk.results)
  .parents = read.parents(oboname, template=file.templates$metadata,
                          verbose=FALSE)
  .graph = make.ontology.graph(.parents[parent!=""], remove.only.target=FALSE)
  .indexes = seq_along(.graph$nodes)
  list(search=make.dist.from.search(.search[[1]]),
       graph=igraph::distances(.graph$graph,
                               v=.indexes, to=.indexes))
}


#' make a series of embeddings for an ontology
#'
#' - umap based on small-k search results
#' - umap based on large-k search results
#' - graph layout
#' - node2vec layout
#'
#' @param oboname character name of ontology
#' @param k integer, value of k for large-k search results
#' @param k.series integer vector, series for k for umap embeddings
#'
#' @return list of matrices, each one containing a 2D layout
make.embeddings = function(oboname, config, k=15, k.series=seq(5, 15, by=2)) {
  sspg = get.sspg(oboname, read.diff=FALSE)
  sspg.dist = make.distance.matrices(oboname, k=k)
  make.umap.from.search = function(d.raw, n_neighbors=5) {
    d.dist = make.dist.from.search(d.raw)
    umap(d.dist, config=config, n_neighbors=n_neighbors)$layout
  }
  # make embeddings from standard search results
  result = lapply(sspg$search, make.umap.from.search)
  # make embeddings from large-k search results (search and graph)
  for (.k in k.series) {
    result[[paste0("umap.search.k", .k)]] =
      umap(sspg.dist$search, config=config, n_neighbors=.k)$layout
    result[[paste0("umap.graph.k", .k)]] =
      umap(sspg.dist$graph, config=config, n_neighbors=.k)$layout
  }
  # record embeddings produced by node2vec, graph layout
  result[["node2vec"]] = read.node2vec("fbdv",
                                       file.templates$node2vec,
                                       file.templates$nodes)
  result[["graph"]] = sspg$graph$layout
  result
}


###############################################################################
# Human phenotypes

# information about phenotypes
if (!assignc("hp")) {
  hp = get.sspg("hp", read.diff=TRUE)
  savec(hp)
}
if (!assignc("hp.distances")) {
  hp.pathlen = evaluate.search.distances(hp$search$plain.data.name.diff.NA.NA,
                                         ontograph=hp$graph, cores=2)
  savec(hp.pathlen)
  hp.pathlen.diff = evaluate.search.distances(hp$search$plain.data.name.diff.parents.0.3,
                                         ontograph=hp$graph, cores=2)
  savec(hp.pathlen.diff)
  hp.distances = list(nodiff=collapse.search.distances(hp.pathlen),
                      diff=collapse.search.distances(hp.pathlen.diff))
  savec(hp.distances)
}
if (!assignc("hp.search.diff.summary")) {
  hp.search.diff.summary = make.search.diff.summary("hp")
  savec(hp.search.diff.summary)
}


hp.eg = "HP_0020134"
hp.dir = file.path(instances.dir, "hp")
jgz = ".json.gz"
if (!exists("hp.eg.matrix")) {
  hp.featuremap.file = file.path(hp.dir, paste0("hp-features", jgz))
  hp.featuremap = data.table(fromJSON(hp.featuremap.file))
  hp.featuremap$index1 = hp.featuremap$index + 1
  make.hp.eg.matrix = function(id) {
    vectors.file = file.path(hp.dir, paste0("hp-vectors-", id, jgz))
    result = data.table(fromJSON(vectors.file))
    hpvec2df = function(x) {
      result = copy(hp.featuremap)
      result$value = x
      result = result[value != 0, c("feature", "value")]
      result[order(value, decreasing=TRUE)]
    }
    result = result[, hpvec2df(vector), by=c("dataset", "id")]
    result$id_dataset = paste0(result$id, "_", result$dataset)
    result = dcast(result, feature ~ id_dataset, value.var="value")
    result = as.data.frame(result)
    rownames(result) = result$feature
    result$feature = NULL
    as.matrix(result)
  }
  hp.eg.matrix = make.hp.eg.matrix(hp.eg)
}



###############################################################################
# Fly development

# information about all terms in the fbdv ontology
if (!assignc("fbdv")) {
  fbdv = get.sspg("fbdv", read.diff=TRUE)
  savec(fbdv)
}
if (!assignc("fbdv.dist")) {
  fbdv.dist = make.distance.matrices("fbdv")
  savec(fbdv.dist)
}
# embeddings
if (!assignc("fbdv.embeddings")) {
  fbdv.umap.config = umap.defaults
  fbdv.umap.config$input = "dist"
  fbdv.umap.config$min_dist = 2
  fbdv.umap.config$spread = 4
  fbdv.umap.config$random_state = 12345
  fbdv.embeddings = make.embeddings("fbdv", fbdv.umap.config,
                                    k=15, k.series=seq(5, 15, by=2))
  savec(fbdv.embeddings)
}
if (!assignc("fbdv.search.diff.summary")) {
  fbdv.search.diff.summary = make.search.diff.summary("fbdv")
  savec(fbdv.search.diff.summary)
}



###############################################################################
# Modified ontologies

# read information about variants of the fbdv and go ontologies
modified.ontologies = c("fbdv", "fbdv-isa", "go", "go-isa")
if (!assignc("modified.parents")) {
  modified.parents = lapply(modified.ontologies, read.parents,
                            template=file.templates$metadata,
                            verbose=FALSE)
  names(modified.parents) = modified.ontologies
  savec(modified.parents)
}
if (!assignc("modified.performance")) {
  modified.performance = lapply(modified.ontologies, make.search.perf,
                                parents=modified.parents)
  modified.performance = Reduce(c, modified.performance)
  savec(modified.performance)
}
if (!exists("modified.performance.summary")) {
  modified.performance.summary = rbindlist(lapply(modified.ontologies,
                                                  make.search.perf.summary,
                                                  modified.performance))
}

