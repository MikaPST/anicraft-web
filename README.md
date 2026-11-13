<p align="center">
  <img src="https://raw.githubusercontent.com/storytold/anicraft/main/assets/app-icon/hicolor/256x256/apps/ai.storyteller.anicraft.png" width="128" height="128" alt="AniCraft application icon">
</p>

<h1 align="center">AniCraft Web — Docker Image</h1>
<p align="center">
  A community-maintained Docker image for
  <a href="https://github.com/storytold/anicraft">AniCraft</a>,
  providing its browser-based 2D animation editor through a self-hosted web interface.
  <br>
  Build automation and image publication to GitHub Container Registry (GHCR).
</p>
<p align="center">
  <a href="https://github.com/MikaPST/anicraft-web/actions/workflows/publish-image.yml">
    <img src="https://github.com/MikaPST/anicraft-web/actions/workflows/publish-image.yml/badge.svg" alt="Build and publish AniCraft Web">
  </a>
  <a href="https://github.com/MikaPST/anicraft-web/releases/latest">
    <img src="https://img.shields.io/github/v/release/MikaPST/anicraft-web?label=Release&logo=github&color=blue" alt="Latest Release">
  </a>
  <a href="https://github.com/MikaPST/anicraft-web/pkgs/container/anicraft-web">
    <img src="https://ghcr-badge.egpl.dev/mikapst/anicraft-web/latest_tag?trim=major&label=GHCR" alt="GHCR image tag">
  </a>
  <a href="docker-compose.yml">
    <img src="https://img.shields.io/badge/Docker%20Compose-ready-2496ED?logo=docker&logoColor=white" alt="Docker Compose configuration">
  </a>
</p>

---

## Why this repository?

The official AniCraft project provides a WebAssembly-based 2D animation editor that can be hosted as a static website. This repository packages the web application into a Docker image to simplify self-hosting.

The goals are to:
- Build the AniCraft Web application from the upstream source code.
- Publish a ready-to-run Docker image to GHCR.
- Automatically build a versioned image when a new official AniCraft release is published.
- Publish a matching GitHub Release in this repository, using the official version and release notes.
- Provide a convenient deployment option for Unraid Community Applications.
- Offer a simple Docker Compose configuration for users who prefer managing containers with Compose.
- Keep the packaging and deployment configuration separate from the upstream AniCraft project.

This is a packaging and distribution project, not a fork intended to develop a separate 2D animation editor.

## How it works

AniCraft Web runs directly in the user's browser using WebAssembly. The Docker container serves the static web application through NGINX; it does not provide a remote Linux desktop.
- **Browser-based interface:** access the editor through a web browser.
- **Local file selection:** opening a file uses the browser's file picker.
- **Browser downloads:** saving and exporting documents uses the browser's download mechanism.
- **No remote desktop:** no VNC, remote desktop session or Linux graphical environment is required.
- **Self-hosted:** run the application on your own server and access it over your local network or through a properly configured reverse proxy.

File selection, editing and export are handled by the browser application. The container serves the application files rather than acting as a document-storage service. AniCraft browser autosaves use site-local browser storage; for remote access, HTTPS is required for secure-context browser features such as Web Locks. The browser edition currently has limitations compared with the desktop application (see the upstream web documentation).

## Docker image

Once a build has succeeded, the image is published to GitHub Container Registry:

```text
ghcr.io/mikapst/anicraft-web:latest
```

Each upstream AniCraft release is also published as a matching version tag. For example:

```text
ghcr.io/mikapst/anicraft-web:v0.2.1
```

### Option 1 — Docker Compose (recommended)

A `docker-compose.yml` file is provided at the root of this repository. It is the simplest way to start and maintain AniCraft Web with Docker Compose.

```yaml
services:
  anicraft-web:
    image: ghcr.io/mikapst/anicraft-web:latest
    container_name: anicraft-web
    ports:
      - "8080:8080"
    restart: unless-stopped
```

From the repository root, start the application with:

```bash
docker compose up -d
```

Open the application in your browser:

```text
http://YOUR_SERVER_IP:8080
```

Replace `YOUR_SERVER_IP` with the IP address or hostname of your server. If Docker is running on your own computer, you can use `http://localhost:8080`.

#### Useful Compose commands

```bash
# View container logs
docker compose logs -f

# Pull the latest image and recreate the container
docker compose pull
docker compose up -d

# Stop and remove the container
docker compose down
```

No `.env` file or persistent volume is required for this basic setup. The host port is configured in `docker-compose.yml`; by default, port `8080` on the host is mapped to port `8080` in the container. To use a different host port, change the left-hand side of the mapping. For example, `8081:8080` exposes the application on host port `8081`.

### Option 2 — Run directly with Docker

If you prefer not to use Docker Compose, you can run the container directly:

```bash
docker pull ghcr.io/mikapst/anicraft-web:latest

docker run -d \
  --name anicraft-web \
  --restart unless-stopped \
  -p 8080:8080 \
  ghcr.io/mikapst/anicraft-web:latest
```

Open the application at:

```text
http://YOUR_SERVER_IP:8080
```

Optional CPU and memory limits can be added to the `docker run` command if needed, for example `--cpus=2 --memory=2g`. These limits are not included in the default Compose file.

### Network access and reverse proxies

The container listens for HTTP traffic on port `8080`. For external access, use a reverse proxy such as Traefik to terminate HTTPS and forward requests to the container over HTTP.

Do not expose an unencrypted HTTP port directly to the public Internet. Restrict access to your intended network or protect external access with HTTPS and appropriate access controls.

## Packaging files

- `Dockerfile`: packages the compiled static web assets into an unprivileged NGINX image.
- `nginx.conf`: serves WebAssembly with the correct MIME type and cache policy on port 8080.
- `.dockerignore`: restricts the Docker build context to the generated static web assets and packaging files.
- `.github/workflows/publish-image.yml`: checks upstream releases daily, builds the WebAssembly application and publishes the image.

## Automated builds

GitHub Actions checks the official AniCraft repository for new published releases.

| Trigger | Behaviour |
|---|---|
| Daily schedule | Checks the latest official AniCraft release and builds it if it has not already been published here |
| Manual workflow dispatch | Builds the latest official release, or a specific upstream tag when provided |
| Force rebuild | Rebuilds an already published upstream version and updates its MikaPST Release |
| Workflow changes on `main` | Rebuilds the latest official upstream release using the updated packaging workflow |

Each successful build publishes the following GHCR tags:

- `latest` — the most recently packaged official AniCraft release.
- `<upstream-version>` — the exact upstream release tag, for example `v0.2.1`.
- `upstream-<commit>` — the exact upstream source commit used for the image.

The build targets `linux/amd64` and `linux/arm64`. The WebAssembly application is compiled once on the GitHub Actions runner using the official upstream build script; the resulting static files are packaged into multi-platform NGINX images. It checks out the official AniCraft source at the release tag and uses the versioned Dockerfile and NGINX configuration maintained in this repository.

After the image is successfully built and pushed, this repository creates or updates a GitHub Release with the same version tag. The MikaPST Release includes the upstream release notes, a link to the official release, the upstream commit, supported Docker platforms, image tags and image digest.

The workflow is idempotent: scheduled and ordinary manual runs skip a version that already has a Release in this repository. A manual run can force a rebuild when needed. Changes pushed to the packaging workflow trigger a rebuild of the current latest upstream release.

> [!IMPORTANT]
> A new upstream release is not published to GHCR until its Docker build and multi-platform push have succeeded. The `latest` tag is mutable; use an explicit version tag when you need to keep a deployment on a specific AniCraft release.

AniCraft is under active development. Test new images before relying on them for important work.

## Unraid Community Applications

This image is intended to be distributed through the maintainer's existing Unraid Community Applications repository.

A future Unraid template can reference the published GHCR image and expose the web port.
- **Unraid Community Applications repository:** [MikaPST/unraid-community-apps](https://github.com/MikaPST/unraid-community-apps)
- **AniCraft Web template:** to be added separately to [MikaPST/unraid-community-apps](https://github.com/MikaPST/unraid-community-apps) after the image is validated.

This repository contains the Dockerfile, NGINX configuration, image build, publication workflow and Docker Compose configuration. The Unraid Community Applications template is maintained separately.

## Upstream project

AniCraft is an open-source 2D animation editor developed by the ArtCraft Team and its contributors.
- **Source code:** [storytold/anicraft](https://github.com/storytold/anicraft)
- **Web build documentation:** [AniCraft web editor](https://github.com/storytold/anicraft/blob/main/docs/web.md)
- **Official build script:** [scripts/build-web.sh](https://github.com/storytold/anicraft/blob/main/scripts/build-web.sh)
- **Official releases:** [AniCraft releases](https://github.com/storytold/anicraft/releases)

This repository compiles the official AniCraft WebAssembly application from the selected upstream release tag, then packages the generated static site with its own versioned Dockerfile and NGINX configuration. The MikaPST Release tracks that upstream version but represents the community-maintained Docker packaging, not an official AniCraft release.

## License and attribution

AniCraft is dual-licensed under the **MIT License or Apache License 2.0**, at the user's option. Copyright belongs to the ArtCraft Team and AniCraft contributors.

The upstream project includes license and attribution information for the application and bundled third-party assets. These notices and the applicable license files must be preserved when redistributing the application.
- [Upstream MIT License](https://github.com/storytold/anicraft/blob/main/LICENSE-MIT)
- [Upstream Apache License 2.0](https://github.com/storytold/anicraft/blob/main/LICENSE-APACHE)
- [Upstream NOTICE](https://github.com/storytold/anicraft/blob/main/NOTICE)
- [Upstream asset attributions](https://github.com/storytold/anicraft/blob/main/ATTRIBUTION.md)

The build includes the upstream license and attribution notices under `/licenses/` in the served static files. The licenses for the upstream application do not automatically determine the license of the packaging files maintained in this repository. Refer to the repository's own `LICENSE` file for the terms applicable to those files.

The AniCraft name, ArtCraft branding and logos remain subject to their respective trademark and usage terms. This repository is an independent community-maintained packaging project and is **not an official AniCraft release** and is not affiliated with or endorsed by the AniCraft or ArtCraft maintainers.

## Disclaimer

AniCraft is under active development. Features, compatibility and behaviour may change between builds. Use the application and its generated animations and documents at your own discretion.
