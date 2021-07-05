#include <thrust/sort.h>



// version 0
// global memory only interleaved version
// include comments describing your approach
__global__ void histogram_global_kernel(unsigned int *input, unsigned int *bins,
                                 unsigned int num_elements,
                                 unsigned int num_bins) {

// insert your code here
int i = blockIdx.x *blockDim.x + threadIdx.x; //Thread index
int stride = blockDim.x * gridDim.x; //Stride is total number of threads

while (i < num_elements) { //Loop
	int num_position = input[i]; // position on the array for bins
	if(num_position< num_bins && num_position >= 0) { //boundary check for number in bin allocation
		atomicAdd(&bins[num_position], 1); //increment bins	
	}
	i = i + stride; // increment loop counter
}

}


// version 1
// shared memory privatized version
// include comments describing your approach
__global__ void histogram_shared_kernel(unsigned int *input, unsigned int *bins,
                                 unsigned int num_elements,
                                 unsigned int num_bins) {

// insert your code here

int i = blockIdx.x *blockDim.x + threadIdx.x; //Thread index
int stride = blockDim.x * gridDim.x; //Stride is total number of threads
__shared__ unsigned int histo_private[4096];//number of histogram privatized bins

if(threadIdx.x < 4096){ 
	histo_private[threadIdx.x]= 0; //intialize each bin to 0
} 
__syncthreads();// syncronize threads in a block

while (i < num_elements) { //Loop
	int num_position = input[i]; //position on the array for bins
	if(num_position < 4096 && num_position >=0){//boundary check for number in bin allocation
		atomicAdd(&histo_private[num_position], 1);
	}
	i = i + stride;	//incremetn loop counter	
}

__syncthreads();// syncronize threads in a block barrier sync


int j = 0; //counter for global histogram

while (j < num_bins) { //loop to atomicadd on bins since they are more than the size of the block....
	atomicAdd(&bins[threadIdx.x + j], histo_private[threadIdx.x + j]);
	j = j + blockDim.x; //increment loop counter
}

}



// version 2
// your method of optimization using shared memory 
// include DETAILED comments describing your approach
__global__ void histogram_shared_accumulate_kernel(unsigned int *input, unsigned int *bins,
                                 unsigned int num_elements,
                                 unsigned int num_bins) {

// insert your code here


//unable to utilize thrust sorting and reduce by key feature as I am not familiar with the library.
//intented to sort privatised histogram before running the last loop or sorting bins array before developing histo_private. 
int i = blockIdx.x *blockDim.x + threadIdx.x; //Thread index
int stride = blockDim.x * gridDim.x; //Stride is total number of threads
__shared__ unsigned int histo_private[4096];//number of histogram privatized bins

if(threadIdx.x < 4096){ 
	histo_private[threadIdx.x]= 0; //intialize each bin to 0
} 
__syncthreads();// syncronize threads in a block barrier sync

while (i < num_elements) { //Loop
	int num_position = input[i]; //position on the array for bins
	if(num_position < 4096 && num_position >=0){//boundary check for number in bin allocation
		atomicAdd(&histo_private[num_position], 1);
	}
	i = i + stride;	//incremetn loop counter	
}

__syncthreads();// syncronize threads in a block barrier sync

//sorting histo_private array 
/*
thrust::sort(A, A+N)
*/

//thrust::sort(thrust::device, bins, num_elements + bins);

int j = 0; //counter for global histogram

while (j < num_bins) { //loop to atomicadd on bins since they are more than the size of the block....
	atomicAdd(&bins[threadIdx.x + j], histo_private[threadIdx.x + j]);
	j = j + blockDim.x; //increment loop counter
}


}

// clipping function
// resets bins that have value larger than 127 to 127. 
// that is if bin[i]>127 then bin[i]=127

__global__ void convert_kernel(unsigned int *bins, unsigned int num_bins) {


// insert your code here
int i = blockIdx.x *blockDim.x + threadIdx.x; //Thread index
if (bins[i] > 127){ //limiting to 127 bins
	bins[i] = 127;
}

}


