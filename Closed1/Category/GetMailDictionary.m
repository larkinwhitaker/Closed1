//
//  GetMailDictionary.m
//  Closed1
//
//  Created by Nazim on 25/06/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "GetMailDictionary.h"
#import <UIKit/UIKit.h>
#import "MagicalRecord.h"
#import "UserDetails+CoreDataClass.h"
#import "ClosedResverResponce.h"
#import "MBProgressHUD.h"

@implementation  GetMailDictionary: NSObject

-(void)getMailCOmposerDictionary: (NSArray *)mailContacts withNameArray: (NSArray *)nameArray WithView:(UIView *)viewToDisplay{
    
    NSMutableDictionary *mailDict = [[NSMutableDictionary alloc]init];
    
    UserDetails *userDetails = [UserDetails MR_findFirst];
    
    NSMutableArray *mailArray = [[NSMutableArray alloc]init];
    UserDetails *user = [UserDetails MR_findFirst];
    
    for (NSInteger i =0; i<mailContacts.count; i++) {
        
        [mailArray addObject: @{@"sender_user_id": [NSNumber numberWithInteger:user.userID], @"email": [mailContacts objectAtIndex:i], @"sendername": userDetails.firstName}];
    }
    
    [mailDict setObject:mailArray forKey:@"profile_job"];
    
    
    NSString *message = @"Successfully sent a mail.";
    
    if(mailContacts.count>1) message = @"Successfully sent mails.";
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:viewToDisplay animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Sending mails";
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *serverResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer:@"http://socialmedia.alkurn.info/api-mobile/?function=send_invite_emails" DictionartyToServer:mailDict IsEncodingRequires:NO];
        
        NSLog(@"%@", serverResponce);
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([[[serverResponce valueForKey:@"data"] valueForKey:@"success"] integerValue] == 1) {
                
                [self.delegate isMailSendingSuccess:YES withMesssage:message];
                
            }else{
                
                [self.delegate isMailSendingSuccess:NO withMesssage: @""];

            }
            
        });
    });
    
    
    
}

@end
