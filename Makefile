FILE = manual.pdf			# The generated pdf file

# The purpose of the following block is to show the generated pdf file in an efficient fashion.
# First we check if evince is present. If it is we simply use it to show the pdf. If evince is already showing the file it simply refreshes.
# If evince is missing we check if mupdf is installed.
# If NOT we simply print a message saying neither could be found.
# If mupdf is present we next use 'ps' and 'wmctrl' to determine if mupdf is currently running and if a window with title 'manual.pdf' exists. The presence of both is a good indicator that mupdf is already running and showing the pdf in question.
# In this case we use 'wmctrl' to bring the mupdf window to the front and then use 'xdotool' to simulate an R keypress which refreshes/reloads the file.
# If mupdf is not running then we simply launch mupdf to show manual.pdf

ifneq (, $(shell which evince 2> /dev/null))		# We run 'which evince' to confirm that evince is present
	CMD = evince $(FILE) &
else
ifneq (, $(shell which mupdf 2> /dev/null))
ifneq (, $(shell ps -A | grep mupdf && wmctrl -l | grep $(FILE)))
	CMD = @ echo "Refreshing mupdf" && wmctrl -R $(FILE) && xdotool key r
else
	CMD = @ echo "Launching mupdf" && mupdf $(FILE) &
endif
else
	CMD = @echo -e "\nWarning: evince and mupdf are both missing. Unable to open generated pdf file"
endif
endif


.PHONY: all, clean, preamble

# Since this is the first target it will be run if only 'make' is executed
# The only dependency is manual.pdf since that is the file we want to create and view
# make first looks at the 'manual.pdf' target, processes it and then runs the $(CMD) after it regardless of if 'manual.pdf' is required
# If nothing is required for 'manual.pdf' then $(CMD) simply shows it
all: manual.pdf			# We make the manual.pdf target a pre-req of 'all'. The first step is it will check if that target needs to be executed.
	$(CMD)

# In this target we describe what manual.pdf depends upon. If any of the dependencies (or their recursive dependencies change) the command is executed.
# The command describes how 'manual.pdf' is created (using pdf-latex).
# The -shell-escape option is required for Tikz image externalization.
#
# If any *.tex file is changed we compile again to create the pdf file.
# manual.fmt is a dependecy. If manual.sty or manual.tex is changed manual.fmt will need to be recreated and so the command for manual.pdf will be run as well but after the processing for manual.fmt is complete. 
# Tikz externalization uses pre-created images (pdfs) in the build/ folder so build/*.pdf is a dependency
manual.pdf: *.tex build/*.pdf manual.fmt
	pdflatex -shell-escape manual.tex

# We use patterns here.
# We make every pdf in the build/ folder dependent on the corresponding (same name before extension)
# If any of the diag/*.tex file is changed the corresponding pdf file needs to be recreated
# We do that my deleting the corresponding pdf file using $@ which matches the whole target so 'build/<filename>.pdf'
# By deleting the pdf file we force tikz externalization to recreate it because it won't find the pdf when it looks for it. An elegant solution to the complex inter-dependency of the tex and externalized tikz files.
build/%.pdf: diag/%.tex
	rm -f $@

# manual.fmt is created from manual.sty and manual.tex. If either of these change manual.fmt needs to be recreated using the 'make preamble' command.
manual.fmt:	manual.sty manual.tex
	make preamble

# Compile the tex file.
compile:
	pdflatex -shell-escape manual.tex

# Remove all generated files
clean:
	rm -f *.pdf *.aux *.log *.auxlock manual.fmt build/*.pdf build/*.log build/*.dpth

# Pre-compile the preamble to speed up compilation
# Source: http://www.howtotex.com/tips-tricks/faster-latex-part-iv-use-a-precompiled-preamble/
preamble:
	pdftex -ini -jobname="manual" "&pdflatex" mylatexformat.ltx manual.tex
