//
//  main.m
//  URLEncode
//
//  Created by birney on 2018/6/6.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
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
        url = [url stringByAddingPercentEncodingWithAllowedCharacters:mcharSet.invertedSet];
        NSLog(@"%@",url);
        NSLog(@"Hello, World!");
    }
    return 0;
}
