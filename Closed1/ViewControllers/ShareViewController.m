//
//  ShareViewController.m
//  Closed1
//
//  Created by Nazim on 27/03/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "ShareViewController.h"
#import "JVFloatLabeledTextView.h"

@interface ShareViewController ()

@property (strong, nonatomic) IBOutlet UIButton *shareDealButton;
@property (strong, nonatomic) IBOutlet JVFloatLabeledTextView *nametextView;
@property (strong, nonatomic) IBOutlet JVFloatLabeledTextView *commentTextView;
@end

@implementation ShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustumNavigationBar];
}

- (void)createCustumNavigationBar
{
    [self.navigationController setNavigationBarHidden:YES];
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x-10, self.view.bounds.origin.y, self.view.frame.size.width+10 , 60)];
    UINavigationItem * navItem = [[UINavigationItem alloc] init];
    
    navBar.items = @[navItem];
    [navBar setBarTintColor:[UIColor colorWithRed:107.0/255.0 green:225.0/255.0 blue:211.0/255.0 alpha:1.0]];
    navBar.translucent = NO;
    [navBar setTintColor:[UIColor whiteColor]];
    [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [navItem setTitle:@"Closed1"];
    [self.view addSubview:navBar];
    
}

@end
