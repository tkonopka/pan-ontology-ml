#!/bin/bash -l

## convert primary figures
cd OntoML_files/figure-latex
for figname in all casestudies explaining ontologies reconstruction;
do
  gs -dNOPAUSE -r600x600 -q -sDEVICE=tiffscaled24 -dBATCH -sCompression=lzw \
     -sOutputFile=Fig-$figname.tiff fig.$figname-1.pdf
  gs -dNOPAUSE -r600x600 -q -sDEVICE=png16m -dBATCH \
     -sOutputFile=Fig-$figname.png fig.$figname-1.pdf
done
cd ../../

# convert supplementary figures
cd OntoML_Supplementary_files/figure-latex
for figname in ontologies.notselected.1 ontologies.notselected.2 hp hp.examples fbdv;
do
  gs -dNOPAUSE -r600x600 -q -sDEVICE=tiffscaled24 -dBATCH -sCompression=lzw \
     -sOutputFile=SupFig-$figname.tiff supfig.$figname-1.pdf
  gs -dNOPAUSE -r600x600 -q -sDEVICE=png16m -dBATCH \
     -sOutputFile=SupFig-$figname.png supfig.$figname-1.pdf
done
cd ../../

# collect tiff and png in a separate location "figures"
mkdir figures
mv OntoML_files/figure-latex/*tiff figures/
mv OntoML_files/figure-latex/*png figures/
mv OntoML_Supplementary_files/figure-latex/*tiff figures/
mv OntoML_Supplementary_files/figure-latex/*png figures/

