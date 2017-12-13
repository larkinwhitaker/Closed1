//
//  SettingsViewController.m
//  Closed1
//
//  Created by Nazim on 27/03/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingsTableViewCell.h"
#import "EditProfileViewController.h"
#import "ChangePasswordViewController.h"
#import "ContactDetails+CoreDataProperties.h"
#import "MagicalRecord.h"
#import "UIImageView+WebCache.h"
#import "UINavigationController+NavigationBarAttribute.h"
#import "ClosedResverResponce.h"
#import "UserDetails+CoreDataClass.h"
#import "MBProgressHUD.h"
#import "utilities.h"
#import "JobProfile+CoreDataProperties.h"
#import "CardDetails+CoreDataProperties.h"
#import "CreditCardViewController.h"
#import "RewardsViewController.h"
#import "EditFeedsViewController.h"

@interface SettingsViewController ()<UITableViewDataSource, UITableViewDelegate, CreditCardDelegate>
@property(nonatomic) NSMutableDictionary *creditCardDictionary;
@property(nonatomic) RewardsViewController *rewardsScreen;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustumNavigationBar];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableData) name:@"NewFeedsAvilable" object:nil];
    
    CardDetails *cardDetails = [CardDetails MR_findFirst];
    
    self.rewardsScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"RewardsViewController"];

    self.creditCardDictionary = [[NSMutableDictionary alloc]init];
    [self.creditCardDictionary setValue:cardDetails.cardnumber forKey:@"cardnumber"];
    [self.creditCardDictionary setValue:cardDetails.cardexpirydate forKey:@"cardexpirydate"];
    [self.creditCardDictionary setValue:cardDetails.cvvtext forKey:@"CreditCardCVV"];
    [self.creditCardDictionary setValue:cardDetails.cardname forKey:@"cardname"];
    [self.creditCardDictionary setValue:cardDetails.cardimagename forKey:@"cardimagename"];
    
    [self.creditCardDictionary setValue:cardDetails.cardencryptedtext forKey:@"cardencryptedtext"];
    [self.creditCardDictionary setValue:cardDetails.cvvimageName forKey:@"creditcardCVVImage"];

}

-(void)reloadTableData
{
    [self.tableView reloadData];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadTableData];

    [self.navigationController setNavigationBarHidden:YES];
    
}

- (IBAction)myDealsButtonTapped:(id)sender {
    
    EditFeedsViewController *userfeedsScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"EditFeedsViewController"];
    [self.navigationController pushViewController:userfeedsScreen animated:YES];
}


- (IBAction)claimrewardsPatted:(id)sender {
    
    [self.navigationController pushViewController:self.rewardsScreen animated:YES];

    
}
- (IBAction)changePasswordTapped:(id)sender {
    
    ChangePasswordViewController *changePassword = [self.storyboard instantiateViewControllerWithIdentifier:@"ChangePasswordViewController"];
    changePassword.userEmail = @"aasif.demo@gmail.com";
    [self.navigationController pushViewController:changePassword animated:YES];
}

- (void)createCustumNavigationBar
{
    [self.navigationController setNavigationBarHidden:YES];
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x-10, self.view.bounds.origin.y, self.view.frame.size.width+10 , 60)];
    UINavigationItem * navItem = [[UINavigationItem alloc] init];
    
    navBar.items = @[navItem];
    [navBar setBarTintColor:[UIColor colorWithRed:38.0/255.0 green:166.0/255.0 blue:154.0/255.0 alpha:1.0]];
    navBar.translucent = NO;
    [navBar setTintColor:[UIColor whiteColor]];
    [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [navItem setTitle:@"Settings"];
    [self.view addSubview:navBar];
    
}

-(void)selectedCreditCardDetails:(NSMutableDictionary *)creditCardDetailsDictionary
{
    NSLog(@"%@", creditCardDetailsDictionary);
    
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

#pragma mark - TableView Delegates

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 636;
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserDetails *userDetails = [UserDetails MR_findFirst];
    
    SettingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsTableViewCell"];
    [cell.emailButton addTarget:self action:@selector(emaiButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.gemeralButton addTarget:self action:@selector(openGeneralView) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.profileButton addTarget:self action:@selector(profileVisibility) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.deleteButton addTarget:self action:@selector(deleteButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.editProfile addTarget:self action:@selector(editProfileTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.cancelSubscriptionButton addTarget:self action:@selector(cancelSubscriptionTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.updateCardButton addTarget:self action:@selector(updateCardDetailsTapped:) forControlEvents:UIControlEventTouchUpInside];

    
    cell.userNameLabel.text = userDetails.firstName;
    
    [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:userDetails.profileImage] placeholderImage:[UIImage imageNamed:@"male-circle-128.png"]];
    
    return cell;
}


-(void)editProfileTapped
{
    EditProfileViewController *editProfileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EditProfileViewController"];
    
    [self.navigationController pushViewController:editProfileVC animated:YES];
}

-(void)updateCardDetailsTapped: (id) sender
{
    CreditCardViewController *creditCardScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"CreditCardViewController"];
    creditCardScreen.delegate = self;
    creditCardScreen.isUpdateCarDetails = YES;
    creditCardScreen.creditCardDetails = self.creditCardDictionary;
    [self.navigationController pushViewController:creditCardScreen animated:YES];
}

-(void)cancelSubscriptionTapped: (id) sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Cancel Subscription ?" message:@"Are you sure want to cancel the subscription?" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
        [self callApiForCancelSubscription];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

-(void)callApiForCancelSubscription
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Hang on,";
    hud.detailsLabelText = @"Cancelling Subscription";
    
    UserDetails *user = [UserDetails MR_findFirst];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *cancelSubscriptionAPiName = [NSString stringWithFormat:@"https://closed1app.com/api-mobile/?function=cancel_membership&user_id=%zd", user.userID];
        
        NSLog(@"%@", cancelSubscriptionAPiName);
        
        NSArray *serverResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer:cancelSubscriptionAPiName DictionartyToServer:@{} IsEncodingRequires:nil];
        
        
        NSLog(@"%@", serverResponce);
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            if (![[serverResponce valueForKey:@"success"] isEqual:[NSNull null]]) {
                
                if ([[serverResponce valueForKey:@"success"] integerValue] == 1) {
                    
                    
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"You are unsubscriped from the current plan. To use the app please subscriped to the plan again." message:nil preferredStyle:UIAlertControllerStyleAlert];
                    
                    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                        
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }]];
                    
                    [self presentViewController:alertController animated:YES completion:nil];
                    
                }else{
                    
                    [[[UIAlertView alloc]initWithTitle:@"Failed to Unsubscibe from plan" message:@"We're are really sorry, but at the current moment we are unable to subscribe you from plan." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                }
            }else{
                [[[UIAlertView alloc]initWithTitle:@"Failed to Unsubscibe from plan" message:@"We're are really sorry, but at the current moment we are unable to subscribe you from plan." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            }
            
            
        });

        
    });

    
}

-(void)openGeneralView
{
    
}

-(void)emaiButtonTapped
{
    
}

-(void)profileVisibility
{
    
}

-(void)deleteButtonTapped
{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Are you sure want to logout?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
        
        [UserDetails MR_truncateAll];
        LogoutUser(DEL_ACCOUNT_ALL);
        [JobProfile MR_truncateAll];
        [CardDetails MR_truncateAll];

        
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        [self.navigationController popToRootViewControllerAnimated:YES];
        
        
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

@end
