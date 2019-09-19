/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * mldivide.c
 *
 * Code generation for function 'mldivide'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "uhbmi_CleanMotionArtifacts.h"
#include "mldivide.h"
#include "uhbmi_CleanMotionArtifacts_emxutil.h"
#include "warning.h"
#include "xgetrf.h"
#include "qrsolve.h"
#include "uhbmi_CleanMotionArtifacts_data.h"
#include "blas.h"

/* Variable Definitions */
static emlrtRSInfo ic_emlrtRSI = { 1,  /* lineNo */
  "mldivide",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\lib\\matlab\\ops\\mldivide.p"/* pathName */
};

static emlrtRSInfo mc_emlrtRSI = { 132,/* lineNo */
  "lusolve",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\lusolve.m"/* pathName */
};

static emlrtRSInfo nc_emlrtRSI = { 143,/* lineNo */
  "lusolve",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\lusolve.m"/* pathName */
};

static emlrtRSInfo oc_emlrtRSI = { 145,/* lineNo */
  "lusolve",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\lusolve.m"/* pathName */
};

static emlrtRTEInfo p_emlrtRTEI = { 1, /* lineNo */
  2,                                   /* colNo */
  "mldivide",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\lib\\matlab\\ops\\mldivide.p"/* pName */
};

static emlrtRTEInfo nb_emlrtRTEI = { 1,/* lineNo */
  1,                                   /* colNo */
  "mldivide",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\lib\\matlab\\ops\\mldivide.p"/* pName */
};

/* Function Definitions */
void mldivide(const emlrtStack *sp, const emxArray_real_T *A, emxArray_real_T *B)
{
  emxArray_real_T *b_A;
  emxArray_int32_T *ipiv;
  emxArray_real_T *b_B;
  uint32_T unnamed_idx_0;
  int32_T info;
  int32_T loop_ub;
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
  if (B->size[0] != A->size[0]) {
    emlrtErrorWithMessageIdR2012b(sp, &nb_emlrtRTEI, "Coder:MATLAB:dimagree", 0);
  }

  emxInit_real_T1(sp, &b_A, 2, &p_emlrtRTEI, true);
  emxInit_int32_T1(sp, &ipiv, 2, &p_emlrtRTEI, true);
  emxInit_real_T2(sp, &b_B, 1, &p_emlrtRTEI, true);
  if ((A->size[0] == 0) || (A->size[1] == 0) || (B->size[0] == 0)) {
    unnamed_idx_0 = (uint32_T)A->size[1];
    info = B->size[0];
    B->size[0] = (int32_T)unnamed_idx_0;
    emxEnsureCapacity(sp, (emxArray__common *)B, info, (int32_T)sizeof(real_T),
                      &p_emlrtRTEI);
    loop_ub = (int32_T)unnamed_idx_0;
    for (info = 0; info < loop_ub; info++) {
      B->data[info] = 0.0;
    }
  } else if (A->size[0] == A->size[1]) {
    st.site = &ic_emlrtRSI;
    b_st.site = &jc_emlrtRSI;
    info = b_A->size[0] * b_A->size[1];
    b_A->size[0] = A->size[0];
    b_A->size[1] = A->size[1];
    emxEnsureCapacity(&b_st, (emxArray__common *)b_A, info, (int32_T)sizeof
                      (real_T), &p_emlrtRTEI);
    loop_ub = A->size[0] * A->size[1];
    for (info = 0; info < loop_ub; info++) {
      b_A->data[info] = A->data[info];
    }

    c_st.site = &lc_emlrtRSI;
    xgetrf(&c_st, A->size[1], A->size[1], b_A, A->size[1], ipiv, &info);
    if (info > 0) {
      c_st.site = &kc_emlrtRSI;
      if (!emlrtSetWarningFlag(&c_st)) {
        d_st.site = &pc_emlrtRSI;
        b_warning(&d_st);
      }
    }

    c_st.site = &mc_emlrtRSI;
    for (info = 0; info + 1 < A->size[1]; info++) {
      if (ipiv->data[info] != info + 1) {
        temp = B->data[info];
        B->data[info] = B->data[ipiv->data[info] - 1];
        B->data[ipiv->data[info] - 1] = temp;
      }
    }

    c_st.site = &nc_emlrtRSI;
    temp = 1.0;
    DIAGA = 'U';
    TRANSA = 'N';
    UPLO = 'L';
    SIDE = 'L';
    m_t = (ptrdiff_t)A->size[1];
    n_t = (ptrdiff_t)1;
    lda_t = (ptrdiff_t)A->size[1];
    ldb_t = (ptrdiff_t)A->size[1];
    dtrsm(&SIDE, &UPLO, &TRANSA, &DIAGA, &m_t, &n_t, &temp, &b_A->data[0],
          &lda_t, &B->data[0], &ldb_t);
    c_st.site = &oc_emlrtRSI;
    temp = 1.0;
    DIAGA = 'N';
    TRANSA = 'N';
    UPLO = 'U';
    SIDE = 'L';
    m_t = (ptrdiff_t)A->size[1];
    n_t = (ptrdiff_t)1;
    lda_t = (ptrdiff_t)A->size[1];
    ldb_t = (ptrdiff_t)A->size[1];
    dtrsm(&SIDE, &UPLO, &TRANSA, &DIAGA, &m_t, &n_t, &temp, &b_A->data[0],
          &lda_t, &B->data[0], &ldb_t);
  } else {
    info = b_B->size[0];
    b_B->size[0] = B->size[0];
    emxEnsureCapacity(sp, (emxArray__common *)b_B, info, (int32_T)sizeof(real_T),
                      &p_emlrtRTEI);
    loop_ub = B->size[0];
    for (info = 0; info < loop_ub; info++) {
      b_B->data[info] = B->data[info];
    }

    st.site = &ic_emlrtRSI;
    qrsolve(&st, A, b_B, B);
  }

  emxFree_real_T(&b_B);
  emxFree_int32_T(&ipiv);
  emxFree_real_T(&b_A);
  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

/* End of code generation (mldivide.c) */
