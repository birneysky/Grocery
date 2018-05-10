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

#define BN_CTX_POOL_SIZE    16

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

static void        BN_STACK_init(BN_STACK *);

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


