###========================================
#!/bin/bash
#BSUB -n 1 
#BSUB -o lsf.out
#BSUB -e lsf.err
#BSUB -q "windfall"
#BSUB -J module2 
#---------------------------------------------------------------------
#BSUB -R gpu
#BSUB -R "span[ptile=2]"
mpirun -np 1 ./TiledMatrixMultiplication_Solution -e ./output.raw -i input0.raw,input1.raw -t matrix > tiled_mul_output.txt
###end of script
