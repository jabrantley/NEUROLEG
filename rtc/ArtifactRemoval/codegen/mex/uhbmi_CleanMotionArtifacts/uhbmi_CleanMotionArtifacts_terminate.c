/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * uhbmi_CleanMotionArtifacts_terminate.c
 *
 * Code generation for function 'uhbmi_CleanMotionArtifacts_terminate'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "uhbmi_CleanMotionArtifacts.h"
#include "uhbmi_CleanMotionArtifacts_terminate.h"
#include "_coder_uhbmi_CleanMotionArtifacts_mex.h"
#include "uhbmi_CleanMotionArtifacts_data.h"

/* Function Definitions */
void uhbmi_CleanMotionArtifacts_atexit(void)
{
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  mexFunctionCreateRootTLS();
  st.tls = emlrtRootTLSGlobal;
  emlrtEnterRtStackR2012b(&st);
  uhbmi_CleanMotionArtifacts_free();
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

void uhbmi_CleanMotionArtifacts_terminate(void)
{
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  st.tls = emlrtRootTLSGlobal;
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

/* End of code generation (uhbmi_CleanMotionArtifacts_terminate.c) */
