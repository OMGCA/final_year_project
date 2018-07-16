#include <stdio.h>
#include <math.h>
#include "../src/cgp.h"
#include "../src/xt.h"
#include "cgp-sls.h"


int main(void)
{

	struct parameters *params = NULL;
	struct dataSet *trainingData = NULL;
	struct dataSet *validationData = NULL;
	struct dataSet *testData = NULL;
	struct chromosome *chromo = NULL;

	int numInputs = 9;
	int numNodes = 20;
	int numOutputs = 1;
	int nodeArity = 5;

	int arrayIndex = 0;
	int numGens = 40000;
	double targetFitness = 0.1;
	int updateFrequency = 500;

	int groupSampleQuantity[3] = {5,10,10};

	double fitnessArray[3][numGens];

	params = initialiseParameters(numInputs, numNodes, numOutputs, nodeArity);

	setRandomNumberSeed(1234);

	addNodeFunction(params, "add,sub,mul,div,sin");

	setTargetFitness(params, targetFitness);

	setMutationRate(params,0.08);

	setShortcutConnections(params,0);

	setNumThreads(params,2);

	//setMutationType(params, "single");

	setCustomFitnessFunction(params,threeClassThresholdClassifier,"simpleThresholdClassifier");

	setUpdateFrequency(params, updateFrequency);

	printParameters(params);


	//chromo = runCGP(params, trainingData, numGens);
	trainingData = initialiseDataSetFromFile("./01training1.csv");
	validationData = initialiseDataSetFromFile("./02validation2.csv");
	testData = initialiseDataSetFromFile("./03test3.csv");
	//chromo = runCGP(params, trainingData, numGens);
	//chromo = initialiseChromosomeFromFile("./structual_68_270418.txt");
	//chromo = runValiTestCGP(params,trainingData,validationData,testData,numGens);
    chromo = fRunValiTestCGP(params, trainingData, validationData, testData,numGens,arrayIndex,fitnessArray);

	//arrayToText(fitnessArray);


    FILE *new_file = fopen("fitness.txt", "w");


	int counter = 0;
	int x = 0;
	for ( x = 0; x < 3; x++ )
    {
        for ( counter = 0; counter <= numGens/updateFrequency; counter++ )
        {
            //printf("%5.2f ", fitnessArray[x][counter]);
            fprintf(new_file, "%5.2f ", fitnessArray[x][counter]);
        }
        //printf("\n");
        fprintf(new_file, "\n");
    }

	FILE *new_file2 = fopen("test_output.txt", "w");



	printChromosome(chromo, 0);
	saveChromosome(chromo,"./chromo1.txt");
	saveChromosomeDot(chromo, 0, "chromo.dot");

	char* trainedClass[] = {"Class1","Class2","Class3"};
	int classIndex = 0;
	double chromoOutputs;

	int i;
	int errorCounter[3] = {0,0,0};
	double expectedClass;
	for(i = 0; i < getNumDataSetSamples(testData); i++ )
	{
	        executeChromosome(chromo, getDataSetSampleInputs(testData, i));
			chromoOutputs = getChromosomeOutput(chromo,0);

            if(chromoOutputs > threeThreshold[1] )
                classIndex = 0;
            else if (chromoOutputs > threeThreshold[0] && chromoOutputs <= threeThreshold[1])
                classIndex = 1;
            else if (chromoOutputs <= threeThreshold[0])
                classIndex = 2;

			expectedClass = getDataSetSampleOutput(testData,i,0);
			printf("\n%.2f\t%.2f\t%s",chromoOutputs, expectedClass, trainedClass[classIndex]);

			fprintf(new_file2, "%.2f ", chromoOutputs);
			fprintf(new_file2, "%.2f", expectedClass);
			fprintf(new_file2, "\n");

			if (expectedClass == 1)
            {
                if(classIndex != 0)
                    errorCounter[0]++;
            }
            else if (expectedClass == 2)
            {
                if(classIndex != 1)
                    errorCounter[1]++;
            }
            else if (expectedClass == 3)
            {
                if(classIndex != 2)
                    errorCounter[2]++;
            }
	}
	printf("\nUnmatch results in Class 1: %d/%d\nUnmatch results in Class 2: %d/%d\nUnmatch results in Class 3: %d/%d",errorCounter[0],groupSampleQuantity[0],errorCounter[1],groupSampleQuantity[1],errorCounter[2],groupSampleQuantity[2]);

	freeDataSet(trainingData);
	freeDataSet(validationData);
	freeDataSet(testData);
	freeChromosome(chromo);
	freeParameters(params);

	return 0;
}

