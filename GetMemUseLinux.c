#include "mex.h"
#include <sys/time.h>
#include <sys/resource.h>

#define NUM_RESULTS 16

/* Get CPU time and memory statistics of the current Matlab process, including all its threads, for Linux. */
/* Compile with: */
/* >>  mex GetMemUseLinux.c */

void mexFunction(int nlhs, mxArray* plhs[],
                 int nrhs, const mxArray* prhs[])
{
	struct rusage usage;
	double *Result;

	getrusage(RUSAGE_SELF, &usage);

	plhs[0]=mxCreateDoubleMatrix(1,NUM_RESULTS,mxREAL);
	Result=mxGetPr(plhs[0]);

	Result[0]=((double)usage.ru_utime.tv_sec)+
		1.0e-6*((double)usage.ru_utime.tv_usec);  /* user time used, in seconds*/
	Result[1]=((double)usage.ru_stime.tv_sec)+
		1.0e-6*((double)usage.ru_stime.tv_usec);  /* system time used, in seconds */
	Result[2]=usage.ru_maxrss;        /* maximum resident set size, in KBytes. This is the maximum physical RAM usage. */
    Result[3]=usage.ru_ixrss;         /* integral shared memory size */
    Result[4]=usage.ru_idrss;         /* integral unshared data size */
    Result[5]=usage.ru_isrss;         /* integral unshared stack size */
    Result[6]=usage.ru_minflt;        /* page reclaims */
    Result[7]=usage.ru_majflt;        /* page faults */
    Result[8]=usage.ru_nswap;         /* swaps */
    Result[9]=usage.ru_inblock;       /* block input operations */

    Result[10]=usage.ru_oublock;       /* block output operations */
    Result[11]=usage.ru_msgsnd;        /* messages sent */
    Result[12]=usage.ru_msgrcv;        /* messages received */
    Result[13]=usage.ru_nsignals;      /* signals received */
    Result[14]=usage.ru_nvcsw;         /* voluntary context switches */
    Result[15]=usage.ru_nivcsw;        /* involuntary context switches */

}


