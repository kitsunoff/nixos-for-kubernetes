.PHONY: help install dev build pdf pptx clean

NIX_SHELL := nix-shell --run

help:
	@echo "nixos-for-kubernetes — talk build commands"
	@echo ""
	@echo "  make install   install npm dependencies inside nix-shell"
	@echo "  make dev       run slidev dev server with live preview"
	@echo "  make build     build static SPA into dist/"
	@echo "  make pdf       export presentation to PDF"
	@echo "  make pptx      export presentation to PPTX"
	@echo "  make clean     remove build artifacts and node_modules"

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

clean:
	rm -rf dist node_modules slides-export.pdf slides-export.pptx
