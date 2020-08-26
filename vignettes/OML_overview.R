# script part of OntoML.Rmd
# Loads basic information about ontologies in the Obo Foundry


# read a plain status file with ontology names, obsolete status, etc.
foundry.status.file = file.path(data.dir, "obofoundry-ontologies-status.tsv")
ols.status.file = file.path(data.dir, "ols-ontologies-status.tsv")
if (!assignc("ontologies.status")) {
  foundry.status = fread(foundry.status.file)
  ols.status = fread(ols.status.file)
  ols.status$date = as.character(ols.status$date)
  foundry.status$date = as.character(foundry.status$date)
  ontologies.status = rbind(cbind(foundry.status, source="obofoundry"),
                            cbind(ols.status, source="ols"), use.names=TRUE)
  .newest = max(as.Date(foundry.status$date), na.rm=TRUE)
  ontologies.status$age = as.integer(.newest - as.Date(ontologies.status$date))
  setnames(ontologies.status, "ontology", "id")
  setcolorder(ontologies.status, "id")
  rm(.newest, foundry.status, ols.status)
}


# get a summary of the number of terms in each active ontology
if (!assignc("ontologies.summary")) {
  ontologies.summary = ontologies.status[is_obsolete==FALSE & available==TRUE]
  make.count.summary = function(oboname) {
    print(oboname)
    d = read.pretty.json(glue(file.templates$obo.summary),
                         excise=c("id", "name", "depth",
                                  "chars_name", "chars_def",
                                  "num_parents", "num_ancestors",
                                  "num_siblings", "num_children",
                                  "num_descendents", "num_synonyms"))
    data.table(id=oboname, num_terms=sum(d$is_obsolete==FALSE))
  }
  .counts = rbindlist(lapply(ontologies.summary$id, make.count.summary))
  ontologies.summary = merge(ontologies.summary, .counts, by="id", all=TRUE)
  rm(.counts)
  savec(ontologies.summary)
}
if (!exists("ontologies.recent")) {
  ontologies.recent = ontologies.summary[age<730]$id
}



# compute summary statistics for all the ontologies
if (!assignc("field.summary.stats")) {
  make.field.summary = function(oboname) {
    print(oboname)    
    d = read.pretty.json(glue(file.templates$obo.summary),
                         excise=c("id", "name"))
    if (is.null(ncol(d))) return(NULL)
    if (ncol(d)==0) return(NULL)
    d = d[d$is_obsolete==FALSE,]
    d.numeric = colnames(d)[sapply(d, class) %in% c("numeric", "integer")]
    get.numeric.summary = function(labels) {
      if (length(labels)==1) {
        x = d[[labels]]
      } else {
        x = colSums(t(as.matrix(d[, labels])))
      }
      x = x[is.finite(x)]
      xq = quantile(x, p=c(0.05, 0.25, 0.5, 0.75, 0.95))
      xp = c(mean(x), sd(x))
      xmm = c(min(x), max(x))
      x0 = c(sum(x==0), 100*sum(x==0)/length(x))
      data.table(id=oboname, field=paste(labels, collapse=","),
                 avg=xp[1], std_dev=xp[2],
                 min=xmm[1], max=xmm[2],
                 q05=xq[1], q25=xq[2], q50=xq[3], q75=xq[4], q95=xq[5],
                 count_zero=x0[1], perc_zero=x0[2])             
    }
    result = rbindlist(lapply(d.numeric, get.numeric.summary))
    result.text = get.numeric.summary(c("chars_name", "chars_def", "chars_comments"))
    result.text$field = "chars_text"
    rbind(result, result.text)
  }
  field.summary.stats = rbindlist(lapply(ontologies.summary$id,
                                         make.field.summary))
  savec(field.summary.stats)
  gc()
}


# more summary statistics, in a different format (horizontal)
if (!exists("field.widestats")) {
  numeric.cols = c("avg", "std_dev", "min", "max",
                   "q05", "q25", "q50", "q75", "q95")
  # compute a new field - term depth normalized by logarithm of terms
  add.normalized.depth = function(d) {
    result = merge(d[field=="depth"],
                   ontologies.summary[, c("id", "num_terms")], by="id")
    log2norm = log2(result$num_terms)
    for (x in numeric.cols) {
      result[[x]] = result[[x]] / log2norm
    }
    result$field = "norm_depth"
    result$num_terms = NULL
    rbind(d, result)
  }
  field.summary.stats = add.normalized.depth(field.summary.stats)
  # produce a wide table
  field.widestats = dcast(field.summary.stats, id ~ field,
                          value.var=c(numeric.cols, "count_zero", "perc_zero"))
  field.widestats = merge(ontologies.summary[, c("id", "num_terms")],
                          field.widestats, by="id")
  for (.x in colnames(field.widestats)) {
    if (is(field.widestats[[.x]], "numeric")) {
      field.widestats[[.x]] = signif(field.widestats[[.x]], 7)
    }
  }
  field.widestats = field.widestats[order(-num_terms, id, decreasing=FALSE)]
}

if (!exists("ontologies.selected")) {
  ontologies.selected = field.widestats[id %in% ontologies.recent &
    (count_zero_depth<10 | is.na(count_zero_depth)) &
    num_terms>10]$id
  write(ontologies.selected, file=file.path(cachedir(), "_selected.txt"))
}


ontologies.summary.table = file.path(tables.dir, "ontologies-summary.tsv")
if (!file.exists(ontologies.summary.table)) {
  .temp = merge(ontologies.summary[, c("id", "title", "date", "source", "age")],
                field.widestats, by="id")
  fwrite(.temp, file=ontologies.summary.table, sep="\t")
  rm(.temp)
}

