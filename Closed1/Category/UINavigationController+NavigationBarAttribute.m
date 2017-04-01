//
//  UINavigationController+NavigationBarAttribute.m
//  Airhob
//
//  Created by mYwindow on 04/08/16.
//  Copyright © 2016 mYwindow Inc. All rights reserved.
//

#import "UINavigationController+NavigationBarAttribute.h"

@implementation UINavigationController (NavigationBarAttribute)

-(void)configureNavigationBar:(UIViewController *)viewController

{
    self.navigationBar.barTintColor = [UIColor colorWithRed:34.0/255.0 green:187.0/255.0 blue:187.0/255.0 alpha:1.0];
    [self setNavigationBarHidden:NO animated:NO];
    self.navigationBar.translucent = NO;
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [self.navigationBar setTintColor:[UIColor whiteColor]];
    
}

@end
