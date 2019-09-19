/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * inv.c
 *
 * Code generation for function 'inv'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "uhbmi_CleanMotionArtifacts.h"
#include "inv.h"
#include "uhbmi_CleanMotionArtifacts_emxutil.h"
#include "warning.h"
#include "norm.h"
#include "error.h"
#include "eml_int_forloop_overflow_check.h"
#include "colon.h"
#include "uhbmi_CleanMotionArtifacts_mexutil.h"
#include "uhbmi_CleanMotionArtifacts_data.h"
#include "lapacke.h"
#include "blas.h"

/* Variable Definitions */
static emlrtRSInfo y_emlrtRSI = { 21,  /* lineNo */
  "inv",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\lib\\matlab\\matfun\\inv.m"/* pathName */
};

static emlrtRSInfo ab_emlrtRSI = { 22, /* lineNo */
  "inv",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\lib\\matlab\\matfun\\inv.m"/* pathName */
};

static emlrtRSInfo bb_emlrtRSI = { 172,/* lineNo */
  "inv",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\lib\\matlab\\matfun\\inv.m"/* pathName */
};

static emlrtRSInfo cb_emlrtRSI = { 173,/* lineNo */
  "inv",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\lib\\matlab\\matfun\\inv.m"/* pathName */
};

static emlrtRSInfo db_emlrtRSI = { 176,/* lineNo */
  "inv",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\lib\\matlab\\matfun\\inv.m"/* pathName */
};

static emlrtRSInfo eb_emlrtRSI = { 179,/* lineNo */
  "inv",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\lib\\matlab\\matfun\\inv.m"/* pathName */
};

static emlrtRSInfo fb_emlrtRSI = { 182,/* lineNo */
  "inv",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\lib\\matlab\\matfun\\inv.m"/* pathName */
};

static emlrtRSInfo gb_emlrtRSI = { 189,/* lineNo */
  "inv",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\lib\\matlab\\matfun\\inv.m"/* pathName */
};

static emlrtRSInfo pb_emlrtRSI = { 18, /* lineNo */
  "repmat",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\lib\\matlab\\elmat\\repmat.m"/* pathName */
};

static emlrtRSInfo yb_emlrtRSI = { 10, /* lineNo */
  "int",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\+blas\\int.m"/* pathName */
};

static emlrtRSInfo ac_emlrtRSI = { 14, /* lineNo */
  "eml_ipiv2perm",                     /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\lib\\matlab\\matfun\\private\\eml_ipiv2perm.m"/* pathName */
};

static emlrtRSInfo bc_emlrtRSI = { 70, /* lineNo */
  "xtrsm",                             /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\+blas\\xtrsm.m"/* pathName */
};

static emlrtRSInfo cc_emlrtRSI = { 72, /* lineNo */
  "xtrsm",                             /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\+blas\\xtrsm.m"/* pathName */
};

static emlrtRSInfo dc_emlrtRSI = { 73, /* lineNo */
  "xtrsm",                             /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\+blas\\xtrsm.m"/* pathName */
};

static emlrtRSInfo ec_emlrtRSI = { 68, /* lineNo */
  "xtrsm",                             /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\+blas\\xtrsm.m"/* pathName */
};

static emlrtRSInfo fc_emlrtRSI = { 42, /* lineNo */
  "inv",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\lib\\matlab\\matfun\\inv.m"/* pathName */
};

static emlrtRSInfo gc_emlrtRSI = { 46, /* lineNo */
  "inv",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\lib\\matlab\\matfun\\inv.m"/* pathName */
};

static emlrtRTEInfo k_emlrtRTEI = { 1, /* lineNo */
  14,                                  /* colNo */
  "inv",                               /* fName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\lib\\matlab\\matfun\\inv.m"/* pName */
};

static emlrtRTEInfo l_emlrtRTEI = { 164,/* lineNo */
  14,                                  /* colNo */
  "inv",                               /* fName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\lib\\matlab\\matfun\\inv.m"/* pName */
};

static emlrtRTEInfo m_emlrtRTEI = { 173,/* lineNo */
  1,                                   /* colNo */
  "inv",                               /* fName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\lib\\matlab\\matfun\\inv.m"/* pName */
};

static emlrtRTEInfo jb_emlrtRTEI = { 14,/* lineNo */
  15,                                  /* colNo */
  "inv",                               /* fName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\lib\\matlab\\matfun\\inv.m"/* pName */
};

/* Function Declarations */
static void invNxN(const emlrtStack *sp, const emxArray_real_T *x,
                   emxArray_real_T *y);

/* Function Definitions */
static void invNxN(const emlrtStack *sp, const emxArray_real_T *x,
                   emxArray_real_T *y)
{
  int32_T n;
  int32_T NPIV;
  int32_T c;
  emxArray_real_T *A;
  emxArray_int32_T *ipiv;
  emxArray_int32_T *p;
  emxArray_ptrdiff_t *ipiv_t;
  int32_T k;
  boolean_T overflow;
  ptrdiff_t info_t;
  int32_T i;
  real_T alpha1;
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
  n = x->size[0];
  NPIV = y->size[0] * y->size[1];
  y->size[0] = x->size[0];
  y->size[1] = x->size[1];
  emxEnsureCapacity(sp, (emxArray__common *)y, NPIV, (int32_T)sizeof(real_T),
                    &l_emlrtRTEI);
  c = x->size[0] * x->size[1];
  for (NPIV = 0; NPIV < c; NPIV++) {
    y->data[NPIV] = 0.0;
  }

  emxInit_real_T1(sp, &A, 2, &l_emlrtRTEI, true);
  st.site = &bb_emlrtRSI;
  b_st.site = &ib_emlrtRSI;
  NPIV = A->size[0] * A->size[1];
  A->size[0] = x->size[0];
  A->size[1] = x->size[1];
  emxEnsureCapacity(&b_st, (emxArray__common *)A, NPIV, (int32_T)sizeof(real_T),
                    &l_emlrtRTEI);
  c = x->size[0] * x->size[1];
  for (NPIV = 0; NPIV < c; NPIV++) {
    A->data[NPIV] = x->data[NPIV];
  }

  c_st.site = &ob_emlrtRSI;
  emxInit_int32_T1(&b_st, &ipiv, 2, &l_emlrtRTEI, true);
  if ((A->size[0] == 0) || (A->size[1] == 0)) {
    NPIV = ipiv->size[0] * ipiv->size[1];
    ipiv->size[0] = 1;
    ipiv->size[1] = 0;
    emxEnsureCapacity(&b_st, (emxArray__common *)ipiv, NPIV, (int32_T)sizeof
                      (int32_T), &l_emlrtRTEI);
  } else {
    c_st.site = &nb_emlrtRSI;
    d_st.site = &hb_emlrtRSI;
    c = muIntScalarMin_sint32(n, n);
    c = muIntScalarMax_sint32(c, 1);
    c_st.site = &nb_emlrtRSI;
    d_st.site = &pb_emlrtRSI;
    emxInit_ptrdiff_t(&c_st, &ipiv_t, 1, &n_emlrtRTEI, true);
    NPIV = ipiv_t->size[0];
    ipiv_t->size[0] = c;
    emxEnsureCapacity(&b_st, (emxArray__common *)ipiv_t, NPIV, (int32_T)sizeof
                      (ptrdiff_t), &l_emlrtRTEI);
    c_st.site = &mb_emlrtRSI;
    d_st.site = &hb_emlrtRSI;
    c_st.site = &lb_emlrtRSI;
    d_st.site = &hb_emlrtRSI;
    c_st.site = &kb_emlrtRSI;
    d_st.site = &qb_emlrtRSI;
    info_t = LAPACKE_dgetrf_work(102, (ptrdiff_t)x->size[0], (ptrdiff_t)x->size
      [0], &A->data[0], (ptrdiff_t)x->size[0], &ipiv_t->data[0]);
    c = (int32_T)info_t;
    NPIV = ipiv->size[0] * ipiv->size[1];
    ipiv->size[0] = 1;
    ipiv->size[1] = ipiv_t->size[0];
    emxEnsureCapacity(&b_st, (emxArray__common *)ipiv, NPIV, (int32_T)sizeof
                      (int32_T), &l_emlrtRTEI);
    NPIV = ipiv->size[1];
    c_st.site = &jb_emlrtRSI;
    d_st.site = &rb_emlrtRSI;
    if (c < 0) {
      if (c == -1010) {
        d_st.site = &sb_emlrtRSI;
        b_error(&d_st);
      } else {
        d_st.site = &tb_emlrtRSI;
        c_error(&d_st, c);
      }
    }

    for (k = 0; k < NPIV; k++) {
      ipiv->data[k] = (int32_T)ipiv_t->data[k];
    }

    emxFree_ptrdiff_t(&ipiv_t);
  }

  emxInit_int32_T1(&b_st, &p, 2, &m_emlrtRTEI, true);
  st.site = &cb_emlrtRSI;
  b_st.site = &ac_emlrtRSI;
  c_st.site = &ub_emlrtRSI;
  d_st.site = &vb_emlrtRSI;
  e_st.site = &wb_emlrtRSI;
  eml_signed_integer_colon(&e_st, x->size[0], p);
  for (k = 0; k < ipiv->size[1]; k++) {
    if (ipiv->data[k] > 1 + k) {
      c = p->data[ipiv->data[k] - 1];
      p->data[ipiv->data[k] - 1] = p->data[k];
      p->data[k] = c;
    }
  }

  emxFree_int32_T(&ipiv);
  st.site = &db_emlrtRSI;
  overflow = ((!(1 > x->size[0])) && (x->size[0] > 2147483646));
  if (overflow) {
    b_st.site = &n_emlrtRSI;
    check_forloop_overflow_error(&b_st);
  }

  for (k = 0; k + 1 <= n; k++) {
    c = p->data[k] - 1;
    y->data[k + y->size[0] * (p->data[k] - 1)] = 1.0;
    st.site = &eb_emlrtRSI;
    if ((!(k + 1 > n)) && (n > 2147483646)) {
      b_st.site = &n_emlrtRSI;
      check_forloop_overflow_error(&b_st);
    }

    for (NPIV = k; NPIV + 1 <= n; NPIV++) {
      if (y->data[NPIV + y->size[0] * c] != 0.0) {
        st.site = &fb_emlrtRSI;
        if ((!(NPIV + 2 > n)) && (n > 2147483646)) {
          b_st.site = &n_emlrtRSI;
          check_forloop_overflow_error(&b_st);
        }

        for (i = NPIV + 1; i + 1 <= n; i++) {
          y->data[i + y->size[0] * c] -= y->data[NPIV + y->size[0] * c] *
            A->data[i + A->size[0] * NPIV];
        }
      }
    }
  }

  emxFree_int32_T(&p);
  st.site = &gb_emlrtRSI;
  if (!(x->size[0] < 1)) {
    b_st.site = &bc_emlrtRSI;
    c_st.site = &yb_emlrtRSI;
    b_st.site = &bc_emlrtRSI;
    c_st.site = &yb_emlrtRSI;
    b_st.site = &cc_emlrtRSI;
    c_st.site = &yb_emlrtRSI;
    b_st.site = &dc_emlrtRSI;
    c_st.site = &yb_emlrtRSI;
    b_st.site = &ec_emlrtRSI;
    alpha1 = 1.0;
    DIAGA = 'N';
    TRANSA = 'N';
    UPLO = 'U';
    SIDE = 'L';
    m_t = (ptrdiff_t)x->size[0];
    n_t = (ptrdiff_t)x->size[0];
    lda_t = (ptrdiff_t)x->size[0];
    ldb_t = (ptrdiff_t)x->size[0];
    dtrsm(&SIDE, &UPLO, &TRANSA, &DIAGA, &m_t, &n_t, &alpha1, &A->data[0],
          &lda_t, &y->data[0], &ldb_t);
  }

  emxFree_real_T(&A);
  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

void inv(const emlrtStack *sp, const emxArray_real_T *x, emxArray_real_T *y)
{
  boolean_T b2;
  int32_T i3;
  real_T n1x;
  real_T n1xinv;
  real_T rc;
  int32_T loop_ub;
  const mxArray *b_y;
  char_T rfmt[6];
  static const char_T cv5[6] = { '%', '1', '4', '.', '6', 'e' };

  const mxArray *m1;
  static const int32_T iv9[2] = { 1, 6 };

  const mxArray *c_y;
  char_T cv6[14];
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  b2 = (x->size[0] == x->size[1]);
  if (!b2) {
    emlrtErrorWithMessageIdR2012b(sp, &jb_emlrtRTEI, "Coder:MATLAB:square", 0);
  }

  if ((x->size[0] == 0) || (x->size[1] == 0)) {
    i3 = y->size[0] * y->size[1];
    y->size[0] = x->size[0];
    y->size[1] = x->size[1];
    emxEnsureCapacity(sp, (emxArray__common *)y, i3, (int32_T)sizeof(real_T),
                      &k_emlrtRTEI);
    loop_ub = x->size[0] * x->size[1];
    for (i3 = 0; i3 < loop_ub; i3++) {
      y->data[i3] = x->data[i3];
    }
  } else {
    st.site = &y_emlrtRSI;
    invNxN(&st, x, y);
    st.site = &ab_emlrtRSI;
    n1x = norm(x);
    n1xinv = norm(y);
    rc = 1.0 / (n1x * n1xinv);
    if ((n1x == 0.0) || (n1xinv == 0.0) || (rc == 0.0)) {
      if (!emlrtSetWarningFlag(&st)) {
        b_st.site = &fc_emlrtRSI;
        b_warning(&b_st);
      }
    } else {
      if ((muDoubleScalarIsNaN(rc) || (rc < 2.2204460492503131E-16)) &&
          (!emlrtSetWarningFlag(&st))) {
        b_st.site = &gc_emlrtRSI;
        for (i3 = 0; i3 < 6; i3++) {
          rfmt[i3] = cv5[i3];
        }

        b_y = NULL;
        m1 = emlrtCreateCharArray(2, iv9);
        emlrtInitCharArrayR2013a(&b_st, 6, m1, &rfmt[0]);
        emlrtAssign(&b_y, m1);
        c_y = NULL;
        m1 = emlrtCreateDoubleScalar(rc);
        emlrtAssign(&c_y, m1);
        c_st.site = &yd_emlrtRSI;
        emlrt_marshallIn(&c_st, b_sprintf(&c_st, b_y, c_y, &e_emlrtMCI),
                         "sprintf", cv6);
        b_st.site = &gc_emlrtRSI;
        c_warning(&b_st, cv6);
      }
    }
  }
}

/* End of code generation (inv.c) */
