//
//  RTSettingTableViewController.m
//  RTCTester
//
//  Created by birney on 2019/1/11.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "GSSettingTableViewController.h"
//#import <RongRTCLib/RongRTCLib.h>
#import "GSPickerContainer.h"
#import "GSSetingItem.h"

NSString* const RTCellReuseIdentifyKey = @"reuseIdentify";
NSString* const RTCellSettingNameKey = @"settingName";
NSString* const RTCellSettingValueKey = @"settingvalue";

@interface GSSettingTableViewController ()

@property(nonatomic,copy,readonly) NSArray<GSSettingGroupItem*>* dataSource;
@property(nonatomic,copy,readonly) NSArray* videoPresetOptions;
@property(nonatomic,copy,readonly) NSArray* frameRateOptions;
@property(nonatomic,copy,readonly) NSArray* beautyOptions;
@property(nonatomic,strong) GSSettingGroupItem* videoPresets;
@property(nonatomic,strong) GSSettingGroupItem* frameRates;
@property(nonatomic,strong) GSSettingGroupItem* beautys;
@property (strong, nonatomic) IBOutlet GSPickerContainer *pickerContainer;
@end

@implementation GSSettingTableViewController

@synthesize dataSource = _dataSource;
@synthesize videoPresetOptions = _videoPresetOptions;
@synthesize frameRateOptions = _frameRateOptions;
@synthesize beautyOptions = _beautyOptions;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [UIView new];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Target Action

- (IBAction)okAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource[section].options.count;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.dataSource[section].title;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GSSettingGroupItem* groupItem = self.dataSource[indexPath.section];
    GSSetingItem* item = [groupItem.options objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:groupItem.reuseKey forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = item.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self.pickerContainer.frame = (CGRect){0,screenSize.height,screenSize.width,200};
    [self.navigationController.view addSubview:self.pickerContainer];
    [UIView animateWithDuration:0.25 animations:^{
        self.pickerContainer.frame = (CGRect){0,screenSize.height-200,screenSize.width,200};
    }];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//#pragma mark - Getters
//
//- (NSArray*)videoPresetOptions {
//    if (!_videoPresetOptions) {
//        _videoPresetOptions = @[@(RongRTCVideoSizePresetLow),
//                                @(RongRTCVideoSizePresetMedium),
//                                @(RongRTCVideoSizePresetHigh),
//                                @(RongRTCVideoSizePreset320x240),
//                                @(RongRTCVideoSizePreset352x288),
//                                @(RongRTCVideoSizePreset960x540),
//                                @(RongRTCVideoSizePreset1280x720),
//                                @(RongRTCVideoSizePreset1920x1080)];
//    }
//    return _videoPresetOptions;
//}
//
//
//- (NSArray<RTSetingItem*>*)arrayWithItems:(NSArray<NSDictionary*>*)dicArray {
//    NSMutableArray* array = [[NSMutableArray alloc] initWithCapacity:10];
//    [dicArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        [array addObject:[[RTSetingItem alloc] init:obj]];
//    }];
//    return [array copy];
//}
//
//- (RTSettingGroupItem*)videoPresets {
//    if (!_videoPresets) {
//        NSArray* options = @[@{RTNameKey:@"RongRTCVideoSizePresetLow",RTValueKey:@(RongRTCVideoSizePresetLow)},
//                             @{RTNameKey:@"RongRTCVideoSizePresetMedium",RTValueKey:@(RongRTCVideoSizePresetMedium)},
//                             @{RTNameKey:@"RongRTCVideoSizePresetHigh",RTValueKey:@(RongRTCVideoSizePresetHigh)},
//                             @{RTNameKey:@"RongRTCVideoSizePreset320x240",RTValueKey:@(RongRTCVideoSizePreset320x240)},
//                             @{RTNameKey:@"RongRTCVideoSizePreset352x288",RTValueKey:@(RongRTCVideoSizePreset352x288)},
//                             @{RTNameKey:@"RongRTCVideoSizePreset960x540",RTValueKey:@(RongRTCVideoSizePreset960x540)},
//                             @{RTNameKey:@"RongRTCVideoSizePreset1280x720",RTValueKey:@(RongRTCVideoSizePreset1280x720)},
//                             @{RTNameKey:@"RongRTCVideoSizePreset1920x1080",RTValueKey:@(RongRTCVideoSizePreset1920x1080)}];
//        options = [self arrayWithItems:options];
//        _videoPresets = [[RTSettingGroupItem alloc] init:@{RTReuseKey:@"checkMarkCell",
//                                                           RTTitleKey:@"Video Resolution",
//                                                           RTOptionskey:options
//                                                           }];
//    }
//    return _videoPresets;
//}
//
//- (RTSettingGroupItem*)beautys {
//    if (!_beautys) {
//        NSArray* options = @[@{RTNameKey:@"YES",RTValueKey:@(YES)},@{RTNameKey:@"NO",RTValueKey:@(NO)}];
//        options = [self arrayWithItems:options];
//        _beautys = [[RTSettingGroupItem alloc] init:@{RTReuseKey:@"switchCell",
//                                                      RTTitleKey:@"Video Filter",
//                                                      RTOptionskey:options
//                                                      }];
//    }
//    return _beautys;
//}
//
//- (NSArray*)frameRateOptions {
//    if (!_frameRateOptions) {
//        _frameRateOptions = @[ @(RongRTCVideoFPS5),
//                               @(RongRTCVideoFPS10),
//                               @(RongRTCVideoFPS15),
//                               @(RongRTCVideoFPS20),
//                               @(RongRTCVideoFPS25)];
//    }
//    return _frameRateOptions;
//}
//
//- (RTSettingGroupItem*)frameRates {
//    if (!_frameRates) {
//        NSArray* options = @[ @{RTNameKey:@"RongRTCVideoFPS5",RTValueKey:@(RongRTCVideoFPS5)},
//                              @{RTNameKey:@"RongRTCVideoFPS10",RTValueKey:@(RongRTCVideoFPS10)},
//                              @{RTNameKey:@"RongRTCVideoFPS5",RTValueKey:@(RongRTCVideoFPS15)},
//                              @{RTNameKey:@"RongRTCVideoFPS15",RTValueKey:@(RongRTCVideoFPS20)},
//                              @{RTNameKey:@"RongRTCVideoFPS25",RTValueKey:@(RongRTCVideoFPS25)}];
//        options = [self arrayWithItems:options];
//        _frameRates = [[RTSettingGroupItem alloc] init:@{RTReuseKey:@"rightDetailCell",
//                                                         RTTitleKey:@"Frame rate",
//                                                         RTOptionskey:options
//                                                         }];
//    }
//    return _frameRates;
//}

- (NSArray*)beautyOptions {
    if (!_beautyOptions) {
        _beautyOptions = @[@(YES),@(NO)];
    }
    return _beautyOptions;
}

- (NSArray*)dataSource {
    if (!_dataSource) {
        _dataSource = @[self.videoPresets,self.frameRates,self.beautys];
    }
    return _dataSource;
}
@end
