/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * uhbmi_HinfFilter.c
 *
 * Code generation for function 'uhbmi_HinfFilter'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "uhbmi_CleanMotionArtifacts.h"
#include "uhbmi_HinfFilter.h"
#include "mpower.h"
#include "uhbmi_CleanMotionArtifacts_emxutil.h"
#include "eye.h"
#include "inv.h"
#include "mldivide.h"
#include "lusolve.h"
#include "qrsolve.h"
#include "uhbmi_CleanMotionArtifacts_data.h"
#include "blas.h"

/* Variable Definitions */
static emlrtRSInfo u_emlrtRSI = { 21,  /* lineNo */
  "uhbmi_HinfFilter",                  /* fcnName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_HinfFilter.m"/* pathName */
};

static emlrtRSInfo v_emlrtRSI = { 22,  /* lineNo */
  "uhbmi_HinfFilter",                  /* fcnName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_HinfFilter.m"/* pathName */
};

static emlrtRSInfo w_emlrtRSI = { 25,  /* lineNo */
  "uhbmi_HinfFilter",                  /* fcnName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_HinfFilter.m"/* pathName */
};

static emlrtRSInfo x_emlrtRSI = { 29,  /* lineNo */
  "uhbmi_HinfFilter",                  /* fcnName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_HinfFilter.m"/* pathName */
};

static emlrtRSInfo od_emlrtRSI = { 1,  /* lineNo */
  "mrdivide",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\lib\\matlab\\ops\\mrdivide.p"/* pathName */
};

static emlrtRSInfo rd_emlrtRSI = { 61, /* lineNo */
  "eml_mtimes_helper",                 /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\lib\\matlab\\ops\\eml_mtimes_helper.m"/* pathName */
};

static emlrtRSInfo sd_emlrtRSI = { 21, /* lineNo */
  "eml_mtimes_helper",                 /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\lib\\matlab\\ops\\eml_mtimes_helper.m"/* pathName */
};

static emlrtRTEInfo j_emlrtRTEI = { 1, /* lineNo */
  24,                                  /* colNo */
  "uhbmi_HinfFilter",                  /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_HinfFilter.m"/* pName */
};

static emlrtRTEInfo u_emlrtRTEI = { 17,/* lineNo */
  1,                                   /* colNo */
  "uhbmi_HinfFilter",                  /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_HinfFilter.m"/* pName */
};

static emlrtRTEInfo v_emlrtRTEI = { 20,/* lineNo */
  5,                                   /* colNo */
  "uhbmi_HinfFilter",                  /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_HinfFilter.m"/* pName */
};

static emlrtRTEInfo w_emlrtRTEI = { 21,/* lineNo */
  5,                                   /* colNo */
  "uhbmi_HinfFilter",                  /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_HinfFilter.m"/* pName */
};

static emlrtRTEInfo kb_emlrtRTEI = { 99,/* lineNo */
  23,                                  /* colNo */
  "eml_mtimes_helper",                 /* fName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\lib\\matlab\\ops\\eml_mtimes_helper.m"/* pName */
};

static emlrtRTEInfo lb_emlrtRTEI = { 104,/* lineNo */
  23,                                  /* colNo */
  "eml_mtimes_helper",                 /* fName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\lib\\matlab\\ops\\eml_mtimes_helper.m"/* pName */
};

static emlrtRTEInfo mb_emlrtRTEI = { 1,/* lineNo */
  1,                                   /* colNo */
  "mrdivide",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\lib\\matlab\\ops\\mrdivide.p"/* pName */
};

static emlrtECInfo f_emlrtECI = { 2,   /* nDims */
  29,                                  /* lineNo */
  19,                                  /* colNo */
  "uhbmi_HinfFilter",                  /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_HinfFilter.m"/* pName */
};

static emlrtECInfo g_emlrtECI = { 2,   /* nDims */
  29,                                  /* lineNo */
  26,                                  /* colNo */
  "uhbmi_HinfFilter",                  /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_HinfFilter.m"/* pName */
};

static emlrtECInfo h_emlrtECI = { -1,  /* nDims */
  27,                                  /* lineNo */
  9,                                   /* colNo */
  "uhbmi_HinfFilter",                  /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_HinfFilter.m"/* pName */
};

static emlrtECInfo i_emlrtECI = { -1,  /* nDims */
  27,                                  /* lineNo */
  23,                                  /* colNo */
  "uhbmi_HinfFilter",                  /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_HinfFilter.m"/* pName */
};

static emlrtECInfo j_emlrtECI = { -1,  /* nDims */
  22,                                  /* lineNo */
  5,                                   /* colNo */
  "uhbmi_HinfFilter",                  /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_HinfFilter.m"/* pName */
};

static emlrtECInfo k_emlrtECI = { 2,   /* nDims */
  21,                                  /* lineNo */
  14,                                  /* colNo */
  "uhbmi_HinfFilter",                  /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_HinfFilter.m"/* pName */
};

/* Function Definitions */
void uhbmi_HinfFilter(const emlrtStack *sp, const real_T Yf[64], const
                      emxArray_real_T *Rf, real_T b_gamma, emxArray_real_T *Pt,
                      emxArray_real_T *wh, real_T q, real_T sh[64], real_T zh[64])
{
  emxArray_real_T *g;
  int32_T i8;
  int32_T loop_ub;
  emxArray_real_T *r;
  emxArray_real_T *Ptemp;
  emxArray_real_T *b_r;
  real_T a;
  emxArray_real_T *r4;
  int32_T b_Ptemp;
  int32_T i9;
  int32_T c_Ptemp[2];
  int32_T iv26[2];
  emxArray_int32_T *r5;
  emxArray_real_T *A;
  emxArray_real_T *b_a;
  emxArray_real_T *x;
  emxArray_real_T *d_Ptemp;
  emxArray_real_T *b_A;
  uint32_T unnamed_idx_1;
  int32_T iv27[1];
  ptrdiff_t n_t;
  ptrdiff_t incx_t;
  ptrdiff_t incy_t;
  int32_T m;
  emxArray_real_T *b_wh;
  emxArray_real_T *c_wh;
  emxArray_real_T *c_r;
  boolean_T guard2 = false;
  boolean_T guard1 = false;
  int32_T iv28[2];
  int32_T e_Ptemp[2];
  emxArray_real_T *r6;
  int32_T iv29[1];
  int32_T d_wh[1];
  int32_T b_Pt[2];
  int32_T f_Ptemp[2];
  emlrtStack st;
  emlrtStack b_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  emlrtHeapReferenceStackEnterFcnR2012b(sp);
  emxInit_real_T2(sp, &g, 1, &u_emlrtRTEI, true);

  /* warning off all */
  /* Atilla Kilicarslan - 2014,  */
  /* University of Houston, Non-Invasive Brain Machine Interfaces Laboratory */
  i8 = g->size[0];
  g->size[0] = Rf->size[1];
  emxEnsureCapacity(sp, (emxArray__common *)g, i8, (int32_T)sizeof(real_T),
                    &j_emlrtRTEI);
  loop_ub = Rf->size[1];
  for (i8 = 0; i8 < loop_ub; i8++) {
    g->data[i8] = 0.0;
  }

  emxInit_real_T2(sp, &r, 1, &v_emlrtRTEI, true);
  loop_ub = Rf->size[1];
  i8 = r->size[0];
  r->size[0] = loop_ub;
  emxEnsureCapacity(sp, (emxArray__common *)r, i8, (int32_T)sizeof(real_T),
                    &j_emlrtRTEI);
  for (i8 = 0; i8 < loop_ub; i8++) {
    r->data[i8] = Rf->data[Rf->size[0] * i8];
  }

  emxInit_real_T1(sp, &Ptemp, 2, &w_emlrtRTEI, true);
  emxInit_real_T1(sp, &b_r, 2, &j_emlrtRTEI, true);
  st.site = &u_emlrtRSI;
  inv(&st, Pt, Ptemp);
  st.site = &u_emlrtRSI;
  a = mpower(b_gamma);
  i8 = b_r->size[0] * b_r->size[1];
  b_r->size[0] = r->size[0];
  b_r->size[1] = r->size[0];
  emxEnsureCapacity(sp, (emxArray__common *)b_r, i8, (int32_T)sizeof(real_T),
                    &j_emlrtRTEI);
  loop_ub = r->size[0];
  for (i8 = 0; i8 < loop_ub; i8++) {
    b_Ptemp = r->size[0];
    for (i9 = 0; i9 < b_Ptemp; i9++) {
      b_r->data[i8 + b_r->size[0] * i9] = r->data[i8] * r->data[i9];
    }
  }

  emxInit_real_T1(sp, &r4, 2, &j_emlrtRTEI, true);
  i8 = r4->size[0] * r4->size[1];
  r4->size[0] = b_r->size[0];
  r4->size[1] = b_r->size[1];
  emxEnsureCapacity(sp, (emxArray__common *)r4, i8, (int32_T)sizeof(real_T),
                    &j_emlrtRTEI);
  loop_ub = b_r->size[1];
  for (i8 = 0; i8 < loop_ub; i8++) {
    b_Ptemp = b_r->size[0];
    for (i9 = 0; i9 < b_Ptemp; i9++) {
      r4->data[i9 + r4->size[0] * i8] = a * b_r->data[i9 + b_r->size[0] * i8];
    }
  }

  emxFree_real_T(&b_r);
  for (i8 = 0; i8 < 2; i8++) {
    c_Ptemp[i8] = Ptemp->size[i8];
  }

  for (i8 = 0; i8 < 2; i8++) {
    iv26[i8] = r4->size[i8];
  }

  if ((c_Ptemp[0] != iv26[0]) || (c_Ptemp[1] != iv26[1])) {
    emlrtSizeEqCheckNDR2012b(&c_Ptemp[0], &iv26[0], &k_emlrtECI, sp);
  }

  i8 = Ptemp->size[0] * Ptemp->size[1];
  emxEnsureCapacity(sp, (emxArray__common *)Ptemp, i8, (int32_T)sizeof(real_T),
                    &j_emlrtRTEI);
  b_Ptemp = Ptemp->size[0];
  loop_ub = Ptemp->size[1];
  loop_ub *= b_Ptemp;
  for (i8 = 0; i8 < loop_ub; i8++) {
    Ptemp->data[i8] -= r4->data[i8];
  }

  emxInit_int32_T(sp, &r5, 1, &j_emlrtRTEI, true);
  b_Ptemp = Rf->size[1];
  i8 = r5->size[0];
  r5->size[0] = b_Ptemp;
  emxEnsureCapacity(sp, (emxArray__common *)r5, i8, (int32_T)sizeof(int32_T),
                    &j_emlrtRTEI);
  for (i8 = 0; i8 < b_Ptemp; i8++) {
    r5->data[i8] = i8;
  }

  emxInit_real_T1(sp, &A, 2, &j_emlrtRTEI, true);
  st.site = &v_emlrtRSI;
  i8 = A->size[0] * A->size[1];
  A->size[0] = 1;
  A->size[1] = r->size[0];
  emxEnsureCapacity(&st, (emxArray__common *)A, i8, (int32_T)sizeof(real_T),
                    &j_emlrtRTEI);
  loop_ub = r->size[0];
  for (i8 = 0; i8 < loop_ub; i8++) {
    A->data[A->size[0] * i8] = r->data[i8];
  }

  if (Ptemp->size[1] != A->size[1]) {
    emlrtErrorWithMessageIdR2012b(&st, &mb_emlrtRTEI, "Coder:MATLAB:dimagree", 0);
  }

  emxInit_real_T1(&st, &b_a, 2, &j_emlrtRTEI, true);
  emxInit_real_T2(&st, &x, 1, &j_emlrtRTEI, true);
  emxInit_real_T1(&st, &d_Ptemp, 2, &j_emlrtRTEI, true);
  emxInit_real_T2(&st, &b_A, 1, &j_emlrtRTEI, true);
  if ((A->size[1] == 0) || ((Ptemp->size[0] == 0) || (Ptemp->size[1] == 0))) {
    unnamed_idx_1 = (uint32_T)Ptemp->size[0];
    i8 = b_a->size[0] * b_a->size[1];
    b_a->size[0] = 1;
    b_a->size[1] = (int32_T)unnamed_idx_1;
    emxEnsureCapacity(&st, (emxArray__common *)b_a, i8, (int32_T)sizeof(real_T),
                      &j_emlrtRTEI);
    loop_ub = (int32_T)unnamed_idx_1;
    for (i8 = 0; i8 < loop_ub; i8++) {
      b_a->data[i8] = 0.0;
    }
  } else if (Ptemp->size[0] == Ptemp->size[1]) {
    b_st.site = &od_emlrtRSI;
    lusolve(&b_st, Ptemp, A, b_a);
  } else {
    i8 = d_Ptemp->size[0] * d_Ptemp->size[1];
    d_Ptemp->size[0] = Ptemp->size[1];
    d_Ptemp->size[1] = Ptemp->size[0];
    emxEnsureCapacity(&st, (emxArray__common *)d_Ptemp, i8, (int32_T)sizeof
                      (real_T), &j_emlrtRTEI);
    loop_ub = Ptemp->size[0];
    for (i8 = 0; i8 < loop_ub; i8++) {
      b_Ptemp = Ptemp->size[1];
      for (i9 = 0; i9 < b_Ptemp; i9++) {
        d_Ptemp->data[i9 + d_Ptemp->size[0] * i8] = Ptemp->data[i8 + Ptemp->
          size[0] * i9];
      }
    }

    i8 = b_A->size[0];
    b_A->size[0] = A->size[1];
    emxEnsureCapacity(&st, (emxArray__common *)b_A, i8, (int32_T)sizeof(real_T),
                      &j_emlrtRTEI);
    loop_ub = A->size[1];
    for (i8 = 0; i8 < loop_ub; i8++) {
      b_A->data[i8] = A->data[A->size[0] * i8];
    }

    b_st.site = &od_emlrtRSI;
    qrsolve(&b_st, d_Ptemp, b_A, x);
    i8 = b_a->size[0] * b_a->size[1];
    b_a->size[0] = 1;
    b_a->size[1] = x->size[0];
    emxEnsureCapacity(&st, (emxArray__common *)b_a, i8, (int32_T)sizeof(real_T),
                      &j_emlrtRTEI);
    loop_ub = x->size[0];
    for (i8 = 0; i8 < loop_ub; i8++) {
      b_a->data[b_a->size[0] * i8] = x->data[i8];
    }
  }

  emxFree_real_T(&b_A);
  emxFree_real_T(&d_Ptemp);
  emxFree_real_T(&A);
  st.site = &v_emlrtRSI;
  b_st.site = &sd_emlrtRSI;
  if (!(b_a->size[1] == r->size[0])) {
    if ((b_a->size[1] == 1) || (r->size[0] == 1)) {
      emlrtErrorWithMessageIdR2012b(&b_st, &kb_emlrtRTEI,
        "Coder:toolbox:mtimes_noDynamicScalarExpansion", 0);
    } else {
      emlrtErrorWithMessageIdR2012b(&b_st, &lb_emlrtRTEI,
        "Coder:MATLAB:innerdim", 0);
    }
  }

  if ((b_a->size[1] == 1) || (r->size[0] == 1)) {
    a = 0.0;
    for (i8 = 0; i8 < b_a->size[1]; i8++) {
      a += b_a->data[b_a->size[0] * i8] * r->data[i8];
    }
  } else {
    b_st.site = &rd_emlrtRSI;
    if (b_a->size[1] < 1) {
      a = 0.0;
    } else {
      n_t = (ptrdiff_t)b_a->size[1];
      incx_t = (ptrdiff_t)1;
      incy_t = (ptrdiff_t)1;
      a = ddot(&n_t, &b_a->data[0], &incx_t, &r->data[0], &incy_t);
    }
  }

  i8 = x->size[0];
  x->size[0] = r->size[0];
  emxEnsureCapacity(sp, (emxArray__common *)x, i8, (int32_T)sizeof(real_T),
                    &j_emlrtRTEI);
  loop_ub = r->size[0];
  for (i8 = 0; i8 < loop_ub; i8++) {
    x->data[i8] = r->data[i8];
  }

  st.site = &v_emlrtRSI;
  mldivide(&st, Ptemp, x);
  i8 = x->size[0];
  emxEnsureCapacity(sp, (emxArray__common *)x, i8, (int32_T)sizeof(real_T),
                    &j_emlrtRTEI);
  loop_ub = x->size[0];
  for (i8 = 0; i8 < loop_ub; i8++) {
    x->data[i8] /= 1.0 + a;
  }

  iv27[0] = r5->size[0];
  emlrtSubAssignSizeCheckR2012b(iv27, 1, *(int32_T (*)[1])x->size, 1,
    &j_emlrtECI, sp);
  loop_ub = x->size[0];
  for (i8 = 0; i8 < loop_ub; i8++) {
    g->data[r5->data[i8]] = x->data[i8];
  }

  m = 0;
  emxInit_real_T2(sp, &b_wh, 1, &j_emlrtRTEI, true);
  emxInit_real_T2(sp, &c_wh, 1, &j_emlrtRTEI, true);
  while (m < 64) {
    st.site = &w_emlrtRSI;
    i8 = b_a->size[0] * b_a->size[1];
    b_a->size[0] = 1;
    b_a->size[1] = r->size[0];
    emxEnsureCapacity(&st, (emxArray__common *)b_a, i8, (int32_T)sizeof(real_T),
                      &j_emlrtRTEI);
    loop_ub = r->size[0];
    for (i8 = 0; i8 < loop_ub; i8++) {
      b_a->data[b_a->size[0] * i8] = r->data[i8];
    }

    loop_ub = wh->size[0];
    i8 = x->size[0];
    x->size[0] = loop_ub;
    emxEnsureCapacity(&st, (emxArray__common *)x, i8, (int32_T)sizeof(real_T),
                      &j_emlrtRTEI);
    for (i8 = 0; i8 < loop_ub; i8++) {
      x->data[i8] = wh->data[i8 + wh->size[0] * m];
    }

    b_st.site = &sd_emlrtRSI;
    i8 = wh->size[0];
    if (!(b_a->size[1] == i8)) {
      guard2 = false;
      if (b_a->size[1] == 1) {
        guard2 = true;
      } else {
        i8 = wh->size[0];
        if (i8 == 1) {
          guard2 = true;
        } else {
          emlrtErrorWithMessageIdR2012b(&b_st, &lb_emlrtRTEI,
            "Coder:MATLAB:innerdim", 0);
        }
      }

      if (guard2) {
        emlrtErrorWithMessageIdR2012b(&b_st, &kb_emlrtRTEI,
          "Coder:toolbox:mtimes_noDynamicScalarExpansion", 0);
      }
    }

    guard1 = false;
    if (b_a->size[1] == 1) {
      guard1 = true;
    } else {
      i8 = wh->size[0];
      if (i8 == 1) {
        guard1 = true;
      } else {
        b_st.site = &rd_emlrtRSI;
        if (b_a->size[1] < 1) {
          a = 0.0;
        } else {
          n_t = (ptrdiff_t)b_a->size[1];
          incx_t = (ptrdiff_t)1;
          incy_t = (ptrdiff_t)1;
          a = ddot(&n_t, &b_a->data[0], &incx_t, &x->data[0], &incy_t);
        }
      }
    }

    if (guard1) {
      a = 0.0;
      for (i8 = 0; i8 < b_a->size[1]; i8++) {
        a += b_a->data[b_a->size[0] * i8] * x->data[i8];
      }
    }

    zh[m] = a;
    sh[m] = Yf[m] - zh[m];
    loop_ub = g->size[0];
    i8 = x->size[0];
    x->size[0] = loop_ub;
    emxEnsureCapacity(sp, (emxArray__common *)x, i8, (int32_T)sizeof(real_T),
                      &j_emlrtRTEI);
    for (i8 = 0; i8 < loop_ub; i8++) {
      x->data[i8] = g->data[i8] * sh[m];
    }

    i8 = wh->size[0];
    i9 = x->size[0];
    if (i8 != i9) {
      emlrtSizeEqCheck1DR2012b(i8, i9, &i_emlrtECI, sp);
    }

    loop_ub = wh->size[0];
    i8 = r5->size[0];
    r5->size[0] = loop_ub;
    emxEnsureCapacity(sp, (emxArray__common *)r5, i8, (int32_T)sizeof(int32_T),
                      &j_emlrtRTEI);
    for (i8 = 0; i8 < loop_ub; i8++) {
      r5->data[i8] = i8;
    }

    iv29[0] = r5->size[0];
    loop_ub = wh->size[0];
    i8 = b_wh->size[0];
    b_wh->size[0] = loop_ub;
    emxEnsureCapacity(sp, (emxArray__common *)b_wh, i8, (int32_T)sizeof(real_T),
                      &j_emlrtRTEI);
    for (i8 = 0; i8 < loop_ub; i8++) {
      b_wh->data[i8] = wh->data[i8 + wh->size[0] * m];
    }

    d_wh[0] = b_wh->size[0];
    emlrtSubAssignSizeCheckR2012b(iv29, 1, d_wh, 1, &h_emlrtECI, sp);
    b_Ptemp = wh->size[0];
    i8 = c_wh->size[0];
    c_wh->size[0] = b_Ptemp;
    emxEnsureCapacity(sp, (emxArray__common *)c_wh, i8, (int32_T)sizeof(real_T),
                      &j_emlrtRTEI);
    for (i8 = 0; i8 < b_Ptemp; i8++) {
      c_wh->data[i8] = wh->data[i8 + wh->size[0] * m] + x->data[i8];
    }

    loop_ub = c_wh->size[0];
    for (i8 = 0; i8 < loop_ub; i8++) {
      wh->data[r5->data[i8] + wh->size[0] * m] = c_wh->data[i8];
    }

    m++;
    if (*emlrtBreakCheckR2012bFlagVar != 0) {
      emlrtBreakCheckR2012b(sp);
    }
  }

  emxFree_real_T(&c_wh);
  emxFree_real_T(&b_wh);
  emxFree_real_T(&x);
  emxFree_real_T(&b_a);
  emxFree_int32_T(&r5);
  emxFree_real_T(&g);
  emxInit_real_T1(sp, &c_r, 2, &j_emlrtRTEI, true);
  st.site = &x_emlrtRSI;
  inv(&st, Pt, r4);
  st.site = &x_emlrtRSI;
  a = 1.0 - mpower(b_gamma);
  i8 = c_r->size[0] * c_r->size[1];
  c_r->size[0] = r->size[0];
  c_r->size[1] = r->size[0];
  emxEnsureCapacity(sp, (emxArray__common *)c_r, i8, (int32_T)sizeof(real_T),
                    &j_emlrtRTEI);
  loop_ub = r->size[0];
  for (i8 = 0; i8 < loop_ub; i8++) {
    b_Ptemp = r->size[0];
    for (i9 = 0; i9 < b_Ptemp; i9++) {
      c_r->data[i8 + c_r->size[0] * i9] = r->data[i8] * r->data[i9];
    }
  }

  emxFree_real_T(&r);
  i8 = Ptemp->size[0] * Ptemp->size[1];
  Ptemp->size[0] = c_r->size[0];
  Ptemp->size[1] = c_r->size[1];
  emxEnsureCapacity(sp, (emxArray__common *)Ptemp, i8, (int32_T)sizeof(real_T),
                    &j_emlrtRTEI);
  loop_ub = c_r->size[1];
  for (i8 = 0; i8 < loop_ub; i8++) {
    b_Ptemp = c_r->size[0];
    for (i9 = 0; i9 < b_Ptemp; i9++) {
      Ptemp->data[i9 + Ptemp->size[0] * i8] = a * c_r->data[i9 + c_r->size[0] *
        i8];
    }
  }

  emxFree_real_T(&c_r);
  for (i8 = 0; i8 < 2; i8++) {
    iv28[i8] = r4->size[i8];
  }

  for (i8 = 0; i8 < 2; i8++) {
    e_Ptemp[i8] = Ptemp->size[i8];
  }

  emxInit_real_T1(sp, &r6, 2, &j_emlrtRTEI, true);
  if ((iv28[0] != e_Ptemp[0]) || (iv28[1] != e_Ptemp[1])) {
    emlrtSizeEqCheckNDR2012b(&iv28[0], &e_Ptemp[0], &g_emlrtECI, sp);
  }

  i8 = r6->size[0] * r6->size[1];
  r6->size[0] = r4->size[0];
  r6->size[1] = r4->size[1];
  emxEnsureCapacity(sp, (emxArray__common *)r6, i8, (int32_T)sizeof(real_T),
                    &j_emlrtRTEI);
  loop_ub = r4->size[0] * r4->size[1];
  for (i8 = 0; i8 < loop_ub; i8++) {
    r6->data[i8] = r4->data[i8] + Ptemp->data[i8];
  }

  emxFree_real_T(&r4);
  st.site = &x_emlrtRSI;
  inv(&st, r6, Pt);
  st.site = &x_emlrtRSI;
  eye(&st, Rf->size[1], Ptemp);
  i8 = Ptemp->size[0] * Ptemp->size[1];
  emxEnsureCapacity(sp, (emxArray__common *)Ptemp, i8, (int32_T)sizeof(real_T),
                    &j_emlrtRTEI);
  b_Ptemp = Ptemp->size[0];
  loop_ub = Ptemp->size[1];
  loop_ub *= b_Ptemp;
  emxFree_real_T(&r6);
  for (i8 = 0; i8 < loop_ub; i8++) {
    Ptemp->data[i8] *= q;
  }

  for (i8 = 0; i8 < 2; i8++) {
    b_Pt[i8] = Pt->size[i8];
  }

  for (i8 = 0; i8 < 2; i8++) {
    f_Ptemp[i8] = Ptemp->size[i8];
  }

  if ((b_Pt[0] != f_Ptemp[0]) || (b_Pt[1] != f_Ptemp[1])) {
    emlrtSizeEqCheckNDR2012b(&b_Pt[0], &f_Ptemp[0], &f_emlrtECI, sp);
  }

  i8 = Pt->size[0] * Pt->size[1];
  emxEnsureCapacity(sp, (emxArray__common *)Pt, i8, (int32_T)sizeof(real_T),
                    &j_emlrtRTEI);
  loop_ub = Pt->size[1];
  for (i8 = 0; i8 < loop_ub; i8++) {
    b_Ptemp = Pt->size[0];
    for (i9 = 0; i9 < b_Ptemp; i9++) {
      Pt->data[i9 + Pt->size[0] * i8] += Ptemp->data[i9 + Ptemp->size[0] * i8];
    }
  }

  emxFree_real_T(&Ptemp);
  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

/* End of code generation (uhbmi_HinfFilter.c) */
