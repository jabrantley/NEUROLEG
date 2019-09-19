/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * nchoosek.h
 *
 * Code generation for function 'nchoosek'
 *
 */

#ifndef NCHOOSEK_H
#define NCHOOSEK_H

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
extern real_T nCk(const emlrtStack *sp, real_T n, real_T k);

#ifdef __WATCOMC__

#pragma aux nCk value [8087];

#endif
#endif

/* End of code generation (nchoosek.h) */
