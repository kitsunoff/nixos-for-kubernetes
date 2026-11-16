.PHONY: help install dev build pdf pptx clean dev-kz build-kz pdf-kz png-kz

NIX_SHELL := nix-shell --run

# KZ meetup reskin lives in its own directory so it does not inherit the root theme
KZ_ENTRY := kz/slides.md
# extra flags for slidev export, e.g. EXPORT_FLAGS="--executable-path /path/to/chromium"
EXPORT_FLAGS ?=

help:
	@echo "nixos-for-kubernetes — talk build commands"
	@echo ""
	@echo "  make install   install npm dependencies inside nix-shell"
	@echo "  make dev       run slidev dev server with live preview"
	@echo "  make build     build static SPA into dist/"
	@echo "  make pdf       export presentation to PDF"
	@echo "  make pptx      export presentation to PPTX"
	@echo "  make clean     remove build artifacts and node_modules"
	@echo ""
	@echo "  make dev-kz    run dev server for the KZ meetup deck (kz/)"
	@echo "  make build-kz  build KZ deck SPA into dist/kz/"
	@echo "  make pdf-kz    export KZ deck to kz-slides-export.pdf"
	@echo "  make png-kz    export KZ deck to PNGs in slides-png/kz/"

install:
	$(NIX_SHELL) "npm install"

dev:
	$(NIX_SHELL) "npm run dev"

build:
	$(NIX_SHELL) "npm run build"

pdf:
	$(NIX_SHELL) "npm run export"

pptx:
	$(NIX_SHELL) "npm run export:pptx"

dev-kz:
	$(NIX_SHELL) "npx slidev $(KZ_ENTRY) --open"

build-kz:
	$(NIX_SHELL) "npx slidev build $(KZ_ENTRY) --out ../dist/kz"

pdf-kz:
	$(NIX_SHELL) "npx slidev export $(KZ_ENTRY) --output kz-slides-export.pdf $(EXPORT_FLAGS)"

png-kz:
	$(NIX_SHELL) "npx slidev export $(KZ_ENTRY) --format png --output slides-png/kz $(EXPORT_FLAGS)"

clean:
	rm -rf dist node_modules slides-export.pdf slides-export.pptx kz-slides-export.pdf
