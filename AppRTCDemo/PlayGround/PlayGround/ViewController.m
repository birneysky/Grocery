//
//  ViewController.m
//  PlayGround
//
//  Created by birney on 2019/1/19.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "ViewController.h"
#import "Model.h"

@interface ViewController ()
@property(nonatomic , strong) dispatch_semaphore_t semLock;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.semLock = dispatch_semaphore_create(0);
    NSString* str = @"{\"type\":\"offer\",\"sdp\":\\r\\n}";
//    dispatch_semaphore_wait(self.semLock, DISPATCH_TIME_FOREVER);
//    long count = dispatch_semaphore_signal(self.semLock); 
//    Model* a = [[Model alloc] init];
//    if([NSJSONSerialization isValidJSONObject:@[a]]) {
//        NSData* data =  [NSJSONSerialization dataWithJSONObject:a options:0 error:nil];
//        NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//    }
}


@end
