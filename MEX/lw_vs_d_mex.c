#include "mex.h"
#include "matrix.h"
#include <math.h>
#include <string.h>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif
#if defined(__GNUC__)
#define MEX_EXPORT __attribute__((dllexport))
#else
#define MEX_EXPORT
#endif

/* ------------------------------
   Small helpers (complex arithmetic)
--------------------------------*/

typedef struct {
    double real;
    double imag;
} myComplex;

static inline myComplex cexp_i(double x)
{
    myComplex z;
    z.real = cos(x);
    z.imag = sin(x);
    return z;
}

static inline myComplex cmul(myComplex a, myComplex b)
{
    myComplex z;
    z.real = a.real*b.real - a.imag*b.imag;
    z.imag = a.real*b.imag + a.imag*b.real;
    return z;
}

static inline myComplex cadd(myComplex a, myComplex b)
{
    myComplex z;
    z.real = a.real + b.real;
    z.imag = a.imag + b.imag;
    return z;
}

static inline double cabs2(myComplex a)
{
    return a.real*a.real + a.imag*a.imag;
}

static inline double carg_deg(myComplex a)
{
    return atan2(a.imag, a.real) * (180.0 / M_PI);
}

/* ----------------------------------------------------
   Optimized lw_sum_modes (core physics)
-----------------------------------------------------*/

void lw_sum_modes_fast(
    double power,
    double dist_var,
    int nc,
    const mxArray *data,
    const mxArray *eigens,
    const mxArray *Amk,
    double *amp,
    double *phs,
    /* reusable buffers */
    myComplex *soln_a,
    myComplex *soln_b,
    myComplex *temp,
    double *stp
)
{
    const double dtr = M_PI / 180.0;

    /* unpack scalars */
    double k = mxGetScalar(mxGetField(data,0,"k"));
    double f = mxGetScalar(mxGetField(data,0,"f"));
    double a = mxGetScalar(mxGetField(data,0,"a"));

    /* unpack arrays */
    double *rho = mxGetPr(mxGetField(data,0,"rho"));
    mwSize nrho = mxGetNumberOfElements(mxGetField(data,0,"rho"));

    double *fieldmag = NULL;
    double *fieldang = NULL;

    /* select field component */
    switch (nc) {
        case 1: fieldmag = mxGetPr(mxGetField(data,0,"Ez_mag"));
                fieldang = mxGetPr(mxGetField(data,0,"Ez_ang")); break;
        case 2: fieldmag = mxGetPr(mxGetField(data,0,"Ey_mag"));
                fieldang = mxGetPr(mxGetField(data,0,"Ey_ang")); break;
        case 3: fieldmag = mxGetPr(mxGetField(data,0,"Ex_mag"));
                fieldang = mxGetPr(mxGetField(data,0,"Ex_ang")); break;
        case 4: fieldmag = mxGetPr(mxGetField(data,0,"Hz_mag"));
                fieldang = mxGetPr(mxGetField(data,0,"Hz_ang")); break;
        case 5: fieldmag = mxGetPr(mxGetField(data,0,"Hy_mag"));
                fieldang = mxGetPr(mxGetField(data,0,"Hy_ang")); break;
        case 6: fieldmag = mxGetPr(mxGetField(data,0,"Hx_mag"));
                fieldang = mxGetPr(mxGetField(data,0,"Hx_ang")); break;
    }

    const mwSize *fdims = mxGetDimensions(mxGetField(data,0,"Ex_mag"));
    mwSize nh = fdims[0];
    mwSize nslab = fdims[1];

    /* constants */
    myComplex mik = {0.0, -k};

    double sum0 = 682.2408 * sqrt(f * power);
    double const_factor = sum0;

    double xone = 0.0;
    double xtwo = (nrho > 1) ? rho[1] : dist_var;
    mwSize nsgmnt = 0;

    /* initialize modes (slab 0) */
    const mxArray *eig0 = mxGetCell(eigens,0);
    mwSize nreigen = mxGetNumberOfElements(eig0);
    mxArray *eig0_arr = (mxArray*)eig0;
    double *tp_re = mxGetPr(eig0_arr);

    for (mwSize m = 0; m < nreigen; m++) {
        stp[m] = sin(tp_re[m] * dtr);
        soln_a[m].real = -stp[m];
        soln_a[m].imag = 0.0;

        double mag = fieldmag[m*nh*nslab];
        double ang = fieldang[m*nh*nslab] * dtr;

        soln_b[m].real = -soln_a[m].real * mag * cos(ang);
        soln_b[m].imag = -soln_a[m].real * mag * sin(ang);
    }

    /* slab marching */
    while (dist_var > xtwo) {

        double dx = xtwo - xone;

        for (mwSize m = 0; m < nreigen; m++) {
            double phase = (stp[m] - 1.0) * (-k * dx);
            myComplex e = cexp_i(phase);
            soln_a[m] = cmul(soln_a[m], e);
            temp[m] = soln_a[m];
        }

        xone = xtwo;
        nsgmnt++;

        if (nsgmnt+1 >= nrho)
            xtwo = 10000.0;
        else
            xtwo = rho[nsgmnt+1];

        const mxArray *Amk_cell = mxGetCell(Amk,nsgmnt);
mwSize n2 = mxGetM(Amk_cell);
mwSize n1 = mxGetN(Amk_cell);
double *A_re = mxGetPr(Amk_cell);
double *A_im = mxGetPi(Amk_cell);  // old-style complex arrays

for (mwSize m2 = 0; m2 < n2; m2++) {
    soln_a[m2].real = 0.0;
    soln_a[m2].imag = 0.0;

    for (mwSize m1 = 0; m1 < n1; m1++) {
        double a_re = A_re[m2 + m1*n2];
        double a_im = (A_im) ? A_im[m2 + m1*n2] : 0.0;
        myComplex prod;
        prod.real = a_re * temp[m1].real - a_im * temp[m1].imag;
        prod.imag = a_re * temp[m1].imag + a_im * temp[m1].real;
        soln_a[m2] = cadd(soln_a[m2], prod);
    }


            stp[m2] = sin(tp_re[m2] * dtr);

            mwSize idx = m2*nh*nslab + nsgmnt*nh;
            double mag = fieldmag[idx];
            double ang = fieldang[idx] * dtr;

            soln_b[m2].real = -soln_a[m2].real * mag * cos(ang);
            soln_b[m2].imag = -soln_a[m2].real * mag * sin(ang);
        }

        nreigen = n2;
    }

    /* final summation */
    double dx = dist_var - xone;
    double factor = const_factor / sqrt(fabs(sin(dist_var / a)));

    myComplex tb = {0.0, 0.0};

    for (mwSize m = 0; m < nreigen; m++) {
        double phase = (stp[m] - 1.0) * (-k * dx);
        myComplex e = cexp_i(phase);
        myComplex term = cmul(soln_b[m], e);
        tb = cadd(tb, term);
    }

    tb.real *= factor;
    tb.imag *= factor;

    if (dist_var == 0.0) {
        *amp = 20.0 * log10(const_factor * 80.0);
        *phs = 0.0;
    } else {
        *amp = 20.0 * log10(cabs2(tb));
        *phs = carg_deg(tb);
    }
}

/* ----------------------------------------------------
   MEX ENTRY POINT
-----------------------------------------------------*/

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
    if (nrhs != 4)
        mexErrMsgTxt("Usage: lw_vs_d_mex(data, eigens, Amk, power)");

    const mxArray *data   = prhs[0];
    const mxArray *eigens = prhs[1];
    const mxArray *Amk    = prhs[2];
    double power = mxGetScalar(prhs[3]);

    /* rho_full */
    double *rho = mxGetPr(mxGetField(data,0,"rho"));
    mwSize nrho = mxGetNumberOfElements(mxGetField(data,0,"rho"));

    mwSize nrpts = 1000;
    double rho_max = rho[nrho-1];

    plhs[0] = mxCreateDoubleMatrix(nrpts+1,1,mxREAL);
    plhs[1] = mxCreateDoubleMatrix(nrpts+1,1,mxREAL);
    plhs[2] = mxCreateDoubleMatrix(nrpts+1,1,mxREAL);
    plhs[3] = mxCreateDoubleMatrix(nrpts+1,1,mxREAL);
    plhs[4] = mxCreateDoubleMatrix(nrpts+1,1,mxCOMPLEX);
    plhs[5] = mxCreateDoubleMatrix(nrpts+1,1,mxCOMPLEX);

    double *s0 = mxGetPr(plhs[0]);
    double *s1 = mxGetPr(plhs[1]);
    double *s2 = mxGetPr(plhs[2]);
    double *s3 = mxGetPr(plhs[3]);
    double *hx_re = mxGetPr(plhs[4]);
    double *hx_im = mxGetPi(plhs[4]);
    double *hy_re = mxGetPr(plhs[5]);
    double *hy_im = mxGetPi(plhs[5]);

    /* find max modes */
    mwSize max_modes = 0;
    mwSize ncell = mxGetNumberOfElements(eigens);
    for (mwSize i=0;i<ncell;i++) {
        mwSize n = mxGetNumberOfElements(mxGetCell(eigens,i));
        if (n > max_modes) max_modes = n;
    }

    myComplex *soln_a = mxCalloc(max_modes,sizeof(myComplex));
    myComplex *soln_b = mxCalloc(max_modes,sizeof(myComplex));
    myComplex *temp   = mxCalloc(max_modes,sizeof(myComplex));
    double *stp       = mxCalloc(max_modes,sizeof(double));

    for (mwSize i = 0; i <= nrpts; i++) {

        double dist = rho_max * ((double)i / nrpts);

        double amp, phs;

        lw_sum_modes_fast(power, dist, 6, data, eigens, Amk, &amp, &phs,
                           soln_a, soln_b, temp, stp);
        hx_re[i] = pow(10.0, amp/20.0) * cos(phs*M_PI/180.0);
        hx_im[i] = pow(10.0, amp/20.0) * sin(phs*M_PI/180.0);

        lw_sum_modes_fast(power, dist, 5, data, eigens, Amk, &amp, &phs,
                           soln_a, soln_b, temp, stp);
        hy_re[i] = pow(10.0, amp/20.0) * cos(phs*M_PI/180.0);
        hy_im[i] = pow(10.0, amp/20.0) * sin(phs*M_PI/180.0);

        s0[i] = hx_re[i]*hx_re[i] + hx_im[i]*hx_im[i] + hy_re[i]*hy_re[i] + hy_im[i]*hy_im[i];
        s1[i] = hx_re[i]*hx_re[i] + hx_im[i]*hx_im[i] - hy_re[i]*hy_re[i] - hy_im[i]*hy_im[i];
        s2[i] = 2.0 * (hx_re[i]*hy_re[i] + hx_im[i]*hy_im[i]);
        s3[i] = 2.0 * (hx_im[i]*hy_re[i] - hx_re[i]*hy_im[i]);
    }

    mxFree(soln_a);
    mxFree(soln_b);
    mxFree(temp);
    mxFree(stp);
}
