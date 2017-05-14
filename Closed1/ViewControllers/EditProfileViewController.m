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
#import "MagicalRecord.h"
#import "UserDetails+CoreDataClass.h"
#import "ClosedResverResponce.h"
#import "EditProfileViewController.h"
#import "JobProfileCell.h"

#define kTitle @"Title"
#define kCopmpany @"Company"
#define kTerritory @"Territory"
#define kTargetBuyers @"Target Buyers"
#define kisCurrentPosition @"CurrentPosition"


@interface EditProfileViewController ()<UITableViewDelegate, UITableViewDataSource,SelectedCountryDelegate, ServerFailedDelegate, UITextFieldDelegate>
{
    EditProfileTableViewCell *editProfileCell;
    NSInteger rowCount;
}
@property(nonatomic) NSMutableArray *flightDetailsArray;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _flightDetailsArray = [[NSMutableArray alloc]init];
    [_flightDetailsArray addObject:[self configureFlightDetailsDictionary]];
    [self.tableView registerNib:[UINib nibWithNibName:@"JobProfileCell" bundle:nil] forCellReuseIdentifier:@"JobProfileCell"];

    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectZero];
    
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    UIButton *updateProfile = [[UIButton alloc]initWithFrame:footerView.frame];
    [updateProfile setTitle:@"Update Profile" forState:UIControlStateNormal];
    [updateProfile addTarget:self action:@selector(updateProfileTapped:) forControlEvents:UIControlEventTouchUpInside];
    updateProfile.titleLabel.textColor = [UIColor whiteColor];
    updateProfile.backgroundColor = [UIColor colorWithRed:34.0/255.0 green:187.0/255.0 blue:187.0/255.0 alpha:1.0];
    [footerView addSubview:updateProfile];
    
    self.tableView.tableFooterView = footerView;
    
    [self createCustumNavigationBar];
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectZero];
    
    rowCount = 2;

}

-(NSMutableDictionary *)configureFlightDetailsDictionary
{
    NSMutableDictionary *flightDetails = [[NSMutableDictionary alloc]init];
    [flightDetails setValue:@"" forKey:kTitle];
    [flightDetails setValue:@"" forKey:kCopmpany];
    [flightDetails setValue:@"" forKey:kTerritory];
    [flightDetails setValue:@"" forKey:kTargetBuyers];
    [flightDetails setValue:[NSNumber numberWithBool:NO] forKey:kisCurrentPosition];
    
    return flightDetails;
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

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0) return  1;
    else if (section == 1) return _flightDetailsArray.count;
    else return 0;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0) return 689;
    else return 360;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        editProfileCell = [tableView dequeueReusableCellWithIdentifier:@"EditProfileTableViewCell"];
        
        [editProfileCell.countryButton addTarget:self action:@selector(openCountrySelectionScreen) forControlEvents:UIControlEventTouchUpInside];
        
#pragma mark - Remove Code
        
        UserDetails *userDetails = [UserDetails MR_findFirst];
        
        editProfileCell.emailTextField.text = userDetails.userEmail;
        editProfileCell.fullNameTextField.text = [NSString stringWithFormat:@"%@ %@", userDetails.firstName, userDetails.lastName];
        editProfileCell.citytextField.text = userDetails.city;
        editProfileCell.stateTextField.text = userDetails.state;
        editProfileCell.phoneNumberTextField.text = userDetails.phoneNumber;
        [editProfileCell.countryButton setTitle:userDetails.country forState:UIControlStateNormal];
        editProfileCell.companyNameTextField.text = userDetails.company;
        editProfileCell.designationTextField.text = userDetails.title;
        editProfileCell.terrotoryTextField.text = userDetails.territory;
        editProfileCell.secondaryEmail.text = userDetails.econdaryemail;
        [editProfileCell.countryButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [editProfileCell.updateButton addTarget:self action:@selector(updateProfileTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        
        return editProfileCell;
    }else{
        
        JobProfileCell *jobCell = [tableView dequeueReusableCellWithIdentifier:@"JobProfileCell"];
        [jobCell.addNewJob addTarget:self action:@selector(addmoreCell:) forControlEvents:UIControlEventTouchUpInside];
        [jobCell.removeJob addTarget:self action:@selector(removeJobProfile:) forControlEvents:UIControlEventTouchUpInside];
        jobCell.titleTextField.delegate = self;
        jobCell.companyTextField.delegate = self;
        jobCell.territoryTextFiled.delegate = self;
        jobCell.targetBuyersTextFiled.delegate = self;
        jobCell.removeJob.tag = indexPath.row;
        jobCell.addNewJob.tag = indexPath.row;
        jobCell.titleTextField.tag = indexPath.row;
        jobCell.companyTextField.tag = indexPath.row;
        jobCell.territoryTextFiled.tag = indexPath.row;
        jobCell.targetBuyersTextFiled.tag = indexPath.row;
        [jobCell.isCurrentPosition addTarget:self action:@selector(currentJobSelected:) forControlEvents:UIControlEventValueChanged];
        jobCell.isCurrentPosition.tag = indexPath.row;
        
        jobCell.titleTextField.text = [[_flightDetailsArray objectAtIndex:indexPath.row] valueForKey:kTitle];
        jobCell.companyTextField.text = [[_flightDetailsArray objectAtIndex:indexPath.row] valueForKey:kCopmpany];
        jobCell.territoryTextFiled.text = [[_flightDetailsArray objectAtIndex:indexPath.row] valueForKey:kTerritory];
        jobCell.targetBuyersTextFiled.text = [[_flightDetailsArray objectAtIndex:indexPath.row] valueForKey:kTargetBuyers];

        
        return jobCell;
    }
    
}

-(void)currentJobSelected: (UISwitch *)sender{
    
//    [[_flightDetailsArray objectAtIndex:sender.tag] setBool:sender.isSelected forKey:kisCurrentPosition];
}

-(void)addmoreCell: (UIButton *)sender
{
    if (_flightDetailsArray.count>4) {
        
        [[[UIAlertView alloc]initWithTitle:@"Oops!!" message:@"You cannot add more job profiles" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        
    }else{
        
        NSMutableArray *indexPathsToInsert = [[NSMutableArray alloc] init];
        [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:_flightDetailsArray.count inSection:1]];
        [_flightDetailsArray addObject:[self configureFlightDetailsDictionary]];
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
        
        [self.tableView reloadData];
    }
}

-(void)removeJobProfile: (UIButton *)sender{
    
    if (_flightDetailsArray.count<2) {
        
        [[[UIAlertView alloc]initWithTitle:@"Adding nothing??" message:@"Please add atleast one job profile" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        
    }else{
        
        NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
        [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:sender.tag inSection:1]];
        [_flightDetailsArray removeObjectAtIndex:sender.tag];
        
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
        
        [self.tableView reloadData];

    }

}

#pragma mark - TextField Delegates

-(void)textFieldDidEndEditing:(JVFloatLabeledTextField *)textField
{
    [[self.flightDetailsArray objectAtIndex:textField.tag] setValue:textField.text forKey:textField.placeholder];
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
    [self.view endEditing:YES];
    
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
    }else if([[editProfileCell.secondaryEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0){
        
        [self animateView:editProfileCell.secondaryEmail];
        
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

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *labelText = @"";
    
    if (section == 0) {
        labelText = @"Profile Details";
    }else if (section == 1){
        labelText = @"Job / Position Information";
    }
    
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    label.font = [UIFont boldSystemFontOfSize:16.0];
    label.textColor = [UIColor darkGrayColor];
    label.text = labelText;
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    [headerView addSubview:label];
    headerView.backgroundColor = [UIColor colorWithRed:38.0/255.0 green:166.0/255.0 blue:154.0/255.0 alpha:1.0];
    
    return headerView;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

-(void)submitDataToServer
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Hang on,";
    hud.detailsLabelText = @"Updating Profile";
    
    UserDetails *userDetails = [UserDetails MR_findFirst];
    
    NSArray *userNameArray = [editProfileCell.fullNameTextField.text componentsSeparatedByString:@" "];
    
    NSString *firtName = [userNameArray firstObject];
    NSString *lastName = [userNameArray lastObject];
    
    if (firtName == lastName) {
        
        lastName = @"";
    }
    
    
 NSString *urlName = [NSString stringWithFormat:@"http://socialmedia.alkurn.info/api-mobile/?function=update_profile&user_id=%zd&firstname=%@&lastname=%@&username=%@&email=%@&fullname=%@&city=%@&state=%@&country=%@&phone=%@&title=%@&company=%@&territory=%@&secondary_email=%@", userDetails.userID,firtName, lastName, userDetails.userLogin,userDetails.userEmail,editProfileCell.fullNameTextField.text,editProfileCell.citytextField.text,editProfileCell.stateTextField.text,editProfileCell.countryButton.titleLabel.text,editProfileCell.phoneNumberTextField.text,editProfileCell.designationTextField.text,editProfileCell.companyNameTextField.text,editProfileCell.terrotoryTextField.text,editProfileCell.secondaryEmail.text];
    
    [ClosedResverResponce sharedInstance].delegate = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        NSArray *serverResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer:urlName DictionartyToServer:@{}];
        
        NSLog(@"%@", serverResponce);
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            if ([serverResponce valueForKey:@"success"] != nil) {
                
                if ([[serverResponce valueForKey:@"success"] integerValue] == 1) {
                    
                    [self saveUserProfile:[serverResponce valueForKey:@"data"]];
                    
                    [self.navigationController popViewControllerAnimated:YES];
                    
                }else{
                    
                    [self serverFailedWithTitle:@"Oops!@" SubtitleString:@"Failed to update profile. Please try again later."];

                }
                
            }else{
                
                [self serverFailedWithTitle:@"Oops!@" SubtitleString:@"Failed to update profile. Please try again later."];
                
            }
        });
       
        
    });
    
    
    
    
}

-(void)saveUserProfile: (NSDictionary *)userData
{
    UserDetails *userDetails = [UserDetails MR_findFirst];
    
    userDetails.firstName = [userData valueForKey:@"firstname"];
    userDetails.lastName = [userData valueForKey:@"lastname"];
    userDetails.userEmail = editProfileCell.emailTextField.text;
    userDetails.title = editProfileCell.designationTextField.text;
    userDetails.company = editProfileCell.companyNameTextField.text;
    userDetails.state = editProfileCell.stateTextField.text;
    userDetails.phoneNumber = editProfileCell.phoneNumberTextField.text;
    userDetails.city = editProfileCell.citytextField.text;
    userDetails.country = editProfileCell.countryButton.titleLabel.text;
    userDetails.territory = editProfileCell.terrotoryTextField.text;
    userDetails.econdaryemail = editProfileCell.secondaryEmail.text;
    userDetails.profileImage = [userData valueForKey:@"profile_image"];
    
    [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
    
    UserDetails *user = [UserDetails MR_findFirst];
    NSLog(@"%@", user.firstName);
    NSLog(@"%zd", user.userID);

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

-(void)serverFailedWithTitle:(NSString *)title SubtitleString:(NSString *)subtitle
{
    dispatch_async(dispatch_get_main_queue(), ^{
       
        [[[UIAlertView alloc]initWithTitle:title message:subtitle delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
    });
}

@end
