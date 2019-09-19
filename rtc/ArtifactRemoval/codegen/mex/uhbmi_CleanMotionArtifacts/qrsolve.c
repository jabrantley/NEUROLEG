/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * qrsolve.c
 *
 * Code generation for function 'qrsolve'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "uhbmi_CleanMotionArtifacts.h"
#include "qrsolve.h"
#include "error.h"
#include "uhbmi_CleanMotionArtifacts_emxutil.h"
#include "inv.h"
#include "eml_int_forloop_overflow_check.h"
#include "warning.h"
#include "xgeqp3.h"
#include "uhbmi_CleanMotionArtifacts_mexutil.h"
#include "uhbmi_CleanMotionArtifacts_data.h"
#include "lapacke.h"

/* Variable Definitions */
static emlrtRSInfo qc_emlrtRSI = { 28, /* lineNo */
  "qrsolve",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\qrsolve.m"/* pathName */
};

static emlrtRSInfo rc_emlrtRSI = { 32, /* lineNo */
  "qrsolve",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\qrsolve.m"/* pathName */
};

static emlrtRSInfo sc_emlrtRSI = { 39, /* lineNo */
  "qrsolve",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\qrsolve.m"/* pathName */
};

static emlrtRSInfo dd_emlrtRSI = { 121,/* lineNo */
  "qrsolve",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\qrsolve.m"/* pathName */
};

static emlrtRSInfo ed_emlrtRSI = { 120,/* lineNo */
  "qrsolve",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\qrsolve.m"/* pathName */
};

static emlrtRSInfo fd_emlrtRSI = { 72, /* lineNo */
  "qrsolve",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\qrsolve.m"/* pathName */
};

static emlrtRSInfo gd_emlrtRSI = { 79, /* lineNo */
  "qrsolve",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\qrsolve.m"/* pathName */
};

static emlrtRSInfo hd_emlrtRSI = { 89, /* lineNo */
  "qrsolve",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\qrsolve.m"/* pathName */
};

static emlrtRSInfo id_emlrtRSI = { 29, /* lineNo */
  "xunormqr",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xunormqr.m"/* pathName */
};

static emlrtRSInfo jd_emlrtRSI = { 101,/* lineNo */
  "xunormqr",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xunormqr.m"/* pathName */
};

static emlrtRSInfo kd_emlrtRSI = { 91, /* lineNo */
  "xunormqr",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xunormqr.m"/* pathName */
};

static emlrtRSInfo ld_emlrtRSI = { 78, /* lineNo */
  "xunormqr",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xunormqr.m"/* pathName */
};

static emlrtRSInfo md_emlrtRSI = { 77, /* lineNo */
  "xunormqr",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xunormqr.m"/* pathName */
};

static emlrtRSInfo nd_emlrtRSI = { 57, /* lineNo */
  "xunormqr",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xunormqr.m"/* pathName */
};

static emlrtRTEInfo r_emlrtRTEI = { 1, /* lineNo */
  24,                                  /* colNo */
  "qrsolve",                           /* fName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\qrsolve.m"/* pName */
};

/* Function Definitions */
void qrsolve(const emlrtStack *sp, const emxArray_real_T *A, const
             emxArray_real_T *B, emxArray_real_T *Y)
{
  emxArray_real_T *b_A;
  int32_T maxmn;
  int32_T minmn;
  emxArray_real_T *tau;
  emxArray_int32_T *jpvt;
  int32_T rankR;
  real_T tol;
  const mxArray *y;
  char_T rfmt[6];
  static const char_T cv13[6] = { '%', '1', '4', '.', '6', 'e' };

  const mxArray *m4;
  static const int32_T iv17[2] = { 1, 6 };

  const mxArray *b_y;
  emxArray_real_T *b_B;
  char_T cv14[14];
  ptrdiff_t nrc_t;
  ptrdiff_t info_t;
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  d_st.prev = &c_st;
  d_st.tls = c_st.tls;
  e_st.prev = &d_st;
  e_st.tls = d_st.tls;
  emlrtHeapReferenceStackEnterFcnR2012b(sp);
  emxInit_real_T1(sp, &b_A, 2, &r_emlrtRTEI, true);
  maxmn = b_A->size[0] * b_A->size[1];
  b_A->size[0] = A->size[0];
  b_A->size[1] = A->size[1];
  emxEnsureCapacity(sp, (emxArray__common *)b_A, maxmn, (int32_T)sizeof(real_T),
                    &r_emlrtRTEI);
  minmn = A->size[0] * A->size[1];
  for (maxmn = 0; maxmn < minmn; maxmn++) {
    b_A->data[maxmn] = A->data[maxmn];
  }

  emxInit_real_T2(sp, &tau, 1, &r_emlrtRTEI, true);
  emxInit_int32_T1(sp, &jpvt, 2, &r_emlrtRTEI, true);
  st.site = &qc_emlrtRSI;
  xgeqp3(&st, b_A, tau, jpvt);
  st.site = &rc_emlrtRSI;
  rankR = 0;
  tol = 0.0;
  if (b_A->size[0] < b_A->size[1]) {
    minmn = b_A->size[0];
    maxmn = b_A->size[1];
  } else {
    minmn = b_A->size[1];
    maxmn = b_A->size[0];
  }

  if (minmn > 0) {
    tol = (real_T)maxmn * muDoubleScalarAbs(b_A->data[0]) *
      2.2204460492503131E-16;
    while ((rankR < minmn) && (muDoubleScalarAbs(b_A->data[rankR + b_A->size[0] *
             rankR]) >= tol)) {
      rankR++;
    }
  }

  if ((rankR < minmn) && (!emlrtSetWarningFlag(&st))) {
    b_st.site = &dd_emlrtRSI;
    for (maxmn = 0; maxmn < 6; maxmn++) {
      rfmt[maxmn] = cv13[maxmn];
    }

    y = NULL;
    m4 = emlrtCreateCharArray(2, iv17);
    emlrtInitCharArrayR2013a(&b_st, 6, m4, &rfmt[0]);
    emlrtAssign(&y, m4);
    b_y = NULL;
    m4 = emlrtCreateDoubleScalar(tol);
    emlrtAssign(&b_y, m4);
    c_st.site = &yd_emlrtRSI;
    emlrt_marshallIn(&c_st, b_sprintf(&c_st, y, b_y, &e_emlrtMCI), "sprintf",
                     cv14);
    b_st.site = &ed_emlrtRSI;
    d_warning(&b_st, rankR, cv14);
  }

  st.site = &sc_emlrtRSI;
  minmn = b_A->size[1];
  maxmn = Y->size[0];
  Y->size[0] = minmn;
  emxEnsureCapacity(&st, (emxArray__common *)Y, maxmn, (int32_T)sizeof(real_T),
                    &r_emlrtRTEI);
  for (maxmn = 0; maxmn < minmn; maxmn++) {
    Y->data[maxmn] = 0.0;
  }

  emxInit_real_T2(&st, &b_B, 1, &r_emlrtRTEI, true);
  b_st.site = &fd_emlrtRSI;
  c_st.site = &id_emlrtRSI;
  maxmn = b_B->size[0];
  b_B->size[0] = B->size[0];
  emxEnsureCapacity(&c_st, (emxArray__common *)b_B, maxmn, (int32_T)sizeof
                    (real_T), &r_emlrtRTEI);
  minmn = B->size[0];
  for (maxmn = 0; maxmn < minmn; maxmn++) {
    b_B->data[maxmn] = B->data[maxmn];
  }

  minmn = muIntScalarMin_sint32(b_A->size[0], b_A->size[1]);
  d_st.site = &nd_emlrtRSI;
  if ((!((b_A->size[0] == 0) || (b_A->size[1] == 0))) && (!(b_B->size[0] == 0)))
  {
    d_st.site = &md_emlrtRSI;
    d_st.site = &ld_emlrtRSI;
    nrc_t = (ptrdiff_t)b_B->size[0];
    d_st.site = &kd_emlrtRSI;
    info_t = LAPACKE_dormqr(102, 'L', 'T', nrc_t, (ptrdiff_t)1, (ptrdiff_t)minmn,
      &b_A->data[0], (ptrdiff_t)b_A->size[0], &tau->data[0], &b_B->data[0],
      nrc_t);
    minmn = (int32_T)info_t;
    d_st.site = &jd_emlrtRSI;
    if (minmn != 0) {
      if (minmn == -1010) {
        e_st.site = &sb_emlrtRSI;
        b_error(&e_st);
      } else {
        e_st.site = &tb_emlrtRSI;
        e_error(&e_st, minmn);
      }
    }
  }

  emxFree_real_T(&tau);
  b_st.site = &gd_emlrtRSI;
  if ((!(1 > rankR)) && (rankR > 2147483646)) {
    c_st.site = &n_emlrtRSI;
    check_forloop_overflow_error(&c_st);
  }

  for (maxmn = 0; maxmn + 1 <= rankR; maxmn++) {
    Y->data[jpvt->data[maxmn] - 1] = b_B->data[maxmn];
  }

  emxFree_real_T(&b_B);
  for (minmn = rankR - 1; minmn + 1 > 0; minmn--) {
    Y->data[jpvt->data[minmn] - 1] /= b_A->data[minmn + b_A->size[0] * minmn];
    b_st.site = &hd_emlrtRSI;
    for (maxmn = 0; maxmn + 1 <= minmn; maxmn++) {
      Y->data[jpvt->data[maxmn] - 1] -= Y->data[jpvt->data[minmn] - 1] *
        b_A->data[maxmn + b_A->size[0] * minmn];
    }
  }

  emxFree_int32_T(&jpvt);
  emxFree_real_T(&b_A);
  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

/* End of code generation (qrsolve.c) */
