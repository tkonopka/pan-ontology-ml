# script part of OntoML.Rmd
# General linear models for self-retrieval and parent-retrieval


#' read an ontology summary and search performance results, and build glm models
#'
#' @param oboname characer, name of ontology
#' @param configs data table with search configurations
#' @param perf list with performance for all searches
#' @param search.perf list with data tables with search performance
#' @param verbose logical
#' @param outcome character, name of columns to model as "y"
#' @param covariates character, columns to use as model covariates
#'
#' @return a summary of glm model (with some fields to save memory/disk space)
make.glm = function(oboname, configs=search.configs, perf=search.performance,
                    verbose=TRUE, outcome="precision_any_parent",
                    covariates=c("depth", "num_parents", "num_siblings",
                                 "num_children", "num_synonyms",
                                 "log_chars_name", "log_chars_def",
                                 "log_chars_comments")) {
  if (verbose) {
    print(paste(date(), " ", oboname))
  }
  # modeling formulae
  glmf = lapply(paste0(outcome, "~", paste(covariates, collapse="+")),
                as.formula)
  names(glmf) = outcome
  # read covariates (node-level information), transform, center around median
  obo_summary = read.pretty.json(glue(file.templates$obo.summary), excise=NULL)
  for (.covariate in covariates) {
    if (startsWith(.covariate, "log_")) {
      plain_covariate = gsub("log_", "", .covariate)
      obo_summary[[.covariate]] = log10(1+obo_summary[[plain_covariate]])
    }
  }
  # identify relevant entries in the search performance tables
  .configs = copy(configs)
  .configs$oboname = oboname
  confignames = glue(file.templates$search.ids, .envir=.configs)
  confignames = setNames(as.list(confignames), confignames)
  # build models for each of the performance tables
  lapply(confignames, function(.i) {
    result = list()
    .data = merge(obo_summary, perf[[.i]], by="id")
    for (.o in names(glmf)) {
      .model = suppressWarnings(glm(glmf[[.o]], data=.data, family="binomial"))
      .summary = summary(.model)
      .summary$converged = .model$converged
      .summary$fitted.range = range(.model$fitted.values)
      .summary$deviance.resid = NULL
      .summary$family = NULL
      result[[.o]] = .summary
    }
    result
  })
}


# get id-parent relationships for all ontologies
if (!assignc("ontologies.glm")) {
  ontologies.glm = lapply(ontologies.selected, make.glm,
                          configs=search.configs,
                          perf=search.performance,
                          outcome=c("precision_self", "precision_any_parent"))
  ontologies.glm = Reduce(c, ontologies.glm)
  savec(ontologies.glm)
}


#' create a giant table for all configs
#'
#' @param oboname character
#' @param configs table with configurations
#' @param glms list with glm objects
#' @param saturation numerical - models that predict values lower than
#' saturation or higher than 1-saturation will have all z-scores set to NA
#'
#' @param data table
make.glm.summary = function(oboname, configs=search.configs, glms=NULL,
                            saturation=5e-15) {
  .configs = copy(configs)
  .configs$oboname = oboname
  result = list()
  for (i in seq_len(nrow(search.configs))) {
    .obotype = search.configs$obotype[i]
    .datatype = search.configs$datatype[i]
    .iconfig = .configs[i,]
    .iname = glue(file.templates$search.ids, .envir=.iconfig)
    models = glms[[.iname]]
    for (.o in names(models)) {
      .omodel = models[[.o]]$coefficients
      .omodel = data.table(variable=rownames(.omodel), .omodel)
      .orange = models[[.o]]$fitted.range
      if (min(.orange)<saturation | max(.orange)>1-saturation) {
        .omodel[["z value"]] = as.numeric(NA)
        .omodel[["Pr(>|z|)"]] = as.numeric(NA)
      }
      result[[1+length(result)]] = data.table(.iconfig, outcome=.o, .omodel)
    }
  }
  result = rbindlist(result)
  setcolorder(result, "oboname")
  result
}


if (!assignc("ontologies.glm.summary")) {
  ontologies.glm.summary = lapply(ontologies.selected, make.glm.summary,
                                  configs=search.configs, glms=ontologies.glm)
  ontologies.glm.summary = rbindlist(ontologies.glm.summary)
  savec(ontologies.glm.summary)
}

