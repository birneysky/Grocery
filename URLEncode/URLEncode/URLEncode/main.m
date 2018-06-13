//
//  main.m
//  URLEncode
//
//  Created by birney on 2018/6/6.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString* encodeURL(NSString* url) {
    NSMutableCharacterSet* mcharSet = [[NSMutableCharacterSet alloc] init];
    [mcharSet formIntersectionWithCharacterSet:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    [mcharSet formIntersectionWithCharacterSet:[NSCharacterSet URLHostAllowedCharacterSet]];
    [mcharSet formIntersectionWithCharacterSet:[NSCharacterSet URLPasswordAllowedCharacterSet]];
    [mcharSet formIntersectionWithCharacterSet:[NSCharacterSet URLPathAllowedCharacterSet]];
    [mcharSet formIntersectionWithCharacterSet:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [mcharSet formIntersectionWithCharacterSet:[NSCharacterSet URLUserAllowedCharacterSet]];
    NSCharacterSet* charSet = [mcharSet copy];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:charSet.invertedSet];
    return url;
}


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        //    NSCharacterSet* charSet = [NSCharacterSet characterSetWithCharactersInString:@"#"].invertedSet;
        //    url = [url stringByAddingPercentEncodingWithAllowedCharacters:charSet];
        //    charSet = [NSCharacterSet characterSetWithCharactersInString:@"#"];
        //     url = [url stringByAddingPercentEncodingWithAllowedCharacters:charSet];
        //[mcharSet removeCharactersInString:@"#"];
        NSString* url = @"https://et-rce-test-guanyu.rongcloud.net/admin/#/login";
        url = encodeURL(url);
        NSLog(@"🤐🤐🤐🤐🤐  %@",url);
        url = @"https://et-rce-test-guanyu.rongcloud.net/admin/#/search?你好，我爱你";
        url = encodeURL(url);
        NSLog(@"🤐🤐🤐🤐🤐 %@",url);
        NSLog(@"Hello, World!");
    }
    return 0;
}
