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
#import "UserDetails+CoreDataProperties.h"
#import "MagicalRecord.h"
#import "UINavigationController+NavigationBarAttribute.h"

@interface EmailSettingViewController ()<UITabBarDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property(strong, nonatomic) EmailSettingsCell *emailCell;



@end

@implementation EmailSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController configureNavigationBar:self];
    self.tableView.estimatedRowHeight = 400;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
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

//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 500;
//}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    _emailCell = [tableView dequeueReusableCellWithIdentifier:@"EmailSettingsCell"];
    
    NSLog(@"%lu", (unsigned long)_emailCell.freindsSendsSwict.state);
    UserDetails *userDEatils = [UserDetails MR_findFirst];
    
    _emailCell.emailLabel.text = [NSString stringWithFormat:@"A member mentions you in an update using %@",userDEatils.userEmail];
    
    return _emailCell;
}




@end
