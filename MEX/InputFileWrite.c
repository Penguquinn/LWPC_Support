#include "matrix.h"
#include "mex.h"
#include <stdio.h>
#include <string.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if (nrhs != 6) {
        mexErrMsgTxt("Six inputs required.");
    }
    if (nlhs > 1) {
        mexErrMsgTxt("One output only.");
    }

    /* Get scalar inputs */
    int numFiles = (int) mxGetScalar(prhs[0]);
    double RNG = mxGetScalar(prhs[4]);

    char outputPath[1024];

    /* Handle MATLAB string or char array */
    if (mxIsChar(prhs[5])) {
        if (mxGetString(prhs[5], outputPath, sizeof(outputPath)) != 0) {
            mexErrMsgTxt("Error reading output path.");
        }
    }
#if MX_HAS_STRING_CLASS
    else if (mxIsString(prhs[5])) {  // MATLAB string object
        mxChar *strPtr = mxGetChars(prhs[5]);
        size_t buflen = mxGetNumberOfElements(prhs[5]);
        if (buflen >= sizeof(outputPath)) {
            mexErrMsgTxt("Output path string too long.");
        }
        for (size_t i = 0; i < buflen; i++) {
            outputPath[i] = (char) strPtr[i];
        }
        outputPath[buflen] = '\0';
    }
#endif
    else {
        mexErrMsgTxt("Output path must be a character array or string.");
    }

    /* Get RX vector */
    double *RX = mxGetPr(prhs[3]);

    int err = 0;

    /* Loop over files (same as before) */
    for (int ii = 0; ii < numFiles; ii++) {
        mxArray *pCell = mxGetCell(prhs[1], ii);
        char filename[256];
        if (mxGetString(pCell, filename, sizeof(filename)) != 0) {
            mexErrMsgTxt("Error reading filename from cell array.");
        }

        mxArray *pTXCell = mxGetCell(prhs[2], ii);
        char txstr[256];
        if (mxGetString(pTXCell, txstr, sizeof(txstr)) != 0) {
            mexErrMsgTxt("Error reading TX string from cell array.");
        }

        char outfile[2048];
        snprintf(outfile, sizeof(outfile), "%s/%s.inp", outputPath, filename);

        FILE *fp = fopen(outfile, "w");
        if (!fp) {
            err = 1;
            continue;
        }

        fprintf(fp, "CASE-ID  Prop of wave\n");
        fprintf(fp, "TX    %s\n", filename);
        fprintf(fp, "TX-DATA    %s\n", txstr);
        fprintf(fp, "IONOSPHERE   HOMOGENEOUS TABLE /home/quinn/work/v3.0.1/profile/%s.prf\n", filename);
        fprintf(fp, "RANGE-MAX    %d\n", (int)RNG);
        fprintf(fp, "RECEIVERS   %.3f   %.3f\n", RX[0], RX[1]);
        fprintf(fp, "LWF-VS-DIST 20000\n");
        fprintf(fp, "MC-OPTIONS  FULL-WAVE 0 TRUE\n");
        fprintf(fp, "LWFIELDS\n");
        fprintf(fp, "PRINT-MDS    0\n");
        fprintf(fp, "PRINT-WF    2\n");
        fprintf(fp, "PRINT-LWF    2\n");
        fprintf(fp, "PRINT-SWG    2\n");
        fprintf(fp, "PRINT-MC    1\n");
        fprintf(fp, "START\n");
        fprintf(fp, "QUIT\n");

        fclose(fp);
    }

    plhs[0] = mxCreateDoubleScalar((double)err);
}
