# loader.R
library(shiny)

# Charger l’application utilisateur
source("user_app/app.R", local = TRUE)

# Lancer l’application Shiny
shinyApp(ui = ui, server = server)
