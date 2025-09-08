# 1. Base R multi-arch
FROM rocker/r-ver:4.3.1

# 2. Installer les dépendances système et Shiny
RUN apt-get update && \
    apt-get install -y \
      sudo \
      pandoc \
      pandoc-citeproc \
      libcurl4-openssl-dev \
      libssl-dev \
      libxml2-dev \
      zlib1g-dev \
      chromium-browser && \
    R -e "install.packages(c('httpuv','shiny'), repos='https://cloud.r-project.org')" && \
    rm -rf /var/lib/apt/lists/*

# 3. Copier le loader
COPY loader.R /srv/shiny-server/loader.R

# 4. Exposer le port Shiny
EXPOSE 3838

# 5. Démarrer l’application
CMD ["R", "-e", "shiny::runApp('/srv/shiny-server/loader.R', host='0.0.0.0', port=3838)"]
