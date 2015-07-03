VIEWER = evince		# evince is the default pdf viewer

ifeq (, $(shell which evince))		# We run 'which evince' to confirm that evince is present
	VIEWER = mupdf					# If it is not we switch the viewer to mupdf
endif


.PHONY: all 

# Since this is the first target it will be run if only 'make' is executed
all:
	make manual.pdf			# We run the manual.pdf target looking for the possibility of a needed recompilation
	$(VIEWER) manual.pdf &	# Use the specified VIEWER to open the pdf file

# If any *.tex file is changed we compile again to create the pdf file
manual.pdf: *.tex */*.tex *.sty
	pdflatex manual.tex
