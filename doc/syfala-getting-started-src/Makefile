#NAME=user-getting-started-doc
TEXMASTERS=developer-doc.tex user-getting-started-doc.tex
TEXSRC=$(wildcard *.tex)
TARGETS=$(TEXMASTERS:.tex=.pdf)
all: ${TARGETS}


%.pdf: %.tex dummy
	pdflatex  $<

bib: dummy
	bibtex developer-doc
	pdflatex developer-doc.tex
	pdflatex developer-doc.tex

dummy:

tar: 	dummy 
	cd ..;tar cvf $(NAME).tar $(NAME)/*.tex $(NAME)/*.bib $(NAME)/*.cls $(NAME)/*.bst $(NAME)/Makefile $(NAME)/fig/*.pdf

clean:
	\rm -f $(TARGETS) *.aux *.blg *.brf *.toc *.log *.out *.bbl
	\rm -rf *~

