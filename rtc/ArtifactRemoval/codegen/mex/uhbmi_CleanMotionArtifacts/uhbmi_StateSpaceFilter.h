/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * uhbmi_StateSpaceFilter.h
 *
 * Code generation for function 'uhbmi_StateSpaceFilter'
 *
 */

#ifndef UHBMI_STATESPACEFILTER_H
#define UHBMI_STATESPACEFILTER_H

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
extern void uhbmi_StateSpaceFilter(const emlrtStack *sp, const real_T inData[3],
  const real_T A[16], const real_T B[4], const real_T C[4], real_T D, real_T
  Xnn[12], real_T Yn[3]);

#endif

/* End of code generation (uhbmi_StateSpaceFilter.h) */
