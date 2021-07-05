###========================================
#!/bin/bash
#BSUB -n 1 
#BSUB -o lsf.out
#BSUB -e lsf.err
#BSUB -q "windfall"
#BSUB -J module2 
#BSUB -x
#---------------------------------------------------------------------
#BSUB -R gpu
#BSUB -R "span[ptile=2]"
mpirun -np 1 ./Histogram_Solution -e ./output.raw -i input.raw -t integral_vector > histogram_output.txt
###end of script
