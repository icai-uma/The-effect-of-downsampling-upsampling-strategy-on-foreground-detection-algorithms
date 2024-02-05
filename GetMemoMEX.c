#include "mex.h"
#include <windows.h>
#include <psapi.h>

/*  mex GetMemoMEX.c psapi.lib */
void mexFunction(int nlhs, mxArray* plhs[],
                 int nrhs, const mxArray* prhs[])
{

PROCESS_MEMORY_COUNTERS memCounter;
bool result = GetProcessMemoryInfo(GetCurrentProcess(),
                                   &memCounter,
                                   sizeof( memCounter ));
/* mexPrintf("%d\n",memCounter.PeakWorkingSetSize);*/
plhs[0]=mxCreateDoubleScalar((double)(memCounter.PeakPagefileUsage));
}