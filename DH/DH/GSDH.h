//
//  DH.h
//  DH
//
//  Created by birneysky on 2018/5/21.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSPairKey : NSObject

@property(nonatomic,copy,readonly) NSString* pubKey;
@property(nonatomic,copy,readonly) NSString* privKey;

@end


/**
 DH 对称加密工具类
 */
@interface GSDH : NSObject

/**
 随机生成私有密钥和公开密钥
 
 @return RCPairKey 实例
 */
+ (GSPairKey*)generatePairKey;

/**
 根据对方pubKey和自己的privKey计算对称加密密钥
 
 @param pubKey 对方的公开密钥
 @param privKey 自己私有密钥
 @return 返回对称密钥
 */
+ (NSString*)computeKey:(NSString*)pubKey privKey:(NSString*)privKey;

/**
 加密消息
 
 @param plainJson 明文消息的json字符串
 @param key 对称加密密钥
 @return 返回加密后的数据
 */
+ (NSString *)encryptMessage:(NSString *)plainJson key:(NSString *)key;

/**
 解密消息
 
 @param cipherJson 消息密文
 @param key 对称加密密钥
 @return 返回解密后的数据
 */
+ (NSString *)decryptMessage:(NSString *)cipherJson key:(NSString *)key;

@end
