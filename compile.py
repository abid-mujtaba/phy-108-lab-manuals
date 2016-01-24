#! /usr/bin/env python3

# This script uses subprocess to compile the Latex project.
# It parses the output produced by every compilation and based on it re-compiles the project if necessary. For instance to get cross-references (using \label and \eqref) to work.

import re
import subprocess
import sys

# The -shell-escape flag is needed because it allows pdflatex to spawn parallel processes for building tikz pdfs (this speeds up recompilation)
# The -halt-on-error ensures that if an error occurs the interactive mode is NOT launched and the compilation halts immediately (without creating a broken pdf file). This allows issuing 'make' again to work since it detects a lack of the manual.pdf file and any other build/%.pdf files and recompiles accordingly
# The --synctex=-1 runs synctex which generates a .synctex file (--synctex=1 creates a gzipped .synctex.gz file to save space). This file contains an index which relates pdf output to source code. In Atom clicking on any portion of the pdf will immediately jump you to the relevant portion of code
COMMAND = "pdflatex -halt-on-error -shell-escape --synctex=-1"

def main():

    if len(sys.argv) <= 1:
        error("Missing filename.")

    compile(sys.argv[1])        # Carries out the compilation based on the filename specified


def compile(filename):

    # Open a sub-process with shell set to true otherwise the extended pdflatex command won't work
    # Set stdout=subprocess.PIPE so that we can read the output of the command in real time by reading it off of the output of the PIPE
    # Set bufsize=1 so that the output is printed as soon as it is produced
    p = subprocess.Popen("{} {}".format(COMMAND, filename), shell=True, stdout=subprocess.PIPE, bufsize=1)

    # rerun flag. If true compilation is carried out again
    rerun = False

    # We use this regex to filter the output and determine if the compilation needs to be rerun
    regexes = [re.compile(".*Rerun.*"), re.compile(".*undefined references.*")]

    # Iterate over the output lines
    for line in iter(p.stdout.readline, b''):

        output = line.decode()      # Convert binary data to string
        print(output, end="")       # Print the line received

        for regex in regexes:
            if (regex.match(output)):       # If the line matches the regex the rerun flag should be set
                rerun = True
                break

    # Close the pipe stdout and the pipe itself otherwise the shell won't know that the pipe has terminated
    p.stdout.close()
    p.wait()

    # Detect a failure in the compilation. If the compilation fails this script fails with the same error code
    if (p.returncode != 0):
        print("\nCompilation Failed\n")
        sys.exit(p.returncode)

    # If a rerun match occurs we make a recurisve call to this function to carry our re-compilation
    if (rerun):
        print("\n==========================\nRerunning Compilation\n==========================\n")

        compile(filename)       # Recursive call


def error(msg):
    print("Error - {}".format(msg))
    sys.exit(1)


if __name__ == '__main__':
    main()
