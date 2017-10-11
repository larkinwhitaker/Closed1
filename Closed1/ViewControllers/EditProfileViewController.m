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
#import "JobProfile+CoreDataProperties.h"
#import "CreditCardViewController.h"
#import "CardDetails+CoreDataProperties.h"

#define kTitle @"title"
#define kCopmpany @"company"
#define kTerritory @"territory"
#define kTargetBuyers @"target"
#define kisCurrentPosition @"current_position"


@interface EditProfileViewController ()<UITableViewDelegate, UITableViewDataSource,SelectedCountryDelegate, ServerFailedDelegate, UITextFieldDelegate, CreditCardDelegate>
{
    EditProfileTableViewCell *editProfileCell;
    NSInteger rowCount;
    
}
@property(nonatomic) NSMutableArray *flightDetailsArray;
@property(nonatomic) NSMutableDictionary *creditCardDictionary;
@property(nonatomic) NSMutableDictionary *userProfiledetails;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _flightDetailsArray = [[NSMutableArray alloc]init];
    
    
    CardDetails *cardDetails = [CardDetails MR_findFirst];
    
    self.creditCardDictionary = [[NSMutableDictionary alloc]init];
    [self.creditCardDictionary setValue:cardDetails.cardnumber forKey:@"cardnumber"];
    [self.creditCardDictionary setValue:cardDetails.cardexpirydate forKey:@"cardexpirydate"];
    [self.creditCardDictionary setValue:cardDetails.cvvtext forKey:@"CreditCardCVV"];
    [self.creditCardDictionary setValue:cardDetails.cardname forKey:@"cardname"];
    [self.creditCardDictionary setValue:cardDetails.cardimagename forKey:@"cardimagename"];
    
    [self.creditCardDictionary setValue:cardDetails.cardencryptedtext forKey:@"cardencryptedtext"];
    [self.creditCardDictionary setValue:cardDetails.cvvimageName forKey:@"creditcardCVVImage"];
    
    UserDetails *userDetails = [UserDetails MR_findFirst];
    
    self.userProfiledetails = [[NSMutableDictionary alloc]init];
    [self.userProfiledetails setValue: userDetails.userEmail forKey:@"userEmail"];
    [self.userProfiledetails setValue:userDetails.firstName forKey:@"firstName"];
    [self.userProfiledetails setValue:userDetails.city forKey:@"city"];
    [self.userProfiledetails setValue:userDetails.state forKey:@"state"];
    [self.userProfiledetails setValue:userDetails.phoneNumber forKey:@"phoneNumber"];
    [self.userProfiledetails setValue:userDetails.country forKey:@"country"];
    [self.userProfiledetails setValue:userDetails.company forKey:@"company"];
    [self.userProfiledetails setValue:userDetails.title forKey:@"title"];
    [self.userProfiledetails setValue:userDetails.territory forKey:@"territory"];
    [self.userProfiledetails setValue:userDetails.econdaryemail forKey:@"econdaryemail"];
    
    NSArray *jobArray = [JobProfile MR_findAll];
    
    if (jobArray.count == 0) {
        
        [_flightDetailsArray addObject:[self configureFlightDetailsDictionary]];
        
    }else{
       
        UserDetails *user = [UserDetails MR_findFirst];

        
        for (JobProfile *job in jobArray) {
            
            
            NSString *jobPriofile = @"off";
            if (job.currentPoistion != nil) {
                jobPriofile = job.currentPoistion;
            }
            
            
            NSMutableDictionary *jobDict = [[NSMutableDictionary alloc ]init];
            [jobDict setObject:job.title forKey:kTitle];
            [jobDict setObject:job.targetBuyers forKey:kTargetBuyers];
            [jobDict setObject:job.compnay forKey:kCopmpany];
            [jobDict setObject:job.territory forKey:kTerritory];
            [jobDict setObject:jobPriofile forKey:kisCurrentPosition];
            [jobDict setObject:job.jobid forKey:@"id"];
            [jobDict setObject:[NSNumber numberWithInteger:user.userID] forKey:@"user_id"];
            [self.flightDetailsArray addObject:jobDict];
        }
        
    }
    
    
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
    
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectZero];
    
    rowCount = 2;

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createCustumNavigationBar];

}


-(NSMutableDictionary *)configureFlightDetailsDictionary
{
    
    UserDetails *user = [UserDetails MR_findFirst];
    
    NSMutableDictionary *flightDetails = [[NSMutableDictionary alloc]init];
    [flightDetails setValue:@"" forKey:kTitle];
    [flightDetails setValue:@"" forKey:kCopmpany];
    [flightDetails setValue:@"" forKey:kTerritory];
    [flightDetails setValue:@"" forKey:kTargetBuyers];
    [flightDetails setValue:@"off" forKey:kisCurrentPosition];
    [flightDetails setValue:[NSNumber numberWithInteger:user.userID] forKey:@"user_id"];
    [flightDetails setValue:@"off" forKey:@"chkbox"];
    [flightDetails setObject:@"" forKey:@"id"];
    

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
    
//    UIBarButtonItem *cardButton = [[UIBarButtonItem alloc]initWithTitle:@"Show Card" style:UIBarButtonItemStylePlain target:self action:@selector(openCardScreen)];

    UIButton *addFreinds = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [addFreinds setImage:[UIImage imageNamed:@"CreditcardDefaultImage.png"] forState:UIControlStateNormal];
    [addFreinds addTarget:self action:@selector(openCardScreen) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *cardButton = [[UIBarButtonItem alloc]initWithCustomView:addFreinds];
    
    navItem.rightBarButtonItem = cardButton;
    
    
    [navBar setTintColor:[UIColor whiteColor]];
    [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [navItem setTitle:@"Edit Profile"];
    [self.view addSubview:navBar];
    
}

-(void)openCardScreen
{
    CreditCardViewController *creditCardScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"CreditCardViewController"];
    creditCardScreen.delegate = self;
    creditCardScreen.creditCardDetails = self.creditCardDictionary;
    [self.navigationController pushViewController:creditCardScreen animated:YES];
}

-(void)selectedCreditCardDetails:(NSMutableDictionary *)creditCardDetailsDictionary
{
    NSLog(@"%@", creditCardDetailsDictionary);
    [editProfileCell.showCardButton setTitle:[creditCardDetailsDictionary valueForKey:@"cardencryptedtext"] forState:UIControlStateNormal];
    
    
    [self.creditCardDictionary setValue:[creditCardDetailsDictionary valueForKey:@"cardnumber"] forKey:@"cardnumber"];
    [self.creditCardDictionary setValue:[creditCardDetailsDictionary valueForKey:@"cardexpirydate"] forKey:@"cardexpirydate"];
    [self.creditCardDictionary setValue:[creditCardDetailsDictionary valueForKey:@"CreditCardCVV"] forKey:@"CreditCardCVV"];
    [self.creditCardDictionary setValue:[creditCardDetailsDictionary valueForKey:@"cardname"] forKey:@"cardname"];
    [self.creditCardDictionary setValue:[creditCardDetailsDictionary valueForKey:@"cardimagename"] forKey:@"cardimagename"];
    
    [self.creditCardDictionary setValue:[creditCardDetailsDictionary valueForKey:@"cardencryptedtext"] forKey:@"cardencryptedtext"];
    [self.creditCardDictionary setValue:[creditCardDetailsDictionary valueForKey:@"creditcardCVVImage"] forKey:@"creditcardCVVImage"];
    
    
    
    [CardDetails MR_truncateAll];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext){
        
        CardDetails *cardDetails = [CardDetails MR_createEntityInContext:localContext];
        
        cardDetails.cardname = [creditCardDetailsDictionary valueForKey:@"cardname"];
        cardDetails.cardencryptedtext = [creditCardDetailsDictionary valueForKey:@"cardencryptedtext"];
        cardDetails.cardexpirydate = [creditCardDetailsDictionary valueForKey:@"cardexpirydate"];
        cardDetails.cardimagename = [creditCardDetailsDictionary valueForKey:@"cardimagename"];
        cardDetails.cardnumber = [creditCardDetailsDictionary valueForKey:@"cardnumber"];
        cardDetails.cvvtext = [creditCardDetailsDictionary valueForKey:@"CreditCardCVV"];
        cardDetails.cvvimageName = [creditCardDetailsDictionary valueForKey:@"creditcardCVVImage"];
        
        [localContext MR_saveToPersistentStoreAndWait];
    }];
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
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
    if(indexPath.section == 0) return 513;
    else return 360;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        editProfileCell = [tableView dequeueReusableCellWithIdentifier:@"EditProfileTableViewCell"];
        
        [editProfileCell.countryButton addTarget:self action:@selector(openCountrySelectionScreen) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        editProfileCell.emailTextField.text = [self.userProfiledetails valueForKey:@"userEmail"];
        editProfileCell.fullNameTextField.text = [NSString stringWithFormat:@"%@", [self.userProfiledetails valueForKey:@"firstName"]];
        editProfileCell.citytextField.text = [self.userProfiledetails valueForKey:@"city"];
        editProfileCell.stateTextField.text = [self.userProfiledetails valueForKey:@"state"];
        editProfileCell.phoneNumberTextField.text = [self.userProfiledetails valueForKey:@"phoneNumber"];
        editProfileCell.countryTextField.text = [self.userProfiledetails valueForKey:@"country"];
        editProfileCell.companyNameTextField.text = [self.userProfiledetails valueForKey:@"company"];
        editProfileCell.designationTextField.text = [self.userProfiledetails valueForKey:@"title"];
        editProfileCell.terrotoryTextField.text = [self.userProfiledetails valueForKey:@"territory"];
        editProfileCell.secondaryEmail.text = [self.userProfiledetails valueForKey:@"econdaryemail"];
        
         if([self.creditCardDictionary valueForKey:@"cardencryptedtext"] != nil){
             [editProfileCell.showCardButton setTitle:[self.creditCardDictionary valueForKey:@"cardencryptedtext"] forState:UIControlStateNormal];

         }
        [editProfileCell.showCardButton addTarget:self action:@selector(openCardScreen) forControlEvents:UIControlEventTouchUpInside];
        
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
        jobCell.isCurrentPosition.tag = indexPath.row;

        [jobCell.isCurrentPosition addTarget:self action:@selector(currentJobSelected:) forControlEvents:UIControlEventValueChanged];
        
        jobCell.titleTextField.text = [[_flightDetailsArray objectAtIndex:indexPath.row] valueForKey:kTitle];
        jobCell.companyTextField.text = [[_flightDetailsArray objectAtIndex:indexPath.row] valueForKey:kCopmpany];
        jobCell.territoryTextFiled.text = [[_flightDetailsArray objectAtIndex:indexPath.row] valueForKey:kTerritory];
        jobCell.targetBuyersTextFiled.text = [[_flightDetailsArray objectAtIndex:indexPath.row] valueForKey:kTargetBuyers];

        BOOL isSetON = NO;
        
        if ([[[_flightDetailsArray objectAtIndex:indexPath.row] valueForKey:kisCurrentPosition] isEqual:@"on"]) {
            
            isSetON = YES;
        }
        
        [jobCell.isCurrentPosition setOn:isSetON];
        
        return jobCell;
    }
    
}

-(void)currentJobSelected: (UISwitch *)sender{
    
    
    for (NSDictionary *job in _flightDetailsArray) {
        
        [job setValue:@"off" forKey:kisCurrentPosition];
    }
    
    
    NSInteger index = sender.tag;
    
    NSLog(@"%zd", index);
    
    if (sender.isOn) {
        
        [[self.flightDetailsArray objectAtIndex:index] setObject:@"on" forKey:kisCurrentPosition];
        
    }else{
        [[self.flightDetailsArray objectAtIndex:index] setObject:@"off" forKey:kisCurrentPosition];
        
        
    }
    
//    [self.tableView reloadData];
    
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
    if ([textField.placeholder isEqualToString:@"Title"]) {
        
        [[self.flightDetailsArray objectAtIndex:textField.tag] setValue:textField.text forKey:kTitle];

        
    }else if ([textField.placeholder isEqualToString:@"Company"]){
        [[self.flightDetailsArray objectAtIndex:textField.tag] setValue:textField.text forKey:kCopmpany];

    }else if ([textField.placeholder isEqualToString:@"Territory"]){
        [[self.flightDetailsArray objectAtIndex:textField.tag] setValue:textField.text forKey:kTerritory];

    }else if ([textField.placeholder isEqualToString:@"Target Buyers"]){
        [[self.flightDetailsArray objectAtIndex:textField.tag] setValue:textField.text forKey:kTargetBuyers];

    }else if ([textField.placeholder isEqualToString:@"Full Name"]){
        
        [self.userProfiledetails setValue:textField.text forKey:@"firstName"];
        
    }else if ([textField.placeholder isEqualToString:@"Phone Number"]){
        
        [self.userProfiledetails setValue:textField.text forKey:@"phoneNumber"];
        
    }else if ([textField.placeholder isEqualToString:@"Email"]){
    
        [self.userProfiledetails setValue: textField.text forKey:@"userEmail"];
        
    }else if ([textField.placeholder isEqualToString:@"Secondary Email"]){
        
        [self.userProfiledetails setValue:textField.text forKey:@"econdaryemail"];
        
    }else if ([textField.placeholder isEqualToString:@"City"]){
        
        [self.userProfiledetails setValue:textField.text forKey:@"city"];
        
    }else if ([textField.placeholder isEqualToString:@"State"]){
        
        [self.userProfiledetails setValue:textField.text forKey:@"state"];
    }
    
    
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
    
     if ([[editProfileCell.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ==0) {
        
         [[[UIAlertView alloc]initWithTitle:@"Email Missing" message:@"Please enter your email ID" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
        
        
    }else if ([[editProfileCell.fullNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ==0) {
        
        [[[UIAlertView alloc]initWithTitle:@"Name Missing" message:@"Please enter your full name" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];


        
    }
    else if ([[editProfileCell.citytextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ==0) {
        
        [[[UIAlertView alloc]initWithTitle:@"City Missing" message:@"Please enter your city" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];

        
    }
    else if ([[editProfileCell.stateTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ==0) {
        
        [[[UIAlertView alloc]initWithTitle:@"State Missing" message:@"Please enter your state" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];


        
    }
    else if ([[editProfileCell.phoneNumberTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ==0) {
        
        [[[UIAlertView alloc]initWithTitle:@"Phone number Missing" message:@"Please enter your phone number" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];

        
    }else if ([[editProfileCell.countryTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ==0){
        
        [[[UIAlertView alloc]initWithTitle:@"Oops!!" message:@"Please select the city first to move ahead" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
    }else if([[editProfileCell.secondaryEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0){
        
        [[[UIAlertView alloc]initWithTitle:@"Primary Email Invalid" message:@"Please enter a valid email ID" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];

        
    }else{
    
        NSString *emailReg = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailReg];
        if([emailPredicate evaluateWithObject: editProfileCell.emailTextField.text] == NO){
            
           [[[UIAlertView alloc]initWithTitle:@"Secondary Email Invalid" message:@"Please enter a valid email ID" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
            
            
        }else{
            
            [self submitDataToServer];
        }
        
        
    }
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *labelText = @"";
    
    if (section == 0) {
        labelText = @"Personal Information";
    }else if (section == 1){
        labelText = @"Job / Position Information";
    }
    
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    label.font = [UIFont boldSystemFontOfSize:16.0];
    label.textColor = [UIColor whiteColor];
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
    
    
    
    NSDictionary *dictionaryToSevrer = @{
        @"user_id": [NSNumber numberWithInteger:userDetails.userID],
        @"firstname": firtName,
        @"lastname": lastName,
        @"email": userDetails.userEmail,
        @"fullname": editProfileCell.fullNameTextField.text,
        @"city": editProfileCell.citytextField.text,
        @"state": editProfileCell.stateTextField.text,
        @"country": editProfileCell.countryTextField.text,
        @"phone": editProfileCell.phoneNumberTextField.text,
        @"title": [[_flightDetailsArray objectAtIndex:0] valueForKey:kTitle],
        @"company": [[_flightDetailsArray objectAtIndex:0] valueForKey:kCopmpany],
        @"territory": [[_flightDetailsArray objectAtIndex:0] valueForKey:kTerritory],
        @"secondary_email": editProfileCell.secondaryEmail.text,
        @"profile_job": self.flightDetailsArray,
        @"target": [[_flightDetailsArray objectAtIndex:0] valueForKey:kTargetBuyers]
        };
    
    
    
 NSString *urlName = @"https://closed1app.com/api-mobile/?function=update_profile";
    
    [ClosedResverResponce sharedInstance].delegate = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        NSArray *serverResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer:urlName DictionartyToServer:dictionaryToSevrer IsEncodingRequires:NO];
        
        NSLog(@"%@", serverResponce);
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            if ([serverResponce valueForKey:@"success"] != nil) {
                
                if ([[serverResponce valueForKey:@"success"] integerValue] == 1) {
                    
                    [self saveUserProfile:[serverResponce valueForKey:@"data"]];
                    
                    [self.navigationController popViewControllerAnimated:YES];
                    
                }else{
                    
                    [self serverFailedWithTitle:@"Oops!!" SubtitleString:@"Failed to update profile. Please try again later."];

                }
                
            }else{
                
                [self serverFailedWithTitle:@"Oops!!" SubtitleString:@"Failed to update profile. Please try again later."];
                
            }
        });
       
        
    });
    
    
    
    
}

-(void)saveUserProfile: (NSDictionary *)userData
{
    UserDetails *userDetails = [UserDetails MR_findFirst];
    
    userDetails.firstName = editProfileCell.fullNameTextField.text;
    userDetails.userEmail = editProfileCell.emailTextField.text;
    userDetails.title = [[_flightDetailsArray objectAtIndex:0] valueForKey:kTitle];
    userDetails.company = [[_flightDetailsArray objectAtIndex:0] valueForKey:kCopmpany];
    userDetails.state = editProfileCell.stateTextField.text;
    userDetails.phoneNumber = editProfileCell.phoneNumberTextField.text;
    userDetails.city = editProfileCell.citytextField.text;
    userDetails.country = editProfileCell.countryTextField.text;
    userDetails.territory = [[_flightDetailsArray objectAtIndex:0] valueForKey:kTerritory];
    userDetails.econdaryemail = editProfileCell.secondaryEmail.text;
    userDetails.profileImage = [userData valueForKey:@"profile_image_url"];
    userDetails.targetBuyers = [[_flightDetailsArray objectAtIndex:0] valueForKey:kTargetBuyers];
    
    [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
    
    UserDetails *user = [UserDetails MR_findFirst];
    NSLog(@"%@", user.firstName);
    NSLog(@"%zd", user.userID);
    
    
    [JobProfile MR_truncateAll];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext){
        
        for (NSDictionary *singleJob in _flightDetailsArray) {
            
            
            
            JobProfile *jobDetails = [JobProfile MR_createEntityInContext:localContext];
            
            jobDetails.title = [singleJob valueForKey:kTitle];
            jobDetails.jobid = [singleJob valueForKey: @"id"];
            jobDetails.territory = [singleJob valueForKey:kTerritory];
            jobDetails.compnay = [singleJob valueForKey:kCopmpany];
            jobDetails.targetBuyers = [singleJob valueForKey:kTargetBuyers];
            jobDetails.currentPoistion = [singleJob valueForKey:kisCurrentPosition];
            
            [localContext MR_saveToPersistentStoreAndWait];
            
            
        }
        
    }];

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
    
    editProfileCell.countryTextField.text = selectedProgram;
    [self.userProfiledetails setValue:selectedProgram forKey:@"country"];
}

-(void)serverFailedWithTitle:(NSString *)title SubtitleString:(NSString *)subtitle
{
    dispatch_async(dispatch_get_main_queue(), ^{
       
        [[[UIAlertView alloc]initWithTitle:title message:subtitle delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
    });
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if (textField == editProfileCell.phoneNumberTextField) {
        
        
        int length = (int)[self getLength:textField.text];
        //NSLog(@"Length  =  %d ",length);
        
        if(length == 10)
        {
            if(range.length == 0)
                return NO;
        }
        
        if(length == 3)
        {
            NSString *num = [self formatNumber:textField.text];
            textField.text = [NSString stringWithFormat:@"(%@) ",num];
            
            if(range.length > 0)
                textField.text = [NSString stringWithFormat:@"%@",[num substringToIndex:3]];
        }
        else if(length == 6)
        {
            NSString *num = [self formatNumber:textField.text];
            //NSLog(@"%@",[num  substringToIndex:3]);
            //NSLog(@"%@",[num substringFromIndex:3]);
            textField.text = [NSString stringWithFormat:@"(%@) %@-",[num  substringToIndex:3],[num substringFromIndex:3]];
            
            if(range.length > 0)
                textField.text = [NSString stringWithFormat:@"(%@) %@",[num substringToIndex:3],[num substringFromIndex:3]];
        }
        
        
        return YES;
    }else{
        
        return YES;
    }
}

- (NSString *)formatNumber:(NSString *)mobileNumber
{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    NSLog(@"%@", mobileNumber);
    
    int length = (int)[mobileNumber length];
    if(length > 10)
    {
        mobileNumber = [mobileNumber substringFromIndex: length-10];
        NSLog(@"%@", mobileNumber);
        
    }
    
    return mobileNumber;
}

- (int)getLength:(NSString *)mobileNumber
{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    int length = (int)[mobileNumber length];
    
    return length;
}


@end
