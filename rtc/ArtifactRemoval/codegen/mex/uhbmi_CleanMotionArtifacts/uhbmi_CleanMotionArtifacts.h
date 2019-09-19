/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * uhbmi_CleanMotionArtifacts.h
 *
 * Code generation for function 'uhbmi_CleanMotionArtifacts'
 *
 */

#ifndef UHBMI_CLEANMOTIONARTIFACTS_H
#define UHBMI_CLEANMOTIONARTIFACTS_H

/* Include files */
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "mwmathutil.h"
#include "tmwtypes.h"
#include "mex.h"
#include "emlrt.h"
#include "rtwtypes.h"
#include "omp.h"
#include "uhbmi_CleanMotionArtifacts_types.h"

/* Function Declarations */
extern void REF_not_empty_init(void);
extern void XnnBPFilter_not_empty_init(void);
extern void cleanData_not_empty_init(void);
extern void isFirstLoop_not_empty_init(void);
extern void isLinear_not_empty_init(void);
extern void uhbmi_CleanMotionArtifacts(const emlrtStack *sp, const real_T
  inDataEEG[64], const real_T inDataRef[3], real_T b_gamma, real_T q, real_T
  numTaps, const real_T A[48], const real_T B[12], const real_T C[12], const
  real_T D[3], real_T outData[64]);
extern void uhbmi_CleanMotionArtifacts_free(void);
extern void uhbmi_CleanMotionArtifacts_init(const emlrtStack *sp);

#endif

/* End of code generation (uhbmi_CleanMotionArtifacts.h) */
