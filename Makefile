NAME := manual.x				# The name pattern of files in the project. The .x will be substitued with the relevant extensions (pdf, tex, fmt, sty, .etc).
FILE := $(NAME:.x=.pdf)			# The generated pdf file. Note the use or variable subsitutions to change manual.x to manual.pdf

# The purpose of the following block is to show the generated pdf file in an efficient fashion.
# First we check if evince is present. If it is we simply use it to show the pdf. If evince is already showing the file it simply refreshes.
# If evince is missing we check if mupdf is installed.
# If NOT we simply print a message saying neither could be found.
# If mupdf is present we next use 'ps' and 'wmctrl' to determine if mupdf is currently running and if a window with title 'manual.pdf' exists. The presence of both is a good indicator that mupdf is already running and showing the pdf in question.
# In this case we use 'wmctrl' to bring the mupdf window to the front and then use 'xdotool' to simulate an R keypress which refreshes/reloads the file.
# If mupdf is not running then we simply launch mupdf to show manual.pdf

ifneq (, $(shell which evince 2> /dev/null))		# We run 'which evince' to confirm that evince is present
	CMD := evince $(FILE) &
else
ifneq (, $(shell which mupdf 2> /dev/null))
# We check that mupdf is running and that a window with $(FILE) in the title is present. Because of the peculiarity of make in that it cannot directly access the exit codes of shell commands we have to slightly round-about here.
# We use ps -A and wmctrl to test for both conditions. We use > /dev/null to ensure that these commands do NOT print to stdout. We use && to ensure that both conditions must be met.
# We use the || so that the 'echo' is executed only if the first two commands both fail. In that case the word "Fail" is printed to stdout.
# The 'ifeq' tests if the output of the command is empty. If it is we simply refresh the mupdf window.
# If "Fail" is printed the ifeq command fails and we launch the pdf using mupdf.
ifeq (, $(shell ps -A | grep mupdf > /dev/null && wmctrl -l | grep $(FILE) > /dev/null || echo "Fail"))
	CMD := @ echo "Refreshing mupdf" && wmctrl -R $(FILE) && xdotool key r
else
	CMD := @ echo "Launching mupdf" && mupdf $(FILE) &
endif
else
	CMD := @echo -e "\nWarning: evince and mupdf are both missing. Unable to open generated pdf file"
endif
endif


.PHONY: all, clean, preamble, fresh


# Since this is the first target it will be run if only 'make' is executed
# The only dependency is manual.pdf since that is the file we want to create and view
# make first looks at the 'manual.pdf' target, processes it and then runs the $(CMD) after it regardless of if 'manual.pdf' is required
# If nothing is required for 'manual.pdf' then $(CMD) simply shows it
all: $(NAME:.x=.pdf)			# We make the final .pdf file target a pre-req of 'all'. The first step is it will check if that target needs to be executed.
	$(CMD)

# In this target we describe what manual.pdf depends upon. If any of the dependencies (or their recursive dependencies change) the command is executed.
# The command describes how 'manual.pdf' is created (using pdf-latex).
# The -shell-escape option is required for Tikz image externalization.
#
# If any *.tex file is changed we compile again to create the pdf file.
# manual.fmt is a dependecy. If manual.sty or manual.tex is changed manual.fmt will need to be recreated and so the command for manual.pdf will be run as well but after the processing for manual.fmt is complete.
# Tikz externalization uses pre-created images (pdfs) in the build/ folder so build/*.pdf is a dependency. We use $(wildcard build/*.pdf) to create the list of pdfs in build/ since it will evaluate to empty if none are found. Using build/*.pdf directly as a dependency causes errors when no pdfs exist in build.
$(FILE): *.tex $(wildcard build/*.pdf) $(NAME:.x=.fmt)
	make compile

# We use patterns here.
# We make every pdf in the build/ folder dependent on the corresponding (same name before extension)
# If any of the diag/*.tex file is changed the corresponding pdf file needs to be recreated
# We do that my deleting the corresponding pdf file using $@ which matches the whole target so 'build/<filename>.pdf'
# By deleting the pdf file we force tikz externalization to recreate it because it won't find the pdf when it looks for it. An elegant solution to the complex inter-dependency of the tex and externalized tikz files.
build/%.pdf: diag/%.tex $(wildcard diag/*common*.tex)
	rm -f $@

# manual.fmt is created from abid-base.sty, manual.sty and manual.tex. If either of these change manual.fmt needs to be recreated using the 'make preamble' command.
$(NAME:.x=.fmt): $(NAME:.x=.sty) $(NAME:.x=.tex) abid-base.sty ciit-manual.sty
	make preamble

# Compile the tex file using scons which takes care of any repeated compilation that may be required
compile:
	scons

# Remove all generated files (with the exception of comsats-logo.pdf)
clean:
	rm -f $(NAME:.x=.pdf) *.aux *.log *.auxlock $(NAME:.x=.fmt) $(NAME:.x=.fls) $(NAME:.x=.synctex) .sconsign.dblite build/*.pdf build/*.log build/*.dpth build/*.md5

# Clean the environment before compiling the pdf afresh
fresh:
	make clean
	make all

# Pre-compile the preamble to speed up compilation
# Source: http://www.howtotex.com/tips-tricks/faster-latex-part-iv-use-a-precompiled-preamble/
# Note the use of $(NAME:.x=) to get the string "manual" without the ".x" since -jobname only needs the word "manual" to create the manual.fmt file
preamble:
	pdftex -ini -jobname="$(NAME:.x=)" "&pdflatex" mylatexformat.ltx $(NAME:.x=.tex)


# We include the local.mk file which contains targets that are local/specific to each branch
# We intend this Makefile to be common between all branches and all specificity to be contained in the local.mk file
# The '-' before include tells 'make' to ignore errors in executing this command. Basically this will not complain if 'local.mk' is missing
-include local.mk
