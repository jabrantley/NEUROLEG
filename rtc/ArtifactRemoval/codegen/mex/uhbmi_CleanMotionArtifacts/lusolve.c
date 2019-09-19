/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * lusolve.c
 *
 * Code generation for function 'lusolve'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "uhbmi_CleanMotionArtifacts.h"
#include "lusolve.h"
#include "uhbmi_CleanMotionArtifacts_emxutil.h"
#include "warning.h"
#include "xgetrf.h"
#include "uhbmi_CleanMotionArtifacts_data.h"
#include "blas.h"

/* Variable Definitions */
static emlrtRSInfo pd_emlrtRSI = { 112,/* lineNo */
  "lusolve",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\lusolve.m"/* pathName */
};

static emlrtRSInfo qd_emlrtRSI = { 114,/* lineNo */
  "lusolve",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\lusolve.m"/* pathName */
};

static emlrtRTEInfo t_emlrtRTEI = { 1, /* lineNo */
  19,                                  /* colNo */
  "lusolve",                           /* fName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\lusolve.m"/* pName */
};

/* Function Definitions */
void lusolve(const emlrtStack *sp, const emxArray_real_T *A, const
             emxArray_real_T *B, emxArray_real_T *X)
{
  emxArray_real_T *b_A;
  int32_T info;
  int32_T loop_ub;
  emxArray_int32_T *ipiv;
  real_T temp;
  char_T DIAGA;
  char_T TRANSA;
  char_T UPLO;
  char_T SIDE;
  ptrdiff_t m_t;
  ptrdiff_t n_t;
  ptrdiff_t lda_t;
  ptrdiff_t ldb_t;
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  emlrtHeapReferenceStackEnterFcnR2012b(sp);
  emxInit_real_T1(sp, &b_A, 2, &t_emlrtRTEI, true);
  st.site = &jc_emlrtRSI;
  info = b_A->size[0] * b_A->size[1];
  b_A->size[0] = A->size[0];
  b_A->size[1] = A->size[1];
  emxEnsureCapacity(&st, (emxArray__common *)b_A, info, (int32_T)sizeof(real_T),
                    &t_emlrtRTEI);
  loop_ub = A->size[0] * A->size[1];
  for (info = 0; info < loop_ub; info++) {
    b_A->data[info] = A->data[info];
  }

  emxInit_int32_T1(&st, &ipiv, 2, &t_emlrtRTEI, true);
  b_st.site = &lc_emlrtRSI;
  xgetrf(&b_st, A->size[1], A->size[1], b_A, A->size[1], ipiv, &info);
  if (info > 0) {
    b_st.site = &kc_emlrtRSI;
    if (!emlrtSetWarningFlag(&b_st)) {
      c_st.site = &pc_emlrtRSI;
      b_warning(&c_st);
    }
  }

  b_st.site = &pd_emlrtRSI;
  info = X->size[0] * X->size[1];
  X->size[0] = 1;
  X->size[1] = B->size[1];
  emxEnsureCapacity(&b_st, (emxArray__common *)X, info, (int32_T)sizeof(real_T),
                    &t_emlrtRTEI);
  loop_ub = B->size[0] * B->size[1];
  for (info = 0; info < loop_ub; info++) {
    X->data[info] = B->data[info];
  }

  if (!(A->size[1] < 1)) {
    temp = 1.0;
    DIAGA = 'N';
    TRANSA = 'N';
    UPLO = 'U';
    SIDE = 'R';
    m_t = (ptrdiff_t)1;
    n_t = (ptrdiff_t)A->size[1];
    lda_t = (ptrdiff_t)A->size[1];
    ldb_t = (ptrdiff_t)1;
    dtrsm(&SIDE, &UPLO, &TRANSA, &DIAGA, &m_t, &n_t, &temp, &b_A->data[0],
          &lda_t, &X->data[0], &ldb_t);
  }

  b_st.site = &qd_emlrtRSI;
  if (!(A->size[1] < 1)) {
    temp = 1.0;
    DIAGA = 'U';
    TRANSA = 'N';
    UPLO = 'L';
    SIDE = 'R';
    m_t = (ptrdiff_t)1;
    n_t = (ptrdiff_t)A->size[1];
    lda_t = (ptrdiff_t)A->size[1];
    ldb_t = (ptrdiff_t)1;
    dtrsm(&SIDE, &UPLO, &TRANSA, &DIAGA, &m_t, &n_t, &temp, &b_A->data[0],
          &lda_t, &X->data[0], &ldb_t);
  }

  emxFree_real_T(&b_A);
  for (info = A->size[1] - 2; info + 1 > 0; info--) {
    if (ipiv->data[info] != info + 1) {
      temp = X->data[X->size[0] * info];
      X->data[X->size[0] * info] = X->data[X->size[0] * (ipiv->data[info] - 1)];
      X->data[X->size[0] * (ipiv->data[info] - 1)] = temp;
    }
  }

  emxFree_int32_T(&ipiv);
  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

/* End of code generation (lusolve.c) */
