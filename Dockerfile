FROM rocker/r-ver:4.3.1

# Définir le répertoire de travail
WORKDIR /srv/shiny-server

# Installer les dépendances système et Chromium (non-Snap)
RUN apt-get update && \
    apt-get install -y \
      libcurl4-openssl-dev \
      libssl-dev \
      libxml2-dev \
      zlib1g-dev \
      libv8-dev \
      chromium-browser \
    && rm -rf /var/lib/apt/lists/*

# Installer les packages R nécessaires
RUN R -e "install.packages(c('shiny','httpuv'), repos='https://cloud.r-project.org')"

# Copier l’application Shiny et le script de snapshot
COPY user_app /srv/shiny-server/user_app
COPY loader.R /srv/shiny-server/loader.R
COPY snapshot.R /srv/shiny-server/snapshot.R

# Créer le dossier pour les snapshots
RUN mkdir -p /srv/shiny-server/snapshots

# Exposer le port Shiny
EXPOSE 3838

# Démarrer Shiny en arrière-plan puis exécuter snapshot.R
CMD R -e "shiny::runApp('loader.R', host='0.0.0.0', port=3838, launch.browser = FALSE)" & \
    sleep 5 && \
    Rscript snapshot.R
