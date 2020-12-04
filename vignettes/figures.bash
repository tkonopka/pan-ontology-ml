#!/bin/bash -l

cd OntoML_files/figure-latex

## convert primary figures to tiff
for figname in all casestudies explaining ontologies reconstruction;
do
  gs -dNOPAUSE -r600x600 -q -sDEVICE=tiffscaled24 -dBATCH -sCompression=lzw \
     -sOutputFile=Fig-$figname.tiff fig.$figname-1.pdf
  gs -dNOPAUSE -r600x600 -q -sDEVICE=png16m -dBATCH \
     -sOutputFile=Fig-$figname.png fig.$figname-1.pdf
done


cd ../../
mkdir figures
mv OntoML_files/figure-latex/*tiff figures/
mv OntoML_files/figure-latex/*png figures/


