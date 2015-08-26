# This file contains targets that are specific to each branch. This is the file that should change from branch to branch

# We declare that the file diag/setup.tex is dependent on diag/setup-common.tex since the former uses \input to include the latter.
# Whenever diag/setup-common.tex changes it impacts diag/setup.ex which in turn requires that the build/setup.pdf file be recreated
# This is done by deleting build/setup.pdf which forces pdf-latex to compile it
# Finally we have to 'touch' diag/setup.tex because the way 'make' targets work 'make' expects this target to recompile diag/setup.tex. We fool make by updating the timestamp of that file, otherwise this target will keep getting executed because the timestamp of diag/setup-common.tex will be newere than that of diag/setup.tex
diag/setup.tex: diag/setup-common.tex
	rm -f build/setup.pdf
	touch diag/setup.tex

diag/fbd1.tex: diag/setup-common.tex
	rm -f build/fbd1.pdf
	touch diag/fbd1.tex
