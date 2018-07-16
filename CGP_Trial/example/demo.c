/*
	This file is part of CGP-Library
	Copyright (c) Andrew James Turner 2014 (andrew.turner@york.ac.uk)

    CGP-Library is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    CGP-Library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with CGP-Library.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <stdio.h>
#include <stdlib.h>
#include "cgp-sls.h"
#include <math.h>

	double mean(const int numInputs, const double *inputs, const double *connectionWeights){

		int i;
		double sum = 0;

		for(i=0; i<numInputs; i++){
			sum += inputs[i];
		}

		return sum/numInputs;
	}

	double max(const int numInputs, const double *inputs, const double *connectionWeights){

		if (inputs[0]>inputs[1]) return inputs[0];
		else return inputs[1];
	}

	double min(const int numInputs, const double *inputs, const double *connectionWeights){

		if (inputs[0]<inputs[1]) return inputs[0];
		else return inputs[1];
	}

	double mod(const int numInputs, const double *inputs, const double *connectionWeights){

		return fmod(inputs[0], inputs[1]);

	}

	double simpleThresholdClassifier(struct parameters *params, struct chromosome *chromo, struct dataSet *data){

	    int i,j;
	    double threshError = 0;
	    double threshold = 0.5;

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

	            if (((getChromosomeOutput(chromo,j) <= threshold) && ((getDataSetSampleOutput(data,i,j)==2)||(getDataSetSampleOutput(data,i,j)==3) ||(getDataSetSampleOutput(data,i,j)==4) ))
	            || ((getChromosomeOutput(chromo,j) > threshold) && ((getDataSetSampleOutput(data,i,j)==5)||(getDataSetSampleOutput(data,i,j)==6) ||(getDataSetSampleOutput(data,i,j)==7) || ((getDataSetSampleOutput(data,i,j)==8)))))
	            		threshError++;
	        }
	    }

	    return threshError / (getNumDataSetSamples(data) * getNumDataSetOutputs(data));
	}

	double DoubleOutputSimpleThresholdClassifier(struct parameters *params, struct chromosome *chromo, struct dataSet *data){

	    int i;
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

	        //for(j=0; j<getNumChromosomeOutputs(chromo); j++){

	            if (((getChromosomeOutput(chromo,0) <= getChromosomeOutput(chromo,1)) && (getDataSetSampleOutput(data,i,0)==1))
	            || ((getChromosomeOutput(chromo,0) > getChromosomeOutput(chromo,1)) && (getDataSetSampleOutput(data,i,0)==0)))
	            		threshError++;
	        //}
	    }

	    return threshError / (getNumDataSetSamples(data));
	}



int main(void){

	struct parameters *params = NULL;
	struct dataSet *trainingData = NULL;
	struct dataSet *validationData = NULL;
	struct dataSet *testData = NULL;
	struct chromosome *chromo = NULL;
//	struct results *rels;

	int numInputs = 8;
	int numNodes = 21;
	int numOutputs = 1;
	int nodeArity = 2;

	int numGens = 6000;
//	int numRuns = 3;
	double targetFitness = 0.1;
	int updateFrequency = 5;





	params = initialiseParameters(numInputs, numNodes, numOutputs, nodeArity);

	setRandomNumberSeed(1234);
//	setMutationRate(params,0.05);

	setCustomFitnessFunction(params, simpleThresholdClassifier, "STC");


//	addNodeFunction(params, "nand,nor,xor,or,and,xnor,not,1,0");
//	addNodeFunction(params, "sin, cos");
	addNodeFunction(params, "add,sub,mul,div");
//	addCustomNodeFunction(params, mean, "mean", -1);
//	addCustomNodeFunction(params, max, "max", -1);
//	addCustomNodeFunction(params, min, "min", -1);
//	addCustomNodeFunction(params, mod, "mod", -1);

//	setRecurrentConnectionProbability(params, 0.0);

	setTargetFitness(params, targetFitness);

	setUpdateFrequency(params, updateFrequency);

	printParameters(params);

/*	trainingData = initialiseDataSetFromFile("/Users/sls5/Dropbox/Philips/for stephen/for stephen/trainSO1.data");

	printf("Training dataset read\n");

	validationData = initialiseDataSetFromFile("/Users/sls5/Dropbox/Philips/for stephen/for stephen/validSO1.data");

	printf("Validation dataset read\n");

	testData = initialiseDataSetFromFile("/Users/sls5/Dropbox/Philips/for stephen/for stephen/testSO1.data");

	printf("Test dataset read\n");*/

	/*

	trainingData = initialiseDataSetFromFile("/Users/sls5/Dropbox/UCL/CGP/TrainDataOff.csv");

	printf("Training dataset read\n");

	validationData = initialiseDataSetFromFile("/Users/sls5/Dropbox/UCL/CGP/ValidDataOff.csv");

	printf("Validation dataset read\n");

	testData = initialiseDataSetFromFile("/Users/sls5/Dropbox/UCL/CGP/TestDataOff.csv");

	printf("Test dataset read\n");
	*/
	trainingData = initialiseDataSetFromFile("data3.csv");
	validationData = initialiseDataSetFromFile("data3.csv");

	chromo = runCGP(params, trainingData, validationData, numGens);

//	chromo = runValiCGP(params, trainingData, validationData, numGens);
//	rels = repeatValiCGP(params, trainingData, validationData, numGens, numRuns);

//	saveResults(rels, "/Users/sls5/Dropbox/cgp/CGP-Library-V2.3/dataSets/repeatSymbolic.results");

	printChromosome(chromo, 0);
	///saveChromosome(chromo,"/Users/sls5/Dropbox/Philips/for stephen/bestChromo");
	saveChromosomeDot(chromo,0,"./Chromo.dot");
	saveChromosomeLatex(chromo,0,"./Chromo.tex");


	char* trainedClass;
	double chromoOutputs;

	int i;
	double expectedClass;
	for(i=0; i<getNumDataSetSamples(trainingData); i++){
	        executeChromosome(chromo, getDataSetSampleInputs(trainingData, i));
			chromoOutputs = getChromosomeOutput(chromo,0);
			if(chromoOutputs > 0.5)
				trainedClass = "Class1";
			else if (chromoOutputs <= 0.5)
				trainedClass = "Class2";
			expectedClass = getDataSetSampleOutput(trainingData,i,0);
			printf("\n%.2f\t%.2f\t%s",chromoOutputs, expectedClass, trainedClass);
	}

	printf("\nCustom Cube Test\n");

	double chromoInputs[] = {11.7089,82.9114,4.5886,0.79114,9,100,0.001,8};
	executeChromosome(chromo,chromoInputs);
	chromoOutputs = getChromosomeOutput(chromo,0);
	if(chromoOutputs > 0.5)
		trainedClass = "Class1";
	else if (chromoOutputs <= 0.5)
		trainedClass = "Class2";
	expectedClass = 8;
	printf("\n%.2f\t%.2f\t%s",chromoOutputs, expectedClass, trainedClass);

	double chromoInputs2[] = {41.3294,43.2708,14.9391,0.46068,9,100,0.001,8};
	executeChromosome(chromo,chromoInputs2);
	chromoOutputs = getChromosomeOutput(chromo,0);
	if(chromoOutputs > 0.5)
		trainedClass = "Class1";
	else if (chromoOutputs <= 0.5)
		trainedClass = "Class2";
	expectedClass = 8;
	printf("\n%.2f\t%.2f\t%s",chromoOutputs, expectedClass, trainedClass);

	//executeChromosome(chromo, chromoInputs);
	//chromoOutputs = getChromosomeOutput(chromo,0);
	//printf("\n%d\n",chromoOutputs);

	freeDataSet(trainingData);
	freeDataSet(validationData);
	//freeDataSet(testData);
	freeChromosome(chromo);
	freeParameters(params);

	printf("\n\nAll done.");

	return 0;
}
