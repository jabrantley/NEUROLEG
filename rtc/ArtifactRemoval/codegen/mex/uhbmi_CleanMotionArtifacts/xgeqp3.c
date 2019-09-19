/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * xgeqp3.c
 *
 * Code generation for function 'xgeqp3'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "uhbmi_CleanMotionArtifacts.h"
#include "xgeqp3.h"
#include "error.h"
#include "uhbmi_CleanMotionArtifacts_emxutil.h"
#include "colon.h"
#include "uhbmi_CleanMotionArtifacts_data.h"
#include "lapacke.h"

/* Variable Definitions */
static emlrtRSInfo tc_emlrtRSI = { 14, /* lineNo */
  "xgeqp3",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgeqp3.m"/* pathName */
};

static emlrtRSInfo uc_emlrtRSI = { 37, /* lineNo */
  "xgeqp3",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgeqp3.m"/* pathName */
};

static emlrtRSInfo vc_emlrtRSI = { 38, /* lineNo */
  "xgeqp3",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgeqp3.m"/* pathName */
};

static emlrtRSInfo wc_emlrtRSI = { 41, /* lineNo */
  "xgeqp3",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgeqp3.m"/* pathName */
};

static emlrtRSInfo xc_emlrtRSI = { 45, /* lineNo */
  "xgeqp3",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgeqp3.m"/* pathName */
};

static emlrtRSInfo yc_emlrtRSI = { 64, /* lineNo */
  "xgeqp3",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgeqp3.m"/* pathName */
};

static emlrtRSInfo ad_emlrtRSI = { 67, /* lineNo */
  "xgeqp3",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgeqp3.m"/* pathName */
};

static emlrtRSInfo bd_emlrtRSI = { 76, /* lineNo */
  "xgeqp3",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgeqp3.m"/* pathName */
};

static emlrtRSInfo cd_emlrtRSI = { 79, /* lineNo */
  "xgeqp3",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgeqp3.m"/* pathName */
};

static emlrtRTEInfo s_emlrtRTEI = { 1, /* lineNo */
  25,                                  /* colNo */
  "xgeqp3",                            /* fName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgeqp3.m"/* pName */
};

static emlrtRTEInfo x_emlrtRTEI = { 45,/* lineNo */
  5,                                   /* colNo */
  "xgeqp3",                            /* fName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgeqp3.m"/* pName */
};

/* Function Definitions */
void xgeqp3(const emlrtStack *sp, emxArray_real_T *A, emxArray_real_T *tau,
            emxArray_int32_T *jpvt)
{
  int32_T m;
  int32_T n;
  emxArray_ptrdiff_t *jpvt_t;
  int32_T i10;
  ptrdiff_t m_t;
  ptrdiff_t info_t;
  boolean_T p;
  boolean_T b_p;
  int32_T loop_ub;
  int32_T i11;
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
  st.site = &tc_emlrtRSI;
  m = A->size[0];
  n = A->size[1];
  b_st.site = &uc_emlrtRSI;
  c_st.site = &hb_emlrtRSI;
  b_st.site = &vc_emlrtRSI;
  if ((A->size[0] == 0) || (A->size[1] == 0)) {
    i10 = tau->size[0];
    tau->size[0] = 0;
    emxEnsureCapacity(&st, (emxArray__common *)tau, i10, (int32_T)sizeof(real_T),
                      &s_emlrtRTEI);
    b_st.site = &wc_emlrtRSI;
    c_st.site = &ub_emlrtRSI;
    d_st.site = &vb_emlrtRSI;
    e_st.site = &wb_emlrtRSI;
    eml_signed_integer_colon(&e_st, A->size[1], jpvt);
  } else {
    emxInit_ptrdiff_t(&st, &jpvt_t, 1, &x_emlrtRTEI, true);
    i10 = tau->size[0];
    tau->size[0] = muIntScalarMin_sint32(m, n);
    emxEnsureCapacity(&st, (emxArray__common *)tau, i10, (int32_T)sizeof(real_T),
                      &s_emlrtRTEI);
    b_st.site = &xc_emlrtRSI;
    c_st.site = &hb_emlrtRSI;
    i10 = jpvt_t->size[0];
    jpvt_t->size[0] = A->size[1];
    emxEnsureCapacity(&st, (emxArray__common *)jpvt_t, i10, (int32_T)sizeof
                      (ptrdiff_t), &s_emlrtRTEI);
    m = A->size[1];
    for (i10 = 0; i10 < m; i10++) {
      jpvt_t->data[i10] = (ptrdiff_t)0;
    }

    b_st.site = &yc_emlrtRSI;
    c_st.site = &hb_emlrtRSI;
    m_t = (ptrdiff_t)A->size[0];
    b_st.site = &ad_emlrtRSI;
    c_st.site = &qb_emlrtRSI;
    info_t = LAPACKE_dgeqp3(102, m_t, (ptrdiff_t)A->size[1], &A->data[0], m_t,
      &jpvt_t->data[0], &tau->data[0]);
    m = (int32_T)info_t;
    b_st.site = &bd_emlrtRSI;
    c_st.site = &rb_emlrtRSI;
    if (m != 0) {
      p = true;
      b_p = false;
      if (m == -4) {
        b_p = true;
      }

      if (!b_p) {
        if (m == -1010) {
          c_st.site = &sb_emlrtRSI;
          b_error(&c_st);
        } else {
          c_st.site = &tb_emlrtRSI;
          d_error(&c_st, m);
        }
      }
    } else {
      p = false;
    }

    if (p) {
      i10 = A->size[0] * A->size[1];
      emxEnsureCapacity(&st, (emxArray__common *)A, i10, (int32_T)sizeof(real_T),
                        &s_emlrtRTEI);
      m = A->size[1];
      for (i10 = 0; i10 < m; i10++) {
        loop_ub = A->size[0];
        for (i11 = 0; i11 < loop_ub; i11++) {
          A->data[i11 + A->size[0] * i10] = rtNaN;
        }
      }

      m = tau->size[0];
      i10 = tau->size[0];
      tau->size[0] = m;
      emxEnsureCapacity(&st, (emxArray__common *)tau, i10, (int32_T)sizeof
                        (real_T), &s_emlrtRTEI);
      for (i10 = 0; i10 < m; i10++) {
        tau->data[i10] = rtNaN;
      }

      b_st.site = &cd_emlrtRSI;
      c_st.site = &ub_emlrtRSI;
      d_st.site = &vb_emlrtRSI;
      e_st.site = &wb_emlrtRSI;
      eml_signed_integer_colon(&e_st, n, jpvt);
    } else {
      i10 = jpvt->size[0] * jpvt->size[1];
      jpvt->size[0] = 1;
      jpvt->size[1] = jpvt_t->size[0];
      emxEnsureCapacity(&st, (emxArray__common *)jpvt, i10, (int32_T)sizeof
                        (int32_T), &s_emlrtRTEI);
      m = jpvt_t->size[0];
      for (i10 = 0; i10 < m; i10++) {
        jpvt->data[jpvt->size[0] * i10] = (int32_T)jpvt_t->data[i10];
      }
    }

    emxFree_ptrdiff_t(&jpvt_t);
  }

  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

/* End of code generation (xgeqp3.c) */
