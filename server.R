# server.R – Plumber API for Cloud Run

library(plumber)

# Récupérer le port fourni par Cloud Run (par défaut 8080 si non défini)
port <- as.integer(Sys.getenv("PORT", "8080"))

#* @apiTitle Axiny Snapshot Service

#* Receive an app.R file and return snapshots ZIP
#* @param file:file The Shiny app file
#* @serializer contentType list(type="application/zip")
function(file) {
  tmpdir <- tempfile("axiny")
  dir.create(tmpdir)
  app_path <- file.path(tmpdir, "app.R")
  writeBin(file$datapath, app_path)
  file.copy("/srv/shiny-server/snapshot.R", tmpdir)
  oldwd <- setwd(tmpdir)
  system("Rscript snapshot.R", intern = TRUE)
  setwd(oldwd)
  zipfile <- file.path(tmpdir, "snapshots.zip")
  utils::zip(zipfile, list.files(file.path(tmpdir, "snapshots"), full.names = TRUE))
  readBin(zipfile, what="raw", n=file.info(zipfile)$size)
} -> pr_endpoint

pr <- plumber::plumb("/srv/shiny-server/server.R")
pr$run(host = "0.0.0.0", port = port)
