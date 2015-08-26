# This file contains targets that are specific to each branch. This is the file that should change from branch to branch


# We declare that the files diag/setup.tex and diag/fbd1.tex are both dependent on diag/setup-common.tex since the former use \input to include the latter.
# Whenever diag/setup-common.tex changes it impacts both diag/*.tex which in turn requires that the corresponding build/*.pdf file be recreated
#
# We don't actually have to do the deletion since this target is called by the build/%.pdf target. So when this needs to be executed (when diag/setup-common.tex has changed) make automatically assumes that the build/%.pdf target needs to be executed as well since a prerequisite of its prerequisite has changed.
#
# Basically the only thing that needs to be done here is to 'touch' the diag/%.tex because the way 'make' targets work 'make' expects this target to recompile diag/%.tex. We fool make by updating the timestamp of that file, otherwise this target will keep getting executed because the timestamp of diag/setup-common.tex will be newere than that of diag/%.tex
#
# Note the use of the automatic variable $@ to refer to the target which has triggered the target. Both diag/setup.tex and diag/fbd1.tex will be called whenever their common prerequisite diag/setup-common.tex changes

diag/setup.tex diag/fbd1.tex: diag/setup-common.tex
	touch $@
