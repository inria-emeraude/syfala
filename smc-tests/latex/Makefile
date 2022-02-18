NAME=fig7
TEXSRC=$(wildcard *.tex)

all: $(NAME).pdf


%.pdf: %.tex dummy
	pdflatex  $<

bib: $(NAME).aux
	bibtex $(NAME)
	pdflatex $(NAME)
	pdflatex $(NAME)

dummy:

tar: 	dummy 
	cd ..;tar cvf $(NAME).tar $(NAME)/*.tex $(NAME)/*.bib $(NAME)/*.cls $(NAME)/*.bst $(NAME)/Makefile $(NAME)/fig/*.pdf

clean:
	rm -rf $(NAME).pdf $(NAME).aux $(NAME).bbl $(NAME).blg $(NAME).log $(NAME).out
	\rm -rf *~

clear:
