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


.PHONY: all 

# Since this is the first target it will be run if only 'make' is executed
all: manual.pdf					# We make the manual.pdf target a pre-req of 'all'. The first step is it will check if that target needs to be executed.
	$(CMD)

# If any *.tex file is changed we compile again to create the pdf file
manual.pdf: *.tex */*.tex *.sty
	pdflatex manual.tex
