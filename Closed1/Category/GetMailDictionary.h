//
//  GetMailDictionary.h
//  Closed1
//
//  Created by Nazim on 25/06/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol MailSendDelegates <NSObject>


-(void)isMailSendingSuccess: (BOOL)isSuccess withMesssage: (NSString *)message;

@end

@interface GetMailDictionary : NSObject

@property(nonatomic, weak) id<MailSendDelegates>delegate;

-(void)getMailCOmposerDictionary: (NSArray *)mailContacts withNameArray: (NSArray *)nameArray WithView: (UIView *)viewToDisplay;
@end
