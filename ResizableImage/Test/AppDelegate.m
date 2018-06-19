//
//  AppDelegate.m
//  Test
//
//  Created by birney on 2018/3/2.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSString* a = [[NSMutableString alloc] initWithUTF8String:"xxxxxx"];
    NSString* b = [a copy];
    NSLog(@"retainCount %d",(int)CFGetRetainCount((__bridge CFTypeRef)(a)));

    NSLog(@"retainCount %d",(int)CFGetRetainCount((__bridge CFTypeRef)(b)));
    NSLog(@"retainCount %zd",[[b valueForKey:@"retainCount"] integerValue]);
    
//    NSUInteger count = [a retainCount];
//    NSLog(@"retainCount %zd",(int)[a retainCount]);
    //NSLog(@"retainCount %zd",(int)[b retainCount]);
    [self tttt:a];
    [a substringFromIndex:3];
    return YES;
}

- (void)tttt:(id)object {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(2);
        NSLog(@"are you  %@",object);
    }) ;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
