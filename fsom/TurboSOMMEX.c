/* Update of the Probabilistic Self-organising Maps from:
Foreground Detection in Video Sequences with Probabilistic Self-Organising Maps
Ezequiel Lopez-Rubio, Rafael Marcos Luque-Baena and Enrique Dominguez
International Journal of Neural Systems. ISSN: 0129-0657. DOI: 10.1142/S012906571100281X
 
 Example usage: See the matlab file test.m 

Coded by: R.M.Luque and Ezequiel Lopez-Rubio
Date: June 2011
*/

/*
Use the following commands to compile this MEX file at the Matlab prompt:
32-bit and 64-bit Windows:
mex TurboSOMMEX.c Debugging.c
*/

#include "mex.h"
#include "Debugging.h"
#include <stdio.h>
#include <math.h>
#include <time.h>
#include <float.h>
#include <string.h>

/* Get the pixel (x,y) with image size (M,N)
   MY_PIXEL = (x-1)*M + (y-1)	
   Ej: Pixel (153,430) and size (480,640)
   MY_PIXEL = (153-1)*480 + (430 - 1) = 73389
 */
/* This is used for debugging porposes*/
#define MY_PIXEL 6940
#define DEBUG_MODE 0

/* Compute offsets for convolutions */
void ComputeOffsets(int *Offset,int NdxPixel,int NumRows);

/* Compute the locations of the 8 neighbors of a given pixel. 
Returns zero iff the a neighbor does not exist, i.e. out of bounds */
void ComputeOffsets8neighbors(int *Offset,int NdxPixel,int NumRows,int NumCols);

/* Convert a pixel index to row and column format. Analogous to Matlab function ind2sub() */
void PositionRowColumn(int NdxPixel,int NumRows,int *col,int *row);

void mexFunction(int nlhs, mxArray* plhs[],
                 int nrhs, const mxArray* prhs[])
{  
	/* Work pointers over the mxArray */ 
	double *ptrMu,*ptrSigma2,*ptrR,*ptrG,*ptrB,*ptrNeuroWin,*ptrimMask,*ptrCoef,*ptrPi;
	double *ptrVar,*ptrCov,*ptrMaximumVariance,*ptrMiCov,*MiCoef;
	/* Original pointers over the mxArray */ 
	double *ptrMuOri,*ptrSigma2Ori,*ptrROri,*ptrGOri,*ptrBOri,*ptrNeuroWinOri,*ptrimMaskOri,*ptrCoefOri,*ptrPiOri;
	double *ptrVarOri,*ptrCovOri,*ptrMaximumVarianceOri,*ptrCurrentFrame;
	/* Original auxiliar dynamic memmory */
	int *Offset;
	double *NewimMaskOri,*CorrOri;
	/* Auxiliar dynamic memmory (work pointers) */
	double *NewimMask,*Corr,*MiCorr;

	/* Local variables without influence in the dynamic memmory */
	int NumMapRows,NumMapColumns,NumImageRows,NumImageColumns,CurrentFrame,fil,col;
	double MiLogDens,MyR,MyG,MyB,ThisCoef,MiPi,DensMap,MaximumVariance,MyVar;
	double sum,respY,corrY,sqrtVarX,sqrtVarY;
	double StepSize,OneLessStepSize,Correction,DensWin,MiDens,MinimumVariance,tempVar,tempVarY;
	double Norm2;
	int NdxPixel,NdxNeuro,NdxWin,NumNeurons,NumPixels,NdxCorr;
	int truncCounter,cont;
	double numerator,denominator,difR,difG,difB;
		
	#if (DEBUG_MODE == 1) 
		/*Log variables*/
		char *fileName;
		mwSize loglen; 
		mxArray *Log;
		FILE * fich;
		
		/* Getting the name of the log file*/
		Log = mxGetField(prhs[0],0,"Log");
		loglen = mxGetNumberOfElements(Log) + 1;
		fileName = mxMalloc(loglen*sizeof(char));

	    if (mxGetString(Log, fileName, loglen) != 0)
			mexErrMsgTxt("Could not convert string data.");
		
		fich = OpenLog(fileName);
    #endif
	
	/* Duplicate the model structure */
    plhs[0]=mxDuplicateArray(prhs[0]);
    
	/* Get the work variables */
    ptrMuOri=mxGetPr(mxGetField(plhs[0],0,"Mu"));
    ptrSigma2Ori=mxGetPr(mxGetField(plhs[0],0,"Sigma2"));	
	ptrimMaskOri=mxGetPr(mxGetField(plhs[0],0,"imMask"));
    ptrPiOri=mxGetPr(mxGetField(plhs[0],0,"Pi"));
	ptrNeuroWinOri=mxGetPr(mxGetField(plhs[0],0,"NeuroWin"));
	ptrROri=mxGetPr(prhs[1]);	
	ptrCoefOri=mxGetPr(prhs[2]);
	ptrVarOri=mxGetPr(mxGetField(plhs[0],0,"Var"));
	ptrCovOri=mxGetPr(mxGetField(plhs[0],0,"Cov"));
	ptrMaximumVarianceOri=mxGetPr(mxGetField(plhs[0],0,"MaximumVariance"));
	
	NumMapRows=(int) *mxGetPr(mxGetField(plhs[0],0,"NumMapRows"));
	NumMapColumns=(int) *mxGetPr(mxGetField(plhs[0],0,"NumMapColumns"));
	NumImageRows=(int) *mxGetPr(mxGetField(plhs[0],0,"NumImageRows"));
	NumImageColumns=(int) *mxGetPr(mxGetField(plhs[0],0,"NumImageColumns"));
	MinimumVariance=(double) *mxGetPr(mxGetField(plhs[0],0,"MinimumVariance"));
	MaximumVariance=(double) *mxGetPr(mxGetField(plhs[0],0,"MaximumVariance"));
	StepSize=(double) *mxGetPr(mxGetField(plhs[0],0,"StepSize"));
	OneLessStepSize=1.0-StepSize;
	NumPixels=NumImageRows*NumImageColumns;
	NumNeurons=NumMapRows*NumMapColumns;	
	ptrGOri=ptrROri+NumPixels;
	ptrBOri=ptrROri+2*NumPixels;

	/* Update the current frame */
	ptrCurrentFrame=mxGetPr(mxGetField(plhs[0],0,"CurrentFrame")); 
	(*ptrCurrentFrame) = (*ptrCurrentFrame) + 1.0;
	CurrentFrame=(int)(*ptrCurrentFrame);

	#if (DEBUG_MODE == 1)  
		if (CurrentFrame == 1) {
				fprintf(fich,"Beginning of the update process\n");
			fprintf(fich,"Model parameters: \n");
			fprintf(fich,"NumImageRows: %d, NumImageColumns: %d, NumMapRows: %d, NumMapColumns: %d\n",NumImageRows,NumImageColumns,NumMapRows,NumMapColumns);
			fprintf(fich,"MinimumVariance: %f, MaximumVariance: %f, StepSize: %f\n",MinimumVariance,MaximumVariance,StepSize);
		}
		fprintf(fich,"-----------------------------------\n");	
		fprintf(fich,"[Output] Current Frame nº: %d\n", CurrentFrame);	
	#endif

	/* Allocate memmory */
	Offset=mxMalloc(8*sizeof(double));
	NewimMaskOri=mxMalloc(NumImageRows*NumImageColumns*sizeof(double));
	CorrOri=mxMalloc(4*NumImageRows*NumImageColumns*sizeof(double));
	
	/* ******************************************************************* */
	/*               RESPONSIBILITY AND OUTPUT COMPUTATION               */
	/* ******************************************************************* */
	/* Initialisation of the work variables */
	ptrMu=ptrMuOri;
	ptrSigma2=ptrSigma2Ori;
	ptrR=ptrROri;
	ptrG=ptrGOri;
	ptrB=ptrBOri;
	ptrNeuroWin=ptrNeuroWinOri;
	ptrimMask=ptrimMaskOri;
	ptrCoef=ptrCoefOri;
	ptrPi=ptrPiOri;
	ptrVar=ptrVarOri;
	ptrCov=ptrCovOri;
	ptrMaximumVariance=ptrMaximumVarianceOri;

    /* For each one of the image pixels */
	for(NdxPixel=0;NdxPixel<NumPixels;NdxPixel++)
	{
		/* MATLAB code: Pattern = Patterns(:,NdxPattern); */
		MyR=*ptrR;
		MyG=*ptrG;
		MyB=*ptrB;
		MiPi=*ptrPi;

		/* ------------------------------------------------------------------------------ */ 
		/* Start of the code to compute the map responsibilities                          */
        /* ------------------------------------------------------------------------------ */
		DensMap=0.0;
		DensWin=-DBL_MAX;
		*ptrNeuroWin=0;

		#if (DEBUG_MODE == 1)
			if (NdxPixel==MY_PIXEL) {
				PositionRowColumn(NdxPixel,NumImageRows,&fil,&col);
				fprintf(fich,"Pixel nº %d, coordinates (%d,%d)\n",NdxPixel,fil,col);	
				fprintf(fich,"Input:(%d,%d,%d), ProbPriori(Pi): %f\n",(int)MyR,(int)MyG,(int)MyB,MiPi);	
			}
		#endif

		/* For each one of the neurons of the map */
		for(NdxNeuro=0;NdxNeuro<NumNeurons;NdxNeuro++)
		{
			/* Compute the square distance: 
			MATLAB code: Norm2(NdxNeuro)=sum((Model.Mu(NdxPixel,NdxNeuro,:)-Patterns(NdxPixel,:)).^2);*/
			Norm2=(ptrMu[0]-MyR)*(ptrMu[0]-MyR)+(ptrMu[1]-MyG)*(ptrMu[1]-MyG)
				+(ptrMu[2]-MyB)*(ptrMu[2]-MyB);
			
			(*ptrSigma2)+=MinimumVariance;
			/*log(p(t | i))=-1.5*log(2*pi)-1.5*log(Sigma2)-(0.5/Sigma2)*Norm2(NdxNeuro);  */
			MiLogDens=-2.756815599614018-1.5*log(*ptrSigma2)-0.5*Norm2/(*ptrSigma2);
			(*ptrSigma2)-=MinimumVariance;
			MiDens=exp(MiLogDens);
			DensMap+=MiDens;

			#if (DEBUG_MODE == 1)
				if (NdxPixel==MY_PIXEL) {
					fprintf(fich,"--- Neuron: %d, Color:(%f,%f,%f), Norm2: %f\n",NdxNeuro,MyR,MyG,MyB,Norm2);	
					fprintf(fich,"--- Neuron: %d, Mean:(%f,%f,%f), Sigma2: %f, MiLogDens: %f MiDens: %f, DensWin: %f\n",NdxNeuro,ptrMu[0],ptrMu[1],ptrMu[2],(*ptrSigma2),MiLogDens, MiDens,DensWin);	
				}
			#endif
			
			/* Check if this neuron is winning */
			if (MiDens>DensWin)
			{
				DensWin=MiDens;
				*ptrNeuroWin=NdxNeuro;
			}
			
			/* Go to the following neuron in the map */
			ptrMu+=3;
			ptrSigma2++;
		}
		/* It is assumed the neurons  has the same a priori probability */
		DensMap/=(double)NumNeurons;
		/* ------------------------------------------------------------------------------ */
		/* End of the code to compute the map responsibilities 		   */
		/* ------------------------------------------------------------------------------ */
		
		/* Compute the uniform responsibility and include it in the output mask */
		/* P(Uniform | t) = P(Uniform)*p(t|Uniform) / [ P(Uniform)*p(t|Uniform) + P(Map)*p(t|Map) */
		/* p(t |Uniform)=1/(255^3)=6.030862941101085e-008 */
		#if (DEBUG_MODE == 1)
			if (NdxPixel==MY_PIXEL) {
				fprintf(fich,"imMask(before): %f\n",(*ptrimMask));	
			}
		#endif
		
		(*ptrimMask)=(MiPi*6.030862941101085e-008)/(MiPi*6.030862941101085e-008+(1.0-MiPi)*DensMap);
		NdxWin = (int)(*ptrNeuroWin);
		
		#if (DEBUG_MODE == 1)
			if (NdxPixel==MY_PIXEL) {
				fprintf(fich,"MiPi: %f, DensMap: %f\n",MiPi,DensMap);
				fprintf(fich,"NdxWin: %d, imMask: %f\n",NdxWin,(*ptrimMask));	
			}
		#endif

		/* Go to the following pixel */
		ptrR++;
		ptrG++;
		ptrB++;
		ptrimMask++;
		ptrNeuroWin++;
		ptrPi++;
	}

	/* ******************************************************************* */
	/*           PEARSON CORRELATION COMPUTATION                    		*/
	/* ******************************************************************* */
	/* Initialisation of the work variables */
	ptrMu=ptrMuOri;
	ptrSigma2=ptrSigma2Ori;
	ptrR=ptrROri;
	ptrG=ptrGOri;
	ptrB=ptrBOri;
	ptrNeuroWin=ptrNeuroWinOri;
	ptrimMask=ptrimMaskOri;
	ptrCoef=ptrCoefOri;
	ptrPi=ptrPiOri;
	ptrVar=ptrVarOri;
	ptrCov=ptrCovOri;
	ptrMaximumVariance=ptrMaximumVarianceOri;
	Corr = CorrOri;

	#if (DEBUG_MODE == 1)  
		fprintf(fich,"Pearson correlation computation \n");	
	#endif

	 /* For each one of the image pixels */
	for(NdxPixel=0;NdxPixel<NumPixels;NdxPixel++)
	{
		sqrtVarX = sqrt(*ptrVar);
		MiCorr = Corr;

		ComputeOffsets(Offset,NdxPixel,NumImageRows);
		for (NdxCorr=0;NdxCorr<4;NdxCorr++) 
		{
			if (Offset[NdxCorr] != 0) {
				/* Compute the correlation for each neighbour */
				sqrtVarY = sqrt(*(ptrVar + Offset[NdxCorr]));
				MiCorr[NdxCorr] = (ptrCov[NdxCorr])/(sqrtVarX*sqrtVarY);

				#if (DEBUG_MODE == 1)
					if (NdxPixel==MY_PIXEL) {
						fprintf(fich,"Position: %d, SqrtVarX: %f, SqrtVarY: %f, Cov: %f, Corr: %f \n",NdxCorr,sqrtVarX,sqrtVarY,ptrCov[NdxCorr],MiCorr[NdxCorr]);	
					}
				#endif
	
			}
			else MiCorr[NdxCorr]=0;
		}
		/* Go to the following pixel */
		ptrVar++;
		Corr+=4;
		ptrCov+=4;
	}

	/* Get the neighbour responsibility and smooth the output frame */
	ptrimMask = ptrimMaskOri;
	NewimMask = NewimMaskOri;
	Corr = CorrOri;
	truncCounter = 0;
	for(NdxPixel=0;NdxPixel<NumPixels;NdxPixel++)
	{
		#if (DEBUG_MODE == 1)
			if (NdxPixel==MY_PIXEL) {
				PositionRowColumn(NdxPixel,NumImageRows,&fil,&col);
				fprintf(fich,"Pixel nº %d, coordinates (%d,%d)\n",NdxPixel,fil,col);	
			}
		#endif
		
		ComputeOffsets8neighbors(Offset,NdxPixel,NumImageRows,NumImageColumns);
		
		numerator = *ptrimMask;
		denominator = 1;

		#if (DEBUG_MODE == 1)
			if (NdxPixel==MY_PIXEL) {
				fprintf(fich,"RespX: %f \n",*ptrimMask);	
			}
		#endif

		/* The process is divided in two parts (first 4 neighbour first, and the following ones before) in order to improve the speed of the performance */
		for (NdxCorr=0;NdxCorr<4;NdxCorr++) 
		{
			if (Offset[NdxCorr] != 0) {
				respY = (*(ptrimMask + Offset[NdxCorr]));
				corrY = Corr[NdxCorr];
				numerator += (respY*corrY);
				denominator+= corrY;

				#if (DEBUG_MODE == 1)
					if (NdxPixel==MY_PIXEL) {
						PositionRowColumn(NdxPixel+Offset[NdxCorr],NumImageRows,&fil,&col);
						fprintf(fich,"Pixel (%d,%d), Position: %d, RespY: %f, CorrY: %f \n",fil,col,NdxCorr,respY,corrY);	
					}
				#endif
			}
		}

		cont = 0;
		for (NdxCorr=4;NdxCorr<8;NdxCorr++) 
		{
			if (Offset[NdxCorr] != 0) {
				respY = (*(ptrimMask + Offset[NdxCorr]));
				corrY = *(Corr + 4*Offset[NdxCorr] + cont);
				numerator += (respY*corrY);
				denominator += corrY;
				cont++;

				#if (DEBUG_MODE == 1)
					if (NdxPixel==MY_PIXEL) {
						PositionRowColumn(NdxPixel+Offset[NdxCorr],NumImageRows,&fil,&col);
						fprintf(fich,"Pixel (%d,%d), Position: %d, RespY: %f, CorrY: %f \n",fil,col,NdxCorr,respY,corrY);
					}
				#endif
			}
		}

		/* The new output for each pixel is smoothed using the information of the responsibility and correlation of the neighbours  */
		sum = numerator / 9;
		if (sum >= 0) 
			*NewimMask = sum;
		else {
			*NewimMask = 0;
			truncCounter++;
		}

		#if (DEBUG_MODE == 1)
			if (NdxPixel==MY_PIXEL) {
				fprintf(fich,"Resp_old: %f, RespNueva: %f \n",*ptrimMask,*NewimMask);	
			}
		#endif

		/* Go to the following pixel */
		ptrimMask++;
		NewimMask++;
		Corr+=4;
    }
	#if (DEBUG_MODE == 1)
		fprintf(fich,"Nº times sum < 0: %d \n",truncCounter);	
		fprintf(fich,"End of the smoothing process. Beginning of the copy...\n");	
	#endif

	memcpy(ptrimMaskOri,NewimMaskOri,NumImageRows*NumImageColumns*sizeof(double));

	#if (DEBUG_MODE == 1)
		fprintf(fich,"End of the postprocessing phase.\n");
	#endif

	
	/* ******************************************************************* */
	/*               PROBABILISTIC SELF ORGANISING  MAP UPDATE             */
	/* ******************************************************************* */
	/* Initialisation of the work variables */
	ptrMu=ptrMuOri;
	ptrSigma2=ptrSigma2Ori;
	ptrR=ptrROri;
	ptrG=ptrGOri;
	ptrB=ptrBOri;
	ptrNeuroWin=ptrNeuroWinOri;
	ptrimMask=ptrimMaskOri;
	ptrCoef=ptrCoefOri;
	ptrPi=ptrPiOri;
	ptrVar=ptrVarOri;
	ptrCov=ptrCovOri;
	ptrMaximumVariance=ptrMaximumVarianceOri;

	#if (DEBUG_MODE == 1)  
		fprintf(fich,"[Update] Current Frame nº: %d\n", CurrentFrame);	
	#endif

	for(NdxPixel=0;NdxPixel<NumPixels;NdxPixel++)
	{
		#if (DEBUG_MODE == 1)
			if (NdxPixel==MY_PIXEL) {
				PositionRowColumn(NdxPixel,NumImageRows,&fil,&col);
				fprintf(fich,"Pixel nº %d, Coordinates (%d,%d)\n",NdxPixel,fil,col);	
				fprintf(fich,"MaximumVariance: %f\n",(*ptrMaximumVariance));	
			}
		#endif

		/* MATLAB code: Pattern = Patterns(:,NdxPattern); */
		MyR=*ptrR;
		MyG=*ptrG;
		MyB=*ptrB;
		MiPi=*ptrPi;
		MyVar=*ptrVar;

		/* Duplicate the pointer */
		ptrMiCov=ptrCov;

		/* Update the a priori uniform probability */
		(*ptrPi)=OneLessStepSize*MiPi+StepSize*(*ptrimMask);

		/* MATLAB code: var = (1-step_size)*var + step_size*(P(Uniforme | t) - resp_fore)^2 */
		tempVar = ((*ptrimMask) - (*ptrPi));
		(*ptrVar)=OneLessStepSize*MyVar+StepSize*(tempVar*tempVar);

		#if (DEBUG_MODE == 1)
			if (NdxPixel==MY_PIXEL) {
				fprintf(fich,"RespX: %f, APrioriX_old: %f, APrioriX_new: %f, Var: %f\n",*ptrimMask,MiPi,*ptrPi,*ptrVar);	
			}
		#endif
		
		ComputeOffsets(Offset,NdxPixel,NumImageRows);
		
		/* Update the covariance using stochastic aproximation */
		for (NdxCorr=0;NdxCorr<4;NdxCorr++) 
		{
			if (Offset[NdxCorr] != 0) {
				tempVarY = *(ptrimMask + Offset[NdxCorr]) - (*(ptrPi + Offset[NdxCorr]));
				ptrMiCov[NdxCorr]=OneLessStepSize*ptrMiCov[NdxCorr]+StepSize*(tempVar*tempVarY);	

				#if (DEBUG_MODE == 1)
					if (NdxPixel==MY_PIXEL) {
						fprintf(fich,"Posicion: %d, StdX: %f, StdY: %f, Cov: %f \n",NdxCorr,tempVar,tempVarY,ptrMiCov[NdxCorr]);	
					}
				#endif
			}
			else ptrMiCov[NdxCorr]=0;
		}

		/* Update the self organising maps */
		Correction=(1.0-(*ptrimMask))/(1.0-(*ptrPi));               

		NdxWin=(int)(*ptrNeuroWin);
		MiCoef=ptrCoef+NdxWin*NumNeurons;
		for(NdxNeuro=0;NdxNeuro<NumNeurons;NdxNeuro++)
		{		
			difR = (MyR-ptrMu[0]);
			difG = (MyG-ptrMu[1]);
			difB = (MyB-ptrMu[2]);

			/* MATLAB code: Norm2 = sum(abs(Frame - Mu)) */
			Norm2=difR*difR+difG*difG+difB*difB;

			ThisCoef=(*MiCoef)*Correction;
			ptrMu[0]+=ThisCoef*difR;
			ptrMu[1]+=ThisCoef*difG;
			ptrMu[2]+=ThisCoef*difB;
			ptrMu+=3;
			(*ptrSigma2)+=ThisCoef*(0.333333333333*Norm2-(*ptrSigma2));
			
			/* Update the variance of the neuron only if the new value do not exceed the maximum variance */
			if ((*ptrSigma2) > (*ptrMaximumVariance)) {
				(*ptrSigma2) = (*ptrMaximumVariance);
			} 
			ptrSigma2++;
			MiCoef++;
		}

		/* Go to the following pixel */
		ptrR++;
		ptrG++;
		ptrB++;
		ptrimMask++;
		ptrNeuroWin++;
		ptrMaximumVariance++;
		ptrVar++;
		ptrPi++;
		ptrCov+=4;
	}

	#if (DEBUG_MODE == 1)
		fflush(fich);
		//Close the log file
		CloseLog(fich);
		mxFree(fileName);
	#endif

    /* Release memmory */
    mxFree(Offset); 
	mxFree(CorrOri);
	mxFree(NewimMaskOri);
}    

/* Compute offsets for convolutions */
void ComputeOffsets(int *Offset,int NdxPixel,int NumRows) 
{
	int col, row;
	col = (NdxPixel / NumRows) + 1;
	row = (NdxPixel % NumRows) + 1;

	Offset[0] = 0;
	Offset[1] = 0;
	Offset[2] = 0;
	Offset[3] = 0;
	
	if ((row > 1) && (col > 1))  {
		Offset[0] = -1; 
		Offset[1] = -NumRows-1; 
		Offset[2] = -NumRows;
		if (row < NumRows) Offset[3] = -NumRows+1;
	}
	else if ((row == 1) && (col > 1)) {
		Offset[2] = -NumRows;
		Offset[3] = -NumRows+1;
	}
	else if ((col == 1) && (row > 1)) {
		Offset[0] = -1;
	}
}

/* Compute the locations of the 8 neighbors of a given pixel. 
Returns zero iff the a neighbor does not exist, i.e. out of bounds */
void ComputeOffsets8neighbors(int *Offset,int NdxPixel,int NumRows,int NumCols) 
{
	int col, row;
	
	col = (NdxPixel / NumRows) + 1;
	row = (NdxPixel % NumRows) + 1;

	ComputeOffsets(Offset,NdxPixel,NumRows);
	
	Offset[4] = 0;
	Offset[5] = 0;
	Offset[6] = 0;
	Offset[7] = 0;

	if ((row < NumRows) && (col < NumCols))  {
		Offset[4] = 1; 
		Offset[5] = NumRows+1; 
		Offset[6] = NumRows;
		if (row > 1) Offset[7] = NumRows-1;
	}
	else if ((row == NumRows) && (col < NumCols)) {
		Offset[6] = NumRows;
		Offset[7] = NumRows-1;
	}
	else if ((col == NumCols) && (row < NumRows)) {
		Offset[4] = 1;
	}
}

/* Convert a pixel index to row and column format. Analogous to Matlab function ind2sub() */
void PositionRowColumn(int NdxPixel,int NumRows,int *col,int *row) 
{
	*col = (NdxPixel / NumRows) + 1;
	*row = (NdxPixel % NumRows) + 1;
}
