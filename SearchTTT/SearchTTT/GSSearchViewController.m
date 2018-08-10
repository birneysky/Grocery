//
//  RCESearchViewController.m
//  Search
//
//  Created by zhaobingdong on 2017/12/6.
//  Copyright © 2017年 Search. All rights reserved.
//

#import "GSSearchViewController.h"
#import "GSSearchPresentationController.h"
#import "GSSearchBar.h"

@interface GSSearchViewController () <GSSearchBarDelegate,UIGestureRecognizerDelegate>
@property (nonatomic,strong) GSSearchBar* searchBar;
@property (nonatomic,strong) UIViewController* searchResultsController;
@property (nonatomic,strong) GSSearchPresentationController *presentationController;
@end

extern NSNotificationName const RCESearchBarResignFirstResponderNotification;
extern NSNotificationName const RCESearchBarInputTextDidChangeNotification;

@implementation GSSearchViewController
#pragma mark - Properties

- (GSSearchBar*)searchBar {
    if (!_searchBar) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        _searchBar = [[GSSearchBar alloc] initWithFrame:(CGRect){0,0,width,44}];
        _searchBar.delegate = self;
    }
    return _searchBar;
}

#pragma mark - Init
- (instancetype)initWithSearchResultsController:(nullable UIViewController *)searchResultsController {
    if (self = [super init]) {
        self.searchResultsController = searchResultsController;
    }
    return self;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Use -initWithSearchResultsController:" userInfo:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addChildViewController:self.searchResultsController];
    [self.view addSubview:self.searchResultsController.view];
    self.searchResultsController.view.frame = self.view.bounds;
    self.searchResultsController.view.hidden = YES;
    self.searchResultsController.view.bounds = self.view.bounds;

    UITapGestureRecognizer* tapGesture =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
    //self.view.backgroundColor = [UIColor blackColor];
    NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
     [defaultCenter addObserver:self
                       selector:@selector(searchBarResign:)
                           name:RCESearchBarResignFirstResponderNotification
                         object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(searchBarInputTextDidChange:)
                          name:RCESearchBarInputTextDidChangeNotification
                        object:nil];
    //self.definesPresentationContext = YES;
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    if ([self.presentingViewController respondsToSelector:@selector(setNavigationBarHidden:animated:)]) {
//        UINavigationController* navc = (UINavigationController*)self.presentingViewController;
//        [navc setNavigationBarHidden:NO animated:NO];
//    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self.presentingViewController respondsToSelector:@selector(setNavigationBarHidden:animated:)]) {
        UINavigationController* navc = (UINavigationController*)self.presentingViewController;
        //[navc setNavigationBarHidden:YES animated:YES];
        navc.delegate = self;
    }
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UIView* view =  navigationController.viewControllers.firstObject.view;
      [view addObserver:self forKeyPath:@"nextResponder" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    if ([viewController isKindOfClass:NSClassFromString(@"RCESampleDetailViewController")]) {
        //[self.view.superview removeFromSuperview];
    } else {
        //[navigationController.view.subviews.firstObject.subviews.firstObject addSubview:self.view.superview];
//        UIView* wrapperView = self.view.superview.superview;
//        [self.view.superview removeFromSuperview];
//        [wrapperView.subviews.firstObject addSubview:self.view.superview];
    }
}
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    UIView* view =  navigationController.viewControllers.firstObject.view;
//    UIView* testView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
//    [navigationController.view addSubview:testView];
}

#pragma mark - Target action
- (void)testAction:(UIButton*)sender {

    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:self];
    nav.navigationBarHidden = YES;
    UIViewController *viewController = [self currentviewController];
    GSSearchPresentationController *presentationController NS_VALID_UNTIL_END_OF_SCOPE;
    
    presentationController = [[GSSearchPresentationController alloc] initWithPresentedViewController:nav
                                                                             presentingViewController:viewController];
    
    nav.transitioningDelegate = presentationController;
    
    [viewController presentViewController:nav animated:YES completion:NULL];
    self.presentationController = presentationController;
}

#pragma mark - Helper
- (UIViewController *)currentviewController {
    for (UIView* next = self.searchBar.superview; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}


#pragma mark - RCESearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(GSSearchBar *)searchBar {
    //UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:self];
    //nav.navigationBarHidden = YES;
    UIViewController *viewController = [self currentviewController];
    GSSearchPresentationController *presentationController NS_VALID_UNTIL_END_OF_SCOPE;
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:self];
    presentationController = [[GSSearchPresentationController alloc] initWithPresentedViewController:nav presentingViewController:viewController];
    
    nav.transitioningDelegate = presentationController;
    
    [viewController presentViewController:nav animated:YES completion:NULL];
    return YES;
}

- (void)searchBarTextDidBeginEditing:(GSSearchBar *)searchBar {

}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (!self.searchResultsController.view.hidden) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - Notification Selector
- (void)searchBarResign:(NSNotification*)notification {
    if (notification.object == self.searchBar) {
        [self dismissViewControllerAnimated:YES completion:^{
//            [self.searchResultsController.view removeFromSuperview];
            self.searchResultsController.view.hidden = YES;
        }];
    }
}

- (void)searchBarInputTextDidChange:(NSNotification*)notification {
    
    if (notification.object == self.searchBar) {
        //        self.view.alpha = 1;
        //        self.view.backgroundColor = [UIColor whiteColor];
        if (self.searchResultsController.view.hidden) {
            self.searchResultsController.view.hidden = NO;
        }
        
        [self.searchResultsUpdater updateSearchResultsForSearchController:self];
    }
    
}

#pragma mark - Gesturer Selector
- (void)tapAction:(UITapGestureRecognizer*)recognizer {
    self.searchBar.text = nil;
    [self.searchBar resignFirstResponder];
    //[self.searchResultsController.view removeFromSuperview];
    self.searchResultsController.view.hidden = YES;
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
}

@end
