#NAME=install-toolchain
TEXMASTERS=syfala-getting-started.tex install-toolchain.tex
TEXSRC=$(wildcard *.tex)
TARGETS=$(TEXMASTERS:.tex=.pdf)
all: ${TARGETS}


%.pdf: %.tex dummy
	pdflatex  $<

bib: dummy
	bibtex syfala-getting-started
	pdflatex syfala-getting-started.tex
	pdflatex syfala-getting-started.tex

dummy:

tar: 	dummy 
	cd ..;tar cvf $(NAME).tar $(NAME)/*.tex $(NAME)/*.bib $(NAME)/*.cls $(NAME)/*.bst $(NAME)/Makefile $(NAME)/fig/*.pdf

clean:
	\rm -f $(TARGETS) *.aux *.blg *.brf *.toc *.log *.out
	\rm -rf *~

