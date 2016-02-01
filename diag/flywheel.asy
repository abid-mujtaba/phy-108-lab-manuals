settings.tex="pdflatex";
if (settings.render < 0) settings.render = 8;

defaultpen(fontsize(10pt));
unitsize(1cm);

import solids;
import plain;

revolution c = cylinder(O, 1, 2, Y);

draw(c, linewidth(1pt));
