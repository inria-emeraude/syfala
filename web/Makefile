MAKE ?= make

MKDIR := mkdocs
DOCDIR := ../docs

####################################################################
help:
	@echo "======================================================="
	@echo "                   Syfala Documentation"
	@echo "This Makefile is intended to generate the Syfala documentation"
	@echo "======================================================="
	@echo "Available targets are:"
	@echo "  build    : build the web site"
	@echo "  serve    : launch the mkdoc server"
	@echo "Making the current version publicly available:"
	@echo "             just commit and push the /docs folder (master branch)"


####################################################################
build:
	cd $(MKDIR) && mkdocs build
#	git checkout ../docs/CNAME

serve:
	cd $(MKDIR) && mkdocs serve

all:
	$(MAKE) build

clean:
	rm -f $(DOCDIR)
#	git checkout ../docs/CNAME

####################################################################
install:
	pip install mkdocs
	pip install markdown-include
	pip install mkdocs-bootswatch
	pip install python-markdown-math

uninstall:
	pip uninstall -y mkdocs-material
	pip uninstall -y pymdown-extensions
	pip uninstall -y markdown-blockdiag
