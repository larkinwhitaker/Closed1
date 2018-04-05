//
//  SignupViewController.m
//  Closed1
//
//  Created by Nazim on 26/03/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "SignupViewController.h"
#import "SignupTableViewCell.h"
#import "MBProgressHUD.h"
#import "TabBarHandler.h"
#import "CountryListViewController.h"
#import "ClosedResverResponce.h"
#import "UserDetails+CoreDataProperties.h"
#import "MagicalRecord.h"
#import "WebViewController.h"
#import "RMStore.h"
#import "RMAppReceipt.h"
#import "RMStoreKeychainPersistence.h"
#import "RMStoreAppReceiptVerifier.h"
#import "CommonFunction.h"
#import "UINavigationController+NavigationBarAttribute.h"

#define kAutorenewableSubscriptionKey @"com.Closed1LLC.Closed1.AutoRenewableSubscription"
#define kAutoRenewableGroupSignup @"com.Closed1LLC.Closed1.AutoRenewableSubscriptionsignup"

@interface SignupViewController ()<UITableViewDelegate, UITableViewDataSource, CountryListDelegate, ServerFailedDelegate,LinkedInLoginDelegate, UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property(strong, nonatomic) SignupTableViewCell *signupCell;
@property(nonatomic) NSString *imageURL;
@property(nonatomic) BOOL isCardValid;
@property (weak, nonatomic) IBOutlet UIView *inappPurchseView;
@property (weak, nonatomic) IBOutlet UITableView *inappTableView;
@property(nonatomic)  NSString *subscriptionKey;


@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectZero];
    
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    _imageURL = @"";
 
    self.inappPurchseView.hidden = YES;
    self.inappTableView.hidden = YES;
    
    [self.navigationController configureNavigationBar:self];
    self.navigationItem.titleView = [CommonFunction createNavigationView:@"Sign up" withView:self.view];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - Tableview Delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.inappTableView) {
        
        return 2;
    }
    
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.inappTableView) {
        
        if (indexPath.row == 0) {
            return  400;
        }else if (indexPath.row ==1){
            return 101;
        }else{
            return 0;
        }
    }
    
    return 1100;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.inappTableView) {
        
        if(indexPath.row == 0){
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
            
            return cell;
            
        }else if (indexPath.row == 1){
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConditionCell"];
            
            UIButton *termButton = (UIButton *)[cell viewWithTag:1];
            [termButton addTarget:self action:@selector(termsButtobnTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            UIButton *privacyButton = (UIButton *)[cell viewWithTag:2];
            [privacyButton addTarget:self action:@selector(privacyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            return cell;
            
        }else{
            return [UITableViewCell new];
        }
        
        
    }
    
    _signupCell= [tableView dequeueReusableCellWithIdentifier:@"SignupTableViewCell"];
    
    [_signupCell.signupButton addTarget:self action:@selector(signupButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [_signupCell.countrySelectionButton addTarget:self action:@selector(openCountrySelectionScreen) forControlEvents:UIControlEventTouchUpInside];
    
    [_signupCell.signupLinkedButton addTarget:self action:@selector(signupLinkedInTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_signupCell.termsButton addTarget:self action:@selector(termsButtobnTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.signupCell.privacyPolicyButton addTarget:self action:@selector(privacyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    return _signupCell;
}

-(void)termsButtobnTapped: (id)sender
{
    WebViewController *webView = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    webView.title = @"Terms & Conditions";
    webView.urlString = @"https://closed1app.com/terms-of-service/";
    [self.navigationController pushViewController:webView animated:YES];
}

- (void)privacyButtonTapped:(id)sender {
    
    WebViewController *webView = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    webView.title = @"Privacy Policy";
    webView.urlString = @"https://closed1app.com/privacy-policy/";
    [self.navigationController pushViewController:webView animated:YES];
    
}

-(void)openCountrySelectionScreen
{
    
    CountryListViewController  *listViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CountryListViewController"];
    listViewController.delegate = self;
    NSArray *countryList = [self getDataFromJsonFile:@"CountryList"];
    countryList = [countryList valueForKey:@"data"];
    
    NSMutableArray *countryListArray = [[NSMutableArray alloc]init];
    
    for (NSInteger i =0; i<countryList.count; i++) {
        
        [countryListArray addObject:[[countryList objectAtIndex:i] valueForKey:@"Country"]];
    }
    
    listViewController.countrListArray = countryListArray;
    [self presentViewController:listViewController animated:YES completion:nil];
}

-(NSArray *)getDataFromJsonFile: (NSString *)fileName
{
    NSString *filePath = [[NSBundle mainBundle]pathForResource:fileName ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *dataFromlLocal = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    return dataFromlLocal;
}

-(void)signupButtonTapped: (id)sender
{
    
    if ([[_signupCell.usenameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ==0) {
        
        [self animateView:_signupCell.usenameTextField];
        [self.tableView setContentOffset:CGPointZero animated:YES];
        
    }else if ([[_signupCell.emailtextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ==0) {
        
        [self animateView:_signupCell.emailtextField];
        [self.tableView setContentOffset:CGPointZero animated:YES];

        
    }else if ([[_signupCell.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ==0) {
        
        [self animateView:_signupCell.passwordTextField];
        [self.tableView setContentOffset:CGPointZero animated:YES];

        
    }
    else if ([[_signupCell.confirmPasswordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ==0) {
        
        [self animateView:_signupCell.confirmPasswordTextField];
        [self.tableView setContentOffset:CGPointZero animated:YES];

        
    }
    else if ([[_signupCell.fullNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ==0) {
        
        [self animateView:_signupCell.fullNameTextField];
        [self.tableView setContentOffset:CGPointZero animated:YES];

        
    }
    else if ([[_signupCell.cityTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ==0) {
        
        [self animateView:_signupCell.cityTextField];
        [self.tableView setContentOffset:CGPointZero animated:YES];

        
    }
    else if ([[_signupCell.stateTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ==0) {
        
        [self animateView:_signupCell.stateTextField];

        
    }
    else if ([[_signupCell.phoneNumberTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ==0) {
        
        [self animateView:_signupCell.phoneNumberTextField];

        
    }else if ([_signupCell.countrySelectionButton.titleLabel.text isEqualToString:@"Select Country"]){
        
        [[[UIAlertView alloc]initWithTitle:@"Oops!!" message:@"Please select the city first to move ahead" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
    }else if([[_signupCell.titletextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ==0)
    {
        [self animateView:_signupCell.titletextField];


    }else if([[_signupCell.companyTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ==0){
        [self animateView:_signupCell.companyTextField];
        
    }else if ([[_signupCell.territoryTextFiled.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ==0){
        
        [self animateView:_signupCell.territoryTextFiled];

    }else if([[_signupCell.territoryTextFiled.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ==0){
        
        [self animateView:_signupCell.territoryTextFiled];

    }else if([[_signupCell.targetBuyersTextFiled.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ==0){
        
        [self animateView:_signupCell.targetBuyersTextFiled];

    }else{
     
        NSString *emailReg = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailReg];
        if([emailPredicate evaluateWithObject: _signupCell.emailtextField.text] == NO){
           
            [self animateView:_signupCell.emailtextField];
            [self.tableView setContentOffset:CGPointZero animated:YES];

        }else{
            
            if ([_signupCell.passwordTextField.text isEqualToString:_signupCell.confirmPasswordTextField.text]) {
                
                [self checkUserandEmailExitances];
                
            }else{
                
                [[[UIAlertView alloc]initWithTitle:@"Password not matched" message:@"Please re-enter the password. Both password must be same" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
            }
            
        }

    
    }
}

-(void)signupLinkedInTapped: (id)sender
{
    WebViewController *webView = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    webView.isLinkedinSelected = YES;
    webView.delegate = self;
    webView.title = @"Sign up";
    [self.navigationController pushViewController:webView animated:YES];

}
#pragma mark - Linked Login Sucess Delegate

-(void)linkedInAcessToken:(NSString *)acessToken
{
    
    if (acessToken != nil) {
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        
        NSString *acessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"LIAccessToken"];
        
        // Specify the URL string that we'll get the profile info from.
        NSString *targetURLString = [NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~:(id,first-name,last-name,maiden-name,email-address,picture-url,headline)?oauth2_access_token=%@&format=json", acessToken] ;
        
        // Initialize a mutable URL request object.
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:targetURLString]];
        
        // Indicate that this is a GET request.
        request.HTTPMethod = @"GET";
        
        // Add the access token as an HTTP header field.
        //        [request addValue:[NSString stringWithFormat:@"Bearer %@",acessToken] forHTTPHeaderField:@"Authorization"];
        
        NSURLSession *seesion = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        NSURLSessionDataTask *task = [seesion dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *responce,NSError *error){
            
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) responce;
            NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
            
            if (httpResponse.statusCode == 200) {
                
                NSArray * arrayOfDictionaryFromServer = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                
                NSLog(@"%@", arrayOfDictionaryFromServer);
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    NSLog(@"%@", arrayOfDictionaryFromServer);
                    
                    self.signupCell.emailtextField.text = [arrayOfDictionaryFromServer valueForKey:@"emailAddress"];
                    self.signupCell.fullNameTextField.text = [NSString stringWithFormat:@"%@ %@", [arrayOfDictionaryFromServer valueForKey:@"firstName"], [arrayOfDictionaryFromServer valueForKey:@"lastName"]];
                    self.signupCell.titletextField.text = [arrayOfDictionaryFromServer valueForKey:@"headline"];
                    self.signupCell.usenameTextField.text =[[[arrayOfDictionaryFromServer valueForKey:@"emailAddress"] componentsSeparatedByString:@"@"] firstObject];
                    self.imageURL = [arrayOfDictionaryFromServer valueForKey:@"pictureUrl"];
                    
                });
            }
            
        }];
        
        [task resume];
        
        
        
        
    }else{
        
        [[[UIAlertView alloc]initWithTitle:@"oopss!!" message:@"Failed to sign up with linkedin. Please try again or login manually" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
    }
}


-(void)checkUserandEmailExitances
{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Hang on,";
    hud.detailsLabelText = @"Checking user";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSArray *serverResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer: [NSString stringWithFormat:@"https://closed1app.com/api-mobile/?function=check_email_username_exists&username=%@&email=%@", self.signupCell.usenameTextField.text, self.signupCell.emailtextField.text] DictionartyToServer:@{} IsEncodingRequires:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
        if (![[serverResponce valueForKey:@"success"] isEqual:[NSNull null]]) {
            
            if ([[serverResponce valueForKey:@"success"] integerValue] == 1) {
                
                [self checkForAppStoreSubscription:serverResponce];

            }else{
                
                [[[UIAlertView alloc]initWithTitle:@"Failed to sign up" message:@"It seems that user id and email already exists. Please try with different Email ID or get login with us" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            }
        }else{
            
            [[[UIAlertView alloc]initWithTitle:@"Failed to sign up" message:@"It seems that user id and email already exists. Please try with different Email ID or get login with us" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        }
        
        });

        

    });
}



-(void)submitDataToServer
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Hang on,";
    hud.detailsLabelText = @"Signing you up";
    
    NSString *deviceID = [NSString stringWithFormat:@"%d",rand()];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"FCMToken"]) {
        
        deviceID = [[NSUserDefaults standardUserDefaults] valueForKey:@"FCMToken"];
    }

    [ClosedResverResponce sharedInstance].delegate = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
//       NSString *reuestURL = [NSString stringWithFormat:@"http://socialmedia.alkurn.info/api-mobile/?function=userRegistration&username=%@&email=%@&password=%@&fullname=%@&city=%@&state=%@&country=%@&phone=%@&title=%@&company=%@&territory=%@&secondary_email=%@&target_buyer=%@&device_id=%@&user_avatar_urls=%@&number=%@&exp_month=%@&exp_year=%@&cvc=%@", _signupCell.usenameTextField.text, _signupCell.emailtextField.text, _signupCell.passwordTextField.text, _signupCell.fullNameTextField.text, _signupCell.cityTextField.text, _signupCell.stateTextField.text, _signupCell.countrySelectionButton.titleLabel.text, _signupCell.phoneNumberTextField.text, _signupCell.titletextField.text, _signupCell.companyTextField.text, _signupCell.territoryTextFiled.text, _signupCell.secondaryEmailTextFiled.text, _signupCell.secondaryEmailTextFiled.text, deviceID, _imageURL, [self.creditCardDictionary valueForKey:@"cardnumber"], [[[self.creditCardDictionary valueForKey:@"cardexpirydate"] componentsSeparatedByString:@"/"] firstObject], [[[self.creditCardDictionary valueForKey:@"cardexpirydate"] componentsSeparatedByString:@"/"] lastObject], [self.creditCardDictionary valueForKey:@"CreditCardCVV"]];
        
        
        NSString *reuestURL = [NSString stringWithFormat:@"https://closed1app.com/api-mobile/?function=userRegistration&username=%@&email=%@&password=%@&fullname=%@&city=%@&state=%@&country=%@&phone=%@&title=%@&company=%@&territory=%@&target_buyer=%@&device_id=%@&user_avatar_urls=%@", _signupCell.usenameTextField.text, _signupCell.emailtextField.text, _signupCell.passwordTextField.text, _signupCell.fullNameTextField.text, _signupCell.cityTextField.text, _signupCell.stateTextField.text, _signupCell.countrySelectionButton.titleLabel.text, _signupCell.phoneNumberTextField.text, _signupCell.titletextField.text, _signupCell.companyTextField.text, _signupCell.territoryTextFiled.text, _signupCell.targetBuyersTextFiled.text, deviceID, _imageURL];
        
        
        NSLog(@"%@", reuestURL);
        
        NSArray *serverResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer: reuestURL DictionartyToServer:@{} IsEncodingRequires:NO];
        
        NSLog(@"%@", serverResponce);
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            if (serverResponce != nil) {
                
                if (![[serverResponce valueForKey:@"success"] isEqual:[NSNull null]]) {
                    
                    if ([[serverResponce valueForKey:@"success"] integerValue] == 1) {
                        
                        [self saveUserDetails:serverResponce];
                        [self openHomeScreen];
                        
                    }else{
                        [self serverFailedWithTitle:@"Signup Failed" SubtitleString:[serverResponce valueForKey:@"data"]];
                        
                    }
                    
                }else{
                    [self serverFailedWithTitle:@"Signup Failed" SubtitleString:[serverResponce valueForKey:@"data"]];
                    
                }
            }else{
                
                [self serverFailedWithTitle:@"Signup Failed" SubtitleString:@"We occured some error. Please try again later"];
            }
        });

        
    });
    
}

-(void)checkForAppStoreSubscription: (NSArray *)serverResponce
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Connecting to iTunes";
    [[RMStore defaultStore] requestProducts:[NSSet setWithArray:[NSArray arrayWithObjects:kAutorenewableSubscriptionKey, kAutoRenewableGroupSignup, nil]] success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.dimBackground = YES;
        hud.labelText = @"Checking Subscription details";
        
        
        [[RMStore defaultStore] restoreTransactionsOnSuccess:^(NSArray *transactions){
            
            [[RMStore defaultStore] refreshReceiptOnSuccess:^{
                
                BOOL isActive = NO;
                
                RMAppReceipt *appReceipt = [RMAppReceipt bundleReceipt];
                
                if (appReceipt) {
                    isActive =  [appReceipt containsActiveAutoRenewableSubscriptionOfProductIdentifier: kAutorenewableSubscriptionKey forDate:[NSDate date]];
                }
                
                if(isActive){
                    
                    [self askUserForMakingInAppPurchaseWithSubscriptionID:kAutoRenewableGroupSignup];
                    
                }else{
                    
                    //Check for other receipt sucess
                    [self askUserForMakingInAppPurchaseWithSubscriptionID:kAutorenewableSubscriptionKey];
                }
                
                
            }failure:^(NSError *error){
                
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                
                [[[UIAlertView alloc]initWithTitle:@"Failed to get Subscription" message:@"Please tap on login button again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                
            }];
            
            
        }failure:^(NSError *error){
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            [[[UIAlertView alloc]initWithTitle:@"Failed to get Subscription" message:@"Please tap on login button again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        }];
        
        
        
    } failure:^(NSError *error) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Products Purchase Request Failed", @"")
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
    
    
}

- (IBAction)cancelinAppButtonTapped:(id)sender {
    
    self.inappPurchseView.hidden = YES;
    self.inappTableView.hidden = YES;
}


- (IBAction)buyinappButtonTapped:(id)sender {
    
    self.inappPurchseView.hidden = YES;
    self.inappTableView.hidden = YES;
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Purchasing Subscription";
    
    [[RMStore defaultStore] addPayment:self.subscriptionKey success:^(SKPaymentTransaction *transaction) {
        
        if ([transaction.payment.productIdentifier isEqualToString:self.subscriptionKey]) {
            
            [self submitDataToServer];
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        }
        
    } failure:^(SKPaymentTransaction *transaction, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Payment Transaction Failed", @"")
                                                           message:error.localizedDescription
                                                          delegate:nil
                                                 cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                 otherButtonTitles:nil];
        [alerView show];
        
    }];
    
}



-(void)askUserForMakingInAppPurchaseWithSubscriptionID: (NSString *)subscriptionID
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    
    if ([RMStore canMakePayments]){
        
        self.inappPurchseView.hidden = NO;
        self.inappTableView.hidden = NO;
        self.subscriptionKey = subscriptionID;
        
    }else{
        
        [[[UIAlertView alloc] initWithTitle:@"Ypou cannot make paymnet" message:@"Please try login with different apple aor make paymnet from closed1app.com" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    
}

-(void)saveUserDetails: (NSArray *)userData{
    
    userData = [userData valueForKey:@"data"];
    [UserDetails MR_truncateAll];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext){
        
        UserDetails *userDetails = [UserDetails MR_createEntityInContext:localContext];
        
        userDetails.userID = [[userData valueForKey:@"ID"] integerValue];
        userDetails.firstName = self.signupCell.fullNameTextField.text;
        userDetails.userEmail = self.signupCell.emailtextField.text;
        userDetails.userLogin = self.signupCell.usenameTextField.text;
        userDetails.title = self.signupCell.titletextField.text;
        userDetails.company = self.signupCell.companyTextField.text;
        userDetails.city = [userData valueForKey:_signupCell.cityTextField.text];
        
        NSString *countryString = [_signupCell.countrySelectionButton titleForState:UIControlStateNormal];
        
        userDetails.country = countryString;
        userDetails.territory = self.signupCell.territoryTextFiled.text;
         userDetails.phoneNumber = _signupCell.phoneNumberTextField.text;
        userDetails.state = _signupCell.stateTextField.text;
        
        if ([_imageURL isEqualToString:@""]) {
            
            userDetails.profileImage = [userData valueForKey:@"profile_image_url"];
            
        }else{
            
            userDetails.profileImage = _imageURL;
        }

        
        [localContext MR_saveToPersistentStoreAndWait];
        
    }completion:^(BOOL didSave, NSError *error){
        
        if (!didSave) {
            
            NSLog(@"Error While Saving: %@", error);
            
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        }
    }];
    
}


-(void)openHomeScreen
{
    
    self.inappPurchseView.hidden = YES;
    self.inappTableView.hidden = YES;
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    TabBarHandler *tabBarScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"TabBarHandler"];
    
    [UIView transitionWithView:self.navigationController.view
                      duration:0.75
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{
                        [self.navigationController pushViewController:tabBarScreen animated:NO];
                    }
                    completion:nil];
    
    
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

-(void)selectedCountry:(NSString *)countryName
{
    NSLog(@"%@", countryName);
    [_signupCell.countrySelectionButton setTitle:countryName forState:UIControlStateNormal];
    [_signupCell.countrySelectionButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}

#pragma mark - ServerFailes Delegates

-(void)serverFailedWithTitle:(NSString *)title SubtitleString:(NSString *)subtitle
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [[[UIAlertView alloc]initWithTitle:title message:subtitle delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
    });
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    
    if (textField == _signupCell.phoneNumberTextField) {
        
        
    
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
    }
    
    else{
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
