//
//  MainTableViewController.m
//  SearchTTT
//
//  Created by zhaobingdong on 2018/1/6.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "MainTableViewController.h"
#import "STSearchPresentationController.h"
#import "STSearchViewController.h"
#import "STSampleResultController.h"
#import "AppleProduct.h"
#import "STSearchBar.h"

@interface MainTableViewController () <STSearchResultsUpdating>

@property (nonatomic,strong) STSearchViewController* searchVC;
@property (nonatomic,strong) STSampleResultController* sampleResultVC;
@property (nonatomic,strong) NSArray<AppleProduct*>* dataSource;

@end

@implementation MainTableViewController

#pragma mark - Properties
- (STSearchViewController*)searchVC {
    if (!_searchVC) {
        _searchVC = [[STSearchViewController alloc] initWithSearchResultsController:self.sampleResultVC];
        _searchVC.searchResultsUpdater = self;
    }
    return _searchVC;
}

- (STSampleResultController*)sampleResultVC {
    if (!_sampleResultVC) {
        _sampleResultVC = [[STSampleResultController alloc] init];
    }
    return _sampleResultVC;
}

- (NSArray<AppleProduct*>*)dataSource {
    if (!_dataSource) {
        _dataSource = @[[AppleProduct productWithType:[AppleProduct deviceTypeTitle]
                                               name:@"iPhone"
                                               year:@2007
                                              price:@599.00],
                        [AppleProduct productWithType:[AppleProduct deviceTypeTitle]
                                               name:@"iPod"
                                               year:@2001
                                              price:@399.00],
                        [AppleProduct productWithType:[AppleProduct deviceTypeTitle]
                                               name:@"iPod touch"
                                               year:@2007
                                              price:@210.00],
                        [AppleProduct productWithType:[AppleProduct deviceTypeTitle]
                                               name:@"iPad"
                                               year:@2010
                                              price:@499.00],
                        [AppleProduct productWithType:[AppleProduct deviceTypeTitle]
                                               name:@"iPad mini"
                                               year:@2012
                                              price:@659.00],
                        [AppleProduct productWithType:[AppleProduct deviceTypeTitle]
                                               name:@"iMac"
                                               year:@1997
                                              price:@1299.00],
                        [AppleProduct productWithType:[AppleProduct deviceTypeTitle]
                                               name:@"Mac Pro"
                                               year:@2006
                                              price:@2499.00],
                        [AppleProduct productWithType:[AppleProduct portableTypeTitle]
                                               name:@"MacBook Air"
                                               year:@2008
                                              price:@1799.00],
                        [AppleProduct productWithType:[AppleProduct portableTypeTitle]
                                               name:@"MacBook Pro"
                                               year:@2006
                                              price:@1499.00]
                        ];
    }
    return _dataSource;
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Main Tab";
    self.tableView.tableHeaderView = (UIView*)self.searchVC.searchBar;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    self.definesPresentationContext = YES;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

}
    
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
    


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MainCell" forIndexPath:indexPath];
    AppleProduct* product = self.dataSource[indexPath.row];
    // Configure the cell...
    cell.textLabel.text = product.title;
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    NSString *priceString = [numberFormatter stringFromNumber:product.introPrice];
    
    NSString *detailedStr = [NSString stringWithFormat:@"%@ | %@", priceString, (product.yearIntroduced).stringValue];
    cell.detailTextLabel.text = detailedStr;
    return cell;
}

#pragma mark - Target Action

- (IBAction)newAction:(id)sender {
    STSearchViewController *secondViewController = [[STSearchViewController alloc] init];
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:secondViewController];
    nav.navigationBarHidden = YES;
    STSearchPresentationController *presentationController NS_VALID_UNTIL_END_OF_SCOPE;
    
    presentationController = [[STSearchPresentationController alloc] initWithPresentedViewController:nav presentingViewController:self];
    
    nav.transitioningDelegate = presentationController;
    
    [self presentViewController:nav animated:YES completion:NULL];
}

- (IBAction)cancelAction:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - RCESearchResultsUpdating
- (void)updateSearchResultsForSearchController:(STSearchViewController *)searchController {
    NSString *searchText = searchController.searchBar.text;
    NSMutableArray *searchResults = [self.dataSource mutableCopy];
    
    // strip out all the leading and trailing spaces
    NSString *strippedString = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // break up the search terms (separated by spaces)
    NSArray *searchItems = nil;
    if (strippedString.length > 0) {
        searchItems = [strippedString componentsSeparatedByString:@" "];
    }
    
    // build all the "AND" expressions for each value in the searchString
    //
    NSMutableArray *andMatchPredicates = [NSMutableArray array];
    
    for (NSString *searchString in searchItems) {
        // each searchString creates an OR predicate for: name, yearIntroduced, introPrice
        //
        // example if searchItems contains "iphone 599 2007":
        //      name CONTAINS[c] "iphone"
        //      name CONTAINS[c] "599", yearIntroduced ==[c] 599, introPrice ==[c] 599
        //      name CONTAINS[c] "2007", yearIntroduced ==[c] 2007, introPrice ==[c] 2007
        //
        NSMutableArray *searchItemsPredicate = [NSMutableArray array];
        
        // Below we use NSExpression represent expressions in our predicates.
        // NSPredicate is made up of smaller, atomic parts: two NSExpressions (a left-hand value and a right-hand value)
        
        // name field matching
        NSExpression *lhs = [NSExpression expressionForKeyPath:@"title"];
        NSExpression *rhs = [NSExpression expressionForConstantValue:searchString];
        NSPredicate *finalPredicate = [NSComparisonPredicate
                                       predicateWithLeftExpression:lhs
                                       rightExpression:rhs
                                       modifier:NSDirectPredicateModifier
                                       type:NSContainsPredicateOperatorType
                                       options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        
        // yearIntroduced field matching
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.numberStyle = NSNumberFormatterNoStyle;
        NSNumber *targetNumber = [numberFormatter numberFromString:searchString];
        if (targetNumber != nil) {   // searchString may not convert to a number
            lhs = [NSExpression expressionForKeyPath:@"yearIntroduced"];
            rhs = [NSExpression expressionForConstantValue:targetNumber];
            finalPredicate = [NSComparisonPredicate
                              predicateWithLeftExpression:lhs
                              rightExpression:rhs
                              modifier:NSDirectPredicateModifier
                              type:NSEqualToPredicateOperatorType
                              options:NSCaseInsensitivePredicateOption];
            [searchItemsPredicate addObject:finalPredicate];
            
            // price field matching
            lhs = [NSExpression expressionForKeyPath:@"introPrice"];
            rhs = [NSExpression expressionForConstantValue:targetNumber];
            finalPredicate = [NSComparisonPredicate
                              predicateWithLeftExpression:lhs
                              rightExpression:rhs
                              modifier:NSDirectPredicateModifier
                              type:NSEqualToPredicateOperatorType
                              options:NSCaseInsensitivePredicateOption];
            [searchItemsPredicate addObject:finalPredicate];
        }
        
        // at this OR predicate to our master AND predicate
        NSCompoundPredicate *orMatchPredicates = [NSCompoundPredicate orPredicateWithSubpredicates:searchItemsPredicate];
        [andMatchPredicates addObject:orMatchPredicates];
    }
    
    // match up the fields of the Product object
    NSCompoundPredicate *finalCompoundPredicate =
    [NSCompoundPredicate andPredicateWithSubpredicates:andMatchPredicates];
    searchResults = [[searchResults filteredArrayUsingPredicate:finalCompoundPredicate] mutableCopy];
    
    self.sampleResultVC.products = [searchResults copy];
    [self.sampleResultVC.tableView reloadData];
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

@end
