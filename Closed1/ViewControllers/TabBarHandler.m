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

@interface TabBarHandler ()

@end

@implementation TabBarHandler

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(profileUpdatedSucessFully) name:@"ProfileEdited" object:nil];
//    [self setViewControllers:@[homeScreen, navController5]];
    
    
    ContactsViewController *contactScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"ContactsViewController"];
    
    HomeScreenViewController *homeScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeScreenViewController"];

    SearchViewController *searchView = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
    
    ShareViewController *shareDeal = [self.storyboard instantiateViewControllerWithIdentifier:@"ShareViewController"];
    
    SettingsViewController *settings = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    
    self.viewControllers = @[homeScreen, contactScreen, searchView, shareDeal, settings];
    
    
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)profileUpdatedSucessFully
{
    self.selectedIndex = 0;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
