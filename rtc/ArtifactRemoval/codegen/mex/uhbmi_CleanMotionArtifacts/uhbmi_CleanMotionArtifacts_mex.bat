@echo off
set MATLAB=C:\PROGRA~1\MATLAB\R2016b
set MATLAB_ARCH=win64
set MATLAB_BIN="C:\Program Files\MATLAB\R2016b\bin"
set ENTRYPOINT=mexFunction
set OUTDIR=.\
set LIB_NAME=uhbmi_CleanMotionArtifacts_mex
set MEX_NAME=uhbmi_CleanMotionArtifacts_mex
set MEX_EXT=.mexw64
call setEnv.bat
echo # Make settings for uhbmi_CleanMotionArtifacts > uhbmi_CleanMotionArtifacts_mex.mki
echo COMPILER=%COMPILER%>> uhbmi_CleanMotionArtifacts_mex.mki
echo COMPFLAGS=%COMPFLAGS%>> uhbmi_CleanMotionArtifacts_mex.mki
echo OPTIMFLAGS=%OPTIMFLAGS%>> uhbmi_CleanMotionArtifacts_mex.mki
echo DEBUGFLAGS=%DEBUGFLAGS%>> uhbmi_CleanMotionArtifacts_mex.mki
echo LINKER=%LINKER%>> uhbmi_CleanMotionArtifacts_mex.mki
echo LINKFLAGS=%LINKFLAGS%>> uhbmi_CleanMotionArtifacts_mex.mki
echo LINKOPTIMFLAGS=%LINKOPTIMFLAGS%>> uhbmi_CleanMotionArtifacts_mex.mki
echo LINKDEBUGFLAGS=%LINKDEBUGFLAGS%>> uhbmi_CleanMotionArtifacts_mex.mki
echo MATLAB_ARCH=%MATLAB_ARCH%>> uhbmi_CleanMotionArtifacts_mex.mki
echo BORLAND=%BORLAND%>> uhbmi_CleanMotionArtifacts_mex.mki
echo OMPFLAGS=/openmp >> uhbmi_CleanMotionArtifacts_mex.mki
echo OMPLINKFLAGS=/nodefaultlib:vcomp /LIBPATH:"C:\PROGRA~1\MATLAB\R2016b\bin\win64" >> uhbmi_CleanMotionArtifacts_mex.mki
echo EMC_COMPILER=msvc110>> uhbmi_CleanMotionArtifacts_mex.mki
echo EMC_CONFIG=optim>> uhbmi_CleanMotionArtifacts_mex.mki
"C:\Program Files\MATLAB\R2016b\bin\win64\gmake" -B -f uhbmi_CleanMotionArtifacts_mex.mk
