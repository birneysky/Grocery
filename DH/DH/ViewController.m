//
//  ViewController.m
//  DH
//
//  Created by birney on 2018/5/10.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "ViewController.h"
#import <limits.h>
#import <Security/Security.h>
#include <openssl/bn.h>
#include <gmp.h>
#import "RCDH.h"

@interface ViewController ()

@end


NSData *MTExp(NSData *base, NSData *exp, NSData *modulus)
{
    BN_CTX *ctx = BN_CTX_new();
    BIGNUM *bnBase = BN_bin2bn(base.bytes, (int)base.length, NULL);
    BN_set_flags(bnBase, BN_FLG_CONSTTIME);
    
    BIGNUM *bnExp = BN_bin2bn(exp.bytes, (int)exp.length, NULL);
    BN_set_flags(bnExp, BN_FLG_CONSTTIME);
    
    BIGNUM *bnModulus = BN_bin2bn(modulus.bytes, (int)modulus.length, NULL);
    BN_set_flags(bnModulus, BN_FLG_CONSTTIME);
    
    BIGNUM *bnRes = BN_new();
    BN_set_flags(bnModulus, BN_FLG_CONSTTIME);
    
    BN_mod_exp(bnRes, bnBase, bnExp, bnModulus, ctx);
    
    unsigned char *res = malloc((size_t)BN_num_bytes(bnRes));
    int resLen = BN_bn2bin(bnRes, res);
    
    BN_CTX_free(ctx);
    BN_free(bnBase);
    BN_free(bnExp);
    BN_free(bnModulus);
    BN_free(bnRes);
    
    NSData *result = [[NSData alloc] initWithBytes:res length:(NSUInteger)resLen];
    free(res);
    
    return result;
}

//    mpz_t mpBase1;
//    mpz_init_set_str(mpBase,base.bytes,10);
//    int a = mpq_cmp(mpBase,mpBase1);
//    int b = mpq_equal(mpBase,mpBase1);
//mpz_inp_data(mpBase,(const void*)base.bytes,(int)base.length);
//mpz_inp_data(mpExp,(const void*)exp.bytes,(int)exp.length);

//    mpz_t mpExpResult;
//    mpz_pow_ui(mpExpResult,mpBase,mpExp);

char* gmpExp(const char *base, const char *exp, const char *mod)
{
    mpz_t mpBase;
    mpz_init(mpBase);
    mpz_init_set_str(mpBase,base,10);
    
    mpz_t mpExp;
    mpz_init(mpExp);
    mpz_init_set_str(mpExp,exp,10);

    mpz_t mpMod;
    mpz_init(mpMod);
    mpz_init_set_str(mpMod,mod,10);
    
    mpz_t mpModResult;
    mpz_init(mpModResult);
    mpz_powm_sec(mpModResult,mpBase,mpExp,mpMod);
   
//    int len = mpz_sizeinbase (mpMod, 10) + 2;
//    char* buf = malloc(len);
    char* modStr = mpz_get_str(NULL,10,mpModResult);
    return modStr;

}


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self testBIGNUM];
    [self testGPM];
    [self gmpRandom];
    [self testDH];
}

- (void)testGPM {
    unsigned char p[] = {
        0xc7, 0x1c, 0xae, 0xb9, 0xc6, 0xb1, 0xc9, 0x04, 0x8e, 0x6c, 0x52, 0x2f,
        0x70, 0xf1, 0x3f, 0x73, 0x98, 0x0d, 0x40, 0x23, 0x8e, 0x3e, 0x21, 0xc1,
        0x49, 0x34, 0xd0, 0x37, 0x56, 0x3d, 0x93, 0x0f, 0x48, 0x19, 0x8a, 0x0a,
        0xa7, 0xc1, 0x40, 0x58, 0x22, 0x94, 0x93, 0xd2, 0x25, 0x30, 0xf4, 0xdb,
        0xfa, 0x33, 0x6f, 0x6e, 0x0a, 0xc9, 0x25, 0x13, 0x95, 0x43, 0xae, 0xd4,
        0x4c, 0xce, 0x7c, 0x37, 0x20, 0xfd, 0x51, 0xf6, 0x94, 0x58, 0x70, 0x5a,
        0xc6, 0x8c, 0xd4, 0xfe, 0x6b, 0x6b, 0x13, 0xab, 0xdc, 0x97, 0x46, 0x51,
        0x29, 0x69, 0x32, 0x84, 0x54, 0xf1, 0x8f, 0xaf, 0x8c, 0x59, 0x5f, 0x64,
        0x24, 0x77, 0xfe, 0x96, 0xbb, 0x2a, 0x94, 0x1d, 0x5b, 0xcd, 0x1d, 0x4a,
        0xc8, 0xcc, 0x49, 0x88, 0x07, 0x08, 0xfa, 0x9b, 0x37, 0x8e, 0x3c, 0x4f,
        0x3a, 0x90, 0x60, 0xbe, 0xe6, 0x7c, 0xf9, 0xa4, 0xa4, 0xa6, 0x95, 0x81,
        0x10, 0x51, 0x90, 0x7e, 0x16, 0x27, 0x53, 0xb5, 0x6b, 0x0f, 0x6b, 0x41,
        0x0d, 0xba, 0x74, 0xd8, 0xa8, 0x4b, 0x2a, 0x14, 0xb3, 0x14, 0x4e, 0x0e,
        0xf1, 0x28, 0x47, 0x54, 0xfd, 0x17, 0xed, 0x95, 0x0d, 0x59, 0x65, 0xb4,
        0xb9, 0xdd, 0x46, 0x58, 0x2d, 0xb1, 0x17, 0x8d, 0x16, 0x9c, 0x6b, 0xc4,
        0x65, 0xb0, 0xd6, 0xff, 0x9c, 0xa3, 0x92, 0x8f, 0xef, 0x5b, 0x9a, 0xe4,
        0xe4, 0x18, 0xfc, 0x15, 0xe8, 0x3e, 0xbe, 0xa0, 0xf8, 0x7f, 0xa9, 0xff,
        0x5e, 0xed, 0x70, 0x05, 0x0d, 0xed, 0x28, 0x49, 0xf4, 0x7b, 0xf9, 0x59,
        0xd9, 0x56, 0x85, 0x0c, 0xe9, 0x29, 0x85, 0x1f, 0x0d, 0x81, 0x15, 0xf6,
        0x35, 0xb1, 0x05, 0xee, 0x2e, 0x4e, 0x15, 0xd0, 0x4b, 0x24, 0x54, 0xbf,
        0x6f, 0x4f, 0xad, 0xf0, 0x34, 0xb1, 0x04, 0x03, 0x11, 0x9c, 0xd8, 0xe3,
        0xb9, 0x2f, 0xcc, 0x5b
    };
    
    BIGNUM *bnBase = BN_bin2bn(p, 256, NULL);
    char * pStr = BN_bn2dec(bnBase);
    char*  gStr = "3";
    
    uint8_t aBytes[256];
    int result =SecRandomCopyBytes(kSecRandomDefault, 256, (void*)aBytes);
    NSAssert(result == 0, @"随机数生成失败");
    
    
    
    BIGNUM *randomA = BN_bin2bn(aBytes, 256, NULL);
    char * pRandomA = BN_bn2dec(randomA);
    
    char* ga = gmpExp(gStr, pRandomA, pStr);
    
    uint8_t bBytes[256];
    result =SecRandomCopyBytes(kSecRandomDefault, 256, (void*)bBytes);
    NSAssert(result == 0, @"随机数生成失败");
    
    BIGNUM *randomB = BN_bin2bn(bBytes, 256, NULL);
    char * pRandomB = BN_bn2dec(randomB);
    
    char* gb = gmpExp(gStr, pRandomB, pStr);
    
    char* keyA = gmpExp(gb, pRandomA, pStr);
    char* keyB = gmpExp(ga, pRandomB, pStr);
    
    NSAssert(strcmp(keyA, keyB)==0, @"key不相等");
}




- (void)testBIGNUM {
    // Do any additional setup after loading the view, typically from a nib.
    unsigned char p[] = {
        0xc7, 0x1c, 0xae, 0xb9, 0xc6, 0xb1, 0xc9, 0x04, 0x8e, 0x6c, 0x52, 0x2f,
        0x70, 0xf1, 0x3f, 0x73, 0x98, 0x0d, 0x40, 0x23, 0x8e, 0x3e, 0x21, 0xc1,
        0x49, 0x34, 0xd0, 0x37, 0x56, 0x3d, 0x93, 0x0f, 0x48, 0x19, 0x8a, 0x0a,
        0xa7, 0xc1, 0x40, 0x58, 0x22, 0x94, 0x93, 0xd2, 0x25, 0x30, 0xf4, 0xdb,
        0xfa, 0x33, 0x6f, 0x6e, 0x0a, 0xc9, 0x25, 0x13, 0x95, 0x43, 0xae, 0xd4,
        0x4c, 0xce, 0x7c, 0x37, 0x20, 0xfd, 0x51, 0xf6, 0x94, 0x58, 0x70, 0x5a,
        0xc6, 0x8c, 0xd4, 0xfe, 0x6b, 0x6b, 0x13, 0xab, 0xdc, 0x97, 0x46, 0x51,
        0x29, 0x69, 0x32, 0x84, 0x54, 0xf1, 0x8f, 0xaf, 0x8c, 0x59, 0x5f, 0x64,
        0x24, 0x77, 0xfe, 0x96, 0xbb, 0x2a, 0x94, 0x1d, 0x5b, 0xcd, 0x1d, 0x4a,
        0xc8, 0xcc, 0x49, 0x88, 0x07, 0x08, 0xfa, 0x9b, 0x37, 0x8e, 0x3c, 0x4f,
        0x3a, 0x90, 0x60, 0xbe, 0xe6, 0x7c, 0xf9, 0xa4, 0xa4, 0xa6, 0x95, 0x81,
        0x10, 0x51, 0x90, 0x7e, 0x16, 0x27, 0x53, 0xb5, 0x6b, 0x0f, 0x6b, 0x41,
        0x0d, 0xba, 0x74, 0xd8, 0xa8, 0x4b, 0x2a, 0x14, 0xb3, 0x14, 0x4e, 0x0e,
        0xf1, 0x28, 0x47, 0x54, 0xfd, 0x17, 0xed, 0x95, 0x0d, 0x59, 0x65, 0xb4,
        0xb9, 0xdd, 0x46, 0x58, 0x2d, 0xb1, 0x17, 0x8d, 0x16, 0x9c, 0x6b, 0xc4,
        0x65, 0xb0, 0xd6, 0xff, 0x9c, 0xa3, 0x92, 0x8f, 0xef, 0x5b, 0x9a, 0xe4,
        0xe4, 0x18, 0xfc, 0x15, 0xe8, 0x3e, 0xbe, 0xa0, 0xf8, 0x7f, 0xa9, 0xff,
        0x5e, 0xed, 0x70, 0x05, 0x0d, 0xed, 0x28, 0x49, 0xf4, 0x7b, 0xf9, 0x59,
        0xd9, 0x56, 0x85, 0x0c, 0xe9, 0x29, 0x85, 0x1f, 0x0d, 0x81, 0x15, 0xf6,
        0x35, 0xb1, 0x05, 0xee, 0x2e, 0x4e, 0x15, 0xd0, 0x4b, 0x24, 0x54, 0xbf,
        0x6f, 0x4f, 0xad, 0xf0, 0x34, 0xb1, 0x04, 0x03, 0x11, 0x9c, 0xd8, 0xe3,
        0xb9, 0x2f, 0xcc, 0x5b
    };
    
    
    int32_t g = 3;
    int32_t swapG = NSSwapInt(g);
    
    uint8_t aBytes[256];
    int result =SecRandomCopyBytes(kSecRandomDefault, 256, (void*)aBytes);
    NSAssert(result == 0, @"随机数生成失败");
    
    NSData *randomA = [[NSData alloc] initWithBytes:aBytes length:256];
    
    NSData *gData = [[NSData alloc] initWithBytes:&swapG length:sizeof(g)];
    NSData *pData = [[NSData alloc] initWithBytes:p length:sizeof(p)];
    
    
    NSData *gABytes = MTExp(gData, randomA, pData);
    
    
    uint8_t bBytes[256];
    result =SecRandomCopyBytes(kSecRandomDefault, 256, (void*)bBytes);
    NSAssert(result == 0, @"随机数生成失败");
    
    NSData *randomB = [[NSData alloc] initWithBytes:bBytes length:256];
    NSData *gBBytes = MTExp(gData, randomB, pData);
    
    /// gBBytes^randomA % pData
    NSData* keya = MTExp(gBBytes, randomA, pData);
    /// gABytes^randomB % pData
    NSData* keyb = MTExp(gABytes, randomB, pData);
    
    NSAssert([keya isEqual:keyb], @"key不相等");
}

- (void)gmpRandom {
    long seed; int count;
    gmp_randstate_t california; mpz_t  n, temp;
    
    gmp_randinit(california, 0, 128); mpz_init(n); mpz_init(temp);
    mpz_set_str(n,"25135566567101483196994790440833279750474660393232382279277736257066266618532493517139001963526957179514521981877335815379755618191324858392834843718048308951653115284529736874534289456833723962912807104017411854314007953484461899139734367756070456068592886771130491355511301923675421649355211882120329692353507392677087555292357140606251171702417804959957862991259464749806480821163999054978911727901705780417863120490095024926067731615229486812312187386108568833026386220686253160504779704721744600638258183939573405528962511242337923530869616215532193967628076922234051908977996352800560160181197923404454023908443",10);
    
    /* use time (in seconds) to set the value of seed: */
    time (&seed);
    gmp_randseed_ui (california, seed);
    
    for(count=5; count; count--)
    {
        mpz_urandomm (temp, california, n);
        mpz_out_str (stdout, 10, temp);
    }
    
    gmp_randclear (california); mpz_clear(n); mpz_clear(temp);
}

- (void)testDH {
    PairKey* a = [RCDH generatePairKey];
    PairKey* b = [RCDH generatePairKey];
    NSString* akey = [RCDH computeKey:b.pubKey privKey:a.privKey];
    NSString* bKey = [RCDH computeKey:a.pubKey privKey:b.privKey];
    
    NSString* encrypt = [RCDH encryptMessage:@"defafjdkalfdslafds2513556656710148319699479044083327975047466039323238227927773625706626661853249351713900196352695717951452198187733581537975561819132485839283484371804830895165311528452973687453428945683372396291280710401741185431400795348446189913973436775607045606859288677113049135551130192367542164935521188212032969235350739267708755529235714060625117170241780495995786299125946474980648082116399905497891172790170578041786312049009502492606773161522948681231218738610856883302638622068625316050477970472174460063825818393957340552896251124233792353086961621553219396762807692223405190897799635280056016018119792340445402390844384309241234567890abcdef" key:akey];
    NSString* decrpty = [RCDH decryptMessage:encrypt key:akey];
    
    
    NSAssert([akey isEqual:bKey], @"key不相等");
    
    
    NSString* url = @"https://et-rce-test-guanyu.rongcloud.net/admin/#/login";
//    NSCharacterSet* charSet = [NSCharacterSet characterSetWithCharactersInString:@"#"].invertedSet;
//    url = [url stringByAddingPercentEncodingWithAllowedCharacters:charSet];
//    charSet = [NSCharacterSet characterSetWithCharactersInString:@"#"];
//     url = [url stringByAddingPercentEncodingWithAllowedCharacters:charSet];
    
    NSMutableCharacterSet* mcharSet = [[NSMutableCharacterSet alloc] init];
    [mcharSet formIntersectionWithCharacterSet:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    [mcharSet formIntersectionWithCharacterSet:[NSCharacterSet URLHostAllowedCharacterSet]];
    [mcharSet formIntersectionWithCharacterSet:[NSCharacterSet URLPasswordAllowedCharacterSet]];
    [mcharSet formIntersectionWithCharacterSet:[NSCharacterSet URLPathAllowedCharacterSet]];
    [mcharSet formIntersectionWithCharacterSet:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [mcharSet formIntersectionWithCharacterSet:[NSCharacterSet URLUserAllowedCharacterSet]];
    //[mcharSet removeCharactersInString:@"#"];
    NSData* data =  mcharSet.bitmapRepresentation;
    NSString* string  = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:mcharSet.invertedSet];
    NSLog(@"%@",url);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- p;
//- g;
//- (XA,YA)random();
//-NSString* generateKey(const char *random, const char *remoteKey);
//- encode:key data:
//- decode:key data


@end
