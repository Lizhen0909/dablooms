 /* ligra.i */
 
 %module cdablooms
 
 %{
 /* Put header files here or function declarations like below */
#include "murmur.h"
#include "dablooms.h"
 %}
//%include "stdint.i" 
typedef  long long       uint64_t;
typedef  long long       uint32_t;
%include "murmur.h"
%include "dablooms.h"
