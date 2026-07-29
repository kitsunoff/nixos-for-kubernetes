# nixos-for-kubernetes

Talk: **NixOS instead of Talos — the ideal OS for bare-metal Kubernetes, and not only**.

- Duration: 30 minutes
- Audience: devops / sre
- Language: Russian
- Output: PDF / PPTX

## Project layout

| Path | Purpose |
| --- | --- |
| `slides.md` | Slidev presentation source |
| `style.css` | Theme customization (fonts, spacing) |
| `layouts/` | Custom Slidev layouts (cover, section) |
| `setup/` | Slidev setup hooks (mermaid) |
| `public/` | Static assets (images, QR codes) |

## Prerequisites

- Nix (provides reproducible Node.js + Chromium via `shell.nix`)
- GNU Make

## Commands

```bash
make install   # install npm dependencies
make dev       # run dev server with live preview at http://localhost:3030
make build     # build static SPA into dist/
make pdf       # export presentation to PDF
make pptx      # export presentation to PPTX
make clean     # remove build artifacts
```

## Workflow

1. Edit `slides.md`.
2. Iterate visually with `make dev`.
3. Render `make pdf` before delivery.

## Notes on export

Slidev exports PPTX as a container with raster images per slide — text inside
the PPTX is not editable in PowerPoint. For text-quality output prefer PDF.

On first run, `npm install` will download a Chromium binary into
`node_modules/playwright-chromium/` (Chromium is not provided through Nix on
macOS because nixpkgs Chromium does not build for `aarch64-darwin`). Subsequent
runs reuse the cached browser.
