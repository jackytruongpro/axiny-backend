# loader.R
library(shiny)

# Chemin du script utilisateur monté dans le conteneur
app_file <- "/srv/shiny-server/user_app/app.R"

# Vérifier la présence du fichier
if (!file.exists(app_file)) {
  stop("Le fichier app.R est introuvable dans /srv/shiny-server/user_app")
}

# Charger l'app dans un environnement isolé
env <- new.env()
sys.source(app_file, envir = env)

# Lancer l'application définie dans app.R
shinyApp(ui = env$ui, server = env$server)
