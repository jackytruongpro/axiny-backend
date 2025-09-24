# server.R – Plumber API for Cloud Run

library(plumber)

#* @apiTitle Axiny Snapshot Service

#* Receive an app.R file and return snapshots ZIP
#* @param file:file The Shiny app file
#* @serializer contentType list(type="application/zip")
function(file) {
  # Create temp dir
  tmpdir <- tempfile("axiny")
  dir.create(tmpdir)
  app_path <- file.path(tmpdir, "app.R")
  writeBin(file$datapath, app_path)

  # Copy snapshot.R into tmpdir
  file.copy("/srv/shiny-server/snapshot.R", tmpdir)

  # Run snapshot script
  oldwd <- setwd(tmpdir)
  system("Rscript snapshot.R", intern = TRUE)
  setwd(oldwd)

  # Create zip of snapshots folder
  zipfile <- file.path(tmpdir, "snapshots.zip")
  utils::zip(zipfile, list.files(file.path(tmpdir, "snapshots"), full.names = TRUE))

  # Read and return zip
  zip_data <- readBin(zipfile, what="raw", n=file.info(zipfile)$size)
  zip_data
}
