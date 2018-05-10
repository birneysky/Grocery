//
//  rce_bn.h
//  DH
//
//  Created by birney on 2018/5/10.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#ifndef rce_bn_h
#define rce_bn_h

#include <stdio.h>
#include <assert.h>

#if __LP64__ || (TARGET_OS_EMBEDDED && !TARGET_OS_IPHONE) || TARGET_OS_WIN32 || NS_BUILD_32_LIKE_64
typedef unsigned long BN_ULONG;
#  define BN_BYTES        8
#  define BN_BITS2        64
#else
typedef unsigned int BN_ULONG;
#  define BN_BYTES        4
#  define BN_BITS2        32
#endif

#define BN_FLG_MALLOCED        0x01
#define BN_FLG_STATIC_DATA    0x02
#define BN_FLG_FREE        0x8000
# define bn_wexpand(a,words) (((words) <= (a)->dmax)?(a):bn_expand2((a),(words)))
# define BN_get_flags(b,n)       ((b)->flags&(n))

typedef struct bignum_st BIGNUM;
typedef struct bignum_ctx BN_CTX;
int RAND_pseudo_bytes(unsigned char *buf, int num);

#   define bn_pollute(a) \
do { \
const BIGNUM *_bnum1 = (a); \
if(_bnum1->top < _bnum1->dmax) { \
unsigned char _tmp_char; \
/* We cast away const without the compiler knowing, any \
* *genuinely* constant variables that aren't mutable \
* wouldn't be constructed with top!=dmax. */ \
BN_ULONG *_not_const; \
memcpy(&_not_const, &_bnum1->d, sizeof(BN_ULONG*)); \
/* Debug only - safe to ignore error return */ \
RAND_pseudo_bytes(&_tmp_char, 1); \
memset((unsigned char *)(_not_const + _bnum1->top), _tmp_char, \
(_bnum1->dmax - _bnum1->top) * sizeof(BN_ULONG)); \
} \
} while(0)

#  define bn_check_top(a) \
do { \
const BIGNUM *_bnum2 = (a); \
if (_bnum2 != NULL) { \
assert((_bnum2->top == 0) || \
(_bnum2->d[_bnum2->top - 1] != 0)); \
bn_pollute(_bnum2); \
} \
} while(0)

#endif /* rce_bn_h */
