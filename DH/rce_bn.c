//
//  rce_bn.c
//  DH
//
//  Created by birney on 2018/5/10.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#include "rce_bn.h"
#include <stdlib.h>
#include <limits.h>
#include <string.h>

#define BN_CTX_POOL_SIZE    16
#define BN_CTX_START_FRAMES    32

struct bignum_st {
    BN_ULONG *d;                /* Pointer to an array of 'BN_BITS2' bit
                                 * chunks. */
    int top;                    /* Index of last used d +1. */
    /* The next are internal book keeping for bn_expand. */
    int dmax;                   /* Size of the d array. */
    int neg;                    /* one if the number is negative */
    int flags;
};

typedef struct bignum_st BIGNUM;

/* A bundle of bignums that can be linked with other bundles */
typedef struct bignum_pool_item
{
    /* The bignum values */
    BIGNUM vals[BN_CTX_POOL_SIZE];
    /* Linked-list admin */
    struct bignum_pool_item *prev, *next;
} BN_POOL_ITEM;

typedef struct bignum_pool
{
    /* Linked-list admin */
    BN_POOL_ITEM *head, *current, *tail;
    /* Stack depth and allocation size */
    unsigned used, size;
} BN_POOL;
static void        BN_POOL_init(BN_POOL *);
static void BN_POOL_release(BN_POOL *p, unsigned int num);

/************/
/* BN_STACK */
/************/

/* A wrapper to manage the "stack frames" */
typedef struct bignum_ctx_stack
{
    /* Array of indexes into the bignum stack */
    unsigned int *indexes;
    /* Number of stack frames, and the size of the allocated array */
    unsigned int depth, size;
} BN_STACK;

static void BN_STACK_init(BN_STACK *);
static int  BN_STACK_push(BN_STACK *st, unsigned int idx);
static unsigned int BN_STACK_pop(BN_STACK *st);

/* The opaque BN_CTX type */
struct bignum_ctx
{
    /* The bignum bundles */
    BN_POOL pool;
    /* The "stack frames", if you will */
    BN_STACK stack;
    /* The number of bignums currently assigned */
    unsigned int used;
    /* Depth of stack overflow */
    int err_stack;
    /* Block "gets" until an "end" (compatibility behaviour) */
    int too_many;
    };

/* Used for montgomery multiplication */
struct bn_mont_ctx_st {
    int ri;                     /* number of bits in R */
    BIGNUM RR;                  /* used to convert to montgomery form */
    BIGNUM N;                   /* The modulus */
    BIGNUM Ni;                  /* R*(1/R mod N) - N*Ni = 1 (Ni is only
                                 * stored for bignum algorithm) */
    BN_ULONG n0[2];             /* least significant word(s) of Ni; (type
                                 * changed with 0.9.9, was "BN_ULONG n0;"
                                 * before) */
    int flags;
};



BN_CTX *BN_CTX_new(void)
{
    BN_CTX *ret = malloc(sizeof(BN_CTX));
    if(!ret)
    {
        //BNerr(BN_F_BN_CTX_NEW,ERR_R_MALLOC_FAILURE);
        return NULL;
    }
    /* Initialise the structure */
    BN_POOL_init(&ret->pool);
    BN_STACK_init(&ret->stack);
    ret->used = 0;
    ret->err_stack = 0;
    ret->too_many = 0;
    return ret;
}

static void BN_POOL_init(BN_POOL *p)
{
    p->head = p->current = p->tail = NULL;
    p->used = p->size = 0;
}

static void BN_STACK_init(BN_STACK *st)
{
    st->indexes = NULL;
    st->depth = st->size = 0;
}

BIGNUM *BN_new(void)
{
    BIGNUM *ret;
    
    if ((ret=(BIGNUM *)malloc(sizeof(BIGNUM))) == NULL)
    {
        //BNerr(BN_F_BN_NEW,ERR_R_MALLOC_FAILURE);
        return(NULL);
    }
    ret->flags=BN_FLG_MALLOCED;
    ret->top=0;
    ret->neg=0;
    ret->dmax=0;
    ret->d=NULL;
    //bn_check_top(ret);
    return(ret);
}

void BN_free(BIGNUM *a)
{
    if (a == NULL) return;
    //bn_check_top(a);
    if ((a->d != NULL) && !(BN_get_flags(a,BN_FLG_STATIC_DATA)))
        free(a->d);
    if (a->flags & BN_FLG_MALLOCED)
        free(a);
    else
    {
#ifndef OPENSSL_NO_DEPRECATED
        a->flags|=BN_FLG_FREE;
#endif
        a->d = NULL;
    }
}

int BN_num_bits_word(BN_ULONG l)
{
    static const unsigned char bits[256]={
        0,1,2,2,3,3,3,3,4,4,4,4,4,4,4,4,
        5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,
        6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,
        6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,
        7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,
        7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,
        7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,
        7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,
        8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,
        8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,
        8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,
        8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,
        8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,
        8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,
        8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,
        8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,
    };
    
#if defined(SIXTY_FOUR_BIT_LONG)
    if (l & 0xffffffff00000000L)
    {
        if (l & 0xffff000000000000L)
        {
            if (l & 0xff00000000000000L)
            {
                return(bits[(int)(l>>56)]+56);
            }
            else    return(bits[(int)(l>>48)]+48);
        }
        else
        {
            if (l & 0x0000ff0000000000L)
            {
                return(bits[(int)(l>>40)]+40);
            }
            else    return(bits[(int)(l>>32)]+32);
        }
    }
    else
#else
#ifdef SIXTY_FOUR_BIT
        if (l & 0xffffffff00000000LL)
        {
            if (l & 0xffff000000000000LL)
            {
                if (l & 0xff00000000000000LL)
                {
                    return(bits[(int)(l>>56)]+56);
                }
                else    return(bits[(int)(l>>48)]+48);
            }
            else
            {
                if (l & 0x0000ff0000000000LL)
                {
                    return(bits[(int)(l>>40)]+40);
                }
                else    return(bits[(int)(l>>32)]+32);
            }
        }
        else
#endif
#endif
        {
#if defined(THIRTY_TWO_BIT) || defined(SIXTY_FOUR_BIT) || defined(SIXTY_FOUR_BIT_LONG)
            if (l & 0xffff0000L)
            {
                if (l & 0xff000000L)
                    return(bits[(int)(l>>24L)]+24);
                else    return(bits[(int)(l>>16L)]+16);
            }
            else
#endif
            {
#if defined(THIRTY_TWO_BIT) || defined(SIXTY_FOUR_BIT) || defined(SIXTY_FOUR_BIT_LONG)
                if (l & 0xff00L)
                    return(bits[(int)(l>>8)]+8);
                else
#endif
                    return(bits[(int)(l   )]  );
            }
        }
}

//int BN_num_bits(const BIGNUM *a)
//{
//    int i = a->top - 1;
//    bn_check_top(a);
//
//    if (BN_is_zero(a)) return 0;
//    return ((i*BN_BITS2) + BN_num_bits_word(a->d[i]));
//}

unsigned char cleanse_ctr = 0;

void OPENSSL_cleanse(void *ptr, size_t len)
{
    unsigned char *p = ptr;
    size_t loop = len, ctr = cleanse_ctr;
    while(loop--)
    {
        *(p++) = (unsigned char)ctr;
        ctr += (17 + ((size_t)p & 0xF));
    }
    p=memchr(ptr, (unsigned char)ctr, len);
    if(p)
        ctr += (63 + (size_t)p);
    cleanse_ctr = (unsigned char)ctr;
}

void BN_clear_free(BIGNUM *a)
{
    int i;
    
    if (a == NULL) return;
    bn_check_top(a);
    if (a->d != NULL)
    {
        OPENSSL_cleanse(a->d,a->dmax*sizeof(a->d[0]));
        if (!(BN_get_flags(a,BN_FLG_STATIC_DATA)))
            free(a->d);
    }
    i=BN_get_flags(a,BN_FLG_MALLOCED);
    OPENSSL_cleanse(a,sizeof(BIGNUM));
    if (i)
        free(a);
}

void BN_init(BIGNUM *a)
{
    memset(a,0,sizeof(BIGNUM));
    //bn_check_top(a);
}

BIGNUM *BN_copy(BIGNUM *a, const BIGNUM *b)
{
    int i;
    BN_ULONG *A;
    const BN_ULONG *B;
    
    //bn_check_top(b);
    
    if (a == b) return(a);
    if (bn_wexpand(a,b->top) == NULL) return(NULL);
    
#if 1
    A=a->d;
    B=b->d;
    for (i=b->top>>2; i>0; i--,A+=4,B+=4)
    {
        BN_ULONG a0,a1,a2,a3;
        a0=B[0]; a1=B[1]; a2=B[2]; a3=B[3];
        A[0]=a0; A[1]=a1; A[2]=a2; A[3]=a3;
    }
    switch (b->top&3)
    {
        case 3: A[2]=B[2];
        case 2: A[1]=B[1];
        case 1: A[0]=B[0];
        case 0: ; /* ultrix cc workaround, see comments in bn_expand_internal */
    }
#else
    memcpy(a->d,b->d,sizeof(b->d[0])*b->top);
#endif
    
    a->top=b->top;
    a->neg=b->neg;
    //bn_check_top(a);
    return(a);
}

int BN_ucmp(const BIGNUM *a, const BIGNUM *b)
{
    int i;
    BN_ULONG t1,t2,*ap,*bp;
    
    bn_check_top(a);
    bn_check_top(b);
    
    i=a->top-b->top;
    if (i != 0) return(i);
    ap=a->d;
    bp=b->d;
    for (i=a->top-1; i>=0; i--)
    {
        t1= ap[i];
        t2= bp[i];
        if (t1 != t2)
            return((t1 > t2) ? 1 : -1);
    }
    return(0);
}

#ifdef BN_LLONG
BN_ULONG bn_add_words(BN_ULONG *r, const BN_ULONG *a, const BN_ULONG *b, int n)
{
    BN_ULLONG ll=0;
    
    assert(n >= 0);
    if (n <= 0) return((BN_ULONG)0);
    
#ifndef OPENSSL_SMALL_FOOTPRINT
    while (n&~3)
    {
        ll+=(BN_ULLONG)a[0]+b[0];
        r[0]=(BN_ULONG)ll&BN_MASK2;
        ll>>=BN_BITS2;
        ll+=(BN_ULLONG)a[1]+b[1];
        r[1]=(BN_ULONG)ll&BN_MASK2;
        ll>>=BN_BITS2;
        ll+=(BN_ULLONG)a[2]+b[2];
        r[2]=(BN_ULONG)ll&BN_MASK2;
        ll>>=BN_BITS2;
        ll+=(BN_ULLONG)a[3]+b[3];
        r[3]=(BN_ULONG)ll&BN_MASK2;
        ll>>=BN_BITS2;
        a+=4; b+=4; r+=4; n-=4;
    }
#endif
    while (n)
    {
        ll+=(BN_ULLONG)a[0]+b[0];
        r[0]=(BN_ULONG)ll&BN_MASK2;
        ll>>=BN_BITS2;
        a++; b++; r++; n--;
    }
    return((BN_ULONG)ll);
}
#else /* !BN_LLONG */
BN_ULONG bn_add_words(BN_ULONG *r, const BN_ULONG *a, const BN_ULONG *b, int n)
{
    BN_ULONG c,l,t;
    
    assert(n >= 0);
    if (n <= 0) return((BN_ULONG)0);
    
    c=0;
#ifndef OPENSSL_SMALL_FOOTPRINT
    while (n&~3)
    {
        t=a[0];
        t=(t+c)&BN_MASK2;
        c=(t < c);
        l=(t+b[0])&BN_MASK2;
        c+=(l < t);
        r[0]=l;
        t=a[1];
        t=(t+c)&BN_MASK2;
        c=(t < c);
        l=(t+b[1])&BN_MASK2;
        c+=(l < t);
        r[1]=l;
        t=a[2];
        t=(t+c)&BN_MASK2;
        c=(t < c);
        l=(t+b[2])&BN_MASK2;
        c+=(l < t);
        r[2]=l;
        t=a[3];
        t=(t+c)&BN_MASK2;
        c=(t < c);
        l=(t+b[3])&BN_MASK2;
        c+=(l < t);
        r[3]=l;
        a+=4; b+=4; r+=4; n-=4;
    }
#endif
    while(n)
    {
        t=a[0];
        t=(t+c)&BN_MASK2;
        c=(t < c);
        l=(t+b[0])&BN_MASK2;
        c+=(l < t);
        r[0]=l;
        a++; b++; r++; n--;
    }
    return((BN_ULONG)c);
}
#endif /* !BN_LLONG */

int BN_add_word(BIGNUM *a, BN_ULONG w)
{
    BN_ULONG l;
    int i;
    
    bn_check_top(a);
    w &= BN_MASK2;
    
    /* degenerate case: w is zero */
    if (!w) return 1;
    /* degenerate case: a is zero */
    if(BN_is_zero(a)) return BN_set_word(a, w);
    /* handle 'a' when negative */
    if (a->neg)
    {
        a->neg=0;
        i=BN_sub_word(a,w);
        if (!BN_is_zero(a))
            a->neg=!(a->neg);
        return(i);
    }
    for (i=0;w!=0 && i<a->top;i++)
    {
        a->d[i] = l = (a->d[i]+w)&BN_MASK2;
        w = (w>l)?1:0;
    }
    if (w && i==a->top)
    {
        if (bn_wexpand(a,a->top+1) == NULL) return 0;
        a->top++;
        a->d[i]=w;
    }
    bn_check_top(a);
    return(1);
}

/* unsigned add of b to a */
int BN_uadd(BIGNUM *r, const BIGNUM *a, const BIGNUM *b)
{
    int max,min,dif;
    BN_ULONG *ap,*bp,*rp,carry,t1,t2;
    const BIGNUM *tmp;
    
    bn_check_top(a);
    bn_check_top(b);
    
    if (a->top < b->top)
    { tmp=a; a=b; b=tmp; }
    max = a->top;
    min = b->top;
    dif = max - min;
    
    if (bn_wexpand(r,max+1) == NULL)
        return 0;
    
    r->top=max;
    
    
    ap=a->d;
    bp=b->d;
    rp=r->d;
    
    carry=bn_add_words(rp,ap,bp,min);
    rp+=min;
    ap+=min;
    bp+=min;
    
    if (carry)
    {
        while (dif)
        {
            dif--;
            t1 = *(ap++);
            t2 = (t1+1) & BN_MASK2;
            *(rp++) = t2;
            if (t2)
            {
                carry=0;
                break;
            }
        }
        if (carry)
        {
            /* carry != 0 => dif == 0 */
            *rp = 1;
            r->top++;
        }
    }
    if (dif && rp != ap)
        while (dif--)
        /* copy remaining words if ap != rp */
            *(rp++) = *(ap++);
    r->neg = 0;
    bn_check_top(r);
    return 1;
}

/* unsigned subtraction of b from a, a must be larger than b. */
int BN_usub(BIGNUM *r, const BIGNUM *a, const BIGNUM *b)
{
    int max,min,dif;
    register BN_ULONG t1,t2,*ap,*bp,*rp;
    int i,carry;
#if defined(IRIX_CC_BUG) && !defined(LINT)
    int dummy;
#endif
    
    bn_check_top(a);
    bn_check_top(b);
    
    max = a->top;
    min = b->top;
    dif = max - min;
    
    if (dif < 0)    /* hmm... should not be happening */
    {
        //BNerr(BN_F_BN_USUB,BN_R_ARG2_LT_ARG3);
        return(0);
    }
    
    if (bn_wexpand(r,max) == NULL) return(0);
    
    ap=a->d;
    bp=b->d;
    rp=r->d;
    
#if 1
    carry=0;
    for (i = min; i != 0; i--)
    {
        t1= *(ap++);
        t2= *(bp++);
        if (carry)
        {
            carry=(t1 <= t2);
            t1=(t1-t2-1)&BN_MASK2;
        }
        else
        {
            carry=(t1 < t2);
            t1=(t1-t2)&BN_MASK2;
        }
#if defined(IRIX_CC_BUG) && !defined(LINT)
        dummy=t1;
#endif
        *(rp++)=t1&BN_MASK2;
    }
#else
    carry=bn_sub_words(rp,ap,bp,min);
    ap+=min;
    bp+=min;
    rp+=min;
#endif
    if (carry) /* subtracted */
    {
        if (!dif)
        /* error: a < b */
            return 0;
        while (dif)
        {
            dif--;
            t1 = *(ap++);
            t2 = (t1-1)&BN_MASK2;
            *(rp++) = t2;
            if (t1)
                break;
        }
    }
#if 0
    memcpy(rp,ap,sizeof(*rp)*(max-i));
#else
    if (rp != ap)
    {
        for (;;)
        {
            if (!dif--) break;
            rp[0]=ap[0];
            if (!dif--) break;
            rp[1]=ap[1];
            if (!dif--) break;
            rp[2]=ap[2];
            if (!dif--) break;
            rp[3]=ap[3];
            rp+=4;
            ap+=4;
        }
    }
#endif
    
    r->top=max;
    r->neg=0;
    bn_correct_top(r);
    return(1);
}


int BN_add(BIGNUM *r, const BIGNUM *a, const BIGNUM *b)
{
    const BIGNUM *tmp;
    int a_neg = a->neg, ret;
    
    bn_check_top(a);
    bn_check_top(b);
    
    /*  a +  b    a+b
     *  a + -b    a-b
     * -a +  b    b-a
     * -a + -b    -(a+b)
     */
    if (a_neg ^ b->neg)
    {
        /* only one is negative */
        if (a_neg)
        { tmp=a; a=b; b=tmp; }
        
        /* we are now a - b */
        
        if (BN_ucmp(a,b) < 0)
        {
            if (!BN_usub(r,b,a)) return(0);
            r->neg=1;
        }
        else
        {
            if (!BN_usub(r,a,b)) return(0);
            r->neg=0;
        }
        return(1);
    }
    
    ret = BN_uadd(r,a,b);
    r->neg = a_neg;
    bn_check_top(r);
    return ret;
}


int BN_sub(BIGNUM *r, const BIGNUM *a, const BIGNUM *b)
{
    int max;
    int add=0,neg=0;
    const BIGNUM *tmp;
    
    bn_check_top(a);
    bn_check_top(b);
    
    /*  a -  b    a-b
     *  a - -b    a+b
     * -a -  b    -(a+b)
     * -a - -b    b-a
     */
    if (a->neg)
    {
        if (b->neg)
        { tmp=a; a=b; b=tmp; }
        else
        { add=1; neg=1; }
    }
    else
    {
        if (b->neg) { add=1; neg=0; }
    }
    
    if (add)
    {
        if (!BN_uadd(r,a,b)) return(0);
        r->neg=neg;
        return(1);
    }
    
    /* We are actually doing a - b :-) */
    
    max=(a->top > b->top)?a->top:b->top;
    if (bn_wexpand(r,max) == NULL) return(0);
    if (BN_ucmp(a,b) < 0)
    {
        if (!BN_usub(r,b,a)) return(0);
        r->neg=1;
    }
    else
    {
        if (!BN_usub(r,a,b)) return(0);
        r->neg=0;
    }
    bn_check_top(r);
    return(1);
}

BN_ULONG bn_sub_words(BN_ULONG *r, const BN_ULONG *a, const BN_ULONG *b, int n)
{
    BN_ULONG t1,t2;
    int c=0;
    
    assert(n >= 0);
    if (n <= 0) return((BN_ULONG)0);
    
#ifndef OPENSSL_SMALL_FOOTPRINT
    while (n&~3)
    {
        t1=a[0]; t2=b[0];
        r[0]=(t1-t2-c)&BN_MASK2;
        if (t1 != t2) c=(t1 < t2);
        t1=a[1]; t2=b[1];
        r[1]=(t1-t2-c)&BN_MASK2;
        if (t1 != t2) c=(t1 < t2);
        t1=a[2]; t2=b[2];
        r[2]=(t1-t2-c)&BN_MASK2;
        if (t1 != t2) c=(t1 < t2);
        t1=a[3]; t2=b[3];
        r[3]=(t1-t2-c)&BN_MASK2;
        if (t1 != t2) c=(t1 < t2);
        a+=4; b+=4; r+=4; n-=4;
    }
#endif
    while (n)
    {
        t1=a[0]; t2=b[0];
        r[0]=(t1-t2-c)&BN_MASK2;
        if (t1 != t2) c=(t1 < t2);
        a++; b++; r++; n--;
    }
    return(c);
}

void BN_set_negative(BIGNUM *a, int b)
{
    if (b && !BN_is_zero(a))
        a->neg = 1;
    else
        a->neg = 0;
}

int BN_sub_word(BIGNUM *a, BN_ULONG w)
{
    int i;
    
    bn_check_top(a);
    w &= BN_MASK2;
    
    /* degenerate case: w is zero */
    if (!w) return 1;
    /* degenerate case: a is zero */
    if(BN_is_zero(a))
    {
        i = BN_set_word(a,w);
        if (i != 0)
            BN_set_negative(a, 1);
        return i;
    }
    /* handle 'a' when negative */
    if (a->neg)
    {
        a->neg=0;
        i=BN_add_word(a,w);
        a->neg=1;
        return(i);
    }
    
    if ((a->top == 1) && (a->d[0] < w))
    {
        a->d[0]=w-a->d[0];
        a->neg=1;
        return(1);
    }
    i=0;
    for (;;)
    {
        if (a->d[i] >= w)
        {
            a->d[i]-=w;
            break;
        }
        else
        {
            a->d[i]=(a->d[i]-w)&BN_MASK2;
            i++;
            w=1;
        }
    }
    if ((a->d[i] == 0) && (i == (a->top-1)))
        a->top--;
    bn_check_top(a);
    return(1);
}

#if defined(BN_LLONG) && defined(BN_DIV2W)
BN_ULONG bn_div_words(BN_ULONG h, BN_ULONG l, BN_ULONG d)
{
    return((BN_ULONG)(((((BN_ULLONG)h)<<BN_BITS2)|l)/(BN_ULLONG)d));
}
#else
/* Divide h,l by d and return the result. */
/* I need to test this some more :-( */
BN_ULONG bn_div_words(BN_ULONG h, BN_ULONG l, BN_ULONG d)
{
    BN_ULONG dh,dl,q,ret=0,th,tl,t;
    int i,count=2;
    
    if (d == 0) return(BN_MASK2);
    
    i=BN_num_bits_word(d);
    assert((i == BN_BITS2) || (h <= (BN_ULONG)1<<i));
    
    i=BN_BITS2-i;
    if (h >= d) h-=d;
    
    if (i)
    {
        d<<=i;
        h=(h<<i)|(l>>(BN_BITS2-i));
        l<<=i;
    }
    dh=(d&BN_MASK2h)>>BN_BITS4;
    dl=(d&BN_MASK2l);
    for (;;)
    {
        if ((h>>BN_BITS4) == dh)
            q=BN_MASK2l;
        else
            q=h/dh;
        
        th=q*dh;
        tl=dl*q;
        for (;;)
        {
            t=h-th;
            if ((t&BN_MASK2h) ||
                ((tl) <= (
                          (t<<BN_BITS4)|
                          ((l&BN_MASK2h)>>BN_BITS4))))
                break;
            q--;
            th-=dh;
            tl-=dl;
        }
        t=(tl>>BN_BITS4);
        tl=(tl<<BN_BITS4)&BN_MASK2h;
        th+=t;
        
        if (l < tl) th++;
        l-=tl;
        if (h < th)
        {
            h+=d;
            q--;
        }
        h-=th;
        
        if (--count == 0) break;
        
        ret=q<<BN_BITS4;
        h=((h<<BN_BITS4)|(l>>BN_BITS4))&BN_MASK2;
        l=(l&BN_MASK2l)<<BN_BITS4;
    }
    ret|=q;
    return(ret);
}
#endif /* !defined(BN_LLONG) && defined(BN_DIV2W) */

#if defined(BN_LLONG) || defined(BN_UMULT_HIGH)

BN_ULONG bn_mul_add_words(BN_ULONG *rp, const BN_ULONG *ap, int num, BN_ULONG w)
{
    BN_ULONG c1=0;
    
    assert(num >= 0);
    if (num <= 0) return(c1);
    
#ifndef OPENSSL_SMALL_FOOTPRINT
    while (num&~3)
    {
        mul_add(rp[0],ap[0],w,c1);
        mul_add(rp[1],ap[1],w,c1);
        mul_add(rp[2],ap[2],w,c1);
        mul_add(rp[3],ap[3],w,c1);
        ap+=4; rp+=4; num-=4;
    }
#endif
    while (num)
    {
        mul_add(rp[0],ap[0],w,c1);
        ap++; rp++; num--;
    }
    
    return(c1);
}

BN_ULONG bn_mul_words(BN_ULONG *rp, const BN_ULONG *ap, int num, BN_ULONG w)
{
    BN_ULONG c1=0;
    
    assert(num >= 0);
    if (num <= 0) return(c1);
    
#ifndef OPENSSL_SMALL_FOOTPRINT
    while (num&~3)
    {
        mul(rp[0],ap[0],w,c1);
        mul(rp[1],ap[1],w,c1);
        mul(rp[2],ap[2],w,c1);
        mul(rp[3],ap[3],w,c1);
        ap+=4; rp+=4; num-=4;
    }
#endif
    while (num)
    {
        mul(rp[0],ap[0],w,c1);
        ap++; rp++; num--;
    }
    return(c1);
}
#else

BN_ULONG bn_mul_add_words(BN_ULONG *rp, const BN_ULONG *ap, int num, BN_ULONG w)
{
    BN_ULONG c=0;
    BN_ULONG bl,bh;
    
    assert(num >= 0);
    if (num <= 0) return((BN_ULONG)0);
    
    bl=LBITS(w);
    bh=HBITS(w);
    
#ifndef OPENSSL_SMALL_FOOTPRINT
    while (num&~3)
    {
        mul_add(rp[0],ap[0],bl,bh,c);
        mul_add(rp[1],ap[1],bl,bh,c);
        mul_add(rp[2],ap[2],bl,bh,c);
        mul_add(rp[3],ap[3],bl,bh,c);
        ap+=4; rp+=4; num-=4;
    }
#endif
    while (num)
    {
        mul_add(rp[0],ap[0],bl,bh,c);
        ap++; rp++; num--;
    }
    return(c);
}


BN_ULONG bn_mul_words(BN_ULONG *rp, const BN_ULONG *ap, int num, BN_ULONG w)
{
    BN_ULONG carry=0;
    BN_ULONG bl,bh;
    
    assert(num >= 0);
    if (num <= 0) return((BN_ULONG)0);
    
    bl=LBITS(w);
    bh=HBITS(w);
    
#ifndef OPENSSL_SMALL_FOOTPRINT
    while (num&~3)
    {
        mul(rp[0],ap[0],bl,bh,carry);
        mul(rp[1],ap[1],bl,bh,carry);
        mul(rp[2],ap[2],bl,bh,carry);
        mul(rp[3],ap[3],bl,bh,carry);
        ap+=4; rp+=4; num-=4;
    }
#endif
    while (num)
    {
        mul(rp[0],ap[0],bl,bh,carry);
        ap++; rp++; num--;
    }
    return(carry);
}
#endif

int BN_mul_word(BIGNUM *a, BN_ULONG w)
{
    BN_ULONG ll;
    
    bn_check_top(a);
    w&=BN_MASK2;
    if (a->top)
    {
        if (w == 0)
            BN_zero(a);
        else
        {
            ll=bn_mul_words(a->d,a->d,a->top,w);
            if (ll)
            {
                if (bn_wexpand(a,a->top+1) == NULL) return(0);
                a->d[a->top++]=ll;
            }
        }
    }
    bn_check_top(a);
    return(1);
}


int BN_nnmod(BIGNUM *r, const BIGNUM *m, const BIGNUM *d, BN_CTX *ctx)
{
    /* like BN_mod, but returns non-negative remainder
     * (i.e.,  0 <= r < |d|  always holds) */
    
    if (!(BN_mod(r,m,d,ctx)))
        return 0;
    if (!r->neg)
        return 1;
    /* now   -|d| < r < 0,  so we have to set  r := r + |d| */
    return (d->neg ? BN_sub : BN_add)(r, r, d);
}

int BN_lshift(BIGNUM *r, const BIGNUM *a, int n)
{
    int i,nw,lb,rb;
    BN_ULONG *t,*f;
    BN_ULONG l;
    
    bn_check_top(r);
    bn_check_top(a);
    
    r->neg=a->neg;
    nw=n/BN_BITS2;
    if (bn_wexpand(r,a->top+nw+1) == NULL) return(0);
    lb=n%BN_BITS2;
    rb=BN_BITS2-lb;
    f=a->d;
    t=r->d;
    t[a->top+nw]=0;
    if (lb == 0)
        for (i=a->top-1; i>=0; i--)
            t[nw+i]=f[i];
    else
        for (i=a->top-1; i>=0; i--)
        {
            l=f[i];
            t[nw+i+1]|=(l>>rb)&BN_MASK2;
            t[nw+i]=(l<<lb)&BN_MASK2;
        }
    memset(t,0,nw*sizeof(t[0]));
    /*    for (i=0; i<nw; i++)
     t[i]=0;*/
    r->top=a->top+nw+1;
    bn_correct_top(r);
    bn_check_top(r);
    return(1);
}

int BN_rshift(BIGNUM *r, const BIGNUM *a, int n)
{
    int i,j,nw,lb,rb;
    BN_ULONG *t,*f;
    BN_ULONG l,tmp;
    
    bn_check_top(r);
    bn_check_top(a);
    
    nw=n/BN_BITS2;
    rb=n%BN_BITS2;
    lb=BN_BITS2-rb;
    if (nw >= a->top || a->top == 0)
    {
        BN_zero(r);
        return(1);
    }
    i = (BN_num_bits(a)-n+(BN_BITS2-1))/BN_BITS2;
    if (r != a)
    {
        r->neg=a->neg;
        if (bn_wexpand(r,i) == NULL) return(0);
    }
    else
    {
        if (n == 0)
            return 1; /* or the copying loop will go berserk */
    }
    
    f= &(a->d[nw]);
    t=r->d;
    j=a->top-nw;
    r->top=i;
    
    if (rb == 0)
    {
        for (i=j; i != 0; i--)
            *(t++)= *(f++);
    }
    else
    {
        l= *(f++);
        for (i=j-1; i != 0; i--)
        {
            tmp =(l>>rb)&BN_MASK2;
            l= *(f++);
            *(t++) =(tmp|(l<<lb))&BN_MASK2;
        }
        if ((l = (l>>rb)&BN_MASK2)) *(t) = l;
    }
    bn_check_top(r);
    return(1);
}

int BN_rshift1(BIGNUM *r, const BIGNUM *a)
{
    BN_ULONG *ap,*rp,t,c;
    int i,j;
    
    bn_check_top(r);
    bn_check_top(a);
    
    if (BN_is_zero(a))
    {
        BN_zero(r);
        return(1);
    }
    i = a->top;
    ap= a->d;
    j = i-(ap[i-1]==1);
    if (a != r)
    {
        if (bn_wexpand(r,j) == NULL) return(0);
        r->neg=a->neg;
    }
    rp=r->d;
    t=ap[--i];
    c=(t&1)?BN_TBIT:0;
    if (t>>=1) rp[i]=t;
    while (i>0)
    {
        t=ap[--i];
        rp[i]=((t>>1)&BN_MASK2)|c;
        c=(t&1)?BN_TBIT:0;
    }
    r->top=j;
    bn_check_top(r);
    return(1);
}

int BN_lshift1(BIGNUM *r, const BIGNUM *a)
{
    register BN_ULONG *ap,*rp,t,c;
    int i;
    
    bn_check_top(r);
    bn_check_top(a);
    
    if (r != a)
    {
        r->neg=a->neg;
        if (bn_wexpand(r,a->top+1) == NULL) return(0);
        r->top=a->top;
    }
    else
    {
        if (bn_wexpand(r,a->top+1) == NULL) return(0);
    }
    ap=a->d;
    rp=r->d;
    c=0;
    for (i=0; i<a->top; i++)
    {
        t= *(ap++);
        *(rp++)=((t<<1)|c)&BN_MASK2;
        c=(t & BN_TBIT)?1:0;
    }
    if (c)
    {
        *rp=1;
        r->top++;
    }
    bn_check_top(r);
    return(1);
}


void BN_CTX_end(BN_CTX *ctx)
{
    //CTXDBG_ENTRY("BN_CTX_end", ctx);
    if(ctx->err_stack)
        ctx->err_stack--;
    else
    {
        unsigned int fp = BN_STACK_pop(&ctx->stack);
        /* Does this stack frame have anything to release? */
        if(fp < ctx->used)
            BN_POOL_release(&ctx->pool, ctx->used - fp);
        ctx->used = fp;
        /* Unjam "too_many" in case "get" had failed */
        ctx->too_many = 0;
    }
    //CTXDBG_EXIT(ctx);
}

static void BN_POOL_release(BN_POOL *p, unsigned int num)
{
    unsigned int offset = (p->used - 1) % BN_CTX_POOL_SIZE;
    p->used -= num;
    while(num--)
    {
        bn_check_top(p->current->vals + offset);
        if(!offset)
        {
            offset = BN_CTX_POOL_SIZE - 1;
            p->current = p->current->prev;
        }
        else
            offset--;
    }
}

/* BN_div computes  dv := num / divisor,  rounding towards
 * zero, and sets up rm  such that  dv*divisor + rm = num  holds.
 * Thus:
 *     dv->neg == num->neg ^ divisor->neg  (unless the result is zero)
 *     rm->neg == num->neg                 (unless the remainder is zero)
 * If 'dv' or 'rm' is NULL, the respective value is not returned.
 */
int BN_div(BIGNUM *dv, BIGNUM *rm, const BIGNUM *num, const BIGNUM *divisor,
           BN_CTX *ctx)
{
    int norm_shift,i,loop;
    BIGNUM *tmp,wnum,*snum,*sdiv,*res;
    BN_ULONG *resp,*wnump;
    BN_ULONG d0,d1;
    int num_n,div_n;
    int no_branch=0;
    
    /* Invalid zero-padding would have particularly bad consequences
     * in the case of 'num', so don't just rely on bn_check_top() for this one
     * (bn_check_top() works only for BN_DEBUG builds) */
    if (num->top > 0 && num->d[num->top - 1] == 0)
    {
        //BNerr(BN_F_BN_DIV,BN_R_NOT_INITIALIZED);
        return 0;
    }
    
    bn_check_top(num);
    
    if ((BN_get_flags(num, BN_FLG_CONSTTIME) != 0) || (BN_get_flags(divisor, BN_FLG_CONSTTIME) != 0))
    {
        no_branch=1;
    }
    
    bn_check_top(dv);
    bn_check_top(rm);
    /* bn_check_top(num); */ /* 'num' has been checked already */
    bn_check_top(divisor);
    
    if (BN_is_zero(divisor))
    {
        //BNerr(BN_F_BN_DIV,BN_R_DIV_BY_ZERO);
        return(0);
    }
    
    if (!no_branch && BN_ucmp(num,divisor) < 0)
    {
        if (rm != NULL)
        { if (BN_copy(rm,num) == NULL) return(0); }
        if (dv != NULL) BN_zero(dv);
        return(1);
    }
    
    BN_CTX_start(ctx);
    tmp=BN_CTX_get(ctx);
    snum=BN_CTX_get(ctx);
    sdiv=BN_CTX_get(ctx);
    if (dv == NULL)
        res=BN_CTX_get(ctx);
    else    res=dv;
    if (sdiv == NULL || res == NULL || tmp == NULL || snum == NULL)
        goto err;
    
    /* First we normalise the numbers */
    norm_shift=BN_BITS2-((BN_num_bits(divisor))%BN_BITS2);
    if (!(BN_lshift(sdiv,divisor,norm_shift))) goto err;
    sdiv->neg=0;
    norm_shift+=BN_BITS2;
    if (!(BN_lshift(snum,num,norm_shift))) goto err;
    snum->neg=0;
    
    if (no_branch)
    {
        /* Since we don't know whether snum is larger than sdiv,
         * we pad snum with enough zeroes without changing its
         * value.
         */
        if (snum->top <= sdiv->top+1)
        {
            if (bn_wexpand(snum, sdiv->top + 2) == NULL) goto err;
            for (i = snum->top; i < sdiv->top + 2; i++) snum->d[i] = 0;
            snum->top = sdiv->top + 2;
        }
        else
        {
            if (bn_wexpand(snum, snum->top + 1) == NULL) goto err;
            snum->d[snum->top] = 0;
            snum->top ++;
        }
    }
    
    div_n=sdiv->top;
    num_n=snum->top;
    loop=num_n-div_n;
    /* Lets setup a 'window' into snum
     * This is the part that corresponds to the current
     * 'area' being divided */
    wnum.neg   = 0;
    wnum.d     = &(snum->d[loop]);
    wnum.top   = div_n;
    /* only needed when BN_ucmp messes up the values between top and max */
    wnum.dmax  = snum->dmax - loop; /* so we don't step out of bounds */
    
    /* Get the top 2 words of sdiv */
    /* div_n=sdiv->top; */
    d0=sdiv->d[div_n-1];
    d1=(div_n == 1)?0:sdiv->d[div_n-2];
    
    /* pointer to the 'top' of snum */
    wnump= &(snum->d[num_n-1]);
    
    /* Setup to 'res' */
    res->neg= (num->neg^divisor->neg);
    if (!bn_wexpand(res,(loop+1))) goto err;
    res->top=loop-no_branch;
    resp= &(res->d[loop-1]);
    
    /* space for temp */
    if (!bn_wexpand(tmp,(div_n+1))) goto err;
    
    if (!no_branch)
    {
        if (BN_ucmp(&wnum,sdiv) >= 0)
        {
            /* If BN_DEBUG_RAND is defined BN_ucmp changes (via
             * bn_pollute) the const bignum arguments =>
             * clean the values between top and max again */
            bn_clear_top2max(&wnum);
            bn_sub_words(wnum.d, wnum.d, sdiv->d, div_n);
            *resp=1;
        }
        else
            res->top--;
    }
    
    /* if res->top == 0 then clear the neg value otherwise decrease
     * the resp pointer */
    if (res->top == 0)
        res->neg = 0;
    else
        resp--;
    
    for (i=0; i<loop-1; i++, wnump--, resp--)
    {
        BN_ULONG q,l0;
        /* the first part of the loop uses the top two words of
         * snum and sdiv to calculate a BN_ULONG q such that
         * | wnum - sdiv * q | < sdiv */
#if defined(BN_DIV3W) && !defined(OPENSSL_NO_ASM)
        BN_ULONG bn_div_3_words(BN_ULONG*,BN_ULONG,BN_ULONG);
        q=bn_div_3_words(wnump,d1,d0);
#else
        BN_ULONG n0,n1,rem=0;
        
        n0=wnump[0];
        n1=wnump[-1];
        if (n0 == d0)
            q=BN_MASK2;
        else             /* n0 < d0 */
        {
#ifdef BN_LLONG
            BN_ULLONG t2;
            
#if defined(BN_LLONG) && defined(BN_DIV2W) && !defined(bn_div_words)
            q=(BN_ULONG)(((((BN_ULLONG)n0)<<BN_BITS2)|n1)/d0);
#else
            q=bn_div_words(n0,n1,d0);
#ifdef BN_DEBUG_LEVITTE
            fprintf(stderr,"DEBUG: bn_div_words(0x%08X,0x%08X,0x%08\
                    X) -> 0x%08X\n",
                    n0, n1, d0, q);
#endif
#endif
            
#ifndef REMAINDER_IS_ALREADY_CALCULATED
            /*
             * rem doesn't have to be BN_ULLONG. The least we
             * know it's less that d0, isn't it?
             */
            rem=(n1-q*d0)&BN_MASK2;
#endif
            t2=(BN_ULLONG)d1*q;
            
            for (;;)
            {
                if (t2 <= ((((BN_ULLONG)rem)<<BN_BITS2)|wnump[-2]))
                    break;
                q--;
                rem += d0;
                if (rem < d0) break; /* don't let rem overflow */
                t2 -= d1;
            }
#else /* !BN_LLONG */
            BN_ULONG t2l,t2h;
            
            q=bn_div_words(n0,n1,d0);
#ifdef BN_DEBUG_LEVITTE
            fprintf(stderr,"DEBUG: bn_div_words(0x%08X,0x%08X,0x%08\
                    X) -> 0x%08X\n",
                    n0, n1, d0, q);
#endif
#ifndef REMAINDER_IS_ALREADY_CALCULATED
            rem=(n1-q*d0)&BN_MASK2;
#endif
            
#if defined(BN_UMULT_LOHI)
            BN_UMULT_LOHI(t2l,t2h,d1,q);
#elif defined(BN_UMULT_HIGH)
            t2l = d1 * q;
            t2h = BN_UMULT_HIGH(d1,q);
#else
            {
                BN_ULONG ql, qh;
                t2l=LBITS(d1); t2h=HBITS(d1);
                ql =LBITS(q);  qh =HBITS(q);
                mul64(t2l,t2h,ql,qh); /* t2=(BN_ULLONG)d1*q; */
            }
#endif
            
            for (;;)
            {
                if ((t2h < rem) ||
                    ((t2h == rem) && (t2l <= wnump[-2])))
                    break;
                q--;
                rem += d0;
                if (rem < d0) break; /* don't let rem overflow */
                if (t2l < d1) t2h--; t2l -= d1;
            }
#endif /* !BN_LLONG */
        }
#endif /* !BN_DIV3W */
        
        l0=bn_mul_words(tmp->d,sdiv->d,div_n,q);
        tmp->d[div_n]=l0;
        wnum.d--;
        /* ingore top values of the bignums just sub the two
         * BN_ULONG arrays with bn_sub_words */
        if (bn_sub_words(wnum.d, wnum.d, tmp->d, div_n+1))
        {
            /* Note: As we have considered only the leading
             * two BN_ULONGs in the calculation of q, sdiv * q
             * might be greater than wnum (but then (q-1) * sdiv
             * is less or equal than wnum)
             */
            q--;
            if (bn_add_words(wnum.d, wnum.d, sdiv->d, div_n))
            /* we can't have an overflow here (assuming
             * that q != 0, but if q == 0 then tmp is
             * zero anyway) */
                (*wnump)++;
        }
        /* store part of the result */
        *resp = q;
    }
    bn_correct_top(snum);
    if (rm != NULL)
    {
        /* Keep a copy of the neg flag in num because if rm==num
         * BN_rshift() will overwrite it.
         */
        int neg = num->neg;
        BN_rshift(rm,snum,norm_shift);
        if (!BN_is_zero(rm))
            rm->neg = neg;
        bn_check_top(rm);
    }
    if (no_branch)    bn_correct_top(res);
    BN_CTX_end(ctx);
    return(1);
err:
    bn_check_top(rm);
    BN_CTX_end(ctx);
    return(0);
}

int BN_num_bits(const BIGNUM *a)
{
    int i = a->top - 1;
    //bn_check_top(a);
    
    if (BN_is_zero(a)) return 0;
    return ((i*BN_BITS2) + BN_num_bits_word(a->d[i]));
}

int BN_set_bit(BIGNUM *a, int n)
{
    int i,j,k;
    
    if (n < 0)
        return 0;
    
    i=n/BN_BITS2;
    j=n%BN_BITS2;
    if (a->top <= i)
    {
        if (bn_wexpand(a,i+1) == NULL) return(0);
        for(k=a->top; k<i+1; k++)
            a->d[k]=0;
        a->top=i+1;
    }
    
    a->d[i]|=(((BN_ULONG)1)<<j);
    bn_check_top(a);
    return(1);
}


int BN_is_bit_set(const BIGNUM *a, int n)
{
    int i,j;
    
    bn_check_top(a);
    if (n < 0) return 0;
    i=n/BN_BITS2;
    j=n%BN_BITS2;
    if (a->top <= i) return 0;
    return (int)(((a->d[i])>>j)&((BN_ULONG)1));
}

int BN_set_word(BIGNUM *a, BN_ULONG w)
{
    //bn_check_top(a);
    if (bn_expand(a,(int)sizeof(BN_ULONG)*8) == NULL) return(0);
    a->neg = 0;
    a->d[0] = w;
    a->top = (w ? 1 : 0);
    //bn_check_top(a);
    return(1);
}

void bn_mul_normal(BN_ULONG *r, BN_ULONG *a, int na, BN_ULONG *b, int nb)
{
    BN_ULONG *rr;
    
#ifdef BN_COUNT
    fprintf(stderr," bn_mul_normal %d * %d\n",na,nb);
#endif
    
    if (na < nb)
    {
        int itmp;
        BN_ULONG *ltmp;
        
        itmp=na; na=nb; nb=itmp;
        ltmp=a;   a=b;   b=ltmp;
        
    }
    rr= &(r[na]);
    if (nb <= 0)
    {
        (void)bn_mul_words(r,a,na,0);
        return;
    }
    else
        rr[0]=bn_mul_words(r,a,na,b[0]);
    
    for (;;)
    {
        if (--nb <= 0) return;
        rr[1]=bn_mul_add_words(&(r[1]),a,na,b[1]);
        if (--nb <= 0) return;
        rr[2]=bn_mul_add_words(&(r[2]),a,na,b[2]);
        if (--nb <= 0) return;
        rr[3]=bn_mul_add_words(&(r[3]),a,na,b[3]);
        if (--nb <= 0) return;
        rr[4]=bn_mul_add_words(&(r[4]),a,na,b[4]);
        rr+=4;
        r+=4;
        b+=4;
    }
}

int BN_mul(BIGNUM *r, const BIGNUM *a, const BIGNUM *b, BN_CTX *ctx)
{
    int ret=0;
    int top,al,bl;
    BIGNUM *rr;
#if defined(BN_MUL_COMBA) || defined(BN_RECURSION)
    int i;
#endif
#ifdef BN_RECURSION
    BIGNUM *t=NULL;
    int j=0,k;
#endif
    
#ifdef BN_COUNT
    fprintf(stderr,"BN_mul %d * %d\n",a->top,b->top);
#endif
    
    bn_check_top(a);
    bn_check_top(b);
    bn_check_top(r);
    
    al=a->top;
    bl=b->top;
    
    if ((al == 0) || (bl == 0))
    {
        BN_zero(r);
        return(1);
    }
    top=al+bl;
    
    BN_CTX_start(ctx);
    if ((r == a) || (r == b))
    {
        if ((rr = BN_CTX_get(ctx)) == NULL) goto err;
    }
    else
        rr = r;
    rr->neg=a->neg^b->neg;
    
#if defined(BN_MUL_COMBA) || defined(BN_RECURSION)
    i = al-bl;
#endif
#ifdef BN_MUL_COMBA
    if (i == 0)
    {
# if 0
        if (al == 4)
        {
            if (bn_wexpand(rr,8) == NULL) goto err;
            rr->top=8;
            bn_mul_comba4(rr->d,a->d,b->d);
            goto end;
        }
# endif
        if (al == 8)
        {
            if (bn_wexpand(rr,16) == NULL) goto err;
            rr->top=16;
            bn_mul_comba8(rr->d,a->d,b->d);
            goto end;
        }
    }
#endif /* BN_MUL_COMBA */
#ifdef BN_RECURSION
    if ((al >= BN_MULL_SIZE_NORMAL) && (bl >= BN_MULL_SIZE_NORMAL))
    {
        if (i >= -1 && i <= 1)
        {
            /* Find out the power of two lower or equal
             to the longest of the two numbers */
            if (i >= 0)
            {
                j = BN_num_bits_word((BN_ULONG)al);
            }
            if (i == -1)
            {
                j = BN_num_bits_word((BN_ULONG)bl);
            }
            j = 1<<(j-1);
            assert(j <= al || j <= bl);
            k = j+j;
            t = BN_CTX_get(ctx);
            if (t == NULL)
                goto err;
            if (al > j || bl > j)
            {
                if (bn_wexpand(t,k*4) == NULL) goto err;
                if (bn_wexpand(rr,k*4) == NULL) goto err;
                bn_mul_part_recursive(rr->d,a->d,b->d,
                                      j,al-j,bl-j,t->d);
            }
            else    /* al <= j || bl <= j */
            {
                if (bn_wexpand(t,k*2) == NULL) goto err;
                if (bn_wexpand(rr,k*2) == NULL) goto err;
                bn_mul_recursive(rr->d,a->d,b->d,
                                 j,al-j,bl-j,t->d);
            }
            rr->top=top;
            goto end;
        }
#if 0
        if (i == 1 && !BN_get_flags(b,BN_FLG_STATIC_DATA))
        {
            BIGNUM *tmp_bn = (BIGNUM *)b;
            if (bn_wexpand(tmp_bn,al) == NULL) goto err;
            tmp_bn->d[bl]=0;
            bl++;
            i--;
        }
        else if (i == -1 && !BN_get_flags(a,BN_FLG_STATIC_DATA))
        {
            BIGNUM *tmp_bn = (BIGNUM *)a;
            if (bn_wexpand(tmp_bn,bl) == NULL) goto err;
            tmp_bn->d[al]=0;
            al++;
            i++;
        }
        if (i == 0)
        {
            /* symmetric and > 4 */
            /* 16 or larger */
            j=BN_num_bits_word((BN_ULONG)al);
            j=1<<(j-1);
            k=j+j;
            t = BN_CTX_get(ctx);
            if (al == j) /* exact multiple */
            {
                if (bn_wexpand(t,k*2) == NULL) goto err;
                if (bn_wexpand(rr,k*2) == NULL) goto err;
                bn_mul_recursive(rr->d,a->d,b->d,al,t->d);
            }
            else
            {
                if (bn_wexpand(t,k*4) == NULL) goto err;
                if (bn_wexpand(rr,k*4) == NULL) goto err;
                bn_mul_part_recursive(rr->d,a->d,b->d,al-j,j,t->d);
            }
            rr->top=top;
            goto end;
        }
#endif
    }
#endif /* BN_RECURSION */
    if (bn_wexpand(rr,top) == NULL) goto err;
    rr->top=top;
    bn_mul_normal(rr->d,a->d,al,b->d,bl);
    
#if defined(BN_MUL_COMBA) || defined(BN_RECURSION)
end:
#endif
    bn_correct_top(rr);
    if (r != rr) BN_copy(r,rr);
    ret=1;
err:
    bn_check_top(r);
    BN_CTX_end(ctx);
    return(ret);
}

static BIGNUM *BN_mod_inverse_no_branch(BIGNUM *in,
                                        const BIGNUM *a,
                                        const BIGNUM *n,
                                        BN_CTX *ctx)
{
    BIGNUM *A,*B,*X,*Y,*M,*D,*T,*R=NULL;
    BIGNUM local_A, local_B;
    BIGNUM *pA, *pB;
    BIGNUM *ret=NULL;
    int sign;
    
    bn_check_top(a);
    bn_check_top(n);
    
    BN_CTX_start(ctx);
    A = BN_CTX_get(ctx);
    B = BN_CTX_get(ctx);
    X = BN_CTX_get(ctx);
    D = BN_CTX_get(ctx);
    M = BN_CTX_get(ctx);
    Y = BN_CTX_get(ctx);
    T = BN_CTX_get(ctx);
    if (T == NULL) goto err;
    
    if (in == NULL)
        R=BN_new();
    else
        R=in;
    if (R == NULL) goto err;
    
    BN_one(X);
    BN_zero(Y);
    if (BN_copy(B,a) == NULL) goto err;
    if (BN_copy(A,n) == NULL) goto err;
    A->neg = 0;
    
    if (B->neg || (BN_ucmp(B, A) >= 0))
    {
        /* Turn BN_FLG_CONSTTIME flag on, so that when BN_div is invoked,
         * BN_div_no_branch will be called eventually.
         */
        pB = &local_B;
        BN_with_flags(pB, B, BN_FLG_CONSTTIME);
        if (!BN_nnmod(B, pB, A, ctx)) goto err;
    }
    sign = -1;
    /* From  B = a mod |n|,  A = |n|  it follows that
     *
     *      0 <= B < A,
     *     -sign*X*a  ==  B   (mod |n|),
     *      sign*Y*a  ==  A   (mod |n|).
     */
    
    while (!BN_is_zero(B))
    {
        BIGNUM *tmp;
        
        /*
         *      0 < B < A,
         * (*) -sign*X*a  ==  B   (mod |n|),
         *      sign*Y*a  ==  A   (mod |n|)
         */
        
        /* Turn BN_FLG_CONSTTIME flag on, so that when BN_div is invoked,
         * BN_div_no_branch will be called eventually.
         */
        pA = &local_A;
        BN_with_flags(pA, A, BN_FLG_CONSTTIME);
        
        /* (D, M) := (A/B, A%B) ... */
        if (!BN_div(D,M,pA,B,ctx)) goto err;
        
        /* Now
         *      A = D*B + M;
         * thus we have
         * (**)  sign*Y*a  ==  D*B + M   (mod |n|).
         */
        
        tmp=A; /* keep the BIGNUM object, the value does not matter */
        
        /* (A, B) := (B, A mod B) ... */
        A=B;
        B=M;
        /* ... so we have  0 <= B < A  again */
        
        /* Since the former  M  is now  B  and the former  B  is now  A,
         * (**) translates into
         *       sign*Y*a  ==  D*A + B    (mod |n|),
         * i.e.
         *       sign*Y*a - D*A  ==  B    (mod |n|).
         * Similarly, (*) translates into
         *      -sign*X*a  ==  A          (mod |n|).
         *
         * Thus,
         *   sign*Y*a + D*sign*X*a  ==  B  (mod |n|),
         * i.e.
         *        sign*(Y + D*X)*a  ==  B  (mod |n|).
         *
         * So if we set  (X, Y, sign) := (Y + D*X, X, -sign),  we arrive back at
         *      -sign*X*a  ==  B   (mod |n|),
         *       sign*Y*a  ==  A   (mod |n|).
         * Note that  X  and  Y  stay non-negative all the time.
         */
        
        if (!BN_mul(tmp,D,X,ctx)) goto err;
        if (!BN_add(tmp,tmp,Y)) goto err;
        
        M=Y; /* keep the BIGNUM object, the value does not matter */
        Y=X;
        X=tmp;
        sign = -sign;
    }
    
    /*
     * The while loop (Euclid's algorithm) ends when
     *      A == gcd(a,n);
     * we have
     *       sign*Y*a  ==  A  (mod |n|),
     * where  Y  is non-negative.
     */
    
    if (sign < 0)
    {
        if (!BN_sub(Y,n,Y)) goto err;
    }
    /* Now  Y*a  ==  A  (mod |n|).  */
    
    if (BN_is_one(A))
    {
        /* Y*a == 1  (mod |n|) */
        if (!Y->neg && BN_ucmp(Y,n) < 0)
        {
            if (!BN_copy(R,Y)) goto err;
        }
        else
        {
            if (!BN_nnmod(R,Y,n,ctx)) goto err;
        }
    }
    else
    {
        //BNerr(BN_F_BN_MOD_INVERSE_NO_BRANCH,BN_R_NO_INVERSE);
        goto err;
    }
    ret=R;
err:
    if ((ret == NULL) && (in == NULL)) BN_free(R);
    BN_CTX_end(ctx);
    bn_check_top(ret);
    return(ret);
}


BIGNUM *BN_mod_inverse(BIGNUM *in,
                       const BIGNUM *a, const BIGNUM *n, BN_CTX *ctx)
{
    BIGNUM *A,*B,*X,*Y,*M,*D,*T,*R=NULL;
    BIGNUM *ret=NULL;
    int sign;
    
    if ((BN_get_flags(a, BN_FLG_CONSTTIME) != 0) || (BN_get_flags(n, BN_FLG_CONSTTIME) != 0))
    {
        return BN_mod_inverse_no_branch(in, a, n, ctx);
    }
    
    bn_check_top(a);
    bn_check_top(n);
    
    BN_CTX_start(ctx);
    A = BN_CTX_get(ctx);
    B = BN_CTX_get(ctx);
    X = BN_CTX_get(ctx);
    D = BN_CTX_get(ctx);
    M = BN_CTX_get(ctx);
    Y = BN_CTX_get(ctx);
    T = BN_CTX_get(ctx);
    if (T == NULL) goto err;
    
    if (in == NULL)
        R=BN_new();
    else
        R=in;
    if (R == NULL) goto err;
    
    BN_one(X);
    BN_zero(Y);
    if (BN_copy(B,a) == NULL) goto err;
    if (BN_copy(A,n) == NULL) goto err;
    A->neg = 0;
    if (B->neg || (BN_ucmp(B, A) >= 0))
    {
        if (!BN_nnmod(B, B, A, ctx)) goto err;
    }
    sign = -1;
    /* From  B = a mod |n|,  A = |n|  it follows that
     *
     *      0 <= B < A,
     *     -sign*X*a  ==  B   (mod |n|),
     *      sign*Y*a  ==  A   (mod |n|).
     */
    
    if (BN_is_odd(n) && (BN_num_bits(n) <= (BN_BITS <= 32 ? 450 : 2048)))
    {
        /* Binary inversion algorithm; requires odd modulus.
         * This is faster than the general algorithm if the modulus
         * is sufficiently small (about 400 .. 500 bits on 32-bit
         * sytems, but much more on 64-bit systems) */
        int shift;
        
        while (!BN_is_zero(B))
        {
            /*
             *      0 < B < |n|,
             *      0 < A <= |n|,
             * (1) -sign*X*a  ==  B   (mod |n|),
             * (2)  sign*Y*a  ==  A   (mod |n|)
             */
            
            /* Now divide  B  by the maximum possible power of two in the integers,
             * and divide  X  by the same value mod |n|.
             * When we're done, (1) still holds. */
            shift = 0;
            while (!BN_is_bit_set(B, shift)) /* note that 0 < B */
            {
                shift++;
                
                if (BN_is_odd(X))
                {
                    if (!BN_uadd(X, X, n)) goto err;
                }
                /* now X is even, so we can easily divide it by two */
                if (!BN_rshift1(X, X)) goto err;
            }
            if (shift > 0)
            {
                if (!BN_rshift(B, B, shift)) goto err;
            }
            
            
            /* Same for  A  and  Y.  Afterwards, (2) still holds. */
            shift = 0;
            while (!BN_is_bit_set(A, shift)) /* note that 0 < A */
            {
                shift++;
                
                if (BN_is_odd(Y))
                {
                    if (!BN_uadd(Y, Y, n)) goto err;
                }
                /* now Y is even */
                if (!BN_rshift1(Y, Y)) goto err;
            }
            if (shift > 0)
            {
                if (!BN_rshift(A, A, shift)) goto err;
            }
            
            
            /* We still have (1) and (2).
             * Both  A  and  B  are odd.
             * The following computations ensure that
             *
             *     0 <= B < |n|,
             *      0 < A < |n|,
             * (1) -sign*X*a  ==  B   (mod |n|),
             * (2)  sign*Y*a  ==  A   (mod |n|),
             *
             * and that either  A  or  B  is even in the next iteration.
             */
            if (BN_ucmp(B, A) >= 0)
            {
                /* -sign*(X + Y)*a == B - A  (mod |n|) */
                if (!BN_uadd(X, X, Y)) goto err;
                /* NB: we could use BN_mod_add_quick(X, X, Y, n), but that
                 * actually makes the algorithm slower */
                if (!BN_usub(B, B, A)) goto err;
            }
            else
            {
                /*  sign*(X + Y)*a == A - B  (mod |n|) */
                if (!BN_uadd(Y, Y, X)) goto err;
                /* as above, BN_mod_add_quick(Y, Y, X, n) would slow things down */
                if (!BN_usub(A, A, B)) goto err;
            }
        }
    }
    else
    {
        /* general inversion algorithm */
        
        while (!BN_is_zero(B))
        {
            BIGNUM *tmp;
            
            /*
             *      0 < B < A,
             * (*) -sign*X*a  ==  B   (mod |n|),
             *      sign*Y*a  ==  A   (mod |n|)
             */
            
            /* (D, M) := (A/B, A%B) ... */
            if (BN_num_bits(A) == BN_num_bits(B))
            {
                if (!BN_one(D)) goto err;
                if (!BN_sub(M,A,B)) goto err;
            }
            else if (BN_num_bits(A) == BN_num_bits(B) + 1)
            {
                /* A/B is 1, 2, or 3 */
                if (!BN_lshift1(T,B)) goto err;
                if (BN_ucmp(A,T) < 0)
                {
                    /* A < 2*B, so D=1 */
                    if (!BN_one(D)) goto err;
                    if (!BN_sub(M,A,B)) goto err;
                }
                else
                {
                    /* A >= 2*B, so D=2 or D=3 */
                    if (!BN_sub(M,A,T)) goto err;
                    if (!BN_add(D,T,B)) goto err; /* use D (:= 3*B) as temp */
                    if (BN_ucmp(A,D) < 0)
                    {
                        /* A < 3*B, so D=2 */
                        if (!BN_set_word(D,2)) goto err;
                        /* M (= A - 2*B) already has the correct value */
                    }
                    else
                    {
                        /* only D=3 remains */
                        if (!BN_set_word(D,3)) goto err;
                        /* currently  M = A - 2*B,  but we need  M = A - 3*B */
                        if (!BN_sub(M,M,B)) goto err;
                    }
                }
            }
            else
            {
                if (!BN_div(D,M,A,B,ctx)) goto err;
            }
            
            /* Now
             *      A = D*B + M;
             * thus we have
             * (**)  sign*Y*a  ==  D*B + M   (mod |n|).
             */
            
            tmp=A; /* keep the BIGNUM object, the value does not matter */
            
            /* (A, B) := (B, A mod B) ... */
            A=B;
            B=M;
            /* ... so we have  0 <= B < A  again */
            
            /* Since the former  M  is now  B  and the former  B  is now  A,
             * (**) translates into
             *       sign*Y*a  ==  D*A + B    (mod |n|),
             * i.e.
             *       sign*Y*a - D*A  ==  B    (mod |n|).
             * Similarly, (*) translates into
             *      -sign*X*a  ==  A          (mod |n|).
             *
             * Thus,
             *   sign*Y*a + D*sign*X*a  ==  B  (mod |n|),
             * i.e.
             *        sign*(Y + D*X)*a  ==  B  (mod |n|).
             *
             * So if we set  (X, Y, sign) := (Y + D*X, X, -sign),  we arrive back at
             *      -sign*X*a  ==  B   (mod |n|),
             *       sign*Y*a  ==  A   (mod |n|).
             * Note that  X  and  Y  stay non-negative all the time.
             */
            
            /* most of the time D is very small, so we can optimize tmp := D*X+Y */
            if (BN_is_one(D))
            {
                if (!BN_add(tmp,X,Y)) goto err;
            }
            else
            {
                if (BN_is_word(D,2))
                {
                    if (!BN_lshift1(tmp,X)) goto err;
                }
                else if (BN_is_word(D,4))
                {
                    if (!BN_lshift(tmp,X,2)) goto err;
                }
                else if (D->top == 1)
                {
                    if (!BN_copy(tmp,X)) goto err;
                    if (!BN_mul_word(tmp,D->d[0])) goto err;
                }
                else
                {
                    if (!BN_mul(tmp,D,X,ctx)) goto err;
                }
                if (!BN_add(tmp,tmp,Y)) goto err;
            }
            
            M=Y; /* keep the BIGNUM object, the value does not matter */
            Y=X;
            X=tmp;
            sign = -sign;
        }
    }
    
    /*
     * The while loop (Euclid's algorithm) ends when
     *      A == gcd(a,n);
     * we have
     *       sign*Y*a  ==  A  (mod |n|),
     * where  Y  is non-negative.
     */
    
    if (sign < 0)
    {
        if (!BN_sub(Y,n,Y)) goto err;
    }
    /* Now  Y*a  ==  A  (mod |n|).  */
    
    
    if (BN_is_one(A))
    {
        /* Y*a == 1  (mod |n|) */
        if (!Y->neg && BN_ucmp(Y,n) < 0)
        {
            if (!BN_copy(R,Y)) goto err;
        }
        else
        {
            if (!BN_nnmod(R,Y,n,ctx)) goto err;
        }
    }
    else
    {
        //BNerr(BN_F_BN_MOD_INVERSE,BN_R_NO_INVERSE);
        goto err;
    }
    ret=R;
err:
    if ((ret == NULL) && (in == NULL)) BN_free(R);
    BN_CTX_end(ctx);
    bn_check_top(ret);
    return(ret);
}


void BN_CTX_start(BN_CTX *ctx)
{
    //CTXDBG_ENTRY("BN_CTX_start", ctx);
    /* If we're already overflowing ... */
    if(ctx->err_stack || ctx->too_many)
        ctx->err_stack++;
    /* (Try to) get a new frame pointer */
    else if(!BN_STACK_push(&ctx->stack, ctx->used))
    {
        //BNerr(BN_F_BN_CTX_START,BN_R_TOO_MANY_TEMPORARY_VARIABLES);
        ctx->err_stack++;
    }
    //CTXDBG_EXIT(ctx);
}

void BN_MONT_CTX_init(BN_MONT_CTX *ctx)
{
    ctx->ri=0;
    BN_init(&(ctx->RR));
    BN_init(&(ctx->N));
    BN_init(&(ctx->Ni));
    ctx->n0[0] = ctx->n0[1] = 0;
    ctx->flags=0;
}

BN_MONT_CTX *BN_MONT_CTX_new(void)
{
    BN_MONT_CTX *ret;
    
    if ((ret=(BN_MONT_CTX *)malloc(sizeof(BN_MONT_CTX))) == NULL)
        return(NULL);
    
    BN_MONT_CTX_init(ret);
    ret->flags=BN_FLG_MALLOCED;
    return(ret);
}

int BN_MONT_CTX_set(BN_MONT_CTX *mont, const BIGNUM *mod, BN_CTX *ctx)
{
    int ret = 0;
    BIGNUM *Ri,*R;
    
    BN_CTX_start(ctx);
    if((Ri = BN_CTX_get(ctx)) == NULL) goto err;
    R= &(mont->RR);                    /* grab RR as a temp */
    if (!BN_copy(&(mont->N),mod)) goto err;        /* Set N */
    mont->N.neg = 0;
    
#ifdef MONT_WORD
    {
        BIGNUM tmod;
        BN_ULONG buf[2];
        
        BN_init(&tmod);
        tmod.d=buf;
        tmod.dmax=2;
        tmod.neg=0;
        
        mont->ri=(BN_num_bits(mod)+(BN_BITS2-1))/BN_BITS2*BN_BITS2;
        
#if defined(OPENSSL_BN_ASM_MONT) && (BN_BITS2<=32)
        /* Only certain BN_BITS2<=32 platforms actually make use of
         * n0[1], and we could use the #else case (with a shorter R
         * value) for the others.  However, currently only the assembler
         * files do know which is which. */
        
        BN_zero(R);
        if (!(BN_set_bit(R,2*BN_BITS2))) goto err;
        
        tmod.top=0;
        if ((buf[0] = mod->d[0]))            tmod.top=1;
        if ((buf[1] = mod->top>1 ? mod->d[1] : 0))    tmod.top=2;
        
        if ((BN_mod_inverse(Ri,R,&tmod,ctx)) == NULL)
            goto err;
        if (!BN_lshift(Ri,Ri,2*BN_BITS2)) goto err; /* R*Ri */
        if (!BN_is_zero(Ri))
        {
            if (!BN_sub_word(Ri,1)) goto err;
        }
        else /* if N mod word size == 1 */
        {
            if (bn_expand(Ri,(int)sizeof(BN_ULONG)*2) == NULL)
                goto err;
            /* Ri-- (mod double word size) */
            Ri->neg=0;
            Ri->d[0]=BN_MASK2;
            Ri->d[1]=BN_MASK2;
            Ri->top=2;
        }
        if (!BN_div(Ri,NULL,Ri,&tmod,ctx)) goto err;
        /* Ni = (R*Ri-1)/N,
         * keep only couple of least significant words: */
        mont->n0[0] = (Ri->top > 0) ? Ri->d[0] : 0;
        mont->n0[1] = (Ri->top > 1) ? Ri->d[1] : 0;
#else
        BN_zero(R);
        if (!(BN_set_bit(R,BN_BITS2))) goto err;    /* R */
        
        buf[0]=mod->d[0]; /* tmod = N mod word size */
        buf[1]=0;
        tmod.top = buf[0] != 0 ? 1 : 0;
        /* Ri = R^-1 mod N*/
        if ((BN_mod_inverse(Ri,R,&tmod,ctx)) == NULL)
            goto err;
        if (!BN_lshift(Ri,Ri,BN_BITS2)) goto err; /* R*Ri */
        if (!BN_is_zero(Ri))
        {
            if (!BN_sub_word(Ri,1)) goto err;
        }
        else /* if N mod word size == 1 */
        {
            if (!BN_set_word(Ri,BN_MASK2)) goto err;  /* Ri-- (mod word size) */
        }
        if (!BN_div(Ri,NULL,Ri,&tmod,ctx)) goto err;
        /* Ni = (R*Ri-1)/N,
         * keep only least significant word: */
        mont->n0[0] = (Ri->top > 0) ? Ri->d[0] : 0;
        mont->n0[1] = 0;
#endif
    }
#else /* !MONT_WORD */
    { /* bignum version */
        mont->ri=BN_num_bits(&mont->N);
        BN_zero(R);
        if (!BN_set_bit(R,mont->ri)) goto err;  /* R = 2^ri */
        /* Ri = R^-1 mod N*/
        if ((BN_mod_inverse(Ri,R,&mont->N,ctx)) == NULL)
            goto err;
        if (!BN_lshift(Ri,Ri,mont->ri)) goto err; /* R*Ri */
        if (!BN_sub_word(Ri,1)) goto err;
        /* Ni = (R*Ri-1) / N */
        if (!BN_div(&(mont->Ni),NULL,Ri,&mont->N,ctx)) goto err;
    }
#endif
    
    /* setup RR for conversions */
    BN_zero(&(mont->RR));
    if (!BN_set_bit(&(mont->RR),mont->ri*2)) goto err;
    if (!BN_mod(&(mont->RR),&(mont->RR),&(mont->N),ctx)) goto err;
    
    ret = 1;
err:
    BN_CTX_end(ctx);
    return ret;
}

static BIGNUM *BN_POOL_get(BN_POOL *p)
{
    if(p->used == p->size)
    {
        BIGNUM *bn;
        unsigned int loop = 0;
        BN_POOL_ITEM *item = malloc(sizeof(BN_POOL_ITEM));
        if(!item) return NULL;
        /* Initialise the structure */
        bn = item->vals;
        while(loop++ < BN_CTX_POOL_SIZE)
            BN_init(bn++);
        item->prev = p->tail;
        item->next = NULL;
        /* Link it in */
        if(!p->head)
            p->head = p->current = p->tail = item;
        else
        {
            p->tail->next = item;
            p->tail = item;
            p->current = item;
        }
        p->size += BN_CTX_POOL_SIZE;
        p->used++;
        /* Return the first bignum from the new pool */
        return item->vals;
    }
    if(!p->used)
        p->current = p->head;
    else if((p->used % BN_CTX_POOL_SIZE) == 0)
        p->current = p->current->next;
    return p->current->vals + ((p->used++) % BN_CTX_POOL_SIZE);
}

BIGNUM *BN_CTX_get(BN_CTX *ctx)
{
    BIGNUM *ret;
    //CTXDBG_ENTRY("BN_CTX_get", ctx);
    if(ctx->err_stack || ctx->too_many) return NULL;
    if((ret = BN_POOL_get(&ctx->pool)) == NULL)
    {
        /* Setting too_many prevents repeated "get" attempts from
         * cluttering the error stack. */
        ctx->too_many = 1;
        //BNerr(BN_F_BN_CTX_GET,BN_R_TOO_MANY_TEMPORARY_VARIABLES);
        return NULL;
    }
    /* OK, make sure the returned bignum is "zero" */
    BN_zero(ret);
    ctx->used++;
    //CTXDBG_RET(ctx, ret);
    return ret;
}

static int BN_STACK_push(BN_STACK *st, unsigned int idx)
{
    if(st->depth == st->size)
    /* Need to expand */
    {
        unsigned int newsize = (st->size ?
                                (st->size * 3 / 2) : BN_CTX_START_FRAMES);
        unsigned int *newitems = malloc(newsize *
                                                sizeof(unsigned int));
        if(!newitems) return 0;
        if(st->depth)
            memcpy(newitems, st->indexes, st->depth *
                   sizeof(unsigned int));
        if(st->size) free(st->indexes);
        st->indexes = newitems;
        st->size = newsize;
    }
    st->indexes[(st->depth)++] = idx;
    return 1;
}

static unsigned int BN_STACK_pop(BN_STACK *st)
{
    return st->indexes[--(st->depth)];
}

static BN_ULONG *bn_expand_internal(const BIGNUM *b, int words)
{
    BN_ULONG *A,*a = NULL;
    const BN_ULONG *B;
    int i;
    
    //bn_check_top(b);
    
    if (words > (INT_MAX/(4*BN_BITS2)))
    {
        //BNerr(BN_F_BN_EXPAND_INTERNAL,BN_R_BIGNUM_TOO_LONG);
        return NULL;
    }
    if (BN_get_flags(b,BN_FLG_STATIC_DATA))
    {
        //BNerr(BN_F_BN_EXPAND_INTERNAL,BN_R_EXPAND_ON_STATIC_BIGNUM_DATA);
        return(NULL);
    }
    a=A=(BN_ULONG *)malloc(sizeof(BN_ULONG)*words);
    if (A == NULL)
    {
        //BNerr(BN_F_BN_EXPAND_INTERNAL,ERR_R_MALLOC_FAILURE);
        return(NULL);
    }
#if 1
    B=b->d;
    /* Check if the previous number needs to be copied */
    if (B != NULL)
    {
        for (i=b->top>>2; i>0; i--,A+=4,B+=4)
        {
            /*
             * The fact that the loop is unrolled
             * 4-wise is a tribute to Intel. It's
             * the one that doesn't have enough
             * registers to accomodate more data.
             * I'd unroll it 8-wise otherwise:-)
             *
             *        <appro@fy.chalmers.se>
             */
            BN_ULONG a0,a1,a2,a3;
            a0=B[0]; a1=B[1]; a2=B[2]; a3=B[3];
            A[0]=a0; A[1]=a1; A[2]=a2; A[3]=a3;
        }
        switch (b->top&3)
        {
            case 3:    A[2]=B[2];
            case 2:    A[1]=B[1];
            case 1:    A[0]=B[0];
            case 0: /* workaround for ultrix cc: without 'case 0', the optimizer does
                     * the switch table by doing a=top&3; a--; goto jump_table[a];
                     * which fails for top== 0 */
                ;
        }
    }
    
#else
    memset(A,0,sizeof(BN_ULONG)*words);
    memcpy(A,b->d,sizeof(b->d[0])*b->top);
#endif
    
    return(a);
}


BIGNUM *bn_expand2(BIGNUM *b, int words)
{
    //bn_check_top(b);
    
    if (words > b->dmax)
    {
        BN_ULONG *a = bn_expand_internal(b, words);
        if(!a) return NULL;
        if(b->d) free(b->d);
        b->d=a;
        b->dmax=words;
    }
    
    /* None of this should be necessary because of what b->top means! */
#if 0
    /* NB: bn_wexpand() calls this only if the BIGNUM really has to grow */
    if (b->top < b->dmax)
    {
        int i;
        BN_ULONG *A = &(b->d[b->top]);
        for (i=(b->dmax - b->top)>>3; i>0; i--,A+=8)
        {
            A[0]=0; A[1]=0; A[2]=0; A[3]=0;
            A[4]=0; A[5]=0; A[6]=0; A[7]=0;
        }
        for (i=(b->dmax - b->top)&7; i>0; i--,A++)
            A[0]=0;
        assert(A == &(b->d[b->dmax]));
    }
#endif
    //bn_check_top(b);
    return b;
}

BIGNUM *BN_bin2bn(const unsigned char *s, int len, BIGNUM *ret)
{
    unsigned int i,m;
    unsigned int n;
    BN_ULONG l;
    BIGNUM  *bn = NULL;
    
    if (ret == NULL)
        ret = bn = BN_new();
    if (ret == NULL) return(NULL);
    //bn_check_top(ret);
    l=0;
    n=len;
    if (n == 0)
    {
        ret->top=0;
        return(ret);
    }
    i=((n-1)/BN_BYTES)+1;
    m=((n-1)%(BN_BYTES));
    if (bn_wexpand(ret, (int)i) == NULL)
    {
        if (bn) BN_free(bn);
        return NULL;
    }
    ret->top=i;
    ret->neg=0;
    while (n--)
    {
        l=(l<<8L)| *(s++);
        if (m-- == 0)
        {
            ret->d[--i]=l;
            l=0;
            m=BN_BYTES-1;
        }
    }
    /* need to call this due to clear byte at top if avoiding
     * having the top bit set (-ve number) */
    //bn_correct_top(ret);
    return(ret);
}

int BN_from_montgomery(BIGNUM *ret, const BIGNUM *a, BN_MONT_CTX *mont,
                       BN_CTX *ctx)
{
    int retn=0;
#ifdef MONT_WORD
    BIGNUM *t;
    
    BN_CTX_start(ctx);
    if ((t = BN_CTX_get(ctx)) && BN_copy(t,a))
        retn = BN_from_montgomery_word(ret,t,mont);
    BN_CTX_end(ctx);
#else /* !MONT_WORD */
    BIGNUM *t1,*t2;
    
    BN_CTX_start(ctx);
    t1 = BN_CTX_get(ctx);
    t2 = BN_CTX_get(ctx);
    if (t1 == NULL || t2 == NULL) goto err;
    
    if (!BN_copy(t1,a)) goto err;
    BN_mask_bits(t1,mont->ri);
    
    if (!BN_mul(t2,t1,&mont->Ni,ctx)) goto err;
    BN_mask_bits(t2,mont->ri);
    
    if (!BN_mul(t1,t2,&mont->N,ctx)) goto err;
    if (!BN_add(t2,a,t1)) goto err;
    if (!BN_rshift(ret,t2,mont->ri)) goto err;
    
    if (BN_ucmp(ret, &(mont->N)) >= 0)
    {
        if (!BN_usub(ret,ret,&(mont->N))) goto err;
    }
    retn=1;
    bn_check_top(ret);
err:
    BN_CTX_end(ctx);
#endif /* MONT_WORD */
    return(retn);
}


#define BN_TO_MONTGOMERY_WORD(r, w, mont) \
(BN_set_word(r, (w)) && BN_to_montgomery(r, r, (mont), ctx))

int BN_mod_exp_mont_word(BIGNUM *rr, BN_ULONG a, const BIGNUM *p,
                         const BIGNUM *m, BN_CTX *ctx, BN_MONT_CTX *in_mont)
{
    BN_MONT_CTX *mont = NULL;
    int b, bits, ret=0;
    int r_is_one;
    BN_ULONG w, next_w;
    BIGNUM *d, *r, *t;
    BIGNUM *swap_tmp;
#define BN_MOD_MUL_WORD(r, w, m) \
(BN_mul_word(r, (w)) && \
(/* BN_ucmp(r, (m)) < 0 ? 1 :*/  \
(BN_mod(t, r, m, ctx) && (swap_tmp = r, r = t, t = swap_tmp, 1))))
    /* BN_MOD_MUL_WORD is only used with 'w' large,
     * so the BN_ucmp test is probably more overhead
     * than always using BN_mod (which uses BN_copy if
     * a similar test returns true). */
    /* We can use BN_mod and do not need BN_nnmod because our
     * accumulator is never negative (the result of BN_mod does
     * not depend on the sign of the modulus).
     */
#define BN_TO_MONTGOMERY_WORD(r, w, mont) \
(BN_set_word(r, (w)) && BN_to_montgomery(r, r, (mont), ctx))
    
    if (BN_get_flags(p, BN_FLG_CONSTTIME) != 0)
    {
        /* BN_FLG_CONSTTIME only supported by BN_mod_exp_mont() */
        //BNerr(BN_F_BN_MOD_EXP_MONT_WORD,ERR_R_SHOULD_NOT_HAVE_BEEN_CALLED);
        return -1;
    }
    
    //bn_check_top(p);
    //bn_check_top(m);
    
    if (!BN_is_odd(m))
    {
        //BNerr(BN_F_BN_MOD_EXP_MONT_WORD,BN_R_CALLED_WITH_EVEN_MODULUS);
        return(0);
    }
    if (m->top == 1)
        a %= m->d[0]; /* make sure that 'a' is reduced */
    
    bits = BN_num_bits(p);
    if (bits == 0)
    {
        ret = BN_one(rr);
        return ret;
    }
    if (a == 0)
    {
        BN_zero(rr);
        ret = 1;
        return ret;
    }
    
    BN_CTX_start(ctx);
    d = BN_CTX_get(ctx);
    r = BN_CTX_get(ctx);
    t = BN_CTX_get(ctx);
    if (d == NULL || r == NULL || t == NULL) goto err;
    
    if (in_mont != NULL)
        mont=in_mont;
    else
    {
        if ((mont = BN_MONT_CTX_new()) == NULL) goto err;
        if (!BN_MONT_CTX_set(mont, m, ctx)) goto err;
    }
    
    r_is_one = 1; /* except for Montgomery factor */
    
    /* bits-1 >= 0 */
    
    /* The result is accumulated in the product r*w. */
    w = a; /* bit 'bits-1' of 'p' is always set */
    for (b = bits-2; b >= 0; b--)
    {
        /* First, square r*w. */
        next_w = w*w;
        if ((next_w/w) != w) /* overflow */
        {
            if (r_is_one)
            {
                if (!BN_TO_MONTGOMERY_WORD(r, w, mont)) goto err;
                r_is_one = 0;
            }
            else
            {
                if (!BN_MOD_MUL_WORD(r, w, m)) goto err;
            }
            next_w = 1;
        }
        w = next_w;
        if (!r_is_one)
        {
            if (!BN_mod_mul_montgomery(r, r, r, mont, ctx)) goto err;
        }
        
        /* Second, multiply r*w by 'a' if exponent bit is set. */
        if (BN_is_bit_set(p, b))
        {
            next_w = w*a;
            if ((next_w/a) != w) /* overflow */
            {
                if (r_is_one)
                {
                    if (!BN_TO_MONTGOMERY_WORD(r, w, mont)) goto err;
                    r_is_one = 0;
                }
                else
                {
                    if (!BN_MOD_MUL_WORD(r, w, m)) goto err;
                }
                next_w = a;
            }
            w = next_w;
        }
    }
    
    /* Finally, set r:=r*w. */
    if (w != 1)
    {
        if (r_is_one)
        {
            if (!BN_TO_MONTGOMERY_WORD(r, w, mont)) goto err;
            r_is_one = 0;
        }
        else
        {
            if (!BN_MOD_MUL_WORD(r, w, m)) goto err;
        }
    }
    
    if (r_is_one) /* can happen only if a == 1*/
    {
        if (!BN_one(rr)) goto err;
    }
    else
    {
        if (!BN_from_montgomery(rr, r, mont, ctx)) goto err;
    }
    ret = 1;
err:
    if ((in_mont == NULL) && (mont != NULL)) BN_MONT_CTX_free(mont);
    BN_CTX_end(ctx);
    bn_check_top(rr);
    return(ret);
}

#define TABLE_SIZE    32
int BN_mod_exp_mont(BIGNUM *rr, const BIGNUM *a, const BIGNUM *p,
                    const BIGNUM *m, BN_CTX *ctx, BN_MONT_CTX *in_mont)
{
    int i,j,bits,ret=0,wstart,wend,window,wvalue;
    int start=1;
    BIGNUM *d,*r;
    const BIGNUM *aa;
    /* Table of variables obtained from 'ctx' */
    BIGNUM *val[TABLE_SIZE];
    BN_MONT_CTX *mont=NULL;
    
    if (BN_get_flags(p, BN_FLG_CONSTTIME) != 0)
    {
        return BN_mod_exp_mont_consttime(rr, a, p, m, ctx, in_mont);
    }
    
    bn_check_top(a);
    bn_check_top(p);
    bn_check_top(m);
    
    if (!BN_is_odd(m))
    {
        //BNerr(BN_F_BN_MOD_EXP_MONT,BN_R_CALLED_WITH_EVEN_MODULUS);
        return(0);
    }
    bits=BN_num_bits(p);
    if (bits == 0)
    {
        ret = BN_one(rr);
        return ret;
    }
    
    BN_CTX_start(ctx);
    d = BN_CTX_get(ctx);
    r = BN_CTX_get(ctx);
    val[0] = BN_CTX_get(ctx);
    if (!d || !r || !val[0]) goto err;
    
    /* If this is not done, things will break in the montgomery
     * part */
    
    if (in_mont != NULL)
        mont=in_mont;
    else
    {
        if ((mont=BN_MONT_CTX_new()) == NULL) goto err;
        if (!BN_MONT_CTX_set(mont,m,ctx)) goto err;
    }
    
    if (a->neg || BN_ucmp(a,m) >= 0)
    {
        if (!BN_nnmod(val[0],a,m,ctx))
            goto err;
        aa= val[0];
    }
    else
        aa=a;
    if (BN_is_zero(aa))
    {
        BN_zero(rr);
        ret = 1;
        goto err;
    }
    if (!BN_to_montgomery(val[0],aa,mont,ctx)) goto err; /* 1 */
    
    window = BN_window_bits_for_exponent_size(bits);
    if (window > 1)
    {
        if (!BN_mod_mul_montgomery(d,val[0],val[0],mont,ctx)) goto err; /* 2 */
        j=1<<(window-1);
        for (i=1; i<j; i++)
        {
            if(((val[i] = BN_CTX_get(ctx)) == NULL) ||
               !BN_mod_mul_montgomery(val[i],val[i-1],
                                      d,mont,ctx))
                goto err;
        }
    }
    
    start=1;    /* This is used to avoid multiplication etc
                 * when there is only the value '1' in the
                 * buffer. */
    wvalue=0;    /* The 'value' of the window */
    wstart=bits-1;    /* The top bit of the window */
    wend=0;        /* The bottom bit of the window */
    
    if (!BN_to_montgomery(r,BN_value_one(),mont,ctx)) goto err;
    for (;;)
    {
        if (BN_is_bit_set(p,wstart) == 0)
        {
            if (!start)
            {
                if (!BN_mod_mul_montgomery(r,r,r,mont,ctx))
                    goto err;
            }
            if (wstart == 0) break;
            wstart--;
            continue;
        }
        /* We now have wstart on a 'set' bit, we now need to work out
         * how bit a window to do.  To do this we need to scan
         * forward until the last set bit before the end of the
         * window */
        j=wstart;
        wvalue=1;
        wend=0;
        for (i=1; i<window; i++)
        {
            if (wstart-i < 0) break;
            if (BN_is_bit_set(p,wstart-i))
            {
                wvalue<<=(i-wend);
                wvalue|=1;
                wend=i;
            }
        }
        
        /* wend is the size of the current window */
        j=wend+1;
        /* add the 'bytes above' */
        if (!start)
            for (i=0; i<j; i++)
            {
                if (!BN_mod_mul_montgomery(r,r,r,mont,ctx))
                    goto err;
            }
        
        /* wvalue will be an odd number < 2^window */
        if (!BN_mod_mul_montgomery(r,r,val[wvalue>>1],mont,ctx))
            goto err;
        
        /* move the 'window' down further */
        wstart-=wend+1;
        wvalue=0;
        start=0;
        if (wstart < 0) break;
    }
    if (!BN_from_montgomery(rr,r,mont,ctx)) goto err;
    ret=1;
err:
    if ((in_mont == NULL) && (mont != NULL)) BN_MONT_CTX_free(mont);
    BN_CTX_end(ctx);
    bn_check_top(rr);
    return(ret);
}



int BN_mod_exp(BIGNUM *r, const BIGNUM *a, const BIGNUM *p, const BIGNUM *m,
               BN_CTX *ctx)
{
    int ret;
    
    //bn_check_top(a);
    //bn_check_top(p);
    //bn_check_top(m);
    
    /* For even modulus  m = 2^k*m_odd,  it might make sense to compute
     * a^p mod m_odd  and  a^p mod 2^k  separately (with Montgomery
     * exponentiation for the odd part), using appropriate exponent
     * reductions, and combine the results using the CRT.
     *
     * For now, we use Montgomery only if the modulus is odd; otherwise,
     * exponentiation using the reciprocal-based quick remaindering
     * algorithm is used.
     *
     * (Timing obtained with expspeed.c [computations  a^p mod m
     * where  a, p, m  are of the same length: 256, 512, 1024, 2048,
     * 4096, 8192 bits], compared to the running time of the
     * standard algorithm:
     *
     *   BN_mod_exp_mont   33 .. 40 %  [AMD K6-2, Linux, debug configuration]
     *                     55 .. 77 %  [UltraSparc processor, but
     *                                  debug-solaris-sparcv8-gcc conf.]
     *
     *   BN_mod_exp_recp   50 .. 70 %  [AMD K6-2, Linux, debug configuration]
     *                     62 .. 118 % [UltraSparc, debug-solaris-sparcv8-gcc]
     *
     * On the Sparc, BN_mod_exp_recp was faster than BN_mod_exp_mont
     * at 2048 and more bits, but at 512 and 1024 bits, it was
     * slower even than the standard algorithm!
     *
     * "Real" timings [linux-elf, solaris-sparcv9-gcc configurations]
     * should be obtained when the new Montgomery reduction code
     * has been integrated into OpenSSL.)
     */
    
#define MONT_MUL_MOD
#define MONT_EXP_WORD
#define RECP_MUL_MOD
    
#ifdef MONT_MUL_MOD
    /* I have finally been able to take out this pre-condition of
     * the top bit being set.  It was caused by an error in BN_div
     * with negatives.  There was also another problem when for a^b%m
     * a >= m.  eay 07-May-97 */
    /*    if ((m->d[m->top-1]&BN_TBIT) && BN_is_odd(m)) */
    
    if (BN_is_odd(m))
    {
#  ifdef MONT_EXP_WORD
        if (a->top == 1 && !a->neg && (BN_get_flags(p, BN_FLG_CONSTTIME) == 0))
        {
            BN_ULONG A = a->d[0];
            ret=BN_mod_exp_mont_word(r,A,p,m,ctx,NULL);
        }
        else
#  endif
            ret=BN_mod_exp_mont(r,a,p,m,ctx,NULL);
    }
    else
#endif
#ifdef RECP_MUL_MOD
    { ret=BN_mod_exp_recp(r,a,p,m,ctx); }
#else
    { ret=BN_mod_exp_simple(r,a,p,m,ctx); }
#endif
    
    bn_check_top(r);
    return(ret);
}


