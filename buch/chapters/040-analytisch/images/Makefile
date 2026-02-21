#
# Makefile -- build images
#
# (c) 2026 Prof Dr Andreas Müller
#
all:	nichtanalytisch.pdf wurzel.pdf

nichtanalytisch.pdf:	nichtanalytisch.tex
	pdflatex nichtanalytisch.tex

wurzel.png:	wurzel.pov
	povray +A0.1 -W1920 -H1080 -Owurzel.png wurzel.pov

wurzel.jpg:	wurzel.png Makefile
	magick -extract 1900x850+0+132 wurzel.png wurzel.jpg

wurzel.pdf:	wurzel.tex wurzel.jpg
	pdflatex wurzel.tex
