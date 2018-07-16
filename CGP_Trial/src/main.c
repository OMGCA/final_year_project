#include <stdio.h>
#include <math.h>
#include "cgp.h"

#define NUMINPUTS 9
#define NUMOUTPUTS 1
#define NUMSAMPLES 120
#define INPUTRANGE 10.0

int main(void)
{

	struct parameters *params = NULL;
	struct dataSet *trainingData = NULL;
	struct chromosome *chromo = NULL;

	int numInputs = NUMINPUTS;
	int numNodes = 15;
	int numOutputs = 1;
	int nodeArity = 2;

	int numGens = 10000;
	double targetFitness = 0.1;
	int updateFrequency = 500;

	params = initialiseParameters(numInputs, numNodes, numOutputs, nodeArity);

	addNodeFunction(params, "add,sub,mul,div,sin");

	setTargetFitness(params, targetFitness);

	setUpdateFrequency(params, updateFrequency);

	printParameters(params);

	// Note: you may need to check this path such that it is relative to your executable 
	trainingData = initialiseDataSetFromFile("data.csv");

	chromo = runCGP(params, trainingData, numGens);

	printChromosome(chromo, 0);

	freeDataSet(trainingData);
	freeChromosome(chromo);
	freeParameters(params);

	return 0;
}
