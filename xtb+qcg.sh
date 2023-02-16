# Transform from xmol format to tmol 
x2t str.xyz>coord

# To clean directory before proceeding
if [ -d opt ]
then
    rm -r opt
fi
mkdir opt 

if [ -d crest ]
then
    rm -r crest
fi
mkdir crest

#copy coord file from the directory
cd opt
cp ../coord .

#xtb GFN2 optimization and copy optimized geometry to crest dir
xtb coord --opt | tee xtb.out
cp xtbopt.coord ../crest/solute.coord

#Run QCG
cd ../crest
crest solute.coord --qcg solvent.coord  --nsolv 20 | tee crest.out
