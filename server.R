# server.R – Plumber API for Cloud Run

library(plumber)

#* @apiTitle Axiny Snapshot Service

#* Receive an app.R file and return snapshots ZIP
#* @param file:file The Shiny app file
#* @serializer contentType list(type="application/zip")
#* @post /snapshot
function(req, res){
  tmpdir <- tempfile("axiny")
  dir.create(tmpdir)
  app_path <- file.path(tmpdir, "app.R")
  writeBin(req$postBody, app_path)  # plus fiable que file$datapath dans Plumber
  file.copy("/srv/shiny-server/snapshot.R", tmpdir)
  oldwd <- setwd(tmpdir)
  system("Rscript snapshot.R", intern = TRUE)
  setwd(oldwd)
  zipfile <- file.path(tmpdir, "snapshots.zip")
  utils::zip(zipfile, list.files(file.path(tmpdir, "snapshots"), full.names = TRUE))
  bin <- readBin(zipfile, what="raw", n=file.info(zipfile)$size)
  res$setHeader("Content-Type", "application/zip")
  res$body <- bin
  res
} -> snapshot_endpoint

# Plumb & run
pr <- plumber::plumb(file = "server.R")
pr$run(host = "0.0.0.0", port = as.integer(Sys.getenv("PORT", "8080")))
