//
//  WebViewController.m
//  Closed1
//
//  Created by Nazim on 26/03/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//
//

#import <UIKit/UIKit.h>
#import "PTKTextField.h"

#define RGB(r,g,b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f]
#define DarkGreyColor RGB(0,0,0)
#define RedColor RGB(253,0,17)
#define DefaultBoldFont [UIFont boldSystemFontOfSize:17]

#define kPTKViewPlaceholderViewAnimationDuration 0.25

#define kPTKViewCardExpiryFieldStartX 84 + 200
#define kPTKViewCardCVCFieldStartX 177 + 200

#define kPTKViewCardExpiryFieldEndX 84
#define kPTKViewCardCVCFieldEndX 177

#define kPTKBundle [NSBundle bundleForClass:[PTKView class]]

@protocol CreditCardDelegate <NSObject>

-(void)selectedCreditCardDetails:(NSMutableDictionary *)creditCardDetailsDictionary;

@end

@interface CreditCardViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIView *cardExpiryUnderLineView;
@property (strong, nonatomic) IBOutlet UIView *cardNumberunderLineView;
@property IBOutlet UITextField *cardNumberField;
@property IBOutlet UITextField *cardExpiryField;
@property IBOutlet UIImageView *placeholderView;
@property (strong, nonatomic) IBOutlet UITextField *cardNameTextField;
@property (strong, nonatomic) IBOutlet UIView *cardNameunderLineView;
@property(nonatomic,weak)id<CreditCardDelegate>delegate;
@property (weak, nonatomic) IBOutlet UIImageView *cvvPlaceholderImage;
@property (weak, nonatomic) IBOutlet UITextField *cvvTextFiled;
@property(nonatomic, strong) NSMutableDictionary *creditCardDetails;

@property(nonatomic ) BOOL isUpdateCarDetails;
@property(nonatomic ) BOOL shouldOpenHomeScreen;
@property(nonatomic ) BOOL isComeFromSignup;

@end
