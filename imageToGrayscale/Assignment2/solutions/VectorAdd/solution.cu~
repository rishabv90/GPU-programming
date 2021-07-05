#include <wb.h>

//just testing
/*
#include<cuda.h>
#include <cuda_runtime.h>
#include<stdio.h>
#include<stdlib.h>
*/

__global__ void vecAdd(float *in1, float *in2, float *out, int len) {
  //@@ Insert code to implement vector addition here
  //   and launch your kernel from the main function

	int threadId;

	threadId = blockDim.x * blockIdx.x + threadIdx.x;

	if(threadId < len){
		
		out[threadId] = in1[threadId] + in2[threadId]; 
		printf("\n SUM for tid %d , bid %d is %f + %f = %f\n", threadIdx.x, blockIdx.x, in1[threadId],  in2[threadId], out[threadId]);
		
	}
}

int main(int argc, char **argv) {
  wbArg_t args;
  int inputLength;
  float *hostInput1;
  float *hostInput2;
  float *hostOutput;
  float *deviceInput1;
  float *deviceInput2;
  float *deviceOutput;

  args = wbArg_read(argc, argv);

  wbTime_start(Generic, "Importing data and creating memory on host");
  hostInput1 = (float *)wbImport(wbArg_getInputFile(args, 0), &inputLength);
  hostInput2 = (float *)wbImport(wbArg_getInputFile(args, 1), &inputLength);
  hostOutput = (float *)malloc(inputLength * sizeof(float));
  wbTime_stop(Generic, "Importing data and creating memory on host");

  wbLog(TRACE, "The input length is ", inputLength);

  wbTime_start(GPU, "Allocating GPU memory.");
  //@@ Allocate GPU memory here - device input1 + 2 and output
  if(cudaMalloc((void **) &deviceInput1, inputLength*sizeof(float)) != cudaSuccess){
	printf("Malloc error for device_input1");
	return 0;
  }  

  if(cudaMalloc((void **) &deviceInput2, inputLength*sizeof(float)) != cudaSuccess){
	printf("Malloc error for device_input2");
	return 0;
  }  
 	 

  if(cudaMalloc((void **) &deviceOutput, inputLength*sizeof(float)) != cudaSuccess){
	printf("Malloc error for deviceOutput");
	return 0;
  }  
 	
	
  wbTime_stop(GPU, "Allocating GPU memory.");

  wbTime_start(GPU, "Copying input memory to the GPU.");
  //@@ Copy memory to the GPU here

if (cudaMemcpy(deviceInput1,hostInput1,inputLength* sizeof(float),cudaMemcpyHostToDevice) != cudaSuccess){
  cudaFree(deviceInput1);
  cudaFree(deviceInput2);
  printf("data transfer error from host to device on deviceInput1\n");
  return 0;
 }

if (cudaMemcpy(deviceInput2,hostInput2,inputLength* sizeof(float),cudaMemcpyHostToDevice) != cudaSuccess){
  cudaFree(deviceInput1);
  cudaFree(deviceInput2);
  printf("data transfer error from host to device on deviceInput1\n");
  return 0;
 }

/* Don't think we have to do this
if (cudaMemcpy(deviceOutput,hostOutput,inputLength* sizeof(float),cudaMemcpyHostToDevice) != cudaSuccess){
  cudaFree(deviceInput1);
  cudaFree(deviceInput2);
  printf("data transfer error from host to device on deviceInput1\n");
  return 0;
 }
*/
  wbTime_stop(GPU, "Copying input memory to the GPU.");

  //@@ Initialize the grid and block dimensions here

dim3 mygrid(ceil(inputLength/256.0));
dim3 myblock(256);

  wbTime_start(Compute, "Performing CUDA computation");
  //@@ Launch the GPU Kernel here

  vecAdd<<<mygrid,myblock>>>(deviceInput1,deviceInput2,deviceOutput, inputLength);

  cudaDeviceSynchronize();
  wbTime_stop(Compute, "Performing CUDA computation");

  wbTime_start(Copy, "Copying output memory to the CPU");
  //@@ Copy the GPU memory back to the CPU here

  /*if (cudaMemcpy(hostOutput,deviceOutput,inputLength*sizeof(float),cudaMemcpyDeviceToHost) != cudaSuccess){

   cudaFree(deviceInput1);
   cudaFree(deviceInput2);
   printf("data transfer error from host to device on deviceOutput\n");

   return 0;
 }*/

  cudaMemcpy(hostOutput,deviceOutput,inputLength*sizeof(float),cudaMemcpyDeviceToHost);

  wbTime_stop(Copy, "Copying output memory to the CPU");

  wbTime_start(GPU, "Freeing GPU Memory");
  //@@ Free the GPU memory here

  cudaFree(deviceInput1);
  cudaFree(deviceInput2);
  cudaFree(deviceOutput);	
  	

  wbTime_stop(GPU, "Freeing GPU Memory");

  wbSolution(args, hostOutput, inputLength);

  free(hostInput1);
  free(hostInput2);
  free(hostOutput);

  return 0;
}
