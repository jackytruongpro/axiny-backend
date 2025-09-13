FROM rocker/r-ver:4.3.1

# Définir le répertoire de travail
WORKDIR /srv/shiny-server

# 1. Installer les dépendances système (couche rarement modifiée)
RUN apt-get update && \
    apt-get install -y \
      libcurl4-openssl-dev \
      libssl-dev \
      libxml2-dev \
      zlib1g-dev \
      libv8-dev \
      chromium-browser \
    && rm -rf /var/lib/apt/lists/*

# 2. Installer les packages R nécessaires (couche rarement modifiée)
RUN R -e "install.packages(c('shiny','httpuv','ggplot2','rvest'), repos='https://cloud.r-project.org')"

# 3. Copier l’application Shiny et le script de snapshot (couche fréquemment modifiée)
COPY user_app /srv/shiny-server/user_app
COPY loader.R snapshot.R /srv/shiny-server/

# 4. Créer le dossier pour les snapshots
RUN mkdir -p /srv/shiny-server/snapshots

# Exposer le port Shiny
EXPOSE 3838

# Démarrer Shiny en arrière-plan puis exécuter snapshot.R
CMD R -e "shiny::runApp('loader.R', host='0.0.0.0', port=3838, launch.browser = FALSE)" & \
    sleep 5 && \
    Rscript snapshot.R
