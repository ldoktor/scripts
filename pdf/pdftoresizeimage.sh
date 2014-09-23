#!/bin/bash
for AAA in `find . -iname '*.pdf'`; do
	pdfimages $AAA $AAA
done
for AAA in `find . -iname '*.pbm'`; do
	convert -size 1280x1024 - depth 1 -extract 7000x1800+800+0 $AAA.jpg
done
