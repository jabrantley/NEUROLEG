/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * power.c
 *
 * Code generation for function 'power'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "uhbmi_CleanMotionArtifacts.h"
#include "power.h"
#include "uhbmi_CleanMotionArtifacts_emxutil.h"
#include "eml_int_forloop_overflow_check.h"
#include "scalexpAlloc.h"
#include "uhbmi_CleanMotionArtifacts_data.h"

/* Variable Definitions */
static emlrtRSInfo o_emlrtRSI = { 49,  /* lineNo */
  "power",                             /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\lib\\matlab\\ops\\power.m"/* pathName */
};

static emlrtRSInfo p_emlrtRSI = { 58,  /* lineNo */
  "power",                             /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\lib\\matlab\\ops\\power.m"/* pathName */
};

static emlrtRSInfo q_emlrtRSI = { 73,  /* lineNo */
  "applyScalarFunction",               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\applyScalarFunction.m"/* pathName */
};

static emlrtRSInfo r_emlrtRSI = { 132, /* lineNo */
  "applyScalarFunction",               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\applyScalarFunction.m"/* pathName */
};

static emlrtRTEInfo h_emlrtRTEI = { 1, /* lineNo */
  14,                                  /* colNo */
  "power",                             /* fName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\lib\\matlab\\ops\\power.m"/* pName */
};

static emlrtRTEInfo i_emlrtRTEI = { 16,/* lineNo */
  9,                                   /* colNo */
  "scalexpAlloc",                      /* fName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\scalexpAlloc.m"/* pName */
};

static emlrtRTEInfo ib_emlrtRTEI = { 17,/* lineNo */
  19,                                  /* colNo */
  "scalexpAlloc",                      /* fName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\scalexpAlloc.m"/* pName */
};

/* Function Definitions */
void power(const emlrtStack *sp, const emxArray_real_T *a, emxArray_real_T *y)
{
  emxArray_real_T *x;
  int32_T n;
  int32_T loop_ub;
  int32_T k;
  jmp_buf * volatile emlrtJBStack;
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  d_st.prev = &c_st;
  d_st.tls = c_st.tls;
  emlrtHeapReferenceStackEnterFcnR2012b(sp);
  emxInit_real_T1(sp, &x, 2, &h_emlrtRTEI, true);
  st.site = &o_emlrtRSI;
  b_st.site = &p_emlrtRSI;
  n = x->size[0] * x->size[1];
  x->size[0] = 3;
  x->size[1] = a->size[1];
  emxEnsureCapacity(&b_st, (emxArray__common *)x, n, (int32_T)sizeof(real_T),
                    &h_emlrtRTEI);
  loop_ub = a->size[0] * a->size[1];
  for (n = 0; n < loop_ub; n++) {
    x->data[n] = a->data[n];
  }

  c_st.site = &q_emlrtRSI;
  n = y->size[0] * y->size[1];
  y->size[0] = 3;
  y->size[1] = a->size[1];
  emxEnsureCapacity(&c_st, (emxArray__common *)y, n, (int32_T)sizeof(real_T),
                    &i_emlrtRTEI);
  if (!dimagree(y, a)) {
    emlrtErrorWithMessageIdR2012b(&c_st, &ib_emlrtRTEI, "MATLAB:dimagree", 0);
  }

  n = 3 * a->size[1];
  c_st.site = &r_emlrtRSI;
  if ((!(1 > n)) && (n > 2147483646)) {
    d_st.site = &n_emlrtRSI;
    check_forloop_overflow_error(&d_st);
  }

  emlrtEnterParallelRegion(&b_st, omp_in_parallel());
  emlrtPushJmpBuf(&b_st, &emlrtJBStack);

#pragma omp parallel for \
 num_threads(emlrtAllocRegionTLSs(b_st.tls, omp_in_parallel(), omp_get_max_threads(), omp_get_num_procs()))

  for (k = 1; k <= n; k++) {
    y->data[k - 1] = x->data[k - 1] * x->data[k - 1];
  }

  emlrtPopJmpBuf(&b_st, &emlrtJBStack);
  emlrtExitParallelRegion(&b_st, omp_in_parallel());
  emxFree_real_T(&x);
  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

/* End of code generation (power.c) */
