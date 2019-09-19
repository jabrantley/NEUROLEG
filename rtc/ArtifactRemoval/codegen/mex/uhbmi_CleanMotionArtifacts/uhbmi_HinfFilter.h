/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * uhbmi_HinfFilter.h
 *
 * Code generation for function 'uhbmi_HinfFilter'
 *
 */

#ifndef UHBMI_HINFFILTER_H
#define UHBMI_HINFFILTER_H

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
extern void uhbmi_HinfFilter(const emlrtStack *sp, const real_T Yf[64], const
  emxArray_real_T *Rf, real_T b_gamma, emxArray_real_T *Pt, emxArray_real_T *wh,
  real_T q, real_T sh[64], real_T zh[64]);

#endif

/* End of code generation (uhbmi_HinfFilter.h) */
