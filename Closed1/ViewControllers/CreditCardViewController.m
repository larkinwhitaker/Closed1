//
//  WebViewController.m
//  Closed1
//
//  Created by Nazim on 26/03/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "CreditCardViewController.h"
#import "PTKView.h"
#import "UINavigationController+NavigationBarAttribute.h"
#import "CardDetails+CoreDataProperties.h"
#import "MagicalRecord.h"
#import "WebViewController.h"
#import "MBProgressHUD.h"
#import "TabBarHandler.h"
#import "ClosedResverResponce.h"
#import "ChangePasswordViewController.h"
#import "UserDetails+CoreDataProperties.h"
#import "MagicalRecord.h"
#import "AFNetworking.h"
#import <linkedin-sdk/LISDK.h>
#import "JobProfile+CoreDataProperties.h"
#import "MBProgressHUD.h"

#define CREDIT_CARD_NUMBER_KEY @"cardnumber"
#define CREDIT_CARD_EXPIRY_DATE_KEY @"cardexpirydate"
#define CREDIT_CARD_CVV_KEY @"CreditCardCVV"
#define CREDIT_CARD_NAME_KEY @"cardname"
#define CREDIT_CARD_IMAGE_KEY @"cardimagename"
#define CREDIT_CARD_ENCRYPTED_TEXT @"cardencryptedtext"
#define CREDIT_CARD_CVV_IMAGE_KEY @"creditcardCVVImage"

#define kTitle @"title"
#define kCopmpany @"company"
#define kTerritory @"territory"
#define kTargetBuyers @"target"
#define kisCurrentPosition @"current_position"

@interface CreditCardViewController ()<UITextFieldDelegate, PTKTextFieldDelegate>

@end

@implementation CreditCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cardNumberField.delegate = self;
    self.cardExpiryField.delegate = self;
    
    self.cardNumberField.placeholder = @"1234 5678 9012 3456";
    self.cardExpiryField.placeholder = @"MM/YY";
    self.cvvTextFiled.placeholder = @"CVC";
    self.cardExpiryField.textColor = DarkGreyColor;
    self.cvvTextFiled.font = DefaultBoldFont;
    self.cvvTextFiled.delegate = self;
    self.cardExpiryField.textColor = DarkGreyColor;
    self.cardExpiryField.font = DefaultBoldFont;
    self.cardNumberField.textColor = DarkGreyColor;
    self.cardNumberField.font = DefaultBoldFont;
    self.cardNameTextField.textColor = DarkGreyColor;
    self.cardNameTextField.font = DefaultBoldFont;
    
    self.cardNumberField.text = [self.creditCardDetails valueForKey:CREDIT_CARD_NUMBER_KEY];
    self.cardExpiryField.text = [self.creditCardDetails valueForKey:CREDIT_CARD_EXPIRY_DATE_KEY];
    self.cardNameTextField.text = [self.creditCardDetails valueForKey:CREDIT_CARD_NAME_KEY];
    self.placeholderView.image = [UIImage imageNamed:[self.creditCardDetails valueForKey:CREDIT_CARD_IMAGE_KEY]];
    
    self.cardNameTextField.keyboardType = UIKeyboardTypeAlphabet;
    self.cardNumberField.keyboardType = UIKeyboardTypeNumberPad;
    self.cardExpiryField.keyboardType = UIKeyboardTypeNumberPad;
    self.cvvTextFiled.keyboardType = UIKeyboardTypeNumberPad;

    [self.navigationController configureNavigationBar:self];
    self.title = @"Card Details";
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"BackButton"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped:)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveCardDeatilsWithValidation)];
    self.navigationItem.rightBarButtonItem = saveButton;
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    [self.cardNumberField becomeFirstResponder];

}
-(void)saveCardDeatilsWithValidation
{
    [self.view endEditing:YES];
    [self.creditCardDetails setObject:self.cardNumberField.text forKey:CREDIT_CARD_NUMBER_KEY];
    [self.creditCardDetails setObject:self.cardExpiryField.text forKey:CREDIT_CARD_EXPIRY_DATE_KEY];
    [self.creditCardDetails setObject:self.cardNameTextField.text forKey:CREDIT_CARD_NAME_KEY];
    [self.creditCardDetails setObject:self.cvvTextFiled.text forKey:CREDIT_CARD_CVV_KEY];
    
    NSString *cardString = self.cardNumberField.text;
    cardString = [PTKTextField textByRemovingUselessSpacesFromString:cardString];
    PTKCardNumber *cardNumber = [PTKCardNumber cardNumberWithString:cardString];
    
    NSString *expiryString = self.cardExpiryField.text;
    expiryString = [PTKTextField textByRemovingUselessSpacesFromString:expiryString];
    PTKCardExpiry *cardExpiry = [PTKCardExpiry cardExpiryWithString:expiryString];
 
    
    NSString *nameString = self.cardNameTextField.text;
    nameString = [nameString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(([[PTKCardCVC cardCVCWithString:self.cvvTextFiled.text] isValid])){
    if ([cardNumber isValid]) {
        
        if ([cardExpiry isValid]) {
            
                if (self.cardNameTextField.text.length>0) {
                    
                    [self makePaymnetForCardDetails];
                    
                }else{
                    [[[UIAlertView alloc]initWithTitle:@"Name missing" message:@"Please enter your name on card" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
                    [self.cardNameTextField becomeFirstResponder];
                    
                }
                
        }else{
            
            [[[UIAlertView alloc]initWithTitle:@"Expiry date missing" message:@"Please enter a valid expiry date" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
            [self.cardExpiryField becomeFirstResponder];
            
        }
        
    }else{
        [[[UIAlertView alloc]initWithTitle:@"Invalid card number" message:@"Please enter a valid card number" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
        [self.cardNumberField becomeFirstResponder];
    }
    }else{
        
        [[[UIAlertView alloc]initWithTitle:@"Invalid CVC" message:@"Please enter a valid CVC" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
        [self.cvvTextFiled becomeFirstResponder];

    }
    
}


-(void)makePaymnetForCardDetails
{
    NSString *cardNumber = @"XXXX XXXX XXXX XXXX";
    
    NSString *first4CardNoDetails = [self.cardNumberField.text substringWithRange:NSMakeRange(0, 4)];
    NSString *last4CardNoDetails = [self.cardNumberField.text substringWithRange:NSMakeRange(self.cardNumberField.text.length-4, 4)];
    
    cardNumber = [cardNumber stringByReplacingCharactersInRange:NSMakeRange(0, 4) withString:first4CardNoDetails];
    cardNumber = [cardNumber stringByReplacingCharactersInRange:NSMakeRange(cardNumber.length-4, 4) withString:last4CardNoDetails];
    [self.creditCardDetails setObject:cardNumber forKey:CREDIT_CARD_ENCRYPTED_TEXT];
    
    
    if(self.isUpdateCarDetails){
        
        [self callAPiforUpdateCardDetails];
        
    }else if(self.shouldOpenHomeScreen){
        
        [self callAPiforMakingPayment];
        
    }else if(self.isComeFromSignup){
        
        [self.delegate selectedCreditCardDetails:_creditCardDetails];
        [self.navigationController popViewControllerAnimated:YES];
        
       
    }
    
}

-(void)callAPiforUpdateCardDetails
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Please wait...";
    hud.detailsLabelText = @"Updating Card Details";
    
    UserDetails *user = [UserDetails MR_findFirst];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *apiName = [NSString stringWithFormat:@"https://closed1app.com/api-mobile/?function=update_card_details&user_id=%zd&number=%@&exp_month=%@&exp_year=%@&cvc=%@", user.userID, self.cardNumberField.text, [[self.cardExpiryField.text componentsSeparatedByString:@"/"] firstObject], [[self.cardExpiryField.text componentsSeparatedByString:@"/"] lastObject], self.cvvTextFiled.text];
        
        NSLog(@"%@", apiName);
        
        NSArray *serverResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer:apiName DictionartyToServer:@{} IsEncodingRequires:NO];
        
        NSLog(@"%@", serverResponce);
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            if (![[serverResponce valueForKey:@"success"] isEqual:[NSNull null]]) {
                
                if ([[serverResponce valueForKey:@"success"] integerValue] == 1) {
                    
                    [self.navigationController popViewControllerAnimated:YES];
                    [[[UIAlertView alloc]initWithTitle:@"Sucessfully updated card details" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                    
                }else{
                    
                    [[[UIAlertView alloc]initWithTitle:@"Failed to update card details" message:@"We're are really sorry but at this moment we are uaable to update your card details" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                }
            }else{
                [[[UIAlertView alloc]initWithTitle:@"Failed to update card details" message:@"We're are really sorry but at this moment we are uaable to update your card details" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            }
        });


        
    });
    
    
}

-(void)callAPiforMakingPayment
{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Please wait...";
    hud.detailsLabelText = @"Making Paymnet";
    
    UserDetails *user = [UserDetails MR_findFirst];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *apiName = [NSString stringWithFormat:@"https://closed1app.com/api-mobile/?function=update_membership&&number=%@&exp_month=%@&exp_year=%@&cvc=%@&user_id=%zd&email_id=%@", self.cardNumberField.text, [[self.cardExpiryField.text componentsSeparatedByString:@"/"] firstObject], [[self.cardExpiryField.text componentsSeparatedByString:@"/"] lastObject], self.cvvTextFiled.text, user.userID, user.userEmail];
        
        NSLog(@"%@", apiName);
        
       
        NSArray *serverResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer:apiName DictionartyToServer:@{} IsEncodingRequires:NO];
        
        NSLog(@"%@", serverResponce);
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if (![[serverResponce valueForKey:@"success"] isEqual:[NSNull null]]) {
                
                if ([[serverResponce valueForKey:@"success"] integerValue] == 1) {
                    
                    [self openHomeScreen];
                    [self saveCardDetails];
                }else{
                    
                    [[[UIAlertView alloc]initWithTitle:@"Failed to make paymnet" message:@"We are unable to procees you card details. Please enter a valid card details" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                }
            }else{
                [[[UIAlertView alloc]initWithTitle:@"Failed to make paymnet" message:@"We are unable to procees you card details. Please enter a valid card details" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            }
            
        });
        
        
        
    });
    
}

-(void)saveCardDetails
{
    [CardDetails MR_truncateAll];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext){
        
        CardDetails *cardDetails = [CardDetails MR_createEntityInContext:localContext];
        
        cardDetails.cardname = [self.creditCardDetails valueForKey:@"cardname"];
        cardDetails.cardencryptedtext = [self.creditCardDetails valueForKey:@"cardencryptedtext"];
        cardDetails.cardexpirydate = [self.creditCardDetails valueForKey:@"cardexpirydate"];
        cardDetails.cardimagename = [self.creditCardDetails valueForKey:@"cardimagename"];
        cardDetails.cardnumber = [self.creditCardDetails valueForKey:@"cardnumber"];
        cardDetails.cvvtext = [self.creditCardDetails valueForKey:@"CreditCardCVV"];
        cardDetails.cvvimageName = [self.creditCardDetails valueForKey:@"creditcardCVVImage"];
        
        [localContext MR_saveToPersistentStoreAndWait];
    }];
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

-(void)backButtonTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];

}

- (void)setPlaceholderViewImage:(UIImage *)image
{
    self.placeholderView.image = image;
}

- (void)setPlaceholderToCVC
{
    PTKCardNumber *cardNumber = [PTKCardNumber cardNumberWithString:self.cardNumberField.text];
    PTKCardType cardType = [cardNumber cardType];
    
    if (cardType == PTKCardTypeAmex) {
        self.cvvPlaceholderImage.image = [UIImage imageNamed:@"cvc-amex" inBundle:kPTKBundle compatibleWithTraitCollection:nil];
        [self.creditCardDetails setValue:@"cvc-amex" forKey:CREDIT_CARD_CVV_IMAGE_KEY];
    } else {
        
        [self.creditCardDetails setValue:@"cvc" forKey:CREDIT_CARD_CVV_IMAGE_KEY];
        self.cvvPlaceholderImage.image = [UIImage imageNamed:@"cvc" inBundle:kPTKBundle compatibleWithTraitCollection:nil];
    }
}


- (void)setPlaceholderToCardType
{
    PTKCardNumber *cardNumber = [PTKCardNumber cardNumberWithString:self.cardNumberField.text];
    PTKCardType cardType = [cardNumber cardType];
    NSString *cardTypeName = @"placeholder";
    
    switch (cardType) {
        case PTKCardTypeAmex:
            cardTypeName = @"amex";
            break;
        case PTKCardTypeDinersClub:
            cardTypeName = @"diners";
            break;
        case PTKCardTypeDiscover:
            cardTypeName = @"discover";
            break;
        case PTKCardTypeJCB:
            cardTypeName = @"jcb";
            break;
        case PTKCardTypeMasterCard:
            cardTypeName = @"mastercard";
            break;
        case PTKCardTypeVisa:
            cardTypeName = @"visa";
            break;
        default:
            break;
    }
    [self.creditCardDetails setObject:cardTypeName forKey:CREDIT_CARD_IMAGE_KEY];
    [self setPlaceholderViewImage:[UIImage imageNamed:cardTypeName inBundle:kPTKBundle compatibleWithTraitCollection:nil]];
}

#pragma mark - Delegates

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:self.cvvTextFiled]) {
        [self setPlaceholderToCVC];
    } else {
        [self setPlaceholderToCardType];
    }
    if ([textField isEqual:self.cardNumberField] ) {
//        [self stateCardNumber];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{
    if ([textField isEqual:self.cardNumberField]) {
        return [self cardNumberFieldShouldChangeCharactersInRange:range replacementString:replacementString];
    }
    
    if ([textField isEqual:self.cardExpiryField]) {
        return [self cardExpiryShouldChangeCharactersInRange:range replacementString:replacementString];
    }
    
    if ([textField isEqual:self.cvvTextFiled]) {
        return [self cardCVCShouldChangeCharactersInRange:range replacementString:replacementString];
    }
    
    return YES;
}

- (BOOL)cardNumberFieldShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{
    NSString *resultString = [self.cardNumberField.text stringByReplacingCharactersInRange:range withString:replacementString];
    resultString = [PTKTextField textByRemovingUselessSpacesFromString:resultString];
    PTKCardNumber *cardNumber = [PTKCardNumber cardNumberWithString:resultString];
    
    if (![cardNumber isPartiallyValid])
        return NO;
    
    if (replacementString.length > 0) {
        self.cardNumberField.text = [cardNumber formattedStringWithTrail];
    } else {
        self.cardNumberField.text = [cardNumber formattedString];
    }
    
    [self setPlaceholderToCardType];
    
    if ([cardNumber isValid]) {
        [self textFieldIsValid:self.cardNumberField];
//        [self stateMeta];
        
    } else if ([cardNumber isValidLength] && ![cardNumber isValidLuhn]) {
        [self textFieldIsInvalid:self.cardNumberField withErrors:YES];
        
    } else if (![cardNumber isValidLength]) {
        [self textFieldIsInvalid:self.cardNumberField withErrors:NO];
    }
    
    return NO;
}

- (BOOL)cardExpiryShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{
    NSString *resultString = [self.cardExpiryField.text stringByReplacingCharactersInRange:range withString:replacementString];
    resultString = [PTKTextField textByRemovingUselessSpacesFromString:resultString];
    PTKCardExpiry *cardExpiry = [PTKCardExpiry cardExpiryWithString:resultString];
    
    if (![cardExpiry isPartiallyValid]) return NO;
    
    // Only support shorthand year
    if ([cardExpiry formattedString].length > 5) return NO;
    
    if (replacementString.length > 0) {
        self.cardExpiryField.text = [cardExpiry formattedStringWithTrail];
    } else {
        self.cardExpiryField.text = [cardExpiry formattedString];
    }
    
    if ([cardExpiry isValid]) {
        [self textFieldIsValid:self.cardExpiryField];
//        [self stateCardCVC];
        
    } else if ([cardExpiry isValidLength] && ![cardExpiry isValidDate]) {
        [self textFieldIsInvalid:self.cardExpiryField withErrors:YES];
    } else if (![cardExpiry isValidLength]) {
        [self textFieldIsInvalid:self.cardExpiryField withErrors:NO];
    }
    
    return NO;
}

- (BOOL)cardCVCShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{
    NSString *resultString = [self.cvvTextFiled.text stringByReplacingCharactersInRange:range withString:replacementString];
    resultString = [PTKTextField textByRemovingUselessSpacesFromString:resultString];
    PTKCardCVC *cardCVC = [PTKCardCVC cardCVCWithString:resultString];
    PTKCardType cardType = [[PTKCardNumber cardNumberWithString:self.cardNumberField.text] cardType];
    
    // Restrict length
    if (![cardCVC isPartiallyValidWithType:cardType]) return NO;
    
    // Strip non-digits
    self.cvvTextFiled.text = [cardCVC string];
    
    if ([cardCVC isValidWithType:cardType]) {
        [self textFieldIsValid:self.cvvTextFiled];
    } else {
        [self textFieldIsInvalid:self.cvvTextFiled withErrors:NO];
    }
    
    return NO;
}

#pragma mark - Validations

- (void)checkValid
{
    NSLog(@"Valid Credit cartd");

}

- (void)textFieldIsValid:(UITextField *)textField
{
    textField.textColor = DarkGreyColor;
    [self checkValid];
}

- (void)textFieldIsInvalid:(UITextField *)textField withErrors:(BOOL)errors
{
    if (errors) {
        textField.textColor = RedColor;
    } else {
        textField.textColor = DarkGreyColor;
    }
    
    [self checkValid];
}

-(void)openHomeScreen
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    
    TabBarHandler *tabBarScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"TabBarHandler"];
    
    [UIView transitionWithView:self.navigationController.view
                      duration:0.75
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{
                        [self.navigationController pushViewController:tabBarScreen animated:NO];
                    }
                    completion:nil];
    
    [self getFreindListCount];
    
//    [self getUpdatedUserDetails];
    
}


//-(void)getUpdatedUserDetails
//{
//    
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    hud.detailsLabelText = @"Getting Details";
//    hud.labelText = @"Please Wait...";
//    hud.dimBackground = YES;
//    
//    UserDetails *_userdDetails = [UserDetails MR_findFirst];
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        NSString *url = [NSString stringWithFormat:@"https://closed1app.com/api-mobile/?function=get_profile_data&user_id=%zd", _userdDetails.userID];
//        
//        NSArray *serverResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer: url DictionartyToServer:@{} IsEncodingRequires:NO];
//        
//        
//        
//        NSLog(@"%@", serverResponce);
//        
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//            
//            if (serverResponce != nil) {
//                
//                if (![[serverResponce valueForKey:@"success"] isEqual:[NSNull null]]) {
//                    
//                    if ([[serverResponce valueForKey:@"success"] integerValue] == 1) {
//                        
//                        if ([[[serverResponce valueForKey:@"data"] valueForKey:@"isSubscribed"] boolValue] == YES) {
//                            
//                            [self saveUserDetails:serverResponce];
//                            [self openHomeScreen];
//                            
//                        }
//                        
//                    }
//                }
//            }
//        });
//    });
//        
//}


-(void)getFreindListCount
{
    
    UserDetails *_userdDetails = [UserDetails MR_findFirst];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *servreResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer:[NSString stringWithFormat:@"https://closed1app.com/api-mobile/?function=get_friends_request&user_id=%zd",_userdDetails.userID] DictionartyToServer:@{} IsEncodingRequires:NO];
        
        NSLog(@"%@", servreResponce);
        
        if ([servreResponce valueForKey:@"success"] != nil) {
            
            if ([[servreResponce valueForKey:@"success"] integerValue] == 1) {
                
                NSArray *freinListCOunt = [servreResponce valueForKey:@"data"];
                [[NSUserDefaults standardUserDefaults] setInteger:freinListCOunt.count forKey:@"FreindRequestCount"];
            }else{
                [[NSUserDefaults standardUserDefaults] setInteger: 0 forKey:@"FreindRequestCount"];
            }
        }else{
            [[NSUserDefaults standardUserDefaults] setInteger: 0 forKey:@"FreindRequestCount"];
            
        }
    });
    
}



-(void)saveUserDetails: (NSArray *)userData{
    
    userData = [userData valueForKey:@"data"];
    [UserDetails MR_truncateAll];
    [JobProfile MR_truncateAll];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext){
        
        UserDetails *userDetails = [UserDetails MR_createEntityInContext:localContext];
        
        userDetails.userID = [[userData valueForKey:@"ID"] integerValue];
        userDetails.firstName = [userData valueForKey:@"fullname"];
        userDetails.userEmail = [userData valueForKey:@"user_email"];
        userDetails.userLogin = [userData valueForKey:@"user_login"];
        userDetails.title = [userData valueForKey:@"title"];
        userDetails.company = [userData valueForKey:@"company"];
        userDetails.city = [userData valueForKey:@"city"];
        userDetails.country = [userData valueForKey:@"country"];
        userDetails.territory = [userData valueForKey:@"territory"];
        userDetails.phoneNumber = [userData valueForKey:@"phone"];
        userDetails.state = [userData valueForKey:@"state"];
        userDetails.profileImage = [userData valueForKey:@"profile Image"];
            
        
        NSArray *flightDetailsArray = [userData valueForKey:@"profile_job"];
        
        if (flightDetailsArray.count != 0) {
            
            for (NSDictionary *singleJob in flightDetailsArray) {
                
                JobProfile *jobDetails = [JobProfile MR_createEntityInContext:localContext];
                
                jobDetails.title = [singleJob valueForKey:kTitle];
                jobDetails.territory = [singleJob valueForKey:kTerritory];
                jobDetails.compnay = [singleJob valueForKey:kCopmpany];
                jobDetails.targetBuyers = [singleJob valueForKey:kTargetBuyers];
                jobDetails.jobid = [singleJob valueForKey:@"id"];
                if (![[singleJob valueForKey:kisCurrentPosition] isEqual:[NSNull null]]) {
                    
                    jobDetails.currentPoistion = [singleJob valueForKey:kisCurrentPosition];
                }
                
                [localContext MR_saveToPersistentStoreAndWait];
                
                
            }
        }
        
        
        
        
        [localContext MR_saveToPersistentStoreAndWait];
        
    }completion:^(BOOL didSave, NSError *error){
        
        if (!didSave) {
            
            NSLog(@"Error While Saving: %@", error);
            
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        }
    }];
    
}






@end
