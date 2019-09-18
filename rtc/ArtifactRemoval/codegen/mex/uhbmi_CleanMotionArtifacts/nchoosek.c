/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * nchoosek.c
 *
 * Code generation for function 'nchoosek'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "uhbmi_CleanMotionArtifacts.h"
#include "nchoosek.h"
#include "warning.h"

/* Variable Definitions */
static emlrtRSInfo k_emlrtRSI = { 116, /* lineNo */
  "nchoosek",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\lib\\matlab\\specfun\\nchoosek.m"/* pathName */
};

static emlrtRTEInfo eb_emlrtRTEI = { 103,/* lineNo */
  21,                                  /* colNo */
  "nchoosek",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\lib\\matlab\\specfun\\nchoosek.m"/* pName */
};

/* Function Definitions */
real_T nCk(const emlrtStack *sp, real_T n, real_T k)
{
  real_T y;
  real_T nmk;
  int32_T j;
  emlrtStack st;
  st.prev = sp;
  st.tls = sp->tls;
  if ((!muDoubleScalarIsInf(n)) && (!muDoubleScalarIsInf(k))) {
    if (k > n / 2.0) {
      k = n - k;
    }

    if (k > 1000.0) {
      y = rtInf;
    } else {
      y = 1.0;
      nmk = n - k;
      emlrtForLoopVectorCheckR2012b(1.0, 1.0, k, mxDOUBLE_CLASS, (int32_T)k,
        &eb_emlrtRTEI, sp);
      for (j = 0; j < (int32_T)k; j++) {
        y *= ((1.0 + (real_T)j) + nmk) / (1.0 + (real_T)j);
      }

      y = muDoubleScalarRound(y);
    }
  } else {
    y = rtNaN;
  }

  if ((!(y <= 9.007199254740992E+15)) && (!emlrtSetWarningFlag(sp))) {
    st.site = &k_emlrtRSI;
    warning(&st);
  }

  return y;
}

/* End of code generation (nchoosek.c) */
