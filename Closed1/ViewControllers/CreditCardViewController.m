//
//  ViewControllerCredit.m
//  Airhob
//
//  Created by mYwindow on 22/09/16.
//  Copyright © 2016 mYwindow Inc. All rights reserved.
//

#import "CreditCardViewController.h"
#import "PTKView.h"
#import "UINavigationController+NavigationBarAttribute.h"
#import "CardDetails+CoreDataProperties.h"
#import "MagicalRecord.h"

#define CREDIT_CARD_NUMBER_KEY @"cardnumber"
#define CREDIT_CARD_EXPIRY_DATE_KEY @"cardexpirydate"
#define CREDIT_CARD_CVV_KEY @"CreditCardCVV"
#define CREDIT_CARD_NAME_KEY @"cardname"
#define CREDIT_CARD_IMAGE_KEY @"cardimagename"
#define CREDIT_CARD_ENCRYPTED_TEXT @"cardencryptedtext"
#define CREDIT_CARD_CVV_IMAGE_KEY @"creditcardCVVImage"

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
    self.cvvTextFiled.text = [self.creditCardDetails valueForKey:CREDIT_CARD_CVV_KEY];
    self.cvvPlaceholderImage.image = [UIImage imageNamed:[self.creditCardDetails valueForKey:CREDIT_CARD_CVV_IMAGE_KEY]];
    self.placeholderView.image = [UIImage imageNamed:[self.creditCardDetails valueForKey:CREDIT_CARD_IMAGE_KEY]];
    
    self.cardNameTextField.keyboardType = UIKeyboardTypeAlphabet;
    self.cardNumberField.keyboardType = UIKeyboardTypeNumberPad;
    self.cardExpiryField.keyboardType = UIKeyboardTypeNumberPad;
    self.cvvTextFiled.keyboardType = UIKeyboardTypeNumberPad;

    [self.navigationController configureNavigationBar:self];
    
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
                    
                    if ([self shoulAddCardDetails]) {
                        
                        NSString *cardNumber = @"XXXX XXXX XXXX XXXX";
                        
                        NSString *first4CardNoDetails = [self.cardNumberField.text substringWithRange:NSMakeRange(0, 4)];
                        NSString *last4CardNoDetails = [self.cardNumberField.text substringWithRange:NSMakeRange(self.cardNumberField.text.length-4, 4)];
                        
                        cardNumber = [cardNumber stringByReplacingCharactersInRange:NSMakeRange(0, 4) withString:first4CardNoDetails];
                        cardNumber = [cardNumber stringByReplacingCharactersInRange:NSMakeRange(cardNumber.length-4, 4) withString:last4CardNoDetails];
                        [self.creditCardDetails setObject:cardNumber forKey:CREDIT_CARD_ENCRYPTED_TEXT];
                        
                        [self.delegate selectedCreditCardDetails:_creditCardDetails];
                        [self.navigationController popViewControllerAnimated:YES];
                        

                    }else{
                        
                        [[[UIAlertView alloc]initWithTitle:@"Card already added" message:@"This card is already added. Please add a new card." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
                        [self.cardNameTextField becomeFirstResponder];
                    }
                    
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

-(void)backButtonTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];

}

-(BOOL)shoulAddCardDetails
{
    NSArray *savedCardDeatils = [CardDetails MR_findAll];
    
    if (savedCardDeatils.count == 0 || savedCardDeatils == nil) {
        
        return YES;
    }else{
        
         NSInteger numberOfEntities = [CardDetails MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"(cardnumber == %@) AND (cardexpirydate == %@)", self.cardNumberField.text , self.cardExpiryField.text]];
        
        if (numberOfEntities == 0) {
            return YES;
        }else{
            return NO;
        }
        
    }
    
    return YES;
    
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
//
//#pragma mark -
//#pragma mark UIResponder
//- (UIResponder *)firstResponderField;
//{
//    NSArray *responders = @[self.cardNumberField, self.cardExpiryField, self.cardCVCField];
//    for (UIResponder *responder in responders) {
//        if (responder.isFirstResponder) {
//            return responder;
//        }
//    }
//    
//    return nil;
//}
//
//- (PTKTextField *)firstInvalidField;
//{
//    if (![[PTKCardNumber cardNumberWithString:self.cardNumberField.text] isValid])
//        return self.cardNumberField;
//    else if (![[PTKCardExpiry cardExpiryWithString:self.cardExpiryField.text] isValid])
//        return self.cardExpiryField;
//    else if (![[PTKCardCVC cardCVCWithString:self.cardCVCField.text] isValid])
//        return self.cardCVCField;
//    
//    return nil;
//}
//
//- (PTKTextField *)nextFirstResponder;
//{
//    if (self.firstInvalidField)
//        return self.firstInvalidField;
//    
//    return self.cardCVCField;
//}
//
//- (BOOL)isFirstResponder;
//{
//    return self.firstResponderField.isFirstResponder;
//}
//
//- (BOOL)canBecomeFirstResponder;
//{
//    return self.nextFirstResponder.canBecomeFirstResponder;
//}
//
//- (BOOL)becomeFirstResponder;
//{
//    return [self.nextFirstResponder becomeFirstResponder];
//}
//
//- (BOOL)canResignFirstResponder;
//{
//    return self.firstResponderField.canResignFirstResponder;
//}
//
//- (BOOL)resignFirstResponder;
//{
//    [super resignFirstResponder];
//    
//    return [self.firstResponderField resignFirstResponder];
//}


@end
