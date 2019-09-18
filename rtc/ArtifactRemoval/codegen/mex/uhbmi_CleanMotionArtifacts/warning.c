/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * warning.c
 *
 * Code generation for function 'warning'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "uhbmi_CleanMotionArtifacts.h"
#include "warning.h"

/* Variable Definitions */
static emlrtMCInfo c_emlrtMCI = { 14,  /* lineNo */
  25,                                  /* colNo */
  "warning",                           /* fName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\shared\\coder\\coder\\+coder\\+internal\\warning.m"/* pName */
};

static emlrtMCInfo d_emlrtMCI = { 14,  /* lineNo */
  9,                                   /* colNo */
  "warning",                           /* fName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\shared\\coder\\coder\\+coder\\+internal\\warning.m"/* pName */
};

static emlrtRSInfo xd_emlrtRSI = { 14, /* lineNo */
  "warning",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\shared\\coder\\coder\\+coder\\+internal\\warning.m"/* pathName */
};

/* Function Declarations */
static void b_feval(const emlrtStack *sp, const mxArray *b, const mxArray *c,
                    emlrtMCInfo *location);
static const mxArray *c_feval(const emlrtStack *sp, const mxArray *b, const
  mxArray *c, const mxArray *d, emlrtMCInfo *location);
static const mxArray *d_feval(const emlrtStack *sp, const mxArray *b, const
  mxArray *c, const mxArray *d, const mxArray *e, emlrtMCInfo *location);
static const mxArray *feval(const emlrtStack *sp, const mxArray *b, const
  mxArray *c, emlrtMCInfo *location);

/* Function Definitions */
static void b_feval(const emlrtStack *sp, const mxArray *b, const mxArray *c,
                    emlrtMCInfo *location)
{
  const mxArray *pArrays[2];
  pArrays[0] = b;
  pArrays[1] = c;
  emlrtCallMATLABR2012b(sp, 0, NULL, 2, pArrays, "feval", true, location);
}

static const mxArray *c_feval(const emlrtStack *sp, const mxArray *b, const
  mxArray *c, const mxArray *d, emlrtMCInfo *location)
{
  const mxArray *pArrays[3];
  const mxArray *m11;
  pArrays[0] = b;
  pArrays[1] = c;
  pArrays[2] = d;
  return emlrtCallMATLABR2012b(sp, 1, &m11, 3, pArrays, "feval", true, location);
}

static const mxArray *d_feval(const emlrtStack *sp, const mxArray *b, const
  mxArray *c, const mxArray *d, const mxArray *e, emlrtMCInfo *location)
{
  const mxArray *pArrays[4];
  const mxArray *m12;
  pArrays[0] = b;
  pArrays[1] = c;
  pArrays[2] = d;
  pArrays[3] = e;
  return emlrtCallMATLABR2012b(sp, 1, &m12, 4, pArrays, "feval", true, location);
}

static const mxArray *feval(const emlrtStack *sp, const mxArray *b, const
  mxArray *c, emlrtMCInfo *location)
{
  const mxArray *pArrays[2];
  const mxArray *m9;
  pArrays[0] = b;
  pArrays[1] = c;
  return emlrtCallMATLABR2012b(sp, 1, &m9, 2, pArrays, "feval", true, location);
}

void b_warning(const emlrtStack *sp)
{
  int32_T i4;
  char_T msgID[27];
  static const char_T cv7[27] = { 'C', 'o', 'd', 'e', 'r', ':', 'M', 'A', 'T',
    'L', 'A', 'B', ':', 's', 'i', 'n', 'g', 'u', 'l', 'a', 'r', 'M', 'a', 't',
    'r', 'i', 'x' };

  const mxArray *y;
  char_T u[7];
  static const char_T cv8[7] = { 'w', 'a', 'r', 'n', 'i', 'n', 'g' };

  const mxArray *m2;
  static const int32_T iv10[2] = { 1, 7 };

  const mxArray *b_y;
  char_T b_u[7];
  static const char_T cv9[7] = { 'm', 'e', 's', 's', 'a', 'g', 'e' };

  static const int32_T iv11[2] = { 1, 7 };

  const mxArray *c_y;
  static const int32_T iv12[2] = { 1, 27 };

  emlrtStack st;
  st.prev = sp;
  st.tls = sp->tls;
  for (i4 = 0; i4 < 27; i4++) {
    msgID[i4] = cv7[i4];
  }

  for (i4 = 0; i4 < 7; i4++) {
    u[i4] = cv8[i4];
  }

  y = NULL;
  m2 = emlrtCreateCharArray(2, iv10);
  emlrtInitCharArrayR2013a(sp, 7, m2, &u[0]);
  emlrtAssign(&y, m2);
  for (i4 = 0; i4 < 7; i4++) {
    b_u[i4] = cv9[i4];
  }

  b_y = NULL;
  m2 = emlrtCreateCharArray(2, iv11);
  emlrtInitCharArrayR2013a(sp, 7, m2, &b_u[0]);
  emlrtAssign(&b_y, m2);
  c_y = NULL;
  m2 = emlrtCreateCharArray(2, iv12);
  emlrtInitCharArrayR2013a(sp, 27, m2, &msgID[0]);
  emlrtAssign(&c_y, m2);
  st.site = &xd_emlrtRSI;
  b_feval(&st, y, feval(&st, b_y, c_y, &c_emlrtMCI), &d_emlrtMCI);
}

void c_warning(const emlrtStack *sp, const char_T varargin_1[14])
{
  int32_T i5;
  char_T msgID[33];
  static const char_T cv10[33] = { 'C', 'o', 'd', 'e', 'r', ':', 'M', 'A', 'T',
    'L', 'A', 'B', ':', 'i', 'l', 'l', 'C', 'o', 'n', 'd', 'i', 't', 'i', 'o',
    'n', 'e', 'd', 'M', 'a', 't', 'r', 'i', 'x' };

  const mxArray *y;
  char_T u[7];
  static const char_T cv11[7] = { 'w', 'a', 'r', 'n', 'i', 'n', 'g' };

  const mxArray *m3;
  static const int32_T iv13[2] = { 1, 7 };

  const mxArray *b_y;
  char_T b_u[7];
  static const char_T cv12[7] = { 'm', 'e', 's', 's', 'a', 'g', 'e' };

  static const int32_T iv14[2] = { 1, 7 };

  const mxArray *c_y;
  static const int32_T iv15[2] = { 1, 33 };

  const mxArray *d_y;
  static const int32_T iv16[2] = { 1, 14 };

  emlrtStack st;
  st.prev = sp;
  st.tls = sp->tls;
  for (i5 = 0; i5 < 33; i5++) {
    msgID[i5] = cv10[i5];
  }

  for (i5 = 0; i5 < 7; i5++) {
    u[i5] = cv11[i5];
  }

  y = NULL;
  m3 = emlrtCreateCharArray(2, iv13);
  emlrtInitCharArrayR2013a(sp, 7, m3, &u[0]);
  emlrtAssign(&y, m3);
  for (i5 = 0; i5 < 7; i5++) {
    b_u[i5] = cv12[i5];
  }

  b_y = NULL;
  m3 = emlrtCreateCharArray(2, iv14);
  emlrtInitCharArrayR2013a(sp, 7, m3, &b_u[0]);
  emlrtAssign(&b_y, m3);
  c_y = NULL;
  m3 = emlrtCreateCharArray(2, iv15);
  emlrtInitCharArrayR2013a(sp, 33, m3, &msgID[0]);
  emlrtAssign(&c_y, m3);
  d_y = NULL;
  m3 = emlrtCreateCharArray(2, iv16);
  emlrtInitCharArrayR2013a(sp, 14, m3, &varargin_1[0]);
  emlrtAssign(&d_y, m3);
  st.site = &xd_emlrtRSI;
  b_feval(&st, y, c_feval(&st, b_y, c_y, d_y, &c_emlrtMCI), &d_emlrtMCI);
}

void d_warning(const emlrtStack *sp, int32_T varargin_1, const char_T
               varargin_2[14])
{
  int32_T i6;
  char_T msgID[32];
  static const char_T cv15[32] = { 'C', 'o', 'd', 'e', 'r', ':', 'M', 'A', 'T',
    'L', 'A', 'B', ':', 'r', 'a', 'n', 'k', 'D', 'e', 'f', 'i', 'c', 'i', 'e',
    'n', 't', 'M', 'a', 't', 'r', 'i', 'x' };

  const mxArray *y;
  char_T u[7];
  static const char_T cv16[7] = { 'w', 'a', 'r', 'n', 'i', 'n', 'g' };

  const mxArray *m5;
  static const int32_T iv18[2] = { 1, 7 };

  const mxArray *b_y;
  char_T b_u[7];
  static const char_T cv17[7] = { 'm', 'e', 's', 's', 'a', 'g', 'e' };

  static const int32_T iv19[2] = { 1, 7 };

  const mxArray *c_y;
  static const int32_T iv20[2] = { 1, 32 };

  const mxArray *d_y;
  const mxArray *e_y;
  static const int32_T iv21[2] = { 1, 14 };

  emlrtStack st;
  st.prev = sp;
  st.tls = sp->tls;
  for (i6 = 0; i6 < 32; i6++) {
    msgID[i6] = cv15[i6];
  }

  for (i6 = 0; i6 < 7; i6++) {
    u[i6] = cv16[i6];
  }

  y = NULL;
  m5 = emlrtCreateCharArray(2, iv18);
  emlrtInitCharArrayR2013a(sp, 7, m5, &u[0]);
  emlrtAssign(&y, m5);
  for (i6 = 0; i6 < 7; i6++) {
    b_u[i6] = cv17[i6];
  }

  b_y = NULL;
  m5 = emlrtCreateCharArray(2, iv19);
  emlrtInitCharArrayR2013a(sp, 7, m5, &b_u[0]);
  emlrtAssign(&b_y, m5);
  c_y = NULL;
  m5 = emlrtCreateCharArray(2, iv20);
  emlrtInitCharArrayR2013a(sp, 32, m5, &msgID[0]);
  emlrtAssign(&c_y, m5);
  d_y = NULL;
  m5 = emlrtCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
  *(int32_T *)mxGetData(m5) = varargin_1;
  emlrtAssign(&d_y, m5);
  e_y = NULL;
  m5 = emlrtCreateCharArray(2, iv21);
  emlrtInitCharArrayR2013a(sp, 14, m5, &varargin_2[0]);
  emlrtAssign(&e_y, m5);
  st.site = &xd_emlrtRSI;
  b_feval(&st, y, d_feval(&st, b_y, c_y, d_y, e_y, &c_emlrtMCI), &d_emlrtMCI);
}

void warning(const emlrtStack *sp)
{
  int32_T i2;
  char_T msgID[38];
  static const char_T cv2[38] = { 'C', 'o', 'd', 'e', 'r', ':', 'M', 'A', 'T',
    'L', 'A', 'B', ':', 'n', 'c', 'h', 'o', 'o', 's', 'e', 'k', '_', 'L', 'a',
    'r', 'g', 'e', 'C', 'o', 'e', 'f', 'f', 'i', 'c', 'i', 'e', 'n', 't' };

  const mxArray *y;
  char_T u[7];
  static const char_T cv3[7] = { 'w', 'a', 'r', 'n', 'i', 'n', 'g' };

  const mxArray *m0;
  static const int32_T iv6[2] = { 1, 7 };

  const mxArray *b_y;
  char_T b_u[7];
  static const char_T cv4[7] = { 'm', 'e', 's', 's', 'a', 'g', 'e' };

  static const int32_T iv7[2] = { 1, 7 };

  const mxArray *c_y;
  static const int32_T iv8[2] = { 1, 38 };

  emlrtStack st;
  st.prev = sp;
  st.tls = sp->tls;
  for (i2 = 0; i2 < 38; i2++) {
    msgID[i2] = cv2[i2];
  }

  for (i2 = 0; i2 < 7; i2++) {
    u[i2] = cv3[i2];
  }

  y = NULL;
  m0 = emlrtCreateCharArray(2, iv6);
  emlrtInitCharArrayR2013a(sp, 7, m0, &u[0]);
  emlrtAssign(&y, m0);
  for (i2 = 0; i2 < 7; i2++) {
    b_u[i2] = cv4[i2];
  }

  b_y = NULL;
  m0 = emlrtCreateCharArray(2, iv7);
  emlrtInitCharArrayR2013a(sp, 7, m0, &b_u[0]);
  emlrtAssign(&b_y, m0);
  c_y = NULL;
  m0 = emlrtCreateCharArray(2, iv8);
  emlrtInitCharArrayR2013a(sp, 38, m0, &msgID[0]);
  emlrtAssign(&c_y, m0);
  st.site = &xd_emlrtRSI;
  b_feval(&st, y, feval(&st, b_y, c_y, &c_emlrtMCI), &d_emlrtMCI);
}

/* End of code generation (warning.c) */
