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
#import "CustomListViewController.h"
#import "ClosedResverResponce.h"
#import "UserDetails+CoreDataProperties.h"
#import "MagicalRecord.h"
#import "WebViewController.h"
#import "CreditCardViewController.h"
#import "PTKView.h"
#import "CardDetails+CoreDataProperties.h"

@interface SignupViewController ()<UITableViewDelegate, UITableViewDataSource, SelectedCountryDelegate, ServerFailedDelegate,LinkedInLoginDelegate, UITextFieldDelegate, CreditCardDelegate, PTKViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property(strong, nonatomic) SignupTableViewCell *signupCell;
@property(nonatomic) NSString *imageURL;
@property(nonatomic) BOOL isCardValid;
@property(nonatomic) NSMutableDictionary *creditCardDictionary;

@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectZero];
    
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    _imageURL = @"";

    self.creditCardDictionary = [[NSMutableDictionary alloc]init];
    [self.creditCardDictionary setValue:@"" forKey:@"cardnumber"];
    [self.creditCardDictionary setValue:@"" forKey:@"cardexpirydate"];
    [self.creditCardDictionary setValue:@"" forKey:@"CreditCardCVV"];
    [self.creditCardDictionary setValue:@"" forKey:@"cardname"];
    [self.creditCardDictionary setValue:@"placeholder" forKey:@"cardimagename"];

    [self.creditCardDictionary setValue:@"" forKey:@"cardencryptedtext"];
    [self.creditCardDictionary setValue:@"cvc" forKey:@"creditcardCVVImage"];

}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createCustumNavigationBar];

}

- (void)createCustumNavigationBar
{
    [self.navigationController setNavigationBarHidden:YES];

    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x-10, self.view.bounds.origin.y, self.view.frame.size.width+10 , 60)];
    UINavigationItem * navItem = [[UINavigationItem alloc] init];
    
    navBar.items = @[navItem];
    [navBar setBarTintColor:[UIColor colorWithRed:38.0/255.0 green:166.0/255.0 blue:154.0/255.0 alpha:1.0]];
    navBar.translucent = NO;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"BackButton"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped:)];
    
    navItem.leftBarButtonItem = backButton;

    UIButton *addFreinds = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [addFreinds setImage:[UIImage imageNamed:@"CreditcardDefaultImage.png"] forState:UIControlStateNormal];
    [addFreinds addTarget:self action:@selector(openCreditCardScreen) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *cardButton = [[UIBarButtonItem alloc]initWithCustomView:addFreinds];
    navItem.rightBarButtonItem = cardButton;
    
    [navBar setTintColor:[UIColor whiteColor]];
    [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [navItem setTitle:@"Sign up"];
    [self.view addSubview:navBar];
    
}

#pragma mark - First card Delegate

-(void)openCreditCardScreen
{
    CreditCardViewController *creditcardVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CreditCardViewController"];
    creditcardVC.delegate = self;
    creditcardVC.creditCardDetails = self.creditCardDictionary;
    [self.navigationController pushViewController:creditcardVC animated:YES];
    
}

-(void)selectedCreditCardDetails:(NSMutableDictionary *)creditCardDetailsDictionary
{
    NSLog(@"%@", creditCardDetailsDictionary);
    [self.signupCell.addCardButton setTitle:[creditCardDetailsDictionary valueForKey:@"cardencryptedtext"] forState:UIControlStateNormal];
    [CardDetails MR_truncateAll];
    
    
    [self.creditCardDictionary setValue:[creditCardDetailsDictionary valueForKey:@"cardnumber"] forKey:@"cardnumber"];
    [self.creditCardDictionary setValue:[creditCardDetailsDictionary valueForKey:@"cardexpirydate"] forKey:@"cardexpirydate"];
    [self.creditCardDictionary setValue:[creditCardDetailsDictionary valueForKey:@"CreditCardCVV"] forKey:@"CreditCardCVV"];
    [self.creditCardDictionary setValue:[creditCardDetailsDictionary valueForKey:@"cardname"] forKey:@"cardname"];
    [self.creditCardDictionary setValue:[creditCardDetailsDictionary valueForKey:@"cardimagename"] forKey:@"cardimagename"];
    
    [self.creditCardDictionary setValue:[creditCardDetailsDictionary valueForKey:@"cardencryptedtext"] forKey:@"cardencryptedtext"];
    [self.creditCardDictionary setValue:[creditCardDetailsDictionary valueForKey:@"creditcardCVVImage"] forKey:@"creditcardCVVImage"];

    
    
    
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


#pragma mark - 2nd Card Delegdate
- (void) paymentView:(PTKView *)paymentView withCard:(PTKCard *)card isValid:(BOOL)valid
{
    _isCardValid = valid;
}

-(void)saveCardDetails

{
    PTKCard* card = _signupCell.cardView.card;

    NSLog(@"Card Number: %@", card.number);
    NSLog(@"Card expiry: %lu/%lu", (unsigned long)card.expMonth, (unsigned long)card.expYear);
    NSLog(@"Card cvc: %@", card.cvc);
    
    [[NSUserDefaults standardUserDefaults] setValue:card.last4 forKey:@"card.last4"];

}

-(IBAction)backButtonTapped:(UIBarButtonItem *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Tableview Delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 1140;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    _signupCell= [tableView dequeueReusableCellWithIdentifier:@"SignupTableViewCell"];
    
    [_signupCell.signupButton addTarget:self action:@selector(signupButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    _signupCell.cardView.delegate = self;
    [_signupCell.addCardButton addTarget:self action:@selector(openCreditCardScreen) forControlEvents:UIControlEventTouchUpInside];
    
    [_signupCell.countrySelectionButton addTarget:self action:@selector(openCountrySelectionScreen) forControlEvents:UIControlEventTouchUpInside];
    
    [_signupCell.signupLinkedButton addTarget:self action:@selector(signupLinkedInTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_signupCell.termsButton addTarget:self action:@selector(termsButtobnTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    return _signupCell;
}

-(void)termsButtobnTapped: (id)sender
{
    WebViewController *webView = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    webView.title = @"Terms & Conditions";
    webView.urlString = @"https://closed1app.com/terms-of-service/";
    
    [self presentViewController:webView animated:YES completion:nil];
    
    
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

    }else if([[_signupCell.secondaryEmailTextFiled.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] ==0){
        
        [self animateView:_signupCell.secondaryEmailTextFiled];

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

        
        }else if([emailPredicate evaluateWithObject: _signupCell.secondaryEmailTextFiled.text] == NO){
            
            [self animateView:_signupCell.secondaryEmailTextFiled];

        }else{
            
            if ([_signupCell.passwordTextField.text isEqualToString:_signupCell.confirmPasswordTextField.text]) {
                
                if ([self.signupCell.addCardButton.titleLabel.text isEqualToString:@"Add card"]) {
                    [[[UIAlertView alloc]initWithTitle:@"Credit card details missing" message:@"Please enter your credit card details to move ahead" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];

                }else{
                    
                    [self submitDataToServer];
                }

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
    [self presentViewController:webView animated:YES completion:nil];

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
                    self.imageURL = [arrayOfDictionaryFromServer valueForKey:@"pictureUrl"];
                    
                });
            }
            
        }];
        
        [task resume];
        
        
        
        
    }else{
        
        [[[UIAlertView alloc]initWithTitle:@"oopss!!" message:@"Failed to sign up with linkedin. Please try again or login manually" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
    }
}

-(void)submitDataToServer
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Hang on,";
    hud.detailsLabelText = @"Signing you up";
    
    NSString *deviceID = @"";
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"FCMToken"]) {
        
        deviceID = [[NSUserDefaults standardUserDefaults] valueForKey:@"FCMToken"];
    }

    [ClosedResverResponce sharedInstance].delegate = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        NSString *reuestURL = [NSString stringWithFormat:@"https://closed1app.com/api-mobile/?function=userRegistration&username=%@&email=%@&password=%@&fullname=%@&city=%@&state=%@&country=%@&phone=%@&title=%@&company=%@&territory=%@&secondary_email=%@&target_buyer=%@&device_id=%@&user_avatar_urls=%@", _signupCell.usenameTextField.text, _signupCell.emailtextField.text, _signupCell.passwordTextField.text, _signupCell.fullNameTextField.text, _signupCell.cityTextField.text, _signupCell.stateTextField.text, _signupCell.countrySelectionButton.titleLabel.text, _signupCell.phoneNumberTextField.text, _signupCell.titletextField.text, _signupCell.companyTextField.text, _signupCell.territoryTextFiled.text, _signupCell.secondaryEmailTextFiled.text, _signupCell.secondaryEmailTextFiled.text, deviceID, _imageURL];
        
        
    

        
        
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
                    [self serverFailedWithTitle:@"Signup Failed" SubtitleString:@"We occured some error. Please try again later"];
                    
                }
            }else{
                
                [self serverFailedWithTitle:@"Signup Failed" SubtitleString:@"We occured some error. Please try again later"];
            }
        });

        
    });
    
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
        userDetails.econdaryemail = self.signupCell.secondaryEmailTextFiled.text;
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

-(void)getSelectedIndex:(NSInteger)selectedIndex SelectedProgram:(NSString *)selectedProgram
{
    NSLog(@"%@", selectedProgram);
    [_signupCell.countrySelectionButton setTitle:selectedProgram forState:UIControlStateNormal];
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
