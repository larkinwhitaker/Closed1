//
//  FreindRequestViewController.h
//  Closed1
//
//  Created by Nazim on 20/04/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FreindsListDelegate <NSObject>

-(void)freindListAddedSucessFully;

@end

@interface FreindRequestViewController : UIViewController
@property(nonatomic, weak) id<FreindsListDelegate>delegate;

@end
