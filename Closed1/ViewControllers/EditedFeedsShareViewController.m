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


@interface EditedFeedsShareViewController ()

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
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController configureNavigationBar:self];
    self.title = @"Share a Deal";
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM-dd-yyyy HH:mm"];
    
    NSDate *currentDate = [NSDate date];
    NSString *dateString = [formatter stringFromDate:currentDate];
    self.timingLabel.text = dateString;
    
}

- (IBAction)shareDealTapped:(id)sender {
    
    [self.view endEditing:YES];
    
    if ([[self.nametextView.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]] length] == 0) {
        
        
    }else if ([[self.commentTextView.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]] length] == 0){
        
    }else{
        
        [self submitDatatToServer];
    }
}

-(void)submitDatatToServer
{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *currentDate = [NSDate date];
    NSString *dateString = [formatter stringFromDate:currentDate];
    
    NSLog(@"%@", dateString);
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Posting feed";
    
    UserDetails *userDetails = [UserDetails MR_findFirst];
    
    [ClosedResverResponce sharedInstance].delegate = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *serverResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer:[NSString stringWithFormat:@"https://closed1app.com/api-mobile/?function=sharedeal&user_id=%zd&closed=%@&comment=%@&date_recorded=%@", userDetails.userID, self.nametextView.text, self.commentTextView.text, dateString] DictionartyToServer:@{} IsEncodingRequires:NO];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            NSLog(@"%@", serverResponce);
            
            if ([serverResponce valueForKey:@"success"] != nil ) {
                
                if ([[serverResponce valueForKey:@"success"] integerValue] == 1) {
                    self.commentTextView.text = @"";
                    self.nametextView.text = @"";
                    
                    [self.tabBarController setSelectedIndex:0];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"NewFeedsAvilable" object:nil];
                }else{
                    
                    [self serverFailedWithTitle:@"Oops!!" SubtitleString:[serverResponce valueForKey:@"data"]];
                    
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
