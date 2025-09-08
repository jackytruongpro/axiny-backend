# snapshot.R
# Génération directe des histogrammes sans navigateur

# Charger les données
data("faithful")

# Sortie absolue vers le dossier monté par Docker
outdir <- "/srv/shiny-server/snapshots"
if (!dir.exists(outdir)) dir.create(outdir, recursive = TRUE)

# Combinaisons d’inputs
binsList <- c(5, 10, 15, 20, 25)
colors   <- c("darkgray", "steelblue", "forestgreen")

count <- 1
for (b in binsList) {
  for (col in colors) {
    # Fichiers de sortie
    pngfile <- file.path(outdir, sprintf("snapshot_%02d.png", count))
    pdffile <- file.path(outdir, sprintf("snapshot_%02d.pdf", count))

    message("Génération ", count, ": bins=", b, ", color=", col)

    # Générer PNG
    png(filename = pngfile, width = 800, height = 600)
    hist(faithful$eruptions,
         breaks = seq(min(faithful$eruptions),
                      max(faithful$eruptions),
                      length.out = b + 1),
         col = col,
         xlab = "Duration (minutes)",
         main = "Histogram of eruption durations")
    dev.off()

    # Générer PDF
    pdf(file = pdffile, width = 8, height = 6)
    hist(faithful$eruptions,
         breaks = seq(min(faithful$eruptions),
                      max(faithful$eruptions),
                      length.out = b + 1),
         col = col,
         xlab = "Duration (minutes)",
         main = "Histogram of eruption durations")
    dev.off()

    message(" -> Fichiers créés : ", basename(pngfile), ", ", basename(pdffile))
    count <- count + 1
  }
}

message("Toutes les captures R ont été générées.")
