<p align="center">
  <img src="https://raw.githubusercontent.com/storytold/anicraft/main/assets/app-icon/hicolor/256x256/apps/ai.storyteller.anicraft.png" width="128" height="128" alt="AniCraft application icon">
</p>

<h1 align="center">AniCraft Web — Docker Image</h1>
<p align="center">
  A community-maintained Docker image for
  <a href="https://github.com/storytold/anicraft">AniCraft</a>,
  bringing its WebAssembly-based 2D animation editor to a self-hosted web interface.
  <br>
  Automated builds and image publication to GitHub Container Registry (GHCR).
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

The official AniCraft project provides a WebAssembly-based 2D animation editor that can be hosted as a static website. This repository builds the official web application and packages its generated assets into a lightweight NGINX Docker image for straightforward self-hosting.

The goals are to:

- Build AniCraft Web from a specific official upstream release.
- Publish ready-to-run Docker images to GHCR for `linux/amd64` and `linux/arm64`.
- Automatically detect and package new official AniCraft releases.
- Publish a matching GitHub Release **only after the Docker image has been successfully pushed**.
- Provide Docker Compose deployment and support a separately maintained Unraid Community Applications template.
- Keep the `Dockerfile`, `nginx.conf`, `.dockerignore`, and GitHub Actions workflow version-controlled in this repository.
- Preserve upstream license and attribution notices in the published web assets.

This is an independent packaging and distribution project, not a fork intended to develop a separate animation editor.

## How it works

AniCraft Web runs directly in the user's browser using WebAssembly. The Docker container serves the static web application through NGINX; it does **not** provide a remote Linux desktop or server-side document storage.

- **Browser-based animation editor:** create and edit 2D animation projects through a compatible web browser.
- **Local file selection:** opening files uses the browser's file picker.
- **Browser downloads:** saving and exporting files uses browser download mechanisms.
- **Browser-local autosaves:** AniCraft uses site-local browser storage for autosave data.
- **No remote desktop:** no VNC, remote desktop session, or Linux graphical environment is required.
- **Self-hosted:** run the application on your own server and access it on your LAN or through a properly configured HTTPS reverse proxy.

File selection, editing, and export are handled by the browser application. The container serves application files rather than acting as a document-storage backend.

> [!IMPORTANT]
> Browser-local autosaves are not server-side backups. Keep independent copies of important projects and exports. Clearing browser site data or changing the site's origin may affect access to locally stored data.

For remote access, use HTTPS. Browser features such as Web Locks require a secure context. The web edition currently has limitations compared with the desktop application; consult the [official web documentation](https://github.com/storytold/anicraft/blob/main/docs/web.md).

## Docker image

The image is published to GitHub Container Registry after a successful build:

```text
ghcr.io/mikapst/anicraft-web:latest
```

Each successfully packaged upstream AniCraft release is also published under its official version tag. For example:

```text
ghcr.io/mikapst/anicraft-web:v0.2.1
```

Use a versioned tag to stay on a specific upstream release. The `latest` tag is mutable.

### Option 1 — Docker Compose (recommended)

A `docker-compose.yml` file is provided at the root of this repository:

```yaml
services:
  anicraft-web:
    image: ghcr.io/mikapst/anicraft-web:latest
    container_name: anicraft-web
    ports:
      - "8080:8080"
    restart: unless-stopped
```

From the repository root, start the application:

```bash
docker compose up -d
```

Open the application in your browser:

```text
http://YOUR_SERVER_IP:8080
```

Replace `YOUR_SERVER_IP` with your server's IP address or hostname. If Docker runs on your computer, use `http://localhost:8080`. For access from another machine, prefer HTTPS through a reverse proxy to enable secure-context browser features.

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

No `.env` file or persistent server-side application volume is required for the default configuration. To change the host port, edit the left-hand side of `8080:8080`; for example, `8081:8080` exposes the application on host port `8081`.

### Option 2 — Run directly with Docker

If you prefer not to use Docker Compose:

```bash
docker pull ghcr.io/mikapst/anicraft-web:latest

docker run -d \
  --name anicraft-web \
  --restart unless-stopped \
  -p 8080:8080 \
  ghcr.io/mikapst/anicraft-web:latest
```

Open `http://YOUR_SERVER_IP:8080`, or `http://localhost:8080` when using the Docker host itself.

Optional CPU and memory limits can be added to `docker run`, for example `--cpus=2 --memory=2g`. They are not included in the default Compose configuration.

### Network access and reverse proxies

NGINX listens on port `8080`. For external access, use a reverse proxy such as Traefik to terminate HTTPS and forward requests to the container over HTTP.

Do not expose an unencrypted HTTP service directly to the public Internet. Restrict access to your intended network or protect external access with HTTPS and appropriate access controls.

Because AniCraft uses browser-local storage and secure-context browser APIs, prefer a stable HTTPS origin for regular use. Browser data associated with one hostname or scheme is not automatically available under another origin.

## Repository structure

This repository maintains its own Docker packaging configuration while retrieving the official AniCraft source during automated builds.

```text
anicraft-web/
├── .github/
│   └── workflows/
│       └── publish-image.yml
├── .dockerignore
├── Dockerfile
├── nginx.conf
├── docker-compose.yml
└── README.md
```

| File | Purpose |
|---|---|
| `Dockerfile` | Packages the compiled static web application into an NGINX runtime image. |
| `nginx.conf` | Configures the HTTP server, WebAssembly MIME types, and caching. |
| `.dockerignore` | Excludes unnecessary files and directories from the Docker build context. |
| `docker-compose.yml` | Provides a ready-to-use Docker Compose deployment. |
| `.github/workflows/publish-image.yml` | Automates upstream release detection, WebAssembly compilation, multi-platform GHCR publication, and GitHub Releases. |
| `README.md` | Documents the project, packaging architecture, and deployment methods. |

### Docker build architecture

Unlike PhotoCraft's multi-stage Dockerfile, AniCraft compiles its WebAssembly application **on the GitHub Actions runner before Docker packaging**.

The build process follows these steps:

1. GitHub Actions resolves the latest official AniCraft release, or the `upstream_tag` specified during manual dispatch.
2. It checks out `storytold/anicraft` at the selected official release tag into `anicraft-src/`.
3. Rust and the `wasm32-unknown-unknown` target are installed.
4. The workflow reads the required `wasm-bindgen` version from the upstream `Cargo.lock` and installs the matching `wasm-bindgen-cli`.
5. The official `scripts/build-web.sh` script compiles the WebAssembly application.
6. The workflow validates essential output files in `anicraft-src/web/`, including `index.html`, `anicraft.js`, `anicraft_bg.wasm`, and `anicraft.png`. The HTML guide is included when available.
7. The compiled site is copied into a temporary root-level `web/` directory. Available upstream licenses and attribution notices are copied into `web/licenses/`.
8. Docker Buildx uses this repository's version-controlled `Dockerfile` and the prepared build context to publish `linux/amd64` and `linux/arm64` images, without recompiling Rust separately for each architecture.
9. After GHCR publication succeeds, the workflow creates or updates the matching GitHub Release.

The `anicraft-src/` and generated `web/` directories are temporary GitHub Actions workspace content; they are **not** committed to this packaging repository.

The final runtime image serves static assets using NGINX. It does not require Rust, a database, a server-side project volume, or a remote desktop.

> [!NOTE]
> AniCraft is under active development. Future upstream releases may change its Rust dependencies, WebAssembly build script, or generated file layout and require packaging updates.

## Automated builds

GitHub Actions checks the official [AniCraft releases](https://github.com/storytold/anicraft/releases) and builds the selected upstream release.

| Trigger | Behaviour |
|---|---|
| Daily schedule (`03:47 UTC`) | Checks for a new official AniCraft release and skips it when already packaged. |
| Manual workflow dispatch | Builds the latest official release or a specified `upstream_tag`. |
| Force rebuild | Rebuilds an existing version with `force_rebuild: true`. |
| Packaging changes on `main` | Rebuilds the latest upstream release when `.github/workflows/publish-image.yml`, `Dockerfile`, `nginx.conf`, or `.dockerignore` changes. |

### Published tags

Each successful build publishes these GHCR tags:

- `latest` — the most recently successfully packaged upstream release.
- `<upstream-version>` — the exact official release tag, for example `v0.2.1`.
- `upstream-<commit>` — the first 12 characters of the upstream source commit.

Images target `linux/amd64` and `linux/arm64`. The WebAssembly application is compiled once on the GitHub Actions runner, then its static output is packaged into both runtime architectures.

The build uses the official AniCraft source at the selected release tag, combined with the version-controlled packaging configuration maintained in this repository.

### GitHub Releases

After a successful Docker build and GHCR push, the workflow creates or updates a [GitHub Release](https://github.com/MikaPST/anicraft-web/releases) matching the official upstream release tag.

Each release includes:

- The official upstream release name, link, and publication date.
- The upstream version tag and 12-character source commit identifier.
- Official upstream release notes.
- Published Docker image tags.
- Supported architectures (`linux/amd64` and `linux/arm64`).
- The published Docker image digest.
- A notice that the image is community-maintained packaging.

The Release badge at the top of this README reflects the latest published GitHub Release.

Scheduled and ordinary manual runs skip versions already released in this repository. To rebuild an existing version, open **Actions → Build and publish AniCraft Web → Run workflow** and enable `force_rebuild`. Changes to the monitored packaging files on `main` also trigger a rebuild.

> [!IMPORTANT]
> A GitHub Release is created or updated **only after** the multi-platform Docker image has been successfully pushed to GHCR.
>
> The `latest` tag is mutable. Pin a versioned image tag for a stable deployment, noting that a forced rebuild may also replace an existing version tag.

## Unraid Community Applications

AniCraft Web is intended to be distributed through the maintainer's [Unraid Community Applications repository](https://github.com/MikaPST/unraid-community-apps).

- **Unraid Community Applications repository:** [MikaPST/unraid-community-apps](https://github.com/MikaPST/unraid-community-apps)
- **Container image:** `ghcr.io/mikapst/anicraft-web:latest`
- **Container port:** `8080`
- **AniCraft Web template:** planned separately, after the Docker image has been validated.

Until an AniCraft-specific XML template is published, deploy the image through Docker Compose or Unraid's Docker container configuration.

The Unraid template, when available, will be maintained separately from this Docker packaging repository.

## Upstream project

AniCraft is an open-source 2D animation editor developed by the ArtCraft Team and contributors.

- **Source code:** [storytold/anicraft](https://github.com/storytold/anicraft)
- **Official web documentation:** [docs/web.md](https://github.com/storytold/anicraft/blob/main/docs/web.md)
- **Official web build script:** [scripts/build-web.sh](https://github.com/storytold/anicraft/blob/main/scripts/build-web.sh)
- **Official releases:** [AniCraft releases](https://github.com/storytold/anicraft/releases)

This repository builds the official AniCraft WebAssembly application from a selected upstream release tag, using independent Docker packaging. Its GHCR images and GitHub Releases are **not** official AniCraft distributions.

## License and attribution

AniCraft is dual-licensed under the **MIT License or Apache License 2.0**, at the user's option. Copyright belongs to the ArtCraft Team and AniCraft contributors.

The workflow copies available upstream `LICENSE-MIT`, `LICENSE-APACHE`, `NOTICE`, and `ATTRIBUTION.md` files into the published static site's `/licenses/` directory. Available third-party license notices are also preserved.

- [Upstream MIT License](https://github.com/storytold/anicraft/blob/main/LICENSE-MIT)
- [Upstream Apache License 2.0](https://github.com/storytold/anicraft/blob/main/LICENSE-APACHE)
- [Upstream NOTICE](https://github.com/storytold/anicraft/blob/main/NOTICE)
- [Upstream asset attributions](https://github.com/storytold/anicraft/blob/main/ATTRIBUTION.md)

The upstream application's licenses do not automatically determine the license of this repository's independent packaging files. Refer to the packaging repository's own `LICENSE` file, if present, for their applicable terms.

The AniCraft name, artwork, and ArtCraft branding remain subject to their respective owners' rights. This repository is independently maintained and is not affiliated with or endorsed by the official maintainers.

## Disclaimer

AniCraft is under active development. Features, browser compatibility, storage behaviour, and export capabilities may change between builds. Test new images and keep independent backups of important projects and animations.

This repository is community-maintained and is not an official AniCraft release.
