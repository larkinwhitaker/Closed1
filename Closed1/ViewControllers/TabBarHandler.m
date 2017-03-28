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

@interface TabBarHandler ()

@end

@implementation TabBarHandler

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(profileUpdatedSucessFully) name:@"ProfileEdited" object:nil];
//    [self setViewControllers:@[homeScreen, navController5]];
    
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
