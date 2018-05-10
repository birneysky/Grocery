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
#  define BN_BITS4        32
#  define BN_BITS2        64
#  define BN_BITS         128
#  define BN_MASK2        (0xffffffffffffffffL)
#  define BN_MASK2l       (0xffffffffL)
#  define BN_MASK2h       (0xffffffff00000000L)
#  define BN_TBIT         (0x8000000000000000L)
#else
typedef unsigned int BN_ULONG;
#  define BN_BYTES        4
#  define BN_BITS4        16
#  define BN_BITS2        32
#  define BN_BITS         64
#  define BN_MASK2        (0xffffffffL)
#  define BN_MASK2l       (0xffff)
#  define BN_MASK2h       (0xffff0000L)
#  define BN_TBIT         (0x80000000L)
#endif

#define BN_FLG_MALLOCED        0x01
#define BN_FLG_STATIC_DATA    0x02
#define BN_FLG_FREE        0x8000
#define BN_FLG_CONSTTIME    0x04



typedef struct bignum_st BIGNUM;
typedef struct bignum_ctx BN_CTX;
typedef struct bn_mont_ctx_st BN_MONT_CTX;

int RAND_pseudo_bytes(unsigned char *buf, int num);

BIGNUM *BN_copy(BIGNUM *a, const BIGNUM *b);
int    BN_ucmp(const BIGNUM *a, const BIGNUM *b);
int BN_div(BIGNUM *dv, BIGNUM *rm, const BIGNUM *num, const BIGNUM *divisor,
           BN_CTX *ctx);
int BN_num_bits(const BIGNUM *a);
int BN_set_word(BIGNUM *a, BN_ULONG w);
BN_ULONG bn_sub_words(BN_ULONG *r, const BN_ULONG *a, const BN_ULONG *b, int n);
int BN_sub_word(BIGNUM *a, BN_ULONG w);
BIGNUM *bn_expand2(BIGNUM *b, int words);
void    BN_CTX_start(BN_CTX *ctx);
BIGNUM *BN_CTX_get(BN_CTX *ctx);
int BN_mask_bits(BIGNUM *a, int n);
void BN_MONT_CTX_free(BN_MONT_CTX *mont);
int BN_mod_exp_mont_consttime(BIGNUM *rr, const BIGNUM *a, const BIGNUM *p,
                              const BIGNUM *m, BN_CTX *ctx,
                              BN_MONT_CTX *in_mont);
const BIGNUM *BN_value_one(void);
int BN_mod_exp_recp(BIGNUM *r, const BIGNUM *a, const BIGNUM *p,
                    const BIGNUM *m, BN_CTX *ctx);

BN_MONT_CTX *BN_MONT_CTX_new(void );

# define BN_abs_is_word(a,w) ((((a)->top == 1) && ((a)->d[0] == (BN_ULONG)(w))) || \
                            (((w) == 0) && ((a)->top == 0)))
#define bn_wexpand(a,words) (((words) <= (a)->dmax)?(a):bn_expand2((a),(words)))
#define BN_get_flags(b,n)       ((b)->flags&(n))
#define BN_is_odd(a)        (((a)->top > 0) && ((a)->d[0] & 1))
#define BN_num_bytes(a)    ((BN_num_bits(a)+7)/8)
#define BN_is_zero(a)       ((a)->top == 0)
#define BN_one(a)    (BN_set_word((a),1))
#define BN_zero(a)      BN_zero_ex(a)
#define BN_mod(rem,m,d,ctx) BN_div(NULL,(rem),(m),(d),(ctx))
#define BN_is_one(a)        (BN_abs_is_word((a),1) && !(a)->neg)
#define BN_is_word(a,w)     (BN_abs_is_word((a),(w)) && (!(w) || !(a)->neg))

#define LBITS(a)    ((a)&BN_MASK2l)
#define HBITS(a)    (((a)>>BN_BITS4)&BN_MASK2l)

# define BN_zero_ex(a) \
    do { \
        BIGNUM *_tmp_bn = (a); \
        _tmp_bn->top = 0; \
        _tmp_bn->neg = 0; \
    } while(0)

# define bn_expand(a,bits) \
( \
    bits > (INT_MAX - BN_BITS2 + 1) ? \
    NULL \
    : \
    (((bits+BN_BITS2-1)/BN_BITS2) <= (a)->dmax) ? \
    (a) \
    : \
    bn_expand2((a),(bits+BN_BITS2-1)/BN_BITS2) \
)

# define bn_pollute(a) \
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

# define bn_correct_top(a) \
{ \
    BN_ULONG *ftl; \
    int tmp_top = (a)->top; \
    if (tmp_top > 0) \
    { \
        for (ftl= &((a)->d[tmp_top-1]); tmp_top > 0; tmp_top--) \
        if (*(ftl--)) break; \
        (a)->top = tmp_top; \
    } \
    bn_pollute(a); \
}


# define BN_with_flags(dest,b,n)  ((dest)->d=(b)->d, \
    (dest)->top=(b)->top, \
    (dest)->dmax=(b)->dmax, \
    (dest)->neg=(b)->neg, \
    (dest)->flags=(((dest)->flags & BN_FLG_MALLOCED) \
    |  ((b)->flags & ~BN_FLG_MALLOCED) \
    |  BN_FLG_STATIC_DATA \
    |  (n)))


#ifdef DEBUG
#define bn_clear_top2max(a) \
{ \
int      ind = (a)->dmax - (a)->top; \
BN_ULONG *ftl = &(a)->d[(a)->top-1]; \
for (; ind != 0; ind--) \
*(++ftl) = 0x0; \
}
#else
#define bn_clear_top2max(a)
#endif


#ifdef BN_LLONG
#define mul_add(r,a,w,c) { \
BN_ULLONG t; \
t=(BN_ULLONG)w * (a) + (r) + (c); \
(r)= Lw(t); \
(c)= Hw(t); \
}

#define mul(r,a,w,c) { \
BN_ULLONG t; \
t=(BN_ULLONG)w * (a) + (c); \
(r)= Lw(t); \
(c)= Hw(t); \
}

#define sqr(r0,r1,a) { \
BN_ULLONG t; \
t=(BN_ULLONG)(a)*(a); \
(r0)=Lw(t); \
(r1)=Hw(t); \
}

#elif defined(BN_UMULT_LOHI)
#define mul_add(r,a,w,c) {        \
BN_ULONG high,low,ret,tmp=(a);    \
ret =  (r);            \
BN_UMULT_LOHI(low,high,w,tmp);    \
ret += (c);            \
(c) =  (ret<(c))?1:0;        \
(c) += high;            \
ret += low;            \
(c) += (ret<low)?1:0;        \
(r) =  ret;            \
}

#define mul(r,a,w,c)    {        \
BN_ULONG high,low,ret,ta=(a);    \
BN_UMULT_LOHI(low,high,w,ta);    \
ret =  low + (c);        \
(c) =  high;            \
(c) += (ret<low)?1:0;        \
(r) =  ret;            \
}

#define sqr(r0,r1,a)    {        \
BN_ULONG tmp=(a);        \
BN_UMULT_LOHI(r0,r1,tmp,tmp);    \
}

#elif defined(BN_UMULT_HIGH)
#define mul_add(r,a,w,c) {        \
BN_ULONG high,low,ret,tmp=(a);    \
ret =  (r);            \
high=  BN_UMULT_HIGH(w,tmp);    \
ret += (c);            \
low =  (w) * tmp;        \
(c) =  (ret<(c))?1:0;        \
(c) += high;            \
ret += low;            \
(c) += (ret<low)?1:0;        \
(r) =  ret;            \
}

#define mul(r,a,w,c)    {        \
BN_ULONG high,low,ret,ta=(a);    \
low =  (w) * ta;        \
high=  BN_UMULT_HIGH(w,ta);    \
ret =  low + (c);        \
(c) =  high;            \
(c) += (ret<low)?1:0;        \
(r) =  ret;            \
}

#define sqr(r0,r1,a)    {        \
BN_ULONG tmp=(a);        \
(r0) = tmp * tmp;        \
(r1) = BN_UMULT_HIGH(tmp,tmp);    \
}

#else
/*************************************************************
 * No long long type
 */

#define LBITS(a)    ((a)&BN_MASK2l)
#define HBITS(a)    (((a)>>BN_BITS4)&BN_MASK2l)
#define    L2HBITS(a)    (((a)<<BN_BITS4)&BN_MASK2)

#define LLBITS(a)    ((a)&BN_MASKl)
#define LHBITS(a)    (((a)>>BN_BITS2)&BN_MASKl)
#define    LL2HBITS(a)    ((BN_ULLONG)((a)&BN_MASKl)<<BN_BITS2)

#define mul64(l,h,bl,bh) \
{ \
BN_ULONG m,m1,lt,ht; \
\
lt=l; \
ht=h; \
m =(bh)*(lt); \
lt=(bl)*(lt); \
m1=(bl)*(ht); \
ht =(bh)*(ht); \
m=(m+m1)&BN_MASK2; if (m < m1) ht+=L2HBITS((BN_ULONG)1); \
ht+=HBITS(m); \
m1=L2HBITS(m); \
lt=(lt+m1)&BN_MASK2; if (lt < m1) ht++; \
(l)=lt; \
(h)=ht; \
}

#define sqr64(lo,ho,in) \
{ \
BN_ULONG l,h,m; \
\
h=(in); \
l=LBITS(h); \
h=HBITS(h); \
m =(l)*(h); \
l*=l; \
h*=h; \
h+=(m&BN_MASK2h1)>>(BN_BITS4-1); \
m =(m&BN_MASK2l)<<(BN_BITS4+1); \
l=(l+m)&BN_MASK2; if (l < m) h++; \
(lo)=l; \
(ho)=h; \
}

#define mul_add(r,a,bl,bh,c) { \
BN_ULONG l,h; \
\
h= (a); \
l=LBITS(h); \
h=HBITS(h); \
mul64(l,h,(bl),(bh)); \
\
/* non-multiply part */ \
l=(l+(c))&BN_MASK2; if (l < (c)) h++; \
(c)=(r); \
l=(l+(c))&BN_MASK2; if (l < (c)) h++; \
(c)=h&BN_MASK2; \
(r)=l; \
}

#define mul(r,a,bl,bh,c) { \
BN_ULONG l,h; \
\
h= (a); \
l=LBITS(h); \
h=HBITS(h); \
mul64(l,h,(bl),(bh)); \
\
/* non-multiply part */ \
l+=(c); if ((l&BN_MASK2) < (c)) h++; \
(c)=h&BN_MASK2; \
(r)=l&BN_MASK2; \
}
#endif /* !BN_LLONG */

#if defined(OPENSSL_DOING_MAKEDEPEND) && defined(OPENSSL_FIPS)
#undef bn_div_words
#endif


int BN_mod_mul_montgomery(BIGNUM *r, const BIGNUM *a, const BIGNUM *b,
                          BN_MONT_CTX *mont, BN_CTX *ctx);
# define BN_to_montgomery(r,a,mont,ctx)  BN_mod_mul_montgomery(\
(r),(a),&((mont)->RR),(mont),(ctx))

#if 1
#define BN_window_bits_for_exponent_size(b) \
((b) > 671 ? 6 : \
(b) > 239 ? 5 : \
(b) >  79 ? 4 : \
(b) >  23 ? 3 : 1)
#else
/* Old SSLeay/OpenSSL table.
 * Maximum window size was 5, so this table differs for b==1024;
 * but it coincides for other interesting values (b==160, b==512).
 */
#define BN_window_bits_for_exponent_size(b) \
((b) > 255 ? 5 : \
(b) > 127 ? 4 : \
(b) >  17 ? 3 : 1)
#endif     


#endif /* rce_bn_h */
