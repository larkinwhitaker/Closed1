//
//  ProfileDetailViewController.m
//  Closed1
//
//  Created by Nazim on 31/03/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "ProfileDetailViewController.h"

@interface ProfileDetailViewController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation ProfileDetailViewController

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
    [navBar setBarTintColor:[UIColor colorWithRed:34.0/255.0 green:187.0/255.0 blue:187.0/255.0 alpha:1.0]];
    navBar.translucent = NO;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"BackButton"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped:)];
    
    navItem.leftBarButtonItem = backButton;
    
    
    
    [navBar setTintColor:[UIColor whiteColor]];
    [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [navItem setTitle:@"Sign up"];
    [self.view addSubview:navBar];
    
}
-(IBAction)backButtonTapped:(UIBarButtonItem *)sender

{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)backButtontapped: (id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Tableview Delegate


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileTableViewCell"];
    
    return cell;
    
}



@end
