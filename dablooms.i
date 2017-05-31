 /* ligra.i */
 
 %module cdablooms
 
 %{
 /* Put header files here or function declarations like below */
#include "murmur.h"
#include "dablooms.h"
 %}


typedef  long long       uint64_t;
typedef  long long       uint32_t;

%typemap(jtype) (bytearray_t a) "byte[]";
%typemap(jstype) (bytearray_t a) "byte[]";
%typemap(jni) (bytearray_t a) "jbyteArray";
%typemap(javain) (bytearray_t a) "$javainput";

%typemap(in,numinputs=1) (bytearray_t a) {
  char* a = JCALL2(GetByteArrayElements, jenv, $input, NULL);
  const size_t sz = JCALL1(GetArrayLength, jenv, $input);
  $1 = (bytearray_t) {sz,a};
}

%typemap(freearg) (bytearray_t a) {
  // Or use  0 instead of ABORT to keep changes if it was a copy
  JCALL3(ReleaseByteArrayElements, jenv, $input, $1.array, JNI_ABORT);
}

%include "murmur.h"
%include "dablooms.h"
