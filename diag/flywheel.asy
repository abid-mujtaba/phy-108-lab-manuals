settings.tex="pdflatex";        // Produces PDF output by default
if (settings.render < 0) settings.render = 8;       // Successive rendering required for rasterization which is needed for drawing 'revolution' type objects

defaultpen(fontsize(10pt));
unitsize(1cm);

import solids;
import plain;

revolution c = cylinder(O, 1, 2, Y);

draw(c, linewidth(1pt));
