#include <stdio.h>
#include <math.h>
#include "../src/cgp.h"

#define NUMINPUTS 1
#define NUMOUTPUTS 1
#define NUMSAMPLES 101
#define INPUTRANGE 10.0

double eq1(double area)
{
    double Ax,Ay,FuncA,FuncB,FuncC;
    Ax = 3;
    Ay = 4;
    /*Line representation: A*x+B*y+C = 0*/
    FuncA = Ay/Ax;
    FuncB = 1;
    FuncC = 0;
    /*Derived from triangle area equation*/
    double triangleDownsideLength = sqrt(pow(Ax,2)+pow(Ay,2));
    double triangleHeightLength = sqrt(pow(FuncA,2)+pow(FuncB,2));
    
    return 2*area/triangleDownsideLength*triangleHeightLength/FuncA;
}

double newGradient(double Ax, double Ay, double Bx, double By)
{
    return (By-Ay)/(Bx-Ax);
}

double newCoefficient(double Ax, double Ay, double Bx, double By)
{
    return Ay-Ax*newGradient(Ax,Ay,Bx,By);
}

int main(void)
{
    int i;

    struct dataSet *data = NULL;

    double inputs[NUMSAMPLES][NUMINPUTS];
    double outputs[NUMSAMPLES][NUMOUTPUTS];

    double inputTemp;
    double outputTemp;

    for ( i = 0; i < NUMSAMPLES; i++ )
    {
        inputTemp = ( i * (INPUTRANGE/(NUMSAMPLES-1))) - INPUTRANGE/2;

        outputTemp = eq1(inputTemp);

        inputs[i][0] = inputTemp;
        outputs[i][0] = outputTemp;
    }

    data = initialiseDataSetFromArrays(NUMINPUTS,NUMOUTPUTS,NUMSAMPLES,inputs[0],outputs[0]);

    saveDataSet(data, "equation.data");

    freeDataSet(data);

    struct parameters *params = NULL;
    struct dataSet *trainingData = NULL;
    struct chromosome *chromo = NULL;

    int numInputs = 1;
    int numNodes = 15;
    int numOutputs = 1;
    int nodeArity = 2;

    int numGens = 10000;
    double targetFitness = 0.1;
    int updateFrequency = 500;

    params = initialiseParameters(numInputs,numNodes,numOutputs,nodeArity);

    addNodeFunction(params, "add,sub,mul,div,sin");

    setTargetFitness(params, targetFitness);

    setUpdateFrequency(params,updateFrequency);

    printParameters(params);

    trainingData = initialiseDataSetFromFile("./equation.data");

    chromo = runCGP(params,trainingData,numGens);

    printChromosome(chromo,0);

    double chromoInputs[] = {4};
    double chromoOutputs;

    executeChromosome(chromo, chromoInputs);
    chromoOutputs = getChromosomeOutput(chromo,0);
    printf("Coordinate of C is: (%.2f,0)\n",chromoOutputs);
    printf("Formula expression of line AB is y = %.1f*x+%.1f", newGradient(3,4,chromoOutputs,0), newCoefficient(3,4,chromoOutputs,0));

    freeDataSet(trainingData);
    freeChromosome(chromo);
    freeParameters(params);

    return 0;
}
