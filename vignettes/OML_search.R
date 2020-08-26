# script part of OntoML.Rmd
# Summarizes serch results


#' combinations of obo data types used in the db and for querying
search.configs = expand.grid(list(obotype=c("name", "plain", "parents"),
                                  datatype=c("name", "plain", "parents"),
                                  difftype=NA,
                                  diffvalue=NA),
                             stringsAsFactors=FALSE)



###############################################################################
# load id - parent relationships

# get id-parent relationships for all ontologies
if (!assignc("ontologies.parents")) {
  ontologies.parents = lapply(ontologies.selected, read.parents,
                              template=file.templates$metadata)
  names(ontologies.parents) = ontologies.selected
  savec(ontologies.parents)
}




###############################################################################
# read search results

#' get four search sets of search results for one ontology
#' @param oboname character name of ontology
#' @param configs data table specifying a set of results
#' @param template character, file template
#' @param add.rank logical, whether to add a column with rank integers
read.search.results = function(oboname,
                               configs=search.configs,
                               template="{oboname}-{obotype}-{datatype}.tsv.gz",
                               add.rank=FALSE) {
  .configs = copy(configs)
  .configs$oboname = oboname
  result = as.list(glue(template, .envir=.configs))
  names(result) = glue(file.templates$search.ids, .envir=.configs)
  lapply(result, function(x) {
    xdata = fread(x)
    setnames(xdata, "query", "id")
    if (add.rank) {
      xdata = split(xdata, xdata$id)
      xdata = rbindlist(lapply(xdata, function(z) {
        z$rank = rank(z$distance, ties="first")
        z
      }))
    }
    xdata
  })
}


#' evaluate whether search results find self ids and parent ids
make.search.perf = function(oboname, configs=search.configs,
                            parents=ontologies.parents) {
  result = list()
  obo.parents = parents[[oboname]]
  search.results = read.search.results(oboname, configs,
                                       template=file.templates$search.results)
  for (i in seq_along(search.results)) {
    .id = names(search.results)[i]
    i.data = search.results[[.id]]
    i.perf = merge(i.data, obo.parents, by="id", allow.cartesian=TRUE)
    i.perf$self = i.perf$id
    result[[.id]] =
      i.perf[, list(precision_self=as.integer(any(target==self)),
                    precision_any_parent=as.integer(any(target==parent)),
                    num_parents_found=as.integer(sum(target==parent))),
        by="id"]
  }
  result
}

#' summarize search configurations by means
#' @return a wider table that has configurations and means of metrics
make.search.perf.summary = function(oboname,
                                    search.performance,
                                    configs=search.configs) {
  result = list()
  .configs = copy(configs)
  .configs$oboname = oboname
  ids = glue(file.templates$search.ids, .envir=.configs)
  for (i in seq_along(ids)) {
    .id = ids[i]
    .data = search.performance[[.id]]
    .result = .configs[i,]
    for (.x in colnames(.data)) {
      if (is(.data[[.x]], "integer")) {
        .result[[.x]] = mean(.data[[.x]])
      }
    }
    result[[i]] = .result
  }
  result = rbindlist(result, use.names=TRUE)
  setnames(result, "oboname", "id")
  setcolorder(result, "id")
  result
}


###############################################################################
# evaluate search (was a query document mapped to itself, to its parent, etc.)

if (!assignc("search.performance")) {
  search.performance = lapply(ontologies.selected, make.search.perf)
  search.performance = Reduce(c, search.performance)
  savec(search.performance)
}


if (!exists("search.performance.summary")) {
  search.performance.summary = rbindlist(lapply(ontologies.selected,
                                                make.search.perf.summary,
                                                search.performance))
}
if (!exists("search.performance.summary.wide")) {
  .temp = merge(search.performance.summary, field.widestats, by="id")
  search.performance.summary.wide = .temp[order(num_terms, decreasing=TRUE)]
  rm(.temp)
}


if (!exists("search.performance.matrix")) {
  make.search.perf.matrix = function() {
    result = matrix(0,
                    ncol=length(unique(search.configs$datatype)),
                    nrow=length(unique(search.configs$obotype)))
    colnames(result) = unique(search.configs$datatype)
    rownames(result) = unique(search.configs$obotype)
    result.self = copy(result)
    result.parent = copy(result)
    for (i in seq_len(nrow(search.configs))) {
      .obotype = search.configs$obotype[i]
      .datatype = search.configs$datatype[i]
      i.data = search.performance.summary[obotype==.obotype & datatype==.datatype]
      result.self[.obotype, .datatype] = mean(i.data$precision_self, na.rm=TRUE)
      result.parent[.obotype, .datatype] = mean(i.data$precision_any_parent, na.rm=TRUE)
    }
    list(self=result.self, parent=result.parent)
  }
  search.performance.matrix = make.search.perf.matrix()
}

