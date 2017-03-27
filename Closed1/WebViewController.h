//
//  WebViewController.h
//  Closed1
//
//  Created by Nazim on 26/03/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LinkedInLoginDelegate <NSObject>

-(void)linkedInAcessToken: (NSString *)acessToken;

@end

@interface WebViewController : UIViewController

@property(nonatomic,weak) id<LinkedInLoginDelegate>delegate;

@end
