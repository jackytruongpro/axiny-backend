# Shiny Snapshot Docker Image

This repository contains a Docker setup to dynamically load and run any `app.R` Shiny application and capture snapshots.

## Prerequisites

- Docker Desktop (with Buildx enabled) on macOS Apple Silicon or Linux
- Git

## Repository Structure

```
saas_shine_converter/
├── Dockerfile
├── loader.R
└── user_app/
    └── app.R
```

## Steps to Build and Run

1. **Clone the repository**

   ```bash
   git clone <your-repo-url> saas_shine_converter
   cd saas_shine_converter
   ```

2. **Place your Shiny app**

   Put your `app.R` inside the `user_app` folder:

   ```bash
   cp path/to/your/app.R user_app/app.R
   ```

3. **Build the Docker image (x86_64 emulation)**

   ```bash
   docker buildx create --use --name multiarch-builder  # one-time setup
   docker buildx build --platform linux/amd64 -t shiny-snapshot --load .
   ```

4. **Run the container**

   ```bash
   docker run --rm -p 3838:3838 -v $(pwd)/user_app:/srv/shiny-server/user_app shiny-snapshot
   ```

5. **Access your app**

   Open your browser at:  
   `http://localhost:3838`

6. **Verify output**

   Confirm that your Shiny dashboard loads without errors.

## Dockerfile Highlights

- **Base image**: `rocker/r-ver:4.3.1` (multi-arch)
- **System deps**: `libcurl4-openssl-dev`, `libssl-dev`, `libxml2-dev`, `zlib1g-dev`, `chromium-browser`
- **R packages**: `httpuv`, `shiny`
- **Loader script**: `loader.R` dynamically sources `app.R`