.PHONY: all 

# Since this is the first target it will be run if only 'make' is executed
all: 
	make manual.pdf			# We run the manual.pdf target looking for the possibility of a needed recompilation
	evince manual.pdf &		# Open the pdf file using the evince viewer

# If any *.tex file is changed we compile again to create the pdf file
manual.pdf: *.tex */*.tex *.sty
	pdflatex manual.tex
