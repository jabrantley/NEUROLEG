/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * eye.c
 *
 * Code generation for function 'eye'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "uhbmi_CleanMotionArtifacts.h"
#include "eye.h"
#include "eml_int_forloop_overflow_check.h"
#include "uhbmi_CleanMotionArtifacts_emxutil.h"
#include "uhbmi_CleanMotionArtifacts_data.h"

/* Variable Definitions */
static emlrtRSInfo l_emlrtRSI = { 51,  /* lineNo */
  "eye",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\lib\\matlab\\elmat\\eye.m"/* pathName */
};

static emlrtRSInfo m_emlrtRSI = { 92,  /* lineNo */
  "eye",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\lib\\matlab\\elmat\\eye.m"/* pathName */
};

static emlrtRTEInfo g_emlrtRTEI = { 1, /* lineNo */
  14,                                  /* colNo */
  "eye",                               /* fName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\lib\\matlab\\elmat\\eye.m"/* pName */
};

static emlrtRTEInfo fb_emlrtRTEI = { 53,/* lineNo */
  23,                                  /* colNo */
  "assertValidSizeArg",                /* fName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\assertValidSizeArg.m"/* pName */
};

static emlrtRTEInfo gb_emlrtRTEI = { 59,/* lineNo */
  15,                                  /* colNo */
  "assertValidSizeArg",                /* fName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\assertValidSizeArg.m"/* pName */
};

/* Function Definitions */
void eye(const emlrtStack *sp, real_T varargin_1, emxArray_real_T *I)
{
  boolean_T p;
  real_T b_varargin_1;
  int32_T k;
  int32_T loop_ub;
  emlrtStack st;
  emlrtStack b_st;
  st.prev = sp;
  st.tls = sp->tls;
  st.site = &l_emlrtRSI;
  b_st.prev = &st;
  b_st.tls = st.tls;
  if ((varargin_1 != varargin_1) || muDoubleScalarIsInf(varargin_1)) {
    p = false;
  } else {
    p = true;
  }

  if (p && (!(2.147483647E+9 < varargin_1))) {
    p = true;
  } else {
    p = false;
  }

  if (!p) {
    emlrtErrorWithMessageIdR2012b(&st, &fb_emlrtRTEI,
      "Coder:MATLAB:NonIntegerInput", 4, 12, MIN_int32_T, 12, MAX_int32_T);
  }

  if (varargin_1 <= 0.0) {
    b_varargin_1 = 0.0;
  } else {
    b_varargin_1 = varargin_1;
  }

  if (!(2.147483647E+9 >= b_varargin_1)) {
    emlrtErrorWithMessageIdR2012b(&st, &gb_emlrtRTEI, "Coder:MATLAB:pmaxsize", 0);
  }

  k = I->size[0] * I->size[1];
  I->size[0] = (int32_T)varargin_1;
  I->size[1] = (int32_T)varargin_1;
  emxEnsureCapacity(sp, (emxArray__common *)I, k, (int32_T)sizeof(real_T),
                    &g_emlrtRTEI);
  loop_ub = (int32_T)varargin_1 * (int32_T)varargin_1;
  for (k = 0; k < loop_ub; k++) {
    I->data[k] = 0.0;
  }

  if ((int32_T)varargin_1 > 0) {
    st.site = &m_emlrtRSI;
    if ((!(1 > (int32_T)varargin_1)) && ((int32_T)varargin_1 > 2147483646)) {
      b_st.site = &n_emlrtRSI;
      check_forloop_overflow_error(&b_st);
    }

    for (k = 0; k + 1 <= (int32_T)varargin_1; k++) {
      I->data[k + I->size[0] * k] = 1.0;
    }
  }
}

/* End of code generation (eye.c) */
