/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * lusolve.h
 *
 * Code generation for function 'lusolve'
 *
 */

#ifndef LUSOLVE_H
#define LUSOLVE_H

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
extern void lusolve(const emlrtStack *sp, const emxArray_real_T *A, const
                    emxArray_real_T *B, emxArray_real_T *X);

#endif

/* End of code generation (lusolve.h) */
