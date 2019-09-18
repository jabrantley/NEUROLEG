/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * xgetrf.c
 *
 * Code generation for function 'xgetrf'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "uhbmi_CleanMotionArtifacts.h"
#include "xgetrf.h"
#include "uhbmi_CleanMotionArtifacts_emxutil.h"
#include "error.h"
#include "uhbmi_CleanMotionArtifacts_data.h"
#include "lapacke.h"

/* Variable Definitions */
static emlrtRTEInfo q_emlrtRTEI = { 1, /* lineNo */
  26,                                  /* colNo */
  "xgetrf",                            /* fName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgetrf.m"/* pName */
};

/* Function Definitions */
void xgetrf(const emlrtStack *sp, int32_T m, int32_T n, emxArray_real_T *A,
            int32_T lda, emxArray_int32_T *ipiv, int32_T *info)
{
  int32_T k;
  int32_T b_info;
  int32_T NPIV;
  emxArray_ptrdiff_t *ipiv_t;
  ptrdiff_t info_t;
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
  st.site = &ib_emlrtRSI;
  b_st.site = &ob_emlrtRSI;
  if ((A->size[0] == 0) || (A->size[1] == 0)) {
    k = ipiv->size[0] * ipiv->size[1];
    ipiv->size[0] = 1;
    ipiv->size[1] = 0;
    emxEnsureCapacity(&st, (emxArray__common *)ipiv, k, (int32_T)sizeof(int32_T),
                      &q_emlrtRTEI);
    b_info = 0;
  } else {
    b_st.site = &nb_emlrtRSI;
    NPIV = muIntScalarMin_sint32(m, n);
    NPIV = muIntScalarMax_sint32(NPIV, 1);
    b_st.site = &nb_emlrtRSI;
    emxInit_ptrdiff_t(&b_st, &ipiv_t, 1, &n_emlrtRTEI, true);
    k = ipiv_t->size[0];
    ipiv_t->size[0] = NPIV;
    emxEnsureCapacity(&st, (emxArray__common *)ipiv_t, k, (int32_T)sizeof
                      (ptrdiff_t), &q_emlrtRTEI);
    b_st.site = &mb_emlrtRSI;
    b_st.site = &lb_emlrtRSI;
    b_st.site = &kb_emlrtRSI;
    info_t = LAPACKE_dgetrf_work(102, (ptrdiff_t)m, (ptrdiff_t)n, &A->data[0],
      (ptrdiff_t)lda, &ipiv_t->data[0]);
    b_info = (int32_T)info_t;
    k = ipiv->size[0] * ipiv->size[1];
    ipiv->size[0] = 1;
    ipiv->size[1] = ipiv_t->size[0];
    emxEnsureCapacity(&st, (emxArray__common *)ipiv, k, (int32_T)sizeof(int32_T),
                      &q_emlrtRTEI);
    NPIV = ipiv->size[1];
    b_st.site = &jb_emlrtRSI;
    if (b_info < 0) {
      if (b_info == -1010) {
        c_st.site = &sb_emlrtRSI;
        b_error(&c_st);
      } else {
        c_st.site = &tb_emlrtRSI;
        c_error(&c_st, b_info);
      }
    }

    for (k = 0; k < NPIV; k++) {
      ipiv->data[k] = (int32_T)ipiv_t->data[k];
    }

    emxFree_ptrdiff_t(&ipiv_t);
  }

  *info = b_info;
  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

/* End of code generation (xgetrf.c) */
