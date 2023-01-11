#!/bin/bash

printf "Please enter the name of xyz file: \n"
read filename
filename="$PWD/$filename"
if [[ ! -f $filename ]] 
then
   echo "Such file does not exist"
   exit 0
fi
file=$(basename $filename)

## delete gradients from previous run
rm gradient 2>>/dev/null

k=0
atom_num=($(cat $filename | awk '{ print $0 }'))
printf -v int '%d' ${atom_num[0]}
int=$(($int-1))
   
   
## To iterate through atom list
for atoms in $(seq 0 1 $int) # rows
do
   
   ## To iterate through x y z coordinates
   for i in {2..4} # columns
   do
      k=$(($k+1)) # shows the ongoing coordinate number              
      
      ## +h -h
      for dist in {1..2}
      do
         ## Use only to create directories
         if [ $dist -eq 1 ]
         then
            delta_h="+h"
         else
            delta_h="-h"
         fi
         
         ## Create dir for calc
         dir="$PWD/$k"
         rm -r ${k}_${delta_h} 2>>/dev/null
         mkdir ${k}_${delta_h} 2>>/dev/null 
         echo "$ki_${delta_h} coordinate is calculated"
         
         ## Open dir and copy xyz
         cd ${k}_${delta_h}
         cp $filename .
         cp ../xcontrol .

         myarr=($(cat $filename | awk -v column=$i '{ print $column }')) # take column 
         #point=$(awk -v row=$atoms 'NR=row{$1}') 

   
         if [ $dist -eq 1 ]
         then
            myarr[$atoms]=$(echo "${myarr[$atoms]}+0.001" | bc) # add/subtract 0.001 
         else
            myarr[$atoms]=$(echo "${myarr[$atoms]}-0.001" | bc) # add/subtract 0.001 
         fi
         row=$(($atoms+3))   # row position indicator
         awk -i inplace  -v column=$i -v row=$row -v value=${myarr[$atoms]} 'NR==row{$column=value} {print}' $PWD/$file # substitute coordinate
            
         ## EXECUTION and analysis
         xtb ethan.xyz --oniom turbomole:gfn2 1,3-5 --input xcontrol | tee xtb.out # execute
         res[$dist]=$(grep " TOTAL ENERGY            " xtb.out | awk '{ print $4 }') # grep energy
         cd ..
      done
      
      ## write numerical gradients to "gradient" file
      grad=$(echo "(${res[2]}*(-1)+${res[1]})/(2*0.0018897)" | bc -l)
      echo $grad>> gradient
   done
done
