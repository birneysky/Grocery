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
    NSLog(@"😍😍😍😍😍😍😍😍");
    PairKey* a = [RCDH generatePairKey];
    NSLog(@"user A pubKey:%@ \n privKey:%@",a.pubKey,a.privKey);
    PairKey* b = [RCDH generatePairKey];
    NSLog(@"user B pubKey:%@ \n privKey:%@",b.pubKey,b.privKey);
    
//    PairKey* a = [[PairKey alloc] init];
//    a.pubKey = @"8262144295083094748447466975083604735840904769929590280971697976207792014915505804578337303009551631090160639215697310610056546868146537623277317148198621527969569456650419528239263638381584759221267287278263323342164414952377718116718781632292715393438318332031605886251380798122620727725560787149200101428797469144619836314156225370593640851282312512734171559760208886270016226719934942052574644237437972495072564550841186281403424365223961181443384909048020615201708085975763075723157291530524417596885689305254234996987629673344508688619070297908097252303205958925720388463403031198761066008257727429664364334695";
//    a.privKey = @"22696078462868079429303493801684095913626491383309912896895820841848448229467776826628427323645873207521832153671444903643071314589907371766889610276470003596351072286976818940617999754963542356961012378142384403852803873827168893216643374139036171411009184024112791741611280009412963510216892844362952494117145798498784078161275151722533364038485706270522675702954110024802136141278006996615384882470934107834861639558230391837785554382782316699150051702848146260804889781332866756092296414716754192590650876321839774832003131388929972352111783731205232967439905516123327099346068232898139348577851756052222615729618";
//    PairKey* b = [[PairKey alloc] init];
//    b.pubKey = @"8404473753072264609880931368877381098969980104789382280542551220584700360933457034634816764845076723214790727837594870096289897570614516003923527686230602552439897629818694799920479859441235808008352300236949547284433325437299778431027744065942390448343686418302551447537976518956911510257672374087049278954647768347721805778818013614621943501651371693632569519418364741877183678855952817982036183919822360910101462608856319122732861014133447679625693138655591344839885553493955840663461999943855585461303819671173205538546172171456908607954938075424472975091256714114535081776145212537196187858813588720914723950810";
//    b.privKey = @"24334780286750861680714540366933436235356766278555048330555109946817844125950876438389792421180141291799566971692777820823569401056578249805700100246939166370022981897784083529354612450322526538338244262042596257033856239763708699499394402591198413570430100419622641291500679043613087545904819611015680328882124429217520780276220793783478875542076631497512940749408687712562347399505442243734480274473673683116225060384334587622979350615549516603577883679960541622881645902541945171233533584954742779360641210959102832296101855184773995778241552176356874160691991809369911569488746276773402016384018442175239426336144";
    NSString* akey = [RCDH computeKey:b.pubKey privKey:a.privKey];
    NSString* bKey = [RCDH computeKey:a.pubKey privKey:b.privKey];
    
    NSString* plainText = @"Howareyoufinethankyou你好，\t\n\t\f天空灰的向哭过，离开你以后areyou ok🤑🤑🤑 ";
    NSString* encryptText = [RCDH encryptMessage:plainText key:akey];
    NSString* decrpty = [RCDH decryptMessage:encryptText key:akey];
    
    
    NSAssert([akey isEqual:bKey], @"key不相等");
    NSLog(@"key: %@",akey);
    NSLog(@"plain text: %@ \n encrypt text: %@",plainText,encryptText);
    NSLog(@"🤑🤑🤑🤑🤑🤑🤑🤑");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
