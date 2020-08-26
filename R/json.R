# helper functions for reading json


#' read pretty-formatted JSON from a file, avoiding certain fields
#'
#' WARNING: this is a fragile function, only designed to
#' save some memory for reading large files on a low-mem machine.
#' It can only avoid fields that can be excised from a text file
#'
#' @param filepath character, path to file
#' @param avoid.fields character, fields to avoid
#' @param n integer, lines to read at-a-time
#' 
#' @return data.frame
read.pretty.json = function(filepath, excise.fields=c("id", "name"),
                            n=2^20) {
  d = list()
  fcon = file(filepath, "rt")
  while (length(dlines <- readLines(fcon, n=n, warn=FALSE))) {
    dlines = trimws(dlines)
    for (field in excise.fields) {
      dlines = dlines[!grepl(paste0("\"", field, "\":"),  dlines)]
    }
    d[[length(d)+1]] = dlines
  }
  close(fcon)
  fromJSON(unlist(d))
}


#' read a json file and extra query->targets
#' this is an ad-hoc function that requires pretty-printed json array
#'
#' the implementation reads raw strings and splits elements of the json
#' array using simple string patterns. Each element is parsed with fromJSON.
#' Parsing individual elements is more memory-efficient than applying
#' fromJSON no the entire input json string
#' 
#' @param filepath path to json file
#'
#' @return data.table
read.search.targets.json = function(filepath) {
  stop("no longer needed - read tsv.gz format instead")
  print(filepath)
  result = trimws(readLines(filepath))
  result = result[seq(2, length(result)-1)]
  result = split(result, cumsum(result=="{"))
  result = rbindlist(lapply(result, function(x) {
    if (x[length(x)]=="},") { x[length(x)] = "}" }
    xlist = fromJSON(x)
    if (length(xlist$targets)==0) {
      return(data.frame(query=xlist$query, targets=NA,
                        distances=NA, stringsAsFactors=FALSE))
    }
    as.data.frame(xlist, stringsAsFactors=FALSE)
  }))
  setnames(result, c("query", "targets", "distances"),
           c("id", "target", "distance"))
  result
}

