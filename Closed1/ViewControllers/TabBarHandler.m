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
#import "ChatsView.h"
#import "NavigationController.h"

#import "PJXAnimatedTabBarController.h"
#import "PJXAnimatedTabBarItem.h"
#import "PJXIconView.h"

// Animations
#import "PJXBounceAnimation.h"
#import "PJXFumeAnimation.h"
#import "PJXRotationAnimation.h"
#import "PJXFrameItemAnimation.h"
#import "Closed1-Swift.h"

@interface TabBarHandler ()

@end

@implementation TabBarHandler

- (void)viewDidLoad {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(profileUpdatedSucessFully) name:@"ProfileEdited" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationRecieved:) name:@"Notificationrecived" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationForMessageRecieved:) name:@"NotificationMessage" object:nil];

    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newFeedsAvailable) name:@"NewFeedsAvilable" object:nil];
    
    
    
    PJXBounceAnimation *bounceAnimation = [[PJXBounceAnimation alloc] init];
    bounceAnimation.textSelectedColor = [UIColor colorWithRed:38.0/255.0 green:166.0/255.0 blue:154.0/255.0 alpha:1.0];
    bounceAnimation.iconSelectedColor = [UIColor colorWithRed:38.0/255.0 green:166.0/255.0 blue:154.0/255.0 alpha:1.0];
    
    PJXAnimatedTabBarItem *firstTabBarItem = [[PJXAnimatedTabBarItem alloc] initWithTitle:@"Home" image:[UIImage imageNamed:@"HomeTabBarSelectedImage"] selectedImage:nil];
    firstTabBarItem.animation = bounceAnimation;
    firstTabBarItem.textColor = [UIColor colorWithRed:227.0/255.0 green:181.0/255.0 blue:5.0/255.0 alpha:1.0];
    
    HomeScreenViewController *homeScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeScreenViewController"];
    homeScreen.tabBarItem = firstTabBarItem;
    
    PJXAnimatedTabBarItem *secondTabBarItem = [[PJXAnimatedTabBarItem alloc] initWithTitle:@"Contacts" image:[UIImage imageNamed:@"ContactsTabBarSelectedImage"] selectedImage:nil];
    secondTabBarItem.animation = bounceAnimation;
    secondTabBarItem.badgeValue = @"2";
    secondTabBarItem.textColor = [UIColor colorWithRed:227.0/255.0 green:181.0/255.0 blue:5.0/255.0 alpha:1.0];
    NSInteger total = [[NSUserDefaults standardUserDefaults] integerForKey:@"FreindRequestCount"];
    secondTabBarItem.badgeValue = (total != 0) ? [NSString stringWithFormat:@"%ld", (long) total] : nil;

    ContactsListViewController *contactScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"ContactsListViewController"];
//    ContactsViewController *contactScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"ContactsViewController"];
    contactScreen.tabBarItem = secondTabBarItem;
    contactScreen.iscameFromChatScreen = NO;
    contactScreen.tabBarItem.badgeValue = (total != 0) ? [NSString stringWithFormat:@"%ld", (long) total] : nil;
    PJXAnimatedTabBarItem *thirdTabBarItem = [[PJXAnimatedTabBarItem alloc] initWithTitle:@"Search" image:[UIImage imageNamed:@"SearchTabBarSelectedImage"] selectedImage:nil];
    thirdTabBarItem.animation = bounceAnimation;
    thirdTabBarItem.textColor = [UIColor colorWithRed:227.0/255.0 green:181.0/255.0 blue:5.0/255.0 alpha:1.0];
    SearchViewController *searchView = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
    searchView.tabBarItem = thirdTabBarItem;

    
    PJXAnimatedTabBarItem *fourthTabBarItem = [[PJXAnimatedTabBarItem alloc] initWithTitle:@"Share Deal" image:[UIImage imageNamed:@"ShareTabBarSelectedImage"] selectedImage:nil];
    fourthTabBarItem.animation = bounceAnimation;
    fourthTabBarItem.textColor = [UIColor colorWithRed:227.0/255.0 green:181.0/255.0 blue:5.0/255.0 alpha:1.0];
ShareViewController *shareDeal = [self.storyboard instantiateViewControllerWithIdentifier:@"ShareViewController"];
    shareDeal.tabBarItem = fourthTabBarItem;
    
    PJXAnimatedTabBarItem *fifthTabBarItem = [[PJXAnimatedTabBarItem alloc] initWithTitle:@"Setting" image:[UIImage imageNamed:@"SettingsTabBarSelected"] selectedImage:nil];
    fifthTabBarItem.animation = bounceAnimation;
    fifthTabBarItem.textColor = [UIColor colorWithRed:227.0/255.0 green:181.0/255.0 blue:5.0/255.0 alpha:1.0];
    SettingsViewController *settings = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    settings.tabBarItem = fifthTabBarItem;
    
    
    self.viewControllers = @[homeScreen, contactScreen,shareDeal, searchView, settings];
    
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


-(void)newFeedsAvailable

{
    [self selectetabTabWithselcetdIndex:0];

    /*
    NSArray<PJXAnimatedTabBarItem *> *items = (NSArray<PJXAnimatedTabBarItem *> *)self.tabBar.items;
    
    NSInteger currentIndex = 3;
    
    if(self.tabBarController != nil && self.tabBarController.delegate != nil && [self.tabBarController.delegate respondsToSelector:@selector(tabBarController:shouldSelectViewController:)] && ![self.tabBarController.delegate tabBarController:self.tabBarController shouldSelectViewController:self]) {
        return ;
    }
    
    if (self.selectedIndex != currentIndex) {
        PJXAnimatedTabBarItem *animationItem = (PJXAnimatedTabBarItem *)items[currentIndex];
        [animationItem playAnimation];
        
        //PJXAnimatedTabBarItem *deselectItem = (PJXAnimatedTabBarItem *)items[3];
        //[deselectItem deselectAnimation];
        
        PJXAnimatedTabBarItem *selectedItem = (PJXAnimatedTabBarItem *)items[0];
        [selectedItem selectedState];

        
        self.selectedIndex = 0;
        
        if (self.tabBarController != nil && self.tabBarController.delegate != nil && [self.tabBarController.delegate respondsToSelector:@selector(tabBarController:didSelectViewController:)]) {
            [self.tabBarController.delegate tabBarController:self.tabBarController didSelectViewController:self];
        }
    } else if (self.selectedIndex == currentIndex) {
        if (self.viewControllers[self.selectedIndex]) {
            if (self.viewControllers.count == 1) {
                UINavigationController *navVC = (UINavigationController *)self.viewControllers[self.selectedIndex];
                if (navVC) {
                    [navVC popToRootViewControllerAnimated:YES];
                }
            }
        }
    }
     
     */
}


-(void)notificationRecieved: (NSNotification *)notifcation
{
    self.selectedIndex = 1;
    
    FreindRequestViewController  *freinds = [self.storyboard instantiateViewControllerWithIdentifier:@"FreindRequestViewController"];
    [self.navigationController pushViewController:freinds animated:YES];

    [self selectetabTabWithselcetdIndex:1];
}

-(void)notificationForMessageRecieved: (NSNotification *)notification
{
    
    self.selectedIndex = 0;
    ChatsView *chatsView = [[ChatsView alloc] initWithNibName:@"ChatsView" bundle:nil];
    
    NavigationController *navController1 = [[NavigationController alloc] initWithRootViewController:chatsView];
    
    [self presentViewController:navController1 animated:YES completion:nil];
    
    [self newFeedsAvailable];
    
    
}

-(void)selectetabTabWithselcetdIndex: (NSInteger) index
{
    NSArray<PJXAnimatedTabBarItem *> *items = (NSArray<PJXAnimatedTabBarItem *> *)self.tabBar.items;
    
    
    for (NSInteger i = 0; i<items.count; i++) {
        PJXAnimatedTabBarItem *deselectItem = (PJXAnimatedTabBarItem *)items[i];
        [deselectItem deselectAnimation];
    }
    
    
    PJXAnimatedTabBarItem *selectedItem = (PJXAnimatedTabBarItem *)items[index];
    [selectedItem selectedState];
}

@end
