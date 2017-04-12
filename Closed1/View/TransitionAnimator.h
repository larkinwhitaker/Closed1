//
//  TransitionAnimator.h
//  CustomTransition
//
//  Created by jay on 12/05/15.
//  Copyright (c) 2015 jay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TransitionAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic  , getter=isPresenting) BOOL presenting;
@property (nonatomic ) CGRect imageRectangle;
@property (nonatomic , retain) UIImage * imageToAnimate;

// Used to match the animation start when search viewcontroller is active
@property (nonatomic , getter=isSearching)BOOL searching;

@property (nonatomic, getter=isLocation)BOOL location;
@end
