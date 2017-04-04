//
//  EmailSettingViewController.m
//  Closed1
//
//  Created by Nazim on 01/04/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "EmailSettingViewController.h"
#import "EmailSettingsCell.h"
#import "MBProgressHUD.h"

@interface EmailSettingViewController ()<UITabBarDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property(strong, nonatomic) EmailSettingsCell *emailCell;

@end

@implementation EmailSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createCustumNavigationBar];
    [self configuretableView];
   
    
}

-(void)configuretableView{
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    UILabel *headerLabel = [[UILabel alloc]initWithFrame: CGRectMake(10, 8, self.view.frame.size.width - 20, 30)];
    headerView.backgroundColor = [UIColor colorWithRed:227.0/255.0 green:181.0/255.0 blue:5.0/255.0 alpha:1.0];
    headerLabel.text = @"Send an email notice when";
    headerLabel.font = [UIFont boldSystemFontOfSize:16.0];
    headerLabel.textColor = [UIColor whiteColor];
    [headerView addSubview:headerLabel];
    self.tableView.tableHeaderView = headerView;
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
    
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonTapped:)];
    
    navItem.rightBarButtonItem = saveButton;
    
    [navBar setTintColor:[UIColor whiteColor]];
    [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [navItem setTitle:@"Email Setting"];
    [self.view addSubview:navBar];
    
}

-(void)saveButtonTapped: (id)sender
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Hang on,";
    hud.detailsLabelText = @"Saving Profile";
    hud.dimBackground = YES;
    
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(profileSavesSucessFully) userInfo:nil repeats:NO];
}

-(void)profileSavesSucessFully
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)backButtonTapped:(UIBarButtonItem *)sender

{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Tbaleview Delegates

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 546;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    _emailCell = [tableView dequeueReusableCellWithIdentifier:@"EmailSettingsCell"];
    
    NSLog(@"%lu", (unsigned long)_emailCell.freindsSendsSwict.state);
    
    return _emailCell;
}




@end
