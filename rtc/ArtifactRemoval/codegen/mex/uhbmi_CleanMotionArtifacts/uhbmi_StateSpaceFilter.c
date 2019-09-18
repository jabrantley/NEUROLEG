/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * uhbmi_StateSpaceFilter.c
 *
 * Code generation for function 'uhbmi_StateSpaceFilter'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "uhbmi_CleanMotionArtifacts.h"
#include "uhbmi_StateSpaceFilter.h"
#include "uhbmi_CleanMotionArtifacts_data.h"

/* Function Definitions */
void uhbmi_StateSpaceFilter(const emlrtStack *sp, const real_T inData[3], const
  real_T A[16], const real_T B[4], const real_T C[4], real_T D, real_T Xnn[12],
  real_T Yn[3])
{
  int32_T ti;
  real_T y;
  int32_T k;
  real_T b_A[4];
  int32_T i7;
  ti = 0;
  while (ti < 3) {
    y = 0.0;
    for (k = 0; k < 4; k++) {
      y += C[k] * Xnn[k + (ti << 2)];
    }

    Yn[ti] = y + D * inData[ti];
    for (k = 0; k < 4; k++) {
      y = 0.0;
      for (i7 = 0; i7 < 4; i7++) {
        y += A[k + (i7 << 2)] * Xnn[i7 + (ti << 2)];
      }

      b_A[k] = y + B[k] * inData[ti];
    }

    for (k = 0; k < 4; k++) {
      Xnn[k + (ti << 2)] = b_A[k];
    }

    ti++;
    if (*emlrtBreakCheckR2012bFlagVar != 0) {
      emlrtBreakCheckR2012b(sp);
    }
  }
}

/* End of code generation (uhbmi_StateSpaceFilter.c) */
