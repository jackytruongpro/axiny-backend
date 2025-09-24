# snapshot.R – Génération de snapshots + fusion PDF + archivage PNG

library(shiny)
library(ggplot2)

# 1) VALEURS POUR LES INPUTS (Iris)
species_choices <- c("setosa", "versicolor", "virginica")
bins_values    <- 5:20  # 16 valeurs

# 2) GÉNÉRATION DE TOUTES LES COMBINAISONS
input_combinations <- expand.grid(
  species = species_choices,
  bins    = bins_values,
  stringsAsFactors = FALSE
)
input_combinations <- split(input_combinations, seq(nrow(input_combinations)))
message("Total de combinaisons : ", length(input_combinations))

# 3) FONCTION DE PLOTTING
plot_dashboard <- function(mock_input) {
  data_subset <- iris[iris$Species == mock_input$species, ]
  hist(
    data_subset$Sepal.Length,
    breaks = mock_input$bins,
    col    = "lightblue",
    main   = paste("Histogramme -", mock_input$species),
    xlab   = "Longueur des sépales"
  )
}

# 4) GÉNÉRATION DES SNAPSHOTS
outdir <- "/srv/shiny-server/snapshots"
if (!dir.exists(outdir)) dir.create(outdir, recursive = TRUE)

count <- 1
for (combo in input_combinations) {
  desc <- paste(names(combo), unlist(combo), sep = "=", collapse = ", ")
  message("Configuration ", count, "/", length(input_combinations), ": ", desc)

  # PNG
  png_file <- file.path(outdir, sprintf("snapshot_%03d.png", count))
  png(png_file, width = 800, height = 600)
  plot_dashboard(combo)
  dev.off()

  # PDF
  pdf_file <- file.path(outdir, sprintf("snapshot_%03d.pdf", count))
  pdf(pdf_file, width = 8, height = 6)
  plot_dashboard(combo)
  dev.off()

  if (count %% 10 == 0) message(" -> ", count, " snapshots générés")
  count <- count + 1
}
message("Snapshots individuels générés : ", (count - 1)*2, " fichiers")

# 5) FUSIONNER TOUS LES PDF ET CRÉER UN ZIP POUR LES PNG

# installer et charger pdftools si nécessaire
if (!require(pdftools, quietly = TRUE)) {
  install.packages("pdftools", repos = "https://cloud.r-project.org")
  library(pdftools)
}

# Lister les fichiers
pdf_files <- list.files(outdir, pattern = "\\.pdf$", full.names = TRUE)
png_files <- list.files(outdir, pattern = "\\.png$", full.names = TRUE)

message("Fusion et archivage des fichiers générés...")

# 5a) Fusionner les PDF
if (length(pdf_files) > 0) {
  merged_pdf <- file.path(outdir, "all_snapshots_merged.pdf")
  tryCatch({
    pdf_combine(pdf_files, output = merged_pdf)
    message("✓ PDF fusionné créé : ", basename(merged_pdf))
  }, error = function(e) {
    message("✗ Erreur fusion PDF : ", e$message)
  })
}

# 5b) Créer ZIP des PNG
if (length(png_files) > 0) {
  zip_file <- file.path(outdir, "all_snapshots.zip")
  tryCatch({
    old_wd <- getwd()
    setwd(outdir)
    zip(zipfile = basename(zip_file), files = basename(png_files))
    setwd(old_wd)
    message("✓ Archive ZIP créée : ", basename(zip_file))
  }, error = function(e) {
    message("✗ Erreur création ZIP : ", e$message)
    setwd(old_wd)
  })
}

# 6) RÉSUMÉ FINAL
message("========== RÉSUMÉ FINAL ==========")
message("PDF individuels : ", length(pdf_files))
message("PNG individuels : ", length(png_files))
if (file.exists(file.path(outdir, "all_snapshots_merged.pdf"))) {
  message("PDF fusionné      : all_snapshots_merged.pdf")
}
if (file.exists(file.path(outdir, "all_snapshots.zip"))) {
  message("Archive PNG       : all_snapshots.zip")
}
message("Tous les fichiers sont dans : ", outdir)
