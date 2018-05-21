//
//  DH.m
//  DH
//
//  Created by birneysky on 2018/5/21.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "RCDH.h"
#include <gmp.h>
#import <CommonCrypto/CommonCrypto.h>

NSString* const pStr = @"\
2513556656710148319699479044083327975\
0474660393232382279277736257066266618\
53249351713900196352695717951452198187\
73358153797556181913248583928348437180\
48308951653115284529736874534289456833\
72396291280710401741185431400795348446\
18991397343677560704560685928867711304\
91355511301923675421649355211882120329\
69235350739267708755529235714060625117\
17024178049599578629912594647498064808\
21163999054978911727901705780417863120\
49009502492606773161522948681231218738\
61085688330263862206862531605047797047\
21744600638258183939573405528962511242\
33792353086961621553219396762807692223\
40519089779963528005601601811979234044\
54023908443";
NSString* const gStr = @"3";
NSString *const kInitVector = @"0123456789abcdef";
size_t const kKeySize = kCCKeySizeAES128;

@interface PairKey ()

@property(nonatomic,copy) NSString* pubKey;
@property(nonatomic,copy) NSString* privKey;

@end

@implementation PairKey
@end


@implementation RCDH

+ (NSString*)powM:(NSString*)base
              exp:(NSString*)exp
              mod:(NSString*)mod {
    mpz_t mpBase;
    mpz_init(mpBase);
    mpz_init_set_str(mpBase,base.UTF8String,10);
    
    mpz_t mpExp;
    mpz_init(mpExp);
    mpz_init_set_str(mpExp,exp.UTF8String,10);
    
    mpz_t mpMod;
    mpz_init(mpMod);
    mpz_init_set_str(mpMod,mod.UTF8String,10);
    
    mpz_t mpModResult;
    mpz_init(mpModResult);
    mpz_powm_sec(mpModResult,mpBase,mpExp,mpMod);
    
    char* modStr = mpz_get_str(NULL,10,mpModResult);
    NSString* result = [NSString stringWithUTF8String:modStr];
    free(modStr);
    mpz_clear(mpBase);
    mpz_clear(mpExp);
    mpz_clear(mpMod);
    mpz_clear(mpModResult);
    return result;
}

+ (NSString*)random {
    long seed;
    gmp_randstate_t california;
    mpz_t  n, random;
    
    gmp_randinit(california, 0, 128);
    mpz_init(n);
    mpz_init(random);
    mpz_set_str(n,pStr.UTF8String,10);
    
    /* use time (in seconds) to set the value of seed: */
    time (&seed);
    gmp_randseed_ui (california, seed);
    
    mpz_urandomm (random, california, n);

    char* randomStr = mpz_get_str(NULL,10,random);
    NSString* result = [NSString stringWithUTF8String:randomStr];
    free(randomStr);
    gmp_randclear (california);
    mpz_clear(n);
    mpz_clear(random);
    return result;
}

+ (PairKey*)generatePairKey {
    PairKey* pair = [[PairKey alloc] init];
    NSString* random = [RCDH random];
    NSString* key = [RCDH powM:gStr exp:random mod:pStr];
    pair.pubKey = key;
    pair.privKey = random;
    return pair;
}
+ (NSString*)computeKey:(NSString*)pubKey privKey:(NSString*)privKey {
    NSString* key = [RCDH powM:pubKey exp:privKey mod:pStr];
    return key;
}


NSData * cipherOperation(NSData *contentData, NSData *keyData, CCOperation operation) {
    NSUInteger dataLength = contentData.length;
    
    void const *initVectorBytes = [kInitVector dataUsingEncoding:NSUTF8StringEncoding].bytes;
    void const *contentBytes = contentData.bytes;
    void const *keyBytes = keyData.bytes;
    
    size_t operationSize = dataLength + kCCBlockSizeAES128;
    void *operationBytes = malloc(operationSize);
    if (operationBytes == NULL) {
        return nil;
    }
    size_t actualOutSize = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(operation,
                                          kCCAlgorithmAES,
                                          kCCOptionPKCS7Padding,
                                          keyBytes,
                                          kKeySize,
                                          initVectorBytes,
                                          contentBytes,
                                          dataLength,
                                          operationBytes,
                                          operationSize,
                                          &actualOutSize);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:operationBytes length:actualOutSize];
    }
    free(operationBytes);
    operationBytes = NULL;
    return nil;
}

NSData * aesDecryptData(NSData *contentData, NSData *keyData) {
    NSCParameterAssert(contentData);
    NSCParameterAssert(keyData);
    
    NSString *hint = [NSString stringWithFormat:@"The key size of AES-%lu should be %lu bytes!", kKeySize * 8, kKeySize];
    NSCAssert(keyData.length == kKeySize, hint);
    return cipherOperation(contentData, keyData, kCCDecrypt);
}

NSString * aesDecryptString(NSString *content, NSString *key) {
    NSCParameterAssert(content);
    NSCParameterAssert(key);
    
    NSData *contentData = [[NSData alloc] initWithBase64EncodedString:content options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSData *decryptedData = aesDecryptData(contentData, keyData);
    return [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
}

NSData * aesEncryptData(NSData *contentData, NSData *keyData) {
    NSCParameterAssert(contentData);
    NSCParameterAssert(keyData);
    
    NSString *hint = [NSString stringWithFormat:@"The key size of AES-%lu should be %lu bytes!", kKeySize * 8, kKeySize];
    NSCAssert(keyData.length == kKeySize, hint);
    return cipherOperation(contentData, keyData, kCCEncrypt);
}

+ (NSString *)encryptMessage:(NSString *)jsonContent key:(NSString *)key {
    NSCParameterAssert(jsonContent);
    NSCParameterAssert(key);
    
    NSData *contentData = [jsonContent dataUsingEncoding:NSUTF8StringEncoding];
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encrptedData = aesEncryptData(contentData, keyData);
    return [encrptedData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
}

+ (NSString *)decryptMessage:(NSString *)jsonContent key:(NSString *)key {
    NSCParameterAssert(jsonContent);
    NSCParameterAssert(key);
    
    NSData *contentData = [[NSData alloc] initWithBase64EncodedString:jsonContent options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSData *decryptedData = aesDecryptData(contentData, keyData);
    return [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
}



@end
