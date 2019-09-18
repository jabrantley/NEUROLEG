/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * uhbmi_CleanMotionArtifacts_initialize.c
 *
 * Code generation for function 'uhbmi_CleanMotionArtifacts_initialize'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "uhbmi_CleanMotionArtifacts.h"
#include "uhbmi_CleanMotionArtifacts_initialize.h"
#include "_coder_uhbmi_CleanMotionArtifacts_mex.h"
#include "uhbmi_CleanMotionArtifacts_data.h"

/* Function Declarations */
static void uhbmi_CleanMotionArtifacts_once(const emlrtStack *sp);

/* Function Definitions */
static void uhbmi_CleanMotionArtifacts_once(const emlrtStack *sp)
{
  emlrtStack st;
  st.prev = sp;
  st.tls = sp->tls;
  isLinear_not_empty_init();
  REF_not_empty_init();
  cleanData_not_empty_init();
  XnnBPFilter_not_empty_init();
  isFirstLoop_not_empty_init();
  st.site = NULL;
  uhbmi_CleanMotionArtifacts_init(&st);
}

void uhbmi_CleanMotionArtifacts_initialize(void)
{
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  mexFunctionCreateRootTLS();
  emlrtBreakCheckR2012bFlagVar = emlrtGetBreakCheckFlagAddressR2012b();
  st.tls = emlrtRootTLSGlobal;
  emlrtClearAllocCountR2012b(&st, false, 0U, 0);
  emlrtEnterRtStackR2012b(&st);
  if (emlrtFirstTimeR2012b(emlrtRootTLSGlobal)) {
    uhbmi_CleanMotionArtifacts_once(&st);
  }
}

/* End of code generation (uhbmi_CleanMotionArtifacts_initialize.c) */
