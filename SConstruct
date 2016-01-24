# -*- mode: python -*-
# SCons build file

import os

# We append the os path to the scons path so that it can gain access to the pdflatex program
env = Environment(ENV={'PATH': os.environ['PATH']})

# Pass pdflatex flags to scons
env.AppendUnique(PDFLATEXFLAGS='-synctex=-1')       # Generates the .synctex index that allows clicking in the pdf to open up corresponding code section in Atom
env.AppendUnique(PDFLATEXFLAGS='-shell-escape')     # Allows running pdflatex in multiple shells. Speeds up building of tikz images.
env.AppendUnique(PDFLATEXFLAGS='-halt-on-error')    # Halts compilation on the first error discovered. Speeds up development and debugging

basename = 'manual'                         # Define basename of the main tex file
pdf = env.PDF(basename + '.tex')            # Primary source of the pdf file

env.Clean(pdf, basename + '.synctex')       # when cleaning remove the pdf and the .synctex file

Default(pdf)            # Default target of the builder
