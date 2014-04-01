//
//  CalculatorTabBarController.m
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/02/28.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "CalculatorTabBarController.h"
#import "CalculatorViewController.h"
#import "ShareViewController.h"
#import "RecentCommentsTableViewController.h"
#import "ShufflingLabel.h"

@interface CalculatorTabBarController() <UITabBarControllerDelegate>
@end

@implementation CalculatorTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    
    NSArray *tabViewControllers = tabBarController.viewControllers;
    UIView  *fromView = tabBarController.selectedViewController.view;
    UIView  *toView = viewController.view;
    if (fromView == toView)
        return true;
    
    NSUInteger toIndex = [tabViewControllers indexOfObject:viewController];
    
    // get CalculatorViewController
    UIViewController *firstViewController = (tabBarController.viewControllers)[0];
    CalculatorViewController *calculatorViewController = nil;
    if ([firstViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *firstNavViewController = (UINavigationController *)firstViewController;
        if ([[firstNavViewController topViewController] isKindOfClass:[CalculatorViewController class]]) {
            calculatorViewController = (CalculatorViewController *)[firstNavViewController topViewController];
        }
    }
    
    // Move to ShareViewController
    if ([viewController isKindOfClass:[ShareViewController class]]) {
        
        ShareViewController *shareViewController = (ShareViewController *)viewController;
        // pass data
        if (calculatorViewController) {
            shareViewController.conversionMeasure = calculatorViewController.conversionMeasure;
            shareViewController.conversionUnit = calculatorViewController.conversionUnit;
            shareViewController.sourceValueString = calculatorViewController.display.text;
            shareViewController.convertedValueString = calculatorViewController.conversionDisplay.text;
        }
        
    // Move to RecentCommentsTableViewController
    } else if ([viewController isKindOfClass:[UINavigationController class]]) {
        
        UINavigationController *toNavController = (UINavigationController *)viewController;
        if ([[toNavController topViewController] isKindOfClass:[RecentCommentsTableViewController class]]) {
            // pass data
            RecentCommentsTableViewController *recentCommentsViewController = (RecentCommentsTableViewController *)[toNavController topViewController];
            if (calculatorViewController) {
                recentCommentsViewController.managedObjectContext = calculatorViewController.managedObjectContext;
            }
        }
        
    }
    
    // animation transion among tab view
    [UIView transitionFromView:fromView
                        toView:toView
                      duration:0.1
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    completion:^(BOOL finished) {
                        if (finished) {
                            tabBarController.selectedIndex = toIndex;
                        }
                    }];
    
    return true;
}


@end
