# axiny-backend/Dockerfile

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
RUN R -e "install.packages(c('shiny','httpuv','ggplot2','rvest','pdftools','plumber'), repos='https://cloud.r-project.org')"

# 3) Copier les scripts R
COPY snapshot.R /srv/shiny-server/snapshot.R
COPY server.R   /srv/shiny-server/server.R

# 4) Créer le dossier snapshots (utilisé temporairement par snapshot.R)
RUN mkdir -p /srv/shiny-server/snapshots

EXPOSE 8080

# 5) Démarrer le serveur Plumber
CMD ["R", "-e", "pr <- plumber::plumb('/srv/shiny-server/server.R'); pr$run(host='0.0.0.0', port=8080)"]
