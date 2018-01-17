//
//  EditedFeedsShareViewController.m
//  Closed1
//
//  Created by Nazim on 11/12/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "EditedFeedsShareViewController.h"
#import "JVFloatLabeledTextView.h"
#import "ClosedResverResponce.h"
#import "UserDetails+CoreDataClass.h"
#import "MBProgressHUD.h"
#import "MagicalRecord.h"
#import "UINavigationController+NavigationBarAttribute.h"


@interface EditedFeedsShareViewController () <ServerFailedDelegate>

@property (strong, nonatomic) IBOutlet UIButton *shareDealButton;
@property (strong, nonatomic) IBOutlet JVFloatLabeledTextView *nametextView;
@property (strong, nonatomic) IBOutlet JVFloatLabeledTextView *commentTextView;
@property (strong, nonatomic) IBOutlet UILabel *timingLabel;

@end

@implementation EditedFeedsShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.commentTextView.textContainer.lineFragmentPadding = 5.0;
    self.nametextView.textContainer.lineFragmentPadding = 5.0;
    if(![[self.singlefeedsDetails valueForKey:@"closed"] isEqual:[NSNull null]])     self.nametextView.text = [self.singlefeedsDetails valueForKey:@"closed"];

    self.commentTextView.text = [self.singlefeedsDetails valueForKey:@"content"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController configureNavigationBar:self];
    self.title = @"Share a Deal";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"BackButton"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped:)];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM-dd-yyyy HH:mm"];
    
    NSDate *currentDate = [NSDate date];
    NSString *dateString = [formatter stringFromDate:currentDate];
    self.timingLabel.text = dateString;
    
}

-(void)backButtonTapped: (id) sendeer
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)shareDealTapped:(id)sender {
    
    [self.view endEditing:YES];
    
    if ([[self.nametextView.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]] length] == 0) {
        
        [self animateView:self.nametextView];
        
    }else if ([[self.commentTextView.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]] length] == 0){
        
        [self animateView:self.commentTextView];

    }else{
        
        [self submitDatatToServer];
    }
}

-(void)animateView: (UIView *)textField
{
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.duration = 0.07;
    animation.repeatCount = 4;
    animation.autoreverses = YES;
    animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(textField.center.x - 10, textField.center.y)];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(textField.center.x + 10, textField.center.y)];
    [textField.layer addAnimation:animation forKey:@"position"];
    
}


-(void)submitDatatToServer
{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Posting feed";
    
    UserDetails *userDetails = [UserDetails MR_findFirst];
    
    [ClosedResverResponce sharedInstance].delegate = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *url = [NSString stringWithFormat: @"https://closed1app.com/api-mobile/?function=activity_update_content&user_id=%zd&activityid=%@&content=%@&title=%@", userDetails.userID, [_singlefeedsDetails valueForKey:@"activity_id"],self.commentTextView.text, self.nametextView.text];
        
        NSLog(@"%@", url);
        
        NSArray *serverResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer: url DictionartyToServer:@{} IsEncodingRequires:NO];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            NSLog(@"%@", serverResponce);
            
            if ([serverResponce valueForKey:@"success"] != nil ) {
                
                if ([[serverResponce valueForKey:@"success"] integerValue] == 1) {
                    self.commentTextView.text = @"";
                    self.nametextView.text = @"";
                    
                    [self.tabBarController setSelectedIndex:0];
                    [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:1] animated:YES];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"NewFeedsAvilable" object:nil];
                }else{
                    
                    [self serverFailedWithTitle:@"Oops!!" SubtitleString:@"Failed to update deal. Please try again later."];
                    
                }
            }else{
                
                [self serverFailedWithTitle:@"Oops!!" SubtitleString:@"Failed to post feed. Please try again later."];
                
            }
            
        });
    });
    
    
}


#pragma mark - TextView Delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView == self.nametextView ) {
        
        return textView.text.length + (text.length - range.length) <= 25;
        
        
    }else{
        
        return textView.text.length + (text.length - range.length) <= 125;
        
    }
    
    
}

-(void)serverFailedWithTitle:(NSString *)title SubtitleString:(NSString *)subtitle
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        [[[UIAlertView alloc]initWithTitle:title message:subtitle delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
        
    });
    
}



@end
