//
//  EditProfileViewController.m
//  Closed1
//
//  Created by Nazim on 28/03/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "EditProfileViewController.h"
#import "EditProfileTableViewCell.h"
#import "MBProgressHUD.h"
#import "CustomListViewController.h"
#import "TabBarHandler.h"

@interface EditProfileViewController ()<UITableViewDelegate, UITableViewDataSource,SelectedCountryDelegate>
{
    EditProfileTableViewCell *editProfileCell;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectZero];
    
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    [self createCustumNavigationBar];
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectZero];

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
    [navItem setTitle:@"Edit Profile"];
    [self.view addSubview:navBar];
    
}

-(IBAction)backButtonTapped:(UIBarButtonItem *)sender

{
    [self.navigationController popViewControllerAnimated:YES];
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 664;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    editProfileCell = [tableView dequeueReusableCellWithIdentifier:@"EditProfileTableViewCell"];
    
    [editProfileCell.countryButton addTarget:self action:@selector(openCountrySelectionScreen) forControlEvents:UIControlEventTouchUpInside];
    
#pragma mark - Remove Code
    
    editProfileCell.emailTextField.text = @"johndoe@hotmail.com";
    editProfileCell.fullNameTextField.text = @"John Doe";
    editProfileCell.citytextField.text = @"Nagpur";
    editProfileCell.stateTextField.text = @"Maharashtra";
    editProfileCell.phoneNumberTextField.text = @"1234567890";
    [editProfileCell.countryButton setTitle:@"India" forState:UIControlStateNormal];
    editProfileCell.companyNameTextField.text = @"Google LLC";
    editProfileCell.designationTextField.text = @"iOS Developer";
    editProfileCell.terrotoryTextField.text = @"Los Angeles";

    [editProfileCell.countryButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [editProfileCell.updateButton addTarget:self action:@selector(updateProfileTapped:) forControlEvents:UIControlEventTouchUpInside];

    
    return editProfileCell;
}

-(void)openCountrySelectionScreen
{
    CustomListViewController  *listViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CustomListViewController"];
    listViewController.delegate = self;
    listViewController.heightOFRow = 40.0;
    listViewController.title = @"Search Country";
    NSArray *countryList = [self getDataFromJsonFile:@"CountryList"];
    countryList = [countryList valueForKey:@"data"];
    
    NSMutableArray *countryListArray = [[NSMutableArray alloc]init];
    
    for (NSInteger i =0; i<countryList.count; i++) {
        
        [countryListArray addObject:[[countryList objectAtIndex:i] valueForKey:@"Country"]];
    }
    
    listViewController.listArray = [[NSMutableArray alloc]initWithObjects:countryListArray, nil];
    [self presentViewController:listViewController animated:YES completion:nil];
}

-(NSArray *)getDataFromJsonFile: (NSString *)fileName
{
    NSString *filePath = [[NSBundle mainBundle]pathForResource:fileName ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *dataFromlLocal = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    return dataFromlLocal;
}

-(void)updateProfileTapped: (id)sender
{
    if([[editProfileCell.companyNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ==0){
        [self animateView:editProfileCell.companyNameTextField];
    }else if([[editProfileCell.designationTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ==0){
        [self animateView:editProfileCell.designationTextField];
    }else if([[editProfileCell.terrotoryTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ==0){
        [self animateView:editProfileCell.terrotoryTextField];
        
    }else if ([[editProfileCell.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ==0) {
        
        [self animateView:editProfileCell.emailTextField];
        
        
    }else if ([[editProfileCell.fullNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ==0) {
        
        [self animateView:editProfileCell.fullNameTextField];
        [self.tableView setContentOffset:CGPointZero animated:YES];

        
    }
    else if ([[editProfileCell.citytextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ==0) {
        
        [self animateView:editProfileCell.citytextField];
        [self.tableView setContentOffset:CGPointZero animated:YES];

        
    }
    else if ([[editProfileCell.stateTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ==0) {
        
        [self animateView:editProfileCell.stateTextField];
        [self.tableView setContentOffset:CGPointZero animated:YES];

        
    }
    else if ([[editProfileCell.phoneNumberTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ==0) {
        
        [self animateView:editProfileCell.phoneNumberTextField];
        
    }else if ([editProfileCell.countryButton.titleLabel.text isEqualToString:@""]){
        
        [[[UIAlertView alloc]initWithTitle:@"Oops!!" message:@"Please select the city first to move ahead" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
    }else{
        
        NSString *emailReg = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailReg];
        if([emailPredicate evaluateWithObject: editProfileCell.emailTextField.text] == NO){
            
            [self animateView:editProfileCell.emailTextField];
            [self.tableView setContentOffset:CGPointZero animated:YES];
            
            
        }else{
            
            [self submitDataToServer];
        }
        
        
    }
}

-(void)submitDataToServer
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Hang on,";
    hud.detailsLabelText = @"Updating Profile";
    
    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(openHomeScreen) userInfo:nil repeats:NO];
}
-(void)openHomeScreen
{
//    TabBarHandler *tabBarScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"TabBarHandler"];
//    
//    [UIView transitionWithView:self.navigationController.view
//                      duration:0.75
//                       options:UIViewAnimationOptionTransitionFlipFromRight
//                    animations:^{
//                        [self.navigationController pushViewController:tabBarScreen animated:NO];
//                    }
//                    completion:nil];
    
    for (UIViewController *controller in self.navigationController.viewControllers)
    {
        if ([controller isKindOfClass:[TabBarHandler class]])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ProfileEdited" object:nil];
            [self.navigationController popToViewController:controller animated:YES];
            
            break;
        }
    }
    
    
}

-(void)animateView: (JVFloatLabeledTextField *)textField
{
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.duration = 0.07;
    animation.repeatCount = 4;
    animation.autoreverses = YES;
    animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(textField.center.x - 10, textField.center.y)];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(textField.center.x + 10, textField.center.y)];
    [textField.layer addAnimation:animation forKey:@"position"];
    
}

#pragma mark - Country Selected Delegate

-(void)getSelectedIndex:(NSInteger)selectedIndex SelectedProgram:(NSString *)selectedProgram
{
    
    [editProfileCell.countryButton setTitle:selectedProgram forState:UIControlStateNormal];
    [editProfileCell.countryButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}

@end
