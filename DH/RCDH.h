//
//  DH.h
//  DH
//
//  Created by birneysky on 2018/5/21.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PairKey : NSObject

@property(nonatomic,copy,readonly) NSString* pubKey;
@property(nonatomic,copy,readonly) NSString* privKey;

@end


@interface RCDH : NSObject

+ (PairKey*)generatePairKey;
+ (NSString*)computeKey:(NSString*)pubKey privKey:(NSString*)privKey;
+ (NSString *)encryptMessage:(NSString *)json key:(NSString *)key;
+ (NSString *)decryptMessage:(NSString *)json key:(NSString *)key;

@end
