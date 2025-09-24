FROM rocker/r-ver:4.3.1

WORKDIR /srv/shiny-server

# 1) Installer les dépendances système
RUN apt-get update && \
    apt-get install -y \
      libcurl4-openssl-dev \
      libssl-dev \
      libxml2-dev \
      zlib1g-dev \
      libv8-dev \
      chromium-browser \
      libpoppler-cpp-dev \
    && rm -rf /var/lib/apt/lists/*

# 2) Installer les packages R
RUN R -e "install.packages(c('shiny','httpuv','ggplot2','rvest','pdftools'), repos='https://cloud.r-project.org')"

# 3) Copier votre code
COPY user_app /srv/shiny-server/user_app
COPY loader.R snapshot.R /srv/shiny-server/

# 4) Créer le dossier snapshots
RUN mkdir -p /srv/shiny-server/snapshots

EXPOSE 3838

# 5) Démarrer le conteneur (SYNTAXE CORRIGÉE)
CMD ["/bin/sh", "-c", "R -e \"shiny::runApp('loader.R', host='0.0.0.0', port=3838, launch.browser = FALSE)\" & sleep 5 && Rscript snapshot.R"]
