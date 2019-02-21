# DEFAULT RESIZE
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dNOPAUSE -dQUIET -dBATCH -sOutputFile=output.pdf input.pdf
# Black&white + ebook size
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -sColorConversionStrategy=Gray -dProcessColorModel=/DeviceGray -dPDFSETTINGS=/ebook -dNOPAUSE -dQUIET -dBATCH -sOutputFile=output2.pdf naskenováno_20190221-1415.pdf
# Just resize to ebook size
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook -dNOPAUSE -dQUIET -
# Sizes are:
#    -dPDFSETTINGS=/screen lower quality, smaller size. (72 dpi)
#    -dPDFSETTINGS=/ebook for better quality, but slightly larger pdfs. (150 dpi)
#    -dPDFSETTINGS=/prepress output similar to Acrobat Distiller "Prepress Optimized" setting (300 dpi)
#    -dPDFSETTINGS=/printer selects output similar to the Acrobat Distiller "Print Optimized" setting (300 dpi)
#    -dPDFSETTINGS=/default selects output intended to be useful across a wide variety of uses, possibly at the expense of a larger output file