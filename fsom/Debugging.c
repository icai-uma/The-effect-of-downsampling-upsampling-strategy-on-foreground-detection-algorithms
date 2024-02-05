#include "Debugging.h"
#include "mex.h"
#include <math.h>

void PrintValues(double *Values,int NumValues)
{
    int ndx;
    
    for(ndx=0;ndx<NumValues;ndx++)
        mexPrintf("%lf\n",Values[ndx]);
    mexPrintf("\n\n");
}
  
    
void PrintMatrix(double *Matrix,int NumRows,int NumCols)
{
    int NdxRow,NdxCol;
    
    for(NdxRow=0;NdxRow<NumRows;NdxRow++)
    {
        for(NdxCol=0;NdxCol<NumCols;NdxCol++)
        {
            mexPrintf("%lf\t",Matrix[NdxCol*NumRows+NdxRow]);
        }
        mexPrintf("\n");
    }        
    mexPrintf("\n\n");
}  


FILE * OpenLog(char cad[]) 
{
	FILE * fich;
	fich = fopen( cad, "a+" );

	if( !fich ) mexPrintf( "Error (NO open)\n" );
    
	return fich;
}

void RecordMatrixLog(FILE * fich, double *Matrix,int NumRows,int NumCols)
	{
    int NdxRow,NdxCol;
    
    for(NdxRow=0;NdxRow<NumRows;NdxRow++)
    {
        for(NdxCol=0;NdxCol<NumCols;NdxCol++)
        {
 		    fprintf( fich, "%lf\t",Matrix[NdxCol*NumRows+NdxRow]);
        }
		fprintf( fich, "\n");
    }        
	fprintf( fich, "\n");
	fflush(fich);
}  

void CloseLog(FILE * fich) 
{
   if( fclose(fich) )
      printf( "Error: fich NO close\n" );
}




