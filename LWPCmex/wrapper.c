#include "mex.h"
#include <string.h>

/* Declare the external Fortran function */
extern void LWPM_C(void* lwpcDAT_loc, int datloc, const char* file_name, int file_name_len);

/* The gateway function */
void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
    /* Check number of inputs */
    if (nrhs != 2) {
        mexErrMsgIdAndTxt("LWPM_mex:invalidNumInputs",
                          "Two input arguments required: lwpcDAT_loc and file_name.");
    }

    /* Check that inputs are strings */
    if (!mxIsChar(prhs[0]) || !mxIsChar(prhs[1])) {
        mexErrMsgIdAndTxt("LWPM_mex:inputNotString",
                          "Inputs must be strings.");
    }

    /* Get the input strings from MATLAB */
    char lwpcDAT_loc[120];
    char file_in[120];

    /* Copy strings safely */
    mxGetString(prhs[0], lwpcDAT_loc, sizeof(lwpcDAT_loc));
    mxGetString(prhs[1], file_in, sizeof(file_in));

    int dc = (int)strlen(lwpcDAT_loc);
    int nc = (int)strlen(file_in);

    /* Optional: display info in MATLAB Command Window */
    mexPrintf("LWPC data location length: %s\n", lwpcDAT_loc);
    mexPrintf("LWPC input file length: %s\n", file_in);
    mexEvalString("drawnow;");  // ensure output is flushed

    /* Call the Fortran wrapper */
    LWPM_C(lwpcDAT_loc, dc, file_in, nc);

    /* No outputs */
    //return 0;
}
// extern void LWPM_C(void* lwpcDAT_loc, int datloc, const char* file_name, int file_name_len);

// int main(int argc, char *argv[]) {
//     printf("Program started\n");
//     fflush(stdout);
//     if (argc < 3) {
//         fprintf(stderr, "Usage: %s <lwpcDAT_loc> <file_name>\n", argv[0]);
//         return 1;
//     }

//     char lwpcDAT_loc[120];
//     char file_in[120];

//     strncpy_s(lwpcDAT_loc, sizeof(lwpcDAT_loc), argv[1], _TRUNCATE);
//     strncpy_s(file_in, sizeof(file_in), argv[2], _TRUNCATE);


//     // printf("LWPC data location: %s\n", lwpcDAT_loc);
//     // printf("LWPC input file: %s\n", file_in);
//     // fflush(stdout);

//     int dc = strlen(lwpcDAT_loc);
//     int nc = strlen(file_in);

//     printf("LWPC data location length: %d\n", dc);
//     printf("LWPC input file length: %d\n", nc);
//     fflush(stdout);

//     // Call Fortran wrapper
//     LWPM_C(lwpcDAT_loc, dc, file_in, nc);

//     return 0;
// }