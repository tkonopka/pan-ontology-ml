# helper functions used in download-foundry.R and download-ols.R

#' download files into an output directory
#'
#' @param urls character vector, URLS to download
#' @param local.filename character, leave NULL to use url filenames
#' or set
download.files = function(urls, local.dir=NULL, local.filename=NULL) {
  outdir = local.dir
  if (is.null(local.dir)) {
    outdir = obo.dir
    if (any(endsWith(urls, "owl"))) {
      outdir = owl.dir
    }
  }
  if (is.null(local.filename)) {
    out.files = file.path(outdir, basename(urls))
  } else {
    out.files = file.path(outdir, rep(local.filename, length(urls)))
  }
  for (j in seq_along(urls)){
    j.file = out.files[j]
    if (!file.exists(j.file)) {
      cat(paste0("downloading ", urls[j], "\n"))
      tryCatch({ curl_download(urls[j], j.file) },
               warning=function(w) { warning(w) },
               error=function(e) { warning(e) })
      Sys.sleep(0.5)
    } else {
      cat(paste0("-- skipping ", urls[j], " -- already downloaded --\n"))
    }
  }
  out.files[file.exists(out.files)]
}


# command to convert between owl and obo formats
owl2obo.cmd = "python3 owl2obo.py "

#' apply a conversion from owl format to obo format
convert.owl = function(filepath) {
  owlfile = file.path(owl.dir, filepath)
  obofile = gsub(".owl$", ".obo", file.path(obo.dir, filepath))
  if (!file.exists(obofile)) {
    cat(paste0("converting owl file: ", filepath, "\n"))
    convert.cmd = paste(owl2obo.cmd, " --owl ", owlfile, " --obo ", obofile)
    system(convert.cmd, intern=TRUE)
  } else {
    cat("-- skipping owl conversion, obo exists --\n")
  }
}

