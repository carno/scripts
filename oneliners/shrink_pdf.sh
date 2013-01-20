#!/bin/bash

# Try to decrease the size of the pdf file, useful for files with lot's of
# images or scans

gs  -q -dNOPAUSE -dBATCH -dSAFER \
    -sDEVICE=pdfwrite \
    -dCompatibilityLevel=1.3 \
    -dPDFSETTINGS=/ebook \
    -dEmbedAllFonts=true \
    -dSubsetFonts=true \
    -dColorImageDownsampleType=/Bicubic \
    -dColorImageResolution=90 \
    -dGrayImageDownsampleType=/Bicubic \
    -dGrayImageResolution=90 \
    -dMonoImageDownsampleType=/Bicubic \
    -dMonoImageResolution=90 \
    -sOutputFile=$(basename "$1" .pdf)_out.pdf \
     $1
