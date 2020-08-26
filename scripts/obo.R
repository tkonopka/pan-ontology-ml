# helper functions for reading obo


#' construct a date string with year first
yr.first <- function(x) {
  x = trimws(x)
  xchars = strsplit(x, "")[[1]]
  xchars[xchars=="."] = "-"
  x = paste(xchars, collapse="")
  result = strsplit(x, "-| ")[[1]][1:3]
  if (nchar(result[3])==4) {
    result = rev(result)
  }
  if (as.integer(result[2])>12) {
    result[2:3] = c(result[3], result[2])
  }
  paste(result, collapse="-")
}


#' extract a date from an obo file
#'
#' @param obo character, filename or content of obo file
#' @param n integer, number of line to read from an obo file
#'
#' @return a date string, or NA
obo.date = function(obo, n=256) {
  if (identical(obo, "")) return(as.character(NA))
  if (length(obo)==1 & all(file.exists(obo))) {
    obo = readLines(obo, n)
  }
  # attempt using date:
  fdate = obo[startsWith(obo, "date:")]
  if (length(fdate)) {
    result = strsplit(gsub("date: ", "", fdate), " ")[[1]][[1]]
    result = strsplit(result, ":")[[1]]
    result = paste(rev(result), collapse="-")
    return(yr.first(result))
  }
  # attempt using data:version:
  fversion = obo[startsWith(obo, "data-version:")]
  if (length(fversion)) {
    result = gsub("releases/", "", gsub("data-version: ", "", fversion[1]))
    result = strsplit(result, "/")[[1]]
    result = grep("-..-", result, value=T)
    if (length(result)>0) {
      if (nchar(result)<14) {
        result = tryCatch(yr.first(result), error=function(e){ as.character(NA) })
      } else {
        result = NA
      }
      if (!is.na(result)) {
        return(result)
      }
    }
  }
  # attempt from property date
  fdate = obo[startsWith(obo, "property_value") & grepl("/date", obo)]
  if (length(fdate)) {
    result = strsplit(fdate, "date")[[1]]
    result = gsub("xsd.string", "", result[2])
    result = gsub("\\\"", "", result)
    result = tryCatch(yr.first(result), error=function(e){ as.character(NA) })
    return(result)
  }
  # attempt with versionInfo
  fversion = obo[grepl("versionInfo", obo)]
  if (length(fversion)) {
    result = strsplit(fversion, "versionInfo")[[1]]
    result = gsub("xsd.string", "", result[2])
    result = gsub("\\\"", "", result)
    result = gsub("version", "", gsub("release", "", result))
    result = trimws(gsub(" - ", "", result))
    if (nchar(result)>14) return(as.character(NA))
    result = tryCatch(yr.first(result), error=function(e){ as.character(NA) })
    return(result)
  }
  fremark = obo[startsWith(obo, "remark:")]
  if (length(fremark)) {
    #print(paste("fremark ", fremark))
    fremark = gsub("remark: ", "", fremark)
    result = tryCatch(as.character(as.Date(fremark)), error=function(e){})
    if (!is.null(result)) {
      return(yr.first(result))
    }
  }
  as.character(NA)
}

