/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * uhbmi_CleanMotionArtifacts.c
 *
 * Code generation for function 'uhbmi_CleanMotionArtifacts'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "uhbmi_CleanMotionArtifacts.h"
#include "uhbmi_CleanMotionArtifacts_emxutil.h"
#include "error.h"
#include "uhbmi_StateSpaceFilter.h"
#include "eye.h"
#include "uhbmi_HinfFilter.h"
#include "power.h"
#include "nchoosek.h"
#include "uhbmi_CleanMotionArtifacts_data.h"

/* Variable Definitions */
static boolean_T isFirstLoop_not_empty;
static real_T XnnBPFilter[36];
static emxArray_real_T *refBuffer;
static emxArray_real_T *PtHinf;
static emxArray_real_T *whHinf;
static real_T cleanData[192];
static real_T REF[9];
static emlrtRSInfo emlrtRSI = { 24,    /* lineNo */
  "uhbmi_CleanMotionArtifacts",        /* fcnName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m"/* pathName */
};

static emlrtRSInfo b_emlrtRSI = { 27,  /* lineNo */
  "uhbmi_CleanMotionArtifacts",        /* fcnName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m"/* pathName */
};

static emlrtRSInfo c_emlrtRSI = { 38,  /* lineNo */
  "uhbmi_CleanMotionArtifacts",        /* fcnName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m"/* pathName */
};

static emlrtRSInfo d_emlrtRSI = { 47,  /* lineNo */
  "uhbmi_CleanMotionArtifacts",        /* fcnName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m"/* pathName */
};

static emlrtRSInfo e_emlrtRSI = { 83,  /* lineNo */
  "uhbmi_CleanMotionArtifacts",        /* fcnName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m"/* pathName */
};

static emlrtRSInfo f_emlrtRSI = { 86,  /* lineNo */
  "uhbmi_CleanMotionArtifacts",        /* fcnName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m"/* pathName */
};

static emlrtRSInfo g_emlrtRSI = { 99,  /* lineNo */
  "uhbmi_CleanMotionArtifacts",        /* fcnName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m"/* pathName */
};

static emlrtRSInfo h_emlrtRSI = { 107, /* lineNo */
  "uhbmi_CleanMotionArtifacts",        /* fcnName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m"/* pathName */
};

static emlrtRSInfo i_emlrtRSI = { 39,  /* lineNo */
  "nchoosek",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\lib\\matlab\\specfun\\nchoosek.m"/* pathName */
};

static emlrtRSInfo j_emlrtRSI = { 45,  /* lineNo */
  "nchoosek",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\lib\\matlab\\specfun\\nchoosek.m"/* pathName */
};

static emlrtRSInfo s_emlrtRSI = { 25,  /* lineNo */
  "cat",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\cat.m"/* pathName */
};

static emlrtRSInfo t_emlrtRSI = { 100, /* lineNo */
  "cat",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\cat.m"/* pathName */
};

static emlrtMCInfo emlrtMCI = { 43,    /* lineNo */
  9,                                   /* colNo */
  "uhbmi_CleanMotionArtifacts",        /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m"/* pName */
};

static emlrtMCInfo b_emlrtMCI = { 40,  /* lineNo */
  9,                                   /* colNo */
  "uhbmi_CleanMotionArtifacts",        /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m"/* pName */
};

static emlrtRTEInfo emlrtRTEI = { 9,   /* lineNo */
  53,                                  /* colNo */
  "uhbmi_CleanMotionArtifacts",        /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m"/* pName */
};

static emlrtRTEInfo b_emlrtRTEI = { 9, /* lineNo */
  46,                                  /* colNo */
  "uhbmi_CleanMotionArtifacts",        /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m"/* pName */
};

static emlrtRTEInfo c_emlrtRTEI = { 9, /* lineNo */
  36,                                  /* colNo */
  "uhbmi_CleanMotionArtifacts",        /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m"/* pName */
};

static emlrtRTEInfo d_emlrtRTEI = { 1, /* lineNo */
  20,                                  /* colNo */
  "uhbmi_CleanMotionArtifacts",        /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m"/* pName */
};

static emlrtRTEInfo e_emlrtRTEI = { 86,/* lineNo */
  17,                                  /* colNo */
  "uhbmi_CleanMotionArtifacts",        /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m"/* pName */
};

static emlrtRTEInfo f_emlrtRTEI = { 99,/* lineNo */
  13,                                  /* colNo */
  "uhbmi_CleanMotionArtifacts",        /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m"/* pName */
};

static emlrtRTEInfo y_emlrtRTEI = { 281,/* lineNo */
  27,                                  /* colNo */
  "cat",                               /* fName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\eml\\+coder\\+internal\\cat.m"/* pName */
};

static emlrtRTEInfo ab_emlrtRTEI = { 43,/* lineNo */
  23,                                  /* colNo */
  "nchoosek",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2016b\\toolbox\\eml\\lib\\matlab\\specfun\\nchoosek.m"/* pName */
};

static emlrtECInfo emlrtECI = { -1,    /* nDims */
  107,                                 /* lineNo */
  43,                                  /* colNo */
  "uhbmi_CleanMotionArtifacts",        /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m"/* pName */
};

static emlrtECInfo b_emlrtECI = { -1,  /* nDims */
  107,                                 /* lineNo */
  29,                                  /* colNo */
  "uhbmi_CleanMotionArtifacts",        /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m"/* pName */
};

static emlrtECInfo c_emlrtECI = { -1,  /* nDims */
  47,                                  /* lineNo */
  9,                                   /* colNo */
  "uhbmi_CleanMotionArtifacts",        /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m"/* pName */
};

static emlrtECInfo d_emlrtECI = { -1,  /* nDims */
  92,                                  /* lineNo */
  25,                                  /* colNo */
  "uhbmi_CleanMotionArtifacts",        /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m"/* pName */
};

static emlrtBCInfo emlrtBCI = { -1,    /* iFirst */
  -1,                                  /* iLast */
  92,                                  /* lineNo */
  46,                                  /* colNo */
  "volterraCrossTerms",                /* aName */
  "uhbmi_CleanMotionArtifacts",        /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo b_emlrtBCI = { -1,  /* iFirst */
  -1,                                  /* iLast */
  99,                                  /* lineNo */
  60,                                  /* colNo */
  "refBuffer",                         /* aName */
  "uhbmi_CleanMotionArtifacts",        /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo c_emlrtBCI = { -1,  /* iFirst */
  -1,                                  /* iLast */
  99,                                  /* lineNo */
  42,                                  /* colNo */
  "refBuffer",                         /* aName */
  "uhbmi_CleanMotionArtifacts",        /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo d_emlrtBCI = { -1,  /* iFirst */
  -1,                                  /* iLast */
  92,                                  /* lineNo */
  91,                                  /* colNo */
  "refBuffer",                         /* aName */
  "uhbmi_CleanMotionArtifacts",        /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo e_emlrtBCI = { -1,  /* iFirst */
  -1,                                  /* iLast */
  92,                                  /* lineNo */
  87,                                  /* colNo */
  "refBuffer",                         /* aName */
  "uhbmi_CleanMotionArtifacts",        /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo f_emlrtBCI = { -1,  /* iFirst */
  -1,                                  /* iLast */
  92,                                  /* lineNo */
  71,                                  /* colNo */
  "refBuffer",                         /* aName */
  "uhbmi_CleanMotionArtifacts",        /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo g_emlrtBCI = { -1,  /* iFirst */
  -1,                                  /* iLast */
  92,                                  /* lineNo */
  69,                                  /* colNo */
  "refBuffer",                         /* aName */
  "uhbmi_CleanMotionArtifacts",        /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m",/* pName */
  0                                    /* checkKind */
};

static emlrtRTEInfo bb_emlrtRTEI = { 90,/* lineNo */
  27,                                  /* colNo */
  "uhbmi_CleanMotionArtifacts",        /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m"/* pName */
};

static emlrtRTEInfo cb_emlrtRTEI = { 89,/* lineNo */
  23,                                  /* colNo */
  "uhbmi_CleanMotionArtifacts",        /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m"/* pName */
};

static emlrtECInfo e_emlrtECI = { -1,  /* nDims */
  84,                                  /* lineNo */
  13,                                  /* colNo */
  "uhbmi_CleanMotionArtifacts",        /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m"/* pName */
};

static emlrtBCInfo h_emlrtBCI = { -1,  /* iFirst */
  -1,                                  /* iLast */
  84,                                  /* lineNo */
  27,                                  /* colNo */
  "refBuffer",                         /* aName */
  "uhbmi_CleanMotionArtifacts",        /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo i_emlrtBCI = { -1,  /* iFirst */
  -1,                                  /* iLast */
  84,                                  /* lineNo */
  63,                                  /* colNo */
  "refBuffer",                         /* aName */
  "uhbmi_CleanMotionArtifacts",        /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo j_emlrtBCI = { -1,  /* iFirst */
  -1,                                  /* iLast */
  84,                                  /* lineNo */
  55,                                  /* colNo */
  "refBuffer",                         /* aName */
  "uhbmi_CleanMotionArtifacts",        /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m",/* pName */
  0                                    /* checkKind */
};

static emlrtDCInfo emlrtDCI = { 39,    /* lineNo */
  43,                                  /* colNo */
  "uhbmi_CleanMotionArtifacts",        /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m",/* pName */
  1                                    /* checkKind */
};

static emlrtDCInfo b_emlrtDCI = { 39,  /* lineNo */
  43,                                  /* colNo */
  "uhbmi_CleanMotionArtifacts",        /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m",/* pName */
  4                                    /* checkKind */
};

static emlrtDCInfo c_emlrtDCI = { 45,  /* lineNo */
  28,                                  /* colNo */
  "uhbmi_CleanMotionArtifacts",        /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m",/* pName */
  1                                    /* checkKind */
};

static emlrtDCInfo d_emlrtDCI = { 45,  /* lineNo */
  28,                                  /* colNo */
  "uhbmi_CleanMotionArtifacts",        /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m",/* pName */
  4                                    /* checkKind */
};

static emlrtDCInfo e_emlrtDCI = { 45,  /* lineNo */
  40,                                  /* colNo */
  "uhbmi_CleanMotionArtifacts",        /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m",/* pName */
  1                                    /* checkKind */
};

static emlrtDCInfo f_emlrtDCI = { 45,  /* lineNo */
  40,                                  /* colNo */
  "uhbmi_CleanMotionArtifacts",        /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m",/* pName */
  4                                    /* checkKind */
};

static emlrtDCInfo g_emlrtDCI = { 49,  /* lineNo */
  30,                                  /* colNo */
  "uhbmi_CleanMotionArtifacts",        /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m",/* pName */
  1                                    /* checkKind */
};

static emlrtDCInfo h_emlrtDCI = { 86,  /* lineNo */
  59,                                  /* colNo */
  "uhbmi_CleanMotionArtifacts",        /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m",/* pName */
  1                                    /* checkKind */
};

static emlrtDCInfo i_emlrtDCI = { 86,  /* lineNo */
  59,                                  /* colNo */
  "uhbmi_CleanMotionArtifacts",        /* fName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m",/* pName */
  4                                    /* checkKind */
};

static emlrtRSInfo ae_emlrtRSI = { 40, /* lineNo */
  "uhbmi_CleanMotionArtifacts",        /* fcnName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m"/* pathName */
};

static emlrtRSInfo be_emlrtRSI = { 43, /* lineNo */
  "uhbmi_CleanMotionArtifacts",        /* fcnName */
  "\\\\bmi-nas-01\\Contreras-UH2\\MotionArtifactCodes\\SourceCode\\Generic\\uhbmi_CleanMotionArtifacts.m"/* pathName */
};

/* Function Declarations */
static const mxArray *b_emlrt_marshallOut(const emlrtStack *sp, const char_T u
  [24]);
static void disp(const emlrtStack *sp, const mxArray *b, emlrtMCInfo *location);
static const mxArray *emlrt_marshallOut(const emlrtStack *sp, const char_T u[28]);

/* Function Definitions */
static const mxArray *b_emlrt_marshallOut(const emlrtStack *sp, const char_T u
  [24])
{
  const mxArray *y;
  const mxArray *m7;
  static const int32_T iv23[2] = { 1, 24 };

  y = NULL;
  m7 = emlrtCreateCharArray(2, iv23);
  emlrtInitCharArrayR2013a(sp, 24, m7, &u[0]);
  emlrtAssign(&y, m7);
  return y;
}

static void disp(const emlrtStack *sp, const mxArray *b, emlrtMCInfo *location)
{
  const mxArray *pArray;
  pArray = b;
  emlrtCallMATLABR2012b(sp, 0, NULL, 1, &pArray, "disp", true, location);
}

static const mxArray *emlrt_marshallOut(const emlrtStack *sp, const char_T u[28])
{
  const mxArray *y;
  const mxArray *m6;
  static const int32_T iv22[2] = { 1, 28 };

  y = NULL;
  m6 = emlrtCreateCharArray(2, iv22);
  emlrtInitCharArrayR2013a(sp, 28, m6, &u[0]);
  emlrtAssign(&y, m6);
  return y;
}

void REF_not_empty_init(void)
{
}

void XnnBPFilter_not_empty_init(void)
{
}

void cleanData_not_empty_init(void)
{
}

void isFirstLoop_not_empty_init(void)
{
  isFirstLoop_not_empty = false;
}

void isLinear_not_empty_init(void)
{
}

void uhbmi_CleanMotionArtifacts(const emlrtStack *sp, const real_T inDataEEG[64],
  const real_T inDataRef[3], real_T b_gamma, real_T q, real_T numTaps, const
  real_T A[48], const real_T B[12], const real_T C[12], const real_T D[3],
  real_T outData[64])
{
  boolean_T b0;
  real_T numHinfRefs;
  int32_T isLinear;
  emxArray_int32_T *r0;
  emxArray_int32_T *r1;
  emxArray_real_T *b;
  int32_T i;
  real_T dv0[12];
  int32_T J;
  int32_T i0;
  emxArray_real_T *volterraCrossTerms;
  emxArray_real_T *volterraRef;
  real_T dv1[3];
  int32_T i1;
  emxArray_real_T *r2;
  emxArray_real_T *varargin_1;
  emxArray_real_T *varargin_2;
  emxArray_real_T *b_volterraRef;
  emxArray_real_T *r3;
  static const char_T cv0[24] = { 'U', 'H', 'B', 'M', 'I', ':', ' ', 'L', 'i',
    'n', 'e', 'a', 'r', ' ', 'D', 'e', '-', 'N', 'o', 'i', 's', 'i', 'n', 'g' };

  real_T indat[64];
  int32_T loop_ub;
  static const char_T cv1[28] = { 'U', 'H', 'B', 'M', 'I', ':', ' ', 'N', 'o',
    'n', '-', 'L', 'i', 'n', 'e', 'a', 'r', ' ', 'D', 'e', '-', 'N', 'o', 'i',
    's', 'i', 'n', 'g' };

  int32_T b_loop_ub;
  int32_T b_J;
  int32_T iv0[2];
  real_T dv2[64];
  real_T unusedU0[64];
  real_T y;
  int32_T iv1[2];
  int32_T iv2[2];
  uint32_T numLoop;
  int32_T iv3[2];
  boolean_T b1;
  int32_T iv4[1];
  int32_T iv5[1];
  int32_T result;
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
  b0 = false;

  /*  This code is based on "VHINF_v004.m" */
  /*  Persistent Variables */
  /*  initializations */
  /*  From Input */
  /*  Other */
  if (numTaps > 1.0) {
    st.site = &emlrtRSI;
    if (2.0 > numTaps) {
      b_st.site = &i_emlrtRSI;
      error(&b_st);
    } else {
      if (!(numTaps <= 9.007199254740992E+15)) {
        emlrtErrorWithMessageIdR2012b(&st, &ab_emlrtRTEI,
          "MATLAB:nchoosek:NOutOfRange", 0);
      }

      b_st.site = &j_emlrtRSI;
      numHinfRefs = nCk(&b_st, numTaps, 2.0);
    }

    numHinfRefs = 3.0 * (numHinfRefs + 2.0 * numTaps);
    isLinear = 0;
  } else if (numTaps == 1.0) {
    st.site = &b_emlrtRSI;
    b_st.site = &j_emlrtRSI;
    numHinfRefs = nCk(&b_st, 1.0, 1.0);
    numHinfRefs = 3.0 * (numHinfRefs + 1.0);
    isLinear = 0;
  } else {
    numHinfRefs = 3.0;
    isLinear = 1;
  }

  emxInit_int32_T(sp, &r0, 1, &d_emlrtRTEI, true);
  emxInit_int32_T(sp, &r1, 1, &d_emlrtRTEI, true);
  emxInit_real_T1(sp, &b, 2, &d_emlrtRTEI, true);
  if (!isFirstLoop_not_empty) {
    isFirstLoop_not_empty = true;
    memset(&XnnBPFilter[0], 0, 36U * sizeof(real_T));
    memset(&cleanData[0], 0, 192U * sizeof(real_T));
    st.site = &c_emlrtRSI;
    if (!(isLinear != 0)) {
      i0 = refBuffer->size[0] * refBuffer->size[1] * refBuffer->size[2];
      refBuffer->size[0] = 3;
      if (!(numTaps >= 0.0)) {
        emlrtNonNegativeCheckR2012b(numTaps, &b_emlrtDCI, sp);
      }

      if (numTaps != (int32_T)muDoubleScalarFloor(numTaps)) {
        emlrtIntegerCheckR2012b(numTaps, &emlrtDCI, sp);
      }

      refBuffer->size[1] = (int32_T)numTaps;
      refBuffer->size[2] = 3;
      emxEnsureCapacity(sp, (emxArray__common *)refBuffer, i0, (int32_T)sizeof
                        (real_T), &d_emlrtRTEI);
      if (!(numTaps >= 0.0)) {
        emlrtNonNegativeCheckR2012b(numTaps, &b_emlrtDCI, sp);
      }

      if (numTaps != (int32_T)muDoubleScalarFloor(numTaps)) {
        emlrtIntegerCheckR2012b(numTaps, &emlrtDCI, sp);
      }

      loop_ub = 3 * (int32_T)numTaps * 3;
      for (i0 = 0; i0 < loop_ub; i0++) {
        refBuffer->data[i0] = 0.0;
      }

      st.site = &ae_emlrtRSI;
      disp(&st, emlrt_marshallOut(&st, cv1), &b_emlrtMCI);
    } else {
      i0 = refBuffer->size[0] * refBuffer->size[1] * refBuffer->size[2];
      refBuffer->size[0] = 3;
      refBuffer->size[1] = 1;
      refBuffer->size[2] = 1;
      emxEnsureCapacity(sp, (emxArray__common *)refBuffer, i0, (int32_T)sizeof
                        (real_T), &d_emlrtRTEI);
      for (i0 = 0; i0 < 3; i0++) {
        refBuffer->data[i0] = 0.0;
      }

      st.site = &be_emlrtRSI;
      disp(&st, b_emlrt_marshallOut(&st, cv0), &emlrtMCI);
    }

    i0 = PtHinf->size[0] * PtHinf->size[1] * PtHinf->size[2];
    if (!(numHinfRefs >= 0.0)) {
      emlrtNonNegativeCheckR2012b(numHinfRefs, &d_emlrtDCI, sp);
    }

    if (numHinfRefs != (int32_T)muDoubleScalarFloor(numHinfRefs)) {
      emlrtIntegerCheckR2012b(numHinfRefs, &c_emlrtDCI, sp);
    }

    PtHinf->size[0] = (int32_T)numHinfRefs;
    if (!(numHinfRefs >= 0.0)) {
      emlrtNonNegativeCheckR2012b(numHinfRefs, &f_emlrtDCI, sp);
    }

    if (numHinfRefs != (int32_T)muDoubleScalarFloor(numHinfRefs)) {
      emlrtIntegerCheckR2012b(numHinfRefs, &e_emlrtDCI, sp);
    }

    PtHinf->size[1] = (int32_T)numHinfRefs;
    PtHinf->size[2] = 3;
    emxEnsureCapacity(sp, (emxArray__common *)PtHinf, i0, (int32_T)sizeof(real_T),
                      &d_emlrtRTEI);
    if (!(numHinfRefs >= 0.0)) {
      emlrtNonNegativeCheckR2012b(numHinfRefs, &d_emlrtDCI, sp);
    }

    if (numHinfRefs != (int32_T)muDoubleScalarFloor(numHinfRefs)) {
      emlrtIntegerCheckR2012b(numHinfRefs, &c_emlrtDCI, sp);
    }

    if (!(numHinfRefs >= 0.0)) {
      emlrtNonNegativeCheckR2012b(numHinfRefs, &f_emlrtDCI, sp);
    }

    if (numHinfRefs != (int32_T)muDoubleScalarFloor(numHinfRefs)) {
      emlrtIntegerCheckR2012b(numHinfRefs, &e_emlrtDCI, sp);
    }

    loop_ub = (int32_T)numHinfRefs * (int32_T)numHinfRefs * 3;
    for (i0 = 0; i0 < loop_ub; i0++) {
      PtHinf->data[i0] = 0.0;
    }

    i = 0;
    while (i < 3) {
      loop_ub = PtHinf->size[0];
      i0 = r0->size[0];
      r0->size[0] = loop_ub;
      emxEnsureCapacity(sp, (emxArray__common *)r0, i0, (int32_T)sizeof(int32_T),
                        &d_emlrtRTEI);
      for (i0 = 0; i0 < loop_ub; i0++) {
        r0->data[i0] = i0;
      }

      loop_ub = PtHinf->size[1];
      i0 = r1->size[0];
      r1->size[0] = loop_ub;
      emxEnsureCapacity(sp, (emxArray__common *)r1, i0, (int32_T)sizeof(int32_T),
                        &d_emlrtRTEI);
      for (i0 = 0; i0 < loop_ub; i0++) {
        r1->data[i0] = i0;
      }

      st.site = &d_emlrtRSI;
      eye(&st, numHinfRefs, b);
      i0 = b->size[0] * b->size[1];
      emxEnsureCapacity(sp, (emxArray__common *)b, i0, (int32_T)sizeof(real_T),
                        &d_emlrtRTEI);
      b_loop_ub = b->size[0];
      loop_ub = b->size[1];
      loop_ub *= b_loop_ub;
      for (i0 = 0; i0 < loop_ub; i0++) {
        b->data[i0] *= 0.1;
      }

      iv1[0] = r0->size[0];
      iv1[1] = r1->size[0];
      emlrtSubAssignSizeCheckR2012b(iv1, 2, *(int32_T (*)[2])b->size, 2,
        &c_emlrtECI, sp);
      loop_ub = b->size[1];
      for (i0 = 0; i0 < loop_ub; i0++) {
        b_loop_ub = b->size[0];
        for (i1 = 0; i1 < b_loop_ub; i1++) {
          PtHinf->data[(r0->data[i1] + PtHinf->size[0] * r1->data[i0]) +
            PtHinf->size[0] * PtHinf->size[1] * i] = b->data[i1 + b->size[0] *
            i0];
        }
      }

      i++;
      if (*emlrtBreakCheckR2012bFlagVar != 0) {
        emlrtBreakCheckR2012b(sp);
      }
    }

    i0 = whHinf->size[0] * whHinf->size[1] * whHinf->size[2];
    if (numHinfRefs != (int32_T)muDoubleScalarFloor(numHinfRefs)) {
      emlrtIntegerCheckR2012b(numHinfRefs, &g_emlrtDCI, sp);
    }

    whHinf->size[0] = (int32_T)numHinfRefs;
    whHinf->size[1] = 64;
    whHinf->size[2] = 3;
    emxEnsureCapacity(sp, (emxArray__common *)whHinf, i0, (int32_T)sizeof(real_T),
                      &d_emlrtRTEI);
    if (numHinfRefs != (int32_T)muDoubleScalarFloor(numHinfRefs)) {
      emlrtIntegerCheckR2012b(numHinfRefs, &g_emlrtDCI, sp);
    }

    loop_ub = ((int32_T)numHinfRefs << 6) * 3;
    for (i0 = 0; i0 < loop_ub; i0++) {
      whHinf->data[i0] = 0.0;
    }

    memset(&REF[0], 0, 9U * sizeof(real_T));
  }

  /*  decompose reference into frequencies */
  i = 0;
  while (i < 3) {
    for (i0 = 0; i0 < 3; i0++) {
      for (i1 = 0; i1 < 4; i1++) {
        dv0[i1 + (i0 << 2)] = XnnBPFilter[(i1 + (i0 << 2)) + 12 * i];
      }
    }

    uhbmi_StateSpaceFilter(sp, inDataRef, *(real_T (*)[16])&A[i << 4], *(real_T
      (*)[4])&B[i << 2], *(real_T (*)[4])&C[i << 2], D[i], dv0, dv1);
    for (i0 = 0; i0 < 3; i0++) {
      REF[i0 + 3 * i] = dv1[i0];
      for (i1 = 0; i1 < 4; i1++) {
        XnnBPFilter[(i1 + (i0 << 2)) + 12 * i] = dv0[i1 + (i0 << 2)];
      }
    }

    i++;
    if (*emlrtBreakCheckR2012bFlagVar != 0) {
      emlrtBreakCheckR2012b(sp);
    }
  }

  /*  Form Volterra Representation of reference and Clean using Hinf */
  J = 0;
  emxInit_real_T1(sp, &volterraCrossTerms, 2, &e_emlrtRTEI, true);
  emxInit_real_T1(sp, &volterraRef, 2, &f_emlrtRTEI, true);
  emxInit_real_T1(sp, &r2, 2, &d_emlrtRTEI, true);
  emxInit_real_T1(sp, &varargin_1, 2, &d_emlrtRTEI, true);
  emxInit_real_T1(sp, &varargin_2, 2, &d_emlrtRTEI, true);
  emxInit_real_T1(sp, &b_volterraRef, 2, &d_emlrtRTEI, true);
  emxInit_real_T1(sp, &r3, 2, &d_emlrtRTEI, true);
  while (J < 3) {
    /*  for each target frequency */
    if (J + 1 == 1) {
      memcpy(&indat[0], &inDataEEG[0], sizeof(real_T) << 6);
    } else {
      memcpy(&indat[0], &cleanData[(J << 6) + -64], sizeof(real_T) << 6);
    }

    /*  for each time point */
    /*         %% Volterra Expansion of reference data */
    st.site = &e_emlrtRSI;
    if (!(isLinear != 0)) {
      if (1.0 > (real_T)refBuffer->size[1] - 1.0) {
        loop_ub = -1;
      } else {
        i0 = refBuffer->size[1];
        if (!(1 <= i0)) {
          emlrtDynamicBoundsCheckR2012b(1, 1, i0, &j_emlrtBCI, sp);
        }

        i0 = refBuffer->size[1];
        i1 = (int32_T)((real_T)refBuffer->size[1] - 1.0);
        if (!((i1 >= 1) && (i1 <= i0))) {
          emlrtDynamicBoundsCheckR2012b(i1, 1, i0, &j_emlrtBCI, sp);
        }

        loop_ub = i1 - 1;
      }

      b_loop_ub = refBuffer->size[1];
      i0 = r0->size[0];
      r0->size[0] = b_loop_ub;
      emxEnsureCapacity(sp, (emxArray__common *)r0, i0, (int32_T)sizeof(int32_T),
                        &d_emlrtRTEI);
      for (i0 = 0; i0 < b_loop_ub; i0++) {
        r0->data[i0] = i0;
      }

      i0 = refBuffer->size[2];
      if (!(J + 1 <= i0)) {
        emlrtDynamicBoundsCheckR2012b(J + 1, 1, i0, &h_emlrtBCI, sp);
      }

      i0 = refBuffer->size[2];
      if (!(J + 1 <= i0)) {
        emlrtDynamicBoundsCheckR2012b(J + 1, 1, i0, &i_emlrtBCI, sp);
      }

      b_J = J + 1;
      i0 = varargin_1->size[0] * varargin_1->size[1];
      varargin_1->size[0] = 3;
      varargin_1->size[1] = loop_ub + 2;
      emxEnsureCapacity(sp, (emxArray__common *)varargin_1, i0, (int32_T)sizeof
                        (real_T), &d_emlrtRTEI);
      for (i0 = 0; i0 < 3; i0++) {
        varargin_1->data[i0] = REF[i0 + 3 * J];
      }

      for (i0 = 0; i0 <= loop_ub; i0++) {
        for (i1 = 0; i1 < 3; i1++) {
          varargin_1->data[i1 + varargin_1->size[0] * (i0 + 1)] =
            refBuffer->data[(i1 + refBuffer->size[0] * i0) + refBuffer->size[0] *
            refBuffer->size[1] * (b_J - 1)];
        }
      }

      iv0[0] = 3;
      iv0[1] = r0->size[0];
      emlrtSubAssignSizeCheckR2012b(iv0, 2, *(int32_T (*)[2])varargin_1->size, 2,
        &e_emlrtECI, sp);
      loop_ub = varargin_1->size[1];
      for (i0 = 0; i0 < loop_ub; i0++) {
        for (i1 = 0; i1 < 3; i1++) {
          refBuffer->data[(i1 + refBuffer->size[0] * r0->data[i0]) +
            refBuffer->size[0] * refBuffer->size[1] * J] = varargin_1->data[i1 +
            varargin_1->size[0] * i0];
        }
      }

      if (numTaps > 1.0) {
        st.site = &f_emlrtRSI;
        if (2.0 > numTaps) {
          b_st.site = &i_emlrtRSI;
          error(&b_st);
        } else {
          if (!(numTaps <= 9.007199254740992E+15)) {
            emlrtErrorWithMessageIdR2012b(&st, &ab_emlrtRTEI,
              "MATLAB:nchoosek:NOutOfRange", 0);
          }

          b_st.site = &j_emlrtRSI;
          y = nCk(&b_st, numTaps, 2.0);
        }

        i0 = volterraCrossTerms->size[0] * volterraCrossTerms->size[1];
        volterraCrossTerms->size[0] = 3;
        if (!(y >= 0.0)) {
          emlrtNonNegativeCheckR2012b(y, &i_emlrtDCI, sp);
        }

        if (y != (int32_T)muDoubleScalarFloor(y)) {
          emlrtIntegerCheckR2012b(y, &h_emlrtDCI, sp);
        }

        volterraCrossTerms->size[1] = (int32_T)y;
        emxEnsureCapacity(sp, (emxArray__common *)volterraCrossTerms, i0,
                          (int32_T)sizeof(real_T), &d_emlrtRTEI);
        if (!(y >= 0.0)) {
          emlrtNonNegativeCheckR2012b(y, &i_emlrtDCI, sp);
        }

        if (y != (int32_T)muDoubleScalarFloor(y)) {
          emlrtIntegerCheckR2012b(y, &h_emlrtDCI, sp);
        }

        loop_ub = 3 * (int32_T)y;
        for (i0 = 0; i0 < loop_ub; i0++) {
          volterraCrossTerms->data[i0] = 0.0;
        }

        /* Generating Cross-terms */
        numLoop = 0U;
        emlrtForLoopVectorCheckR2012b(1.0, 1.0, numTaps - 1.0, mxDOUBLE_CLASS,
          (int32_T)(numTaps - 1.0), &cb_emlrtRTEI, sp);
        b_loop_ub = 0;
        while (b_loop_ub <= (int32_T)(numTaps - 1.0) - 1) {
          numHinfRefs = numTaps - (1.0 + (real_T)b_loop_ub);
          emlrtForLoopVectorCheckR2012b(1.0, 1.0, numHinfRefs, mxDOUBLE_CLASS,
            (int32_T)numHinfRefs, &bb_emlrtRTEI, sp);
          loop_ub = 0;
          while (loop_ub <= (int32_T)numHinfRefs - 1) {
            numLoop++;
            i0 = volterraCrossTerms->size[1];
            i1 = (int32_T)numLoop;
            if (!((i1 >= 1) && (i1 <= i0))) {
              emlrtDynamicBoundsCheckR2012b(i1, 1, i0, &emlrtBCI, sp);
            }

            if (!b0) {
              iv4[0] = 3;
              iv5[0] = 3;
              b0 = true;
            }

            emlrtSubAssignSizeCheckR2012b(iv4, 1, iv5, 1, &d_emlrtECI, sp);
            i0 = refBuffer->size[2];
            if (!(J + 1 <= i0)) {
              emlrtDynamicBoundsCheckR2012b(J + 1, 1, i0, &f_emlrtBCI, sp);
            }

            b_J = J + 1;
            i0 = refBuffer->size[1];
            if (!((loop_ub + 1 >= 1) && (loop_ub + 1 <= i0))) {
              emlrtDynamicBoundsCheckR2012b(loop_ub + 1, 1, i0, &g_emlrtBCI, sp);
            }

            i = loop_ub + 1;
            i0 = refBuffer->size[2];
            if (!(J + 1 <= i0)) {
              emlrtDynamicBoundsCheckR2012b(J + 1, 1, i0, &d_emlrtBCI, sp);
            }

            result = J + 1;
            i0 = refBuffer->size[1];
            i1 = (int32_T)((1.0 + (real_T)loop_ub) + (1.0 + (real_T)b_loop_ub));
            if (!((i1 >= 1) && (i1 <= i0))) {
              emlrtDynamicBoundsCheckR2012b(i1, 1, i0, &e_emlrtBCI, sp);
            }

            for (i0 = 0; i0 < 3; i0++) {
              volterraCrossTerms->data[i0 + volterraCrossTerms->size[0] *
                ((int32_T)numLoop - 1)] = refBuffer->data[(i0 + refBuffer->size
                [0] * (i - 1)) + refBuffer->size[0] * refBuffer->size[1] * (b_J
                - 1)] * refBuffer->data[(i0 + refBuffer->size[0] * (i1 - 1)) +
                refBuffer->size[0] * refBuffer->size[1] * (result - 1)];
            }

            loop_ub++;
            if (*emlrtBreakCheckR2012bFlagVar != 0) {
              emlrtBreakCheckR2012b(sp);
            }
          }

          b_loop_ub++;
          if (*emlrtBreakCheckR2012bFlagVar != 0) {
            emlrtBreakCheckR2012b(sp);
          }
        }
      } else {
        i0 = volterraCrossTerms->size[0] * volterraCrossTerms->size[1];
        volterraCrossTerms->size[0] = 0;
        volterraCrossTerms->size[1] = 0;
        emxEnsureCapacity(sp, (emxArray__common *)volterraCrossTerms, i0,
                          (int32_T)sizeof(real_T), &d_emlrtRTEI);
      }

      /*  Final Contents of after Volterra Expansion */
      loop_ub = refBuffer->size[1];
      i0 = refBuffer->size[2];
      if (!(J + 1 <= i0)) {
        emlrtDynamicBoundsCheckR2012b(J + 1, 1, i0, &c_emlrtBCI, sp);
      }

      b_J = J + 1;
      i0 = varargin_1->size[0] * varargin_1->size[1];
      varargin_1->size[0] = 3;
      varargin_1->size[1] = loop_ub;
      emxEnsureCapacity(sp, (emxArray__common *)varargin_1, i0, (int32_T)sizeof
                        (real_T), &d_emlrtRTEI);
      for (i0 = 0; i0 < loop_ub; i0++) {
        for (i1 = 0; i1 < 3; i1++) {
          varargin_1->data[i1 + varargin_1->size[0] * i0] = refBuffer->data[(i1
            + refBuffer->size[0] * i0) + refBuffer->size[0] * refBuffer->size[1]
            * (b_J - 1)];
        }
      }

      loop_ub = refBuffer->size[1];
      i0 = refBuffer->size[2];
      if (!(J + 1 <= i0)) {
        emlrtDynamicBoundsCheckR2012b(J + 1, 1, i0, &b_emlrtBCI, sp);
      }

      b_J = J + 1;
      i0 = r3->size[0] * r3->size[1];
      r3->size[0] = 3;
      r3->size[1] = loop_ub;
      emxEnsureCapacity(sp, (emxArray__common *)r3, i0, (int32_T)sizeof(real_T),
                        &d_emlrtRTEI);
      for (i0 = 0; i0 < loop_ub; i0++) {
        for (i1 = 0; i1 < 3; i1++) {
          r3->data[i1 + r3->size[0] * i0] = refBuffer->data[(i1 +
            refBuffer->size[0] * i0) + refBuffer->size[0] * refBuffer->size[1] *
            (b_J - 1)];
        }
      }

      st.site = &g_emlrtRSI;
      power(&st, r3, varargin_2);
      st.site = &g_emlrtRSI;
      b_st.site = &s_emlrtRSI;
      if (!(varargin_1->size[1] == 0)) {
        b_loop_ub = 3;
      } else if (!(varargin_2->size[1] == 0)) {
        b_loop_ub = 3;
      } else if (!((volterraCrossTerms->size[0] == 0) ||
                   (volterraCrossTerms->size[1] == 0))) {
        b_loop_ub = volterraCrossTerms->size[0];
      } else {
        b_loop_ub = 3;
      }

      c_st.site = &t_emlrtRSI;
      if ((3 == b_loop_ub) || (varargin_1->size[1] == 0)) {
        b1 = true;
      } else {
        b1 = false;
      }

      if (!b1) {
        emlrtErrorWithMessageIdR2012b(&c_st, &y_emlrtRTEI,
          "MATLAB:catenate:matrixDimensionMismatch", 0);
      }

      if ((3 == b_loop_ub) || (varargin_2->size[1] == 0)) {
      } else {
        b1 = false;
      }

      if (!b1) {
        emlrtErrorWithMessageIdR2012b(&c_st, &y_emlrtRTEI,
          "MATLAB:catenate:matrixDimensionMismatch", 0);
      }

      if ((b_loop_ub == volterraCrossTerms->size[0]) ||
          ((volterraCrossTerms->size[0] == 0) || (volterraCrossTerms->size[1] ==
            0))) {
      } else {
        b1 = false;
      }

      if (!b1) {
        emlrtErrorWithMessageIdR2012b(&c_st, &y_emlrtRTEI,
          "MATLAB:catenate:matrixDimensionMismatch", 0);
      }

      if (!(varargin_1->size[1] == 0)) {
        loop_ub = varargin_1->size[1];
      } else {
        loop_ub = 0;
      }

      if (!(varargin_2->size[1] == 0)) {
        i = varargin_2->size[1];
      } else {
        i = 0;
      }

      if (!((volterraCrossTerms->size[0] == 0) || (volterraCrossTerms->size[1] ==
            0))) {
        result = volterraCrossTerms->size[1];
      } else {
        result = 0;
      }

      i0 = volterraRef->size[0] * volterraRef->size[1];
      volterraRef->size[0] = b_loop_ub;
      volterraRef->size[1] = (loop_ub + i) + result;
      emxEnsureCapacity(&b_st, (emxArray__common *)volterraRef, i0, (int32_T)
                        sizeof(real_T), &d_emlrtRTEI);
      for (i0 = 0; i0 < loop_ub; i0++) {
        for (i1 = 0; i1 < b_loop_ub; i1++) {
          volterraRef->data[i1 + volterraRef->size[0] * i0] = varargin_1->
            data[i1 + b_loop_ub * i0];
        }
      }

      for (i0 = 0; i0 < i; i0++) {
        for (i1 = 0; i1 < b_loop_ub; i1++) {
          volterraRef->data[i1 + volterraRef->size[0] * (i0 + loop_ub)] =
            varargin_2->data[i1 + b_loop_ub * i0];
        }
      }

      for (i0 = 0; i0 < result; i0++) {
        for (i1 = 0; i1 < b_loop_ub; i1++) {
          volterraRef->data[i1 + volterraRef->size[0] * ((i0 + loop_ub) + i)] =
            volterraCrossTerms->data[i1 + b_loop_ub * i0];
        }
      }
    } else {
      i0 = volterraRef->size[0] * volterraRef->size[1];
      volterraRef->size[0] = 3;
      volterraRef->size[1] = 1;
      emxEnsureCapacity(sp, (emxArray__common *)volterraRef, i0, (int32_T)sizeof
                        (real_T), &d_emlrtRTEI);
      for (i0 = 0; i0 < 3; i0++) {
        volterraRef->data[i0] = inDataRef[i0];
      }
    }

    /*         %% HINF FILTERING */
    loop_ub = PtHinf->size[0];
    b_loop_ub = PtHinf->size[1];
    i0 = b->size[0] * b->size[1];
    b->size[0] = loop_ub;
    b->size[1] = b_loop_ub;
    emxEnsureCapacity(sp, (emxArray__common *)b, i0, (int32_T)sizeof(real_T),
                      &d_emlrtRTEI);
    for (i0 = 0; i0 < b_loop_ub; i0++) {
      for (i1 = 0; i1 < loop_ub; i1++) {
        b->data[i1 + b->size[0] * i0] = PtHinf->data[(i1 + PtHinf->size[0] * i0)
          + PtHinf->size[0] * PtHinf->size[1] * J];
      }
    }

    loop_ub = whHinf->size[0];
    i0 = r2->size[0] * r2->size[1];
    r2->size[0] = loop_ub;
    r2->size[1] = 64;
    emxEnsureCapacity(sp, (emxArray__common *)r2, i0, (int32_T)sizeof(real_T),
                      &d_emlrtRTEI);
    for (i0 = 0; i0 < 64; i0++) {
      for (i1 = 0; i1 < loop_ub; i1++) {
        r2->data[i1 + r2->size[0] * i0] = whHinf->data[(i1 + whHinf->size[0] *
          i0) + whHinf->size[0] * whHinf->size[1] * J];
      }
    }

    b_loop_ub = volterraRef->size[0] * volterraRef->size[1];
    i0 = b_volterraRef->size[0] * b_volterraRef->size[1];
    b_volterraRef->size[0] = 1;
    b_volterraRef->size[1] = b_loop_ub;
    emxEnsureCapacity(sp, (emxArray__common *)b_volterraRef, i0, (int32_T)sizeof
                      (real_T), &d_emlrtRTEI);
    for (i0 = 0; i0 < b_loop_ub; i0++) {
      b_volterraRef->data[b_volterraRef->size[0] * i0] = volterraRef->data[i0];
    }

    st.site = &h_emlrtRSI;
    uhbmi_HinfFilter(&st, indat, b_volterraRef, b_gamma, b, r2, q, dv2, unusedU0);
    memcpy(&cleanData[J << 6], &dv2[0], sizeof(real_T) << 6);
    loop_ub = PtHinf->size[0];
    i0 = r0->size[0];
    r0->size[0] = loop_ub;
    emxEnsureCapacity(sp, (emxArray__common *)r0, i0, (int32_T)sizeof(int32_T),
                      &d_emlrtRTEI);
    for (i0 = 0; i0 < loop_ub; i0++) {
      r0->data[i0] = i0;
    }

    loop_ub = PtHinf->size[1];
    i0 = r1->size[0];
    r1->size[0] = loop_ub;
    emxEnsureCapacity(sp, (emxArray__common *)r1, i0, (int32_T)sizeof(int32_T),
                      &d_emlrtRTEI);
    for (i0 = 0; i0 < loop_ub; i0++) {
      r1->data[i0] = i0;
    }

    iv2[0] = r0->size[0];
    iv2[1] = r1->size[0];
    emlrtSubAssignSizeCheckR2012b(iv2, 2, *(int32_T (*)[2])b->size, 2,
      &b_emlrtECI, sp);
    loop_ub = b->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      b_loop_ub = b->size[0];
      for (i1 = 0; i1 < b_loop_ub; i1++) {
        PtHinf->data[(r0->data[i1] + PtHinf->size[0] * r1->data[i0]) +
          PtHinf->size[0] * PtHinf->size[1] * J] = b->data[i1 + b->size[0] * i0];
      }
    }

    loop_ub = whHinf->size[0];
    i0 = r0->size[0];
    r0->size[0] = loop_ub;
    emxEnsureCapacity(sp, (emxArray__common *)r0, i0, (int32_T)sizeof(int32_T),
                      &d_emlrtRTEI);
    for (i0 = 0; i0 < loop_ub; i0++) {
      r0->data[i0] = i0;
    }

    iv3[0] = r0->size[0];
    iv3[1] = 64;
    emlrtSubAssignSizeCheckR2012b(iv3, 2, *(int32_T (*)[2])r2->size, 2,
      &emlrtECI, sp);
    for (i0 = 0; i0 < 64; i0++) {
      loop_ub = r2->size[0];
      for (i1 = 0; i1 < loop_ub; i1++) {
        whHinf->data[(r0->data[i1] + whHinf->size[0] * i0) + whHinf->size[0] *
          whHinf->size[1] * J] = r2->data[i1 + r2->size[0] * i0];
      }
    }

    /* [H,~,Pt1,wh1]   = HinfFilter_COP_v1_PRT_RT_Motion_mex(indat(i,:), Vv, gamma, Pt1, wh1, q); */
    J++;
    if (*emlrtBreakCheckR2012bFlagVar != 0) {
      emlrtBreakCheckR2012b(sp);
    }
  }

  emxFree_real_T(&r3);
  emxFree_real_T(&b_volterraRef);
  emxFree_real_T(&b);
  emxFree_real_T(&varargin_2);
  emxFree_real_T(&varargin_1);
  emxFree_int32_T(&r1);
  emxFree_int32_T(&r0);
  emxFree_real_T(&r2);
  emxFree_real_T(&volterraRef);
  emxFree_real_T(&volterraCrossTerms);

  /*  Output */
  memcpy(&outData[0], &cleanData[128], sizeof(real_T) << 6);
  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

void uhbmi_CleanMotionArtifacts_free(void)
{
  emxFree_real_T(&whHinf);
  emxFree_real_T(&PtHinf);
  emxFree_real_T(&refBuffer);
}

void uhbmi_CleanMotionArtifacts_init(const emlrtStack *sp)
{
  emxInit_real_T(sp, &whHinf, 3, &emlrtRTEI, false);
  emxInit_real_T(sp, &PtHinf, 3, &b_emlrtRTEI, false);
  emxInit_real_T(sp, &refBuffer, 3, &c_emlrtRTEI, false);
}

/* End of code generation (uhbmi_CleanMotionArtifacts.c) */
