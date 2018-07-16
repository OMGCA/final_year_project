#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../src/cgp.h"
#include "../example/cgp-sls.h"

const double threeThreshold[2] = {100,200};

double threeClassThresholdClassifier(struct parameters *params, struct chromosome *chromo, struct dataSet *data){

	int i,j;
	double threshError = 0;

	if(getNumChromosomeInputs(chromo) != getNumDataSetInputs(data)){
	    printf("Error: the number of chromosome inputs must match the number of inputs specified in the dataSet.\n");
	    printf("Terminating.\n");
	    exit(0);
	}

	if(getNumChromosomeOutputs(chromo) != getNumDataSetOutputs(data)){
	    printf("Error: the number of chromosome outputs must match the number of outputs specified in the dataSet.\n");
	    printf("Terminating.\n");
	    exit(0);
	}

	for(i=0; i<getNumDataSetSamples(data); i++){

	    executeChromosome(chromo, getDataSetSampleInputs(data, i));

	    for(j=0; j<getNumChromosomeOutputs(chromo); j++){

	        if ( (((getChromosomeOutput(chromo,j) >= threeThreshold[0])) && ((getDataSetSampleOutput(data,i,j)==3))) ||
                 (((getChromosomeOutput(chromo,j) <= threeThreshold[0]) || (getChromosomeOutput(chromo,j) > threeThreshold[1])) && ((getDataSetSampleOutput(data,i,j)==2))) ||
                 (((getChromosomeOutput(chromo,j) <= threeThreshold[1])) && ((getDataSetSampleOutput(data,i,j)==1)))  )
					threshError++;
	    }
	}

	return threshError / (getNumDataSetSamples(data) * getNumDataSetOutputs(data));
}

