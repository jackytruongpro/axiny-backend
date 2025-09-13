# snapshot.R – approche hybride fiable

library(shiny)
library(ggplot2)  # ou vos packages graphiques

# 1) DÉCLARATION MANUELLE DES INPUTS
# Replacez par les IDs et valeurs de votre dashboard
input_combinations <- list(
  list(xvar = "wt", yvar = "mpg", points = 20),  # valeur par défaut
  # Ajoutez autant de listes que vous voulez de configurations
  list(xvar = "hp", yvar = "qsec", points = 10)
)

# 2) FONCTION DE PLOTTING EXTRACTÉE DE VOTRE app.R
plot_dashboard <- function(mock_input) {
  sampled <- mtcars[sample(nrow(mtcars), mock_input$points), ]
  p <- ggplot(sampled, aes_string(x = mock_input$xvar, y = mock_input$yvar)) +
    geom_point(color = "steelblue", size = 3) +
    theme_minimal() +
    labs(title = paste("Nuage de points de", mock_input$yvar, "vs", mock_input$xvar))
  print(p)
}

# 3) GÉNÉRATION DES SNAPSHOTS
outdir <- "/srv/shiny-server/snapshots"
if (!dir.exists(outdir)) dir.create(outdir, recursive = TRUE)

count <- 1
for (combo in input_combinations) {
  desc <- paste(names(combo), combo, sep = "=", collapse = ", ")
  message("Configuration ", count, ": ", desc)

  # PNG
  png_file <- file.path(outdir, sprintf("snapshot_%02d.png", count))
  png(png_file, width = 800, height = 600)
  plot_dashboard(combo)
  dev.off()

  # PDF
  pdf_file <- file.path(outdir, sprintf("snapshot_%02d.pdf", count))
  pdf(pdf_file, width = 8, height = 6)
  plot_dashboard(combo)
  dev.off()

  message(" -> Fichiers générés : ", basename(png_file), ", ", basename(pdf_file))
  count <- count + 1
}

message("Toutes les captures ont été générées dans ", outdir)
