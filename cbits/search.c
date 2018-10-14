#include <stdint.h>

//#define MKW128(a,b) \
//  ((unsigned __int128)a << 64) + (unsigned __int128)b;

int multiplier = 8;
int offset = 11;

int64_t esearch(uint64_t search_a, uint64_t search_b, uint64_t *a, uint64_t *b, int64_t n) {
   int64_t i = 0;
   //unsigned __int128 v = MKW128(search_a,search_b);
   while (i < n) {
     //__builtin_prefetch(a+(multiplier*i+offset));
     //__builtin_prefetch(b+(multiplier*i+offset));
     i = (search_a > a[i])
	    ? (2*i+2)
	    : ((search_a != a[i])
	       ? (2*i+1)
	       : ((search_b <= b[i]) ? (2*i+1) : (2*i+2)));
     // unsigned __int128 w = MKW128(a[i],b[i]);
     // i = (v <= w) ? (2*i+1) : (2*i+2);
   }

   int64_t j = (i+1) >> __builtin_ffs(~(i+1));

   if (j==0) {
      return (-1);
   } else {
      return (search_a == a[j-1] && search_b == b[j-1])
	      ? (j-1)
	      : (-1);
   }
}
