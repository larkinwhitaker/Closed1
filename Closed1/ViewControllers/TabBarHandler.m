//
//  TabBarHandler.m
//  Closed1
//
//  Created by Nazim on 27/03/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "TabBarHandler.h"
#import "HomeScreenViewController.h"
#import "SearchViewController.h"
#import "ContactsViewController.h"
#import "ShareViewController.h"
#import "NavigationController.h"
#import "SettingsViewController.h"
#import "FreindRequestViewController.h"

#import "PJXAnimatedTabBarController.h"
#import "PJXAnimatedTabBarItem.h"
#import "PJXIconView.h"

// Animations
#import "PJXBounceAnimation.h"
#import "PJXFumeAnimation.h"
#import "PJXRotationAnimation.h"
#import "PJXFrameItemAnimation.h"

@interface TabBarHandler ()

@end

@implementation TabBarHandler

- (void)viewDidLoad {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(profileUpdatedSucessFully) name:@"ProfileEdited" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationRecieved:) name:@"Notificationrecived" object:nil];
    
    PJXBounceAnimation *bounceAnimation = [[PJXBounceAnimation alloc] init];
    bounceAnimation.textSelectedColor = [UIColor colorWithRed:38.0/255.0 green:166.0/255.0 blue:154.0/255.0 alpha:1.0];
    bounceAnimation.iconSelectedColor = [UIColor colorWithRed:38.0/255.0 green:166.0/255.0 blue:154.0/255.0 alpha:1.0];
    
    PJXRotationAnimation *rotationAnimation = [[PJXRotationAnimation alloc] init];
    rotationAnimation.textSelectedColor = [UIColor colorWithRed:38.0/255.0 green:166.0/255.0 blue:154.0/255.0 alpha:1.0];
    rotationAnimation.iconSelectedColor = [UIColor colorWithRed:38.0/255.0 green:166.0/255.0 blue:154.0/255.0 alpha:1.0];
    
    PJXAnimatedTabBarItem *firstTabBarItem = [[PJXAnimatedTabBarItem alloc] initWithTitle:@"Home" image:[UIImage imageNamed:@"HomeTabBarSelectedImage"] selectedImage:nil];
    firstTabBarItem.animation = bounceAnimation;
    firstTabBarItem.textColor = [UIColor colorWithRed:227.0/255.0 green:181.0/255.0 blue:5.0/255.0 alpha:1.0];
    
    HomeScreenViewController *homeScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeScreenViewController"];
    homeScreen.tabBarItem = firstTabBarItem;
    
    PJXAnimatedTabBarItem *secondTabBarItem = [[PJXAnimatedTabBarItem alloc] initWithTitle:@"Contacts" image:[UIImage imageNamed:@"ContactsTabBarSelectedImage"] selectedImage:nil];
    secondTabBarItem.animation = bounceAnimation;
    secondTabBarItem.textColor = [UIColor colorWithRed:227.0/255.0 green:181.0/255.0 blue:5.0/255.0 alpha:1.0];
    ContactsViewController *contactScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"ContactsViewController"];
    contactScreen.tabBarItem = secondTabBarItem;
    
    PJXAnimatedTabBarItem *thirdTabBarItem = [[PJXAnimatedTabBarItem alloc] initWithTitle:@"Search" image:[UIImage imageNamed:@"SearchTabBarSelectedImage"] selectedImage:nil];
    thirdTabBarItem.animation = rotationAnimation;
    thirdTabBarItem.textColor = [UIColor colorWithRed:227.0/255.0 green:181.0/255.0 blue:5.0/255.0 alpha:1.0];
    SearchViewController *searchView = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
    searchView.tabBarItem = thirdTabBarItem;

    
    PJXAnimatedTabBarItem *fourthTabBarItem = [[PJXAnimatedTabBarItem alloc] initWithTitle:@"Share Deal" image:[UIImage imageNamed:@"ShareTabBarSelectedImage"] selectedImage:nil];
    fourthTabBarItem.animation = rotationAnimation;
    fourthTabBarItem.textColor = [UIColor colorWithRed:227.0/255.0 green:181.0/255.0 blue:5.0/255.0 alpha:1.0];
ShareViewController *shareDeal = [self.storyboard instantiateViewControllerWithIdentifier:@"ShareViewController"];
    shareDeal.tabBarItem = fourthTabBarItem;
    
    PJXAnimatedTabBarItem *fifthTabBarItem = [[PJXAnimatedTabBarItem alloc] initWithTitle:@"Setting" image:[UIImage imageNamed:@"SettingsTabBarSelected"] selectedImage:nil];
    fifthTabBarItem.animation = bounceAnimation;
    fifthTabBarItem.textColor = [UIColor colorWithRed:227.0/255.0 green:181.0/255.0 blue:5.0/255.0 alpha:1.0];
    SettingsViewController *settings = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    settings.tabBarItem = fifthTabBarItem;
    
    
    self.viewControllers = @[homeScreen, contactScreen, searchView, shareDeal, settings];
    
    [super viewDidLoad];

    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)profileUpdatedSucessFully
{
    self.selectedIndex = 0;
}


-(void)notificationRecieved: (NSNotification *)notifcation
{
    self.selectedIndex = 1;
    
    FreindRequestViewController  *freinds = [self.storyboard instantiateViewControllerWithIdentifier:@"FreindRequestViewController"];
    [self.navigationController pushViewController:freinds animated:YES];

    
    
}

@end
