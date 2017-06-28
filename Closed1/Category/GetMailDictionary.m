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
    
    NSMutableArray *mailArray = [[NSMutableArray alloc]init];
    UserDetails *user = [UserDetails MR_findFirst];
    
    for (NSInteger i =0; i<mailContacts.count; i++) {
        
        [mailArray addObject: @{@"sender_user_id": [NSNumber numberWithInteger:user.userID], @"email": [mailContacts objectAtIndex:i], @"sendername": [nameArray objectAtIndex:i]}];
    }
    
    [mailDict setObject:mailArray forKey:@"profile_job"];
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:viewToDisplay animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Sending mails";
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *serverResponce = [[ClosedResverResponce sharedInstance] getResponceFromServer:@"http://socialmedia.alkurn.info/api-mobile/?function=send_invite_emails" DictionartyToServer:mailDict IsEncodingRequires:NO];
        
        NSLog(@"%@", serverResponce);
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([[[serverResponce valueForKey:@"data"] valueForKey:@"success"] integerValue] == 1) {
                
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"MailSendNotification" object:[NSNumber numberWithBool:YES]] ;
                [self.delegate isMailSendingSuccess:YES];
                
            }else{
                
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"MailSendNotification" object:[NSNumber numberWithBool:NO]];
                [self.delegate isMailSendingSuccess:NO];

            }

//            }else return NO;
            
        });
    });
    
    
    
}

@end
