//
//  RCESearchPresentationController.m
//  Search
//
//  Created by zhaobingdong on 2017/1/7.
//  Copyright © 2017年 Search. All rights reserved.
//

#import "GSSearchPresentationController.h"
#import "GSSearchViewController.h"
#import "GSSearchBarContainerView.h"
#import "GSSearchBar.h"

//! The corner radius applied to the view containing the presented view
//! controller.
#define CORNER_RADIUS   16.f

@interface GSSearchPresentationController () <UIViewControllerAnimatedTransitioning>
@property (nonatomic, weak) UIView *dimmingView;
@property (nonatomic, weak) UIView *presentationWrappingView;
@property (nonatomic, weak) UITableView * originSuperView;
@property (nonatomic, weak) UIView* searchBar;
@property (nonatomic, assign) CGRect originFrme;
@property (nonatomic, strong) GSSearchBarContainerView* searchBarContainer;

@end


@implementation GSSearchPresentationController


- (GSSearchBarContainerView*)searchBarContainer {
    if (!_searchBarContainer) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        _searchBarContainer =[[GSSearchBarContainerView alloc] initWithFrame:(CGRect){0,0,width,44}];
        _searchBarContainer.backgroundColor = [UIColor colorWithRed:201/255.0f green:201/255.0f blue:206/255.0f alpha:1];
    }
    return _searchBarContainer;
}

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController
                       presentingViewController:(UIViewController *)presentingViewController
{
    self = [super initWithPresentedViewController:presentedViewController
                         presentingViewController:presentingViewController];
    if (self) {
        presentedViewController.modalPresentationStyle = UIModalPresentationCustom;
    }
    
    return self;
}

- (BOOL)shouldPresentInFullscreen {
    return NO;
}


- (void)presentationTransitionWillBegin
{

    UIView *presentedViewControllerView = [super presentedView];

    UIView *dimmingView = presentedViewControllerView;

    dimmingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    [dimmingView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dimmingViewTapped:)]];
    self.dimmingView = dimmingView;
    
    [self.containerView removeFromSuperview];
//    //[self.presentingViewController.view.subviews.firstObject.subviews.firstObject addSubview:self.containerView];
//    if ([self.presentingViewController isKindOfClass:[UINavigationController class]]) {
//        UINavigationController* nav = (UINavigationController*)self.presentingViewController;
//        UIViewController* rootVC = nav.viewControllers.firstObject;
//        [rootVC.view.superview addSubview:self.containerView];
//    } else {
        [self.presentingViewController.view.superview addSubview:self.containerView];
//    }
    id<UIViewControllerTransitionCoordinator> transitionCoordinator = self.presentingViewController.transitionCoordinator;

    [transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        dimmingView.backgroundColor = [UIColor colorWithRed:201/255.0f green:201/255.0f blue:206/255.0f alpha:0.5];
    } completion:NULL];
}


- (void)presentationTransitionDidEnd:(BOOL)completed
{
    if (completed == NO)
    {
//        self.presentationWrappingView = nil;
//        self.dimmingView = nil;
    }
}

- (BOOL)shouldRemovePresentersView {
    return NO;
}

- (void)dismissalTransitionWillBegin
{
    id<UIViewControllerTransitionCoordinator> transitionCoordinator = self.presentingViewController.transitionCoordinator;
    
    [transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    } completion:NULL];
}

- (void)dismissalTransitionDidEnd:(BOOL)completed
{
    if (completed == YES)
    {
//        self.presentationWrappingView = nil;
        //self.dimmingView = nil;
    }
}

#pragma mark -
#pragma mark Layout

- (void)preferredContentSizeDidChangeForChildContentContainer:(id<UIContentContainer>)container
{
    [super preferredContentSizeDidChangeForChildContentContainer:container];
    
    if (container == self.presentedViewController)
        [self.containerView setNeedsLayout];
}

- (CGRect)frameOfPresentedViewInContainerView
{
    return self.containerView.bounds;
}


- (void)containerViewWillLayoutSubviews
{
    [super containerViewWillLayoutSubviews];
    
    self.dimmingView.frame = self.containerView.bounds;
//    self.presentationWrappingView.frame = self.frameOfPresentedViewInContainerView;
}

#pragma mark - Gesture selector

- (IBAction)dimmingViewTapped:(UITapGestureRecognizer*)sender
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    [self.searchBar resignFirstResponder];
    [self.presentedViewController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return [transitionContext isAnimated] ? 0.35 : 0;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = transitionContext.containerView;
    
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    BOOL isPresenting = (fromViewController == self.presentingViewController);
    
    CGRect __unused fromViewInitialFrame = [transitionContext initialFrameForViewController:fromViewController];

    CGRect fromViewFinalFrame = [transitionContext finalFrameForViewController:fromViewController];

    CGRect toViewInitialFrame = [transitionContext initialFrameForViewController:toViewController];

    CGRect toViewFinalFrame = [transitionContext finalFrameForViewController:toViewController];
    
    [containerView addSubview:toView];
    
    //O[UIImage imageWithContentsOfFile:<#(nonnull NSString *)#>]

    if (isPresenting) {
        //RCESearchViewController* svc = (RCESearchViewController*)self.presentedViewController;
        UINavigationController* nav = (UINavigationController*)self.presentedViewController;
        GSSearchViewController* svc = (GSSearchViewController*)nav.viewControllers.firstObject;
        GSSearchBar* searchBar = svc.searchBar;
        self.originSuperView = (UITableView*)searchBar.superview;
      
//        self.originSuperView.tableHeaderView = nil;
//        UIView* tempView = [[UIView alloc] initWithFrame:(CGRect){0,0,414,44}];
//        self.originSuperView.tableHeaderView = tempView;
        self.searchBar = searchBar;
        self.originFrme = [searchBar convertRect:searchBar.frame toView:fromView];
        if ([fromViewController respondsToSelector:@selector(setNavigationBarHidden:animated:)]) {
            //UINavigationController* navc = (UINavigationController*)fromViewController;
            //[navc setNavigationBarHidden:YES animated:YES];
            //navigationBar = navc.navigationBar;
        }
        [searchBar removeFromSuperview];
        self.searchBarContainer.frame = self.originFrme;
        searchBar.frame = (CGRect){0,0,self.originFrme.size.width,44};
        [self.searchBarContainer addSubview:searchBar];

        //searchBar.frame = self.originFrme;]

        [containerView addSubview:self.searchBarContainer];
    } else {
//        if ([toViewController respondsToSelector:@selector(setNavigationBarHidden:animated:)]) {
//            UINavigationController* navc = (UINavigationController*)toViewController;
//            [navc setNavigationBarHidden:NO animated:YES];
//        }
        //UIView* searchBar = self.searchBar;
        //[self.searchBar removeFromSuperview];
        //self.originSuperView.tableHeaderView = nil;
        //[self.originSuperView addSubview:searchBar];
        //self.originSuperView.tableHeaderView = searchBar;
    }
    
    


    [UIView animateWithDuration:0.35 animations:^{
        CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
        if (isPresenting) {
            CGRect searchBarFrame = self.searchBar.frame;
            //searchBarFrame.origin.y = statusBarFrame.size.height;
            searchBarFrame.origin.y = 0;
            searchBarFrame.size.height += statusBarFrame.size.height;
            self.searchBarContainer.frame = searchBarFrame;
            searchBarFrame.origin.y = statusBarFrame.size.height;
            searchBarFrame.size.height = 44;
            self.searchBar.frame = searchBarFrame;
            if ([fromViewController respondsToSelector:@selector(setNavigationBarHidden:animated:)]) {
                UINavigationController* navc = (UINavigationController*)fromViewController;
                UINavigationBar* navBar = navc.navigationBar;
                CGRect navFrame = navBar.frame;
                navFrame.origin.y = -44;
                navBar.frame = navFrame;
                CGRect navViewFrame = navc.topViewController.view.frame;
                navViewFrame.origin.y = -44;
                navViewFrame.size.height +=44;
                 navc.topViewController.view.frame = navViewFrame;
            }
        } else {
        
            self.searchBarContainer.frame = self.originFrme;
            self.searchBar.frame = (CGRect){0,0,self.originFrme.size.width,44};
            if ([toViewController respondsToSelector:@selector(setNavigationBarHidden:animated:)]) {
                UINavigationController* navc = (UINavigationController*)toViewController;
                [navc setNavigationBarHidden:NO animated:NO];
                UINavigationBar* navBar = navc.navigationBar;
                CGRect navFrame = navBar.frame;
                navFrame.origin.y = statusBarFrame.size.height;
                navBar.frame = navFrame;
                CGRect navViewFrame = navc.topViewController.view.frame;
                navViewFrame.origin.y = 0;
                navViewFrame.size.height -=44;
                navc.topViewController.view.frame = navViewFrame;
            }
        }

    } completion:^(BOOL finished) {
        if (!isPresenting) {
            
            UIView* searchBar = self.searchBar;
            [self.searchBar removeFromSuperview];
            searchBar.frame = (CGRect){0,0,self.originFrme.size.width,44};
            [self.originSuperView addSubview:searchBar];
        } else {
            [self.searchBar becomeFirstResponder];
        }
        BOOL wasCancelled = [transitionContext transitionWasCancelled];
        [transitionContext completeTransition:!wasCancelled];
    }];
}

#pragma mark - UIViewControllerTransitioningDelegate
- (UIPresentationController*)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source
{
    NSAssert(self.presentedViewController == presented, @"You didn't initialize %@ with the correct presentedViewController.  Expected %@, got %@.",
             self, presented, self.presentedViewController);
    
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self;
}

@end
