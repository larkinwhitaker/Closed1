//
//  TransitionAnimator.m
//  CustomTransition
//
//  Created by jay on 12/05/15.
//  Copyright (c) 2015 jay. All rights reserved.
//

#import "TransitionAnimator.h"

@implementation TransitionAnimator
{
    UIViewController * toViewController;
}

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    // Grab the from and to view controllers from the context
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
//    HACK - Jay  : Used to match the frame for animation in search and Without search viewcontroller
    if(self.isSearching)
    {
        _imageRectangle = CGRectMake(_imageRectangle.origin.x, _imageRectangle.origin.y , _imageRectangle.size.width, _imageRectangle.size.height);
    }
    else
    {
        _imageRectangle = CGRectMake(_imageRectangle.origin.x, _imageRectangle.origin.y + 60, _imageRectangle.size.width, _imageRectangle.size.height);

    }
    
    // Set our ending frame. We'll modify this later if we have to
    CGRect endFrame = CGRectMake(0, 0, transitionContext.containerView.frame.size.width, transitionContext.containerView.frame.size.height);
    
    //View To get white background before transition starts
    UIView * view = [[UIView alloc]initWithFrame:transitionContext.containerView.frame];
    view.backgroundColor = [UIColor whiteColor];
    [transitionContext.containerView addSubview:view];
    
    if (self.presenting) {
        fromViewController.view.userInteractionEnabled = NO;
        
   //     [transitionContext.containerView addSubview:fromViewController.view];
        [transitionContext.containerView addSubview:toViewController.view];
        
        
        
        
        
        CGRect startFrame = endFrame;
       // startFrame.origin.x += 320;
        toViewController.view.alpha = 0;
        toViewController.view.frame = startFrame;
        
        UIImageView * imageView = [[UIImageView alloc]initWithFrame:_imageRectangle];
        imageView.image = _imageToAnimate;
        imageView.layer.contentsRect = CGRectMake(0, 0, 1, 0.9);
        imageView.layer.cornerRadius = 27;
        imageView.layer.masksToBounds = YES;
        
        [transitionContext.containerView addSubview:imageView];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]/2 animations:^{
            CGFloat imageViewWidth = [UIScreen mainScreen].bounds.size.width * 0.34375;
            
            if([UIScreen mainScreen].bounds.size.height == 480)
            {
                imageViewWidth = 120;
            }

            if(self.isLocation)
            {
                imageView.layer.masksToBounds = NO;
                imageView.frame = CGRectMake(0,[UIScreen mainScreen].bounds.size.width * 0.2222 + 20 , [UIScreen mainScreen].bounds.size.width
                                             , [UIScreen mainScreen].bounds.size.width * 0.4291);
            }
            else
            {
               
                
                
                imageView.frame = CGRectMake(transitionContext.containerView.frame.size.width/2 - imageViewWidth / 2 + 5 , 77, imageViewWidth - 10, imageViewWidth - 10);
                imageView.layer.cornerRadius = imageViewWidth / 2 - 5;
                imageView.layer.masksToBounds = YES;
                imageView.layer.contentsRect = CGRectMake(0, 0, 1, 0.9);
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                imageView.layer.borderWidth = 1.0;
                imageView.layer.borderColor = [UIColor blackColor].CGColor;
                //             toViewController.view.alpha = 1;
            }
            
        } completion:^(BOOL finished) {
            toViewController.view.alpha = 1;
            
            [UIView animateWithDuration:[self transitionDuration:transitionContext]/2 animations:^{
                
                imageView.alpha = 0.0;
                view.alpha = 0.0;
                
                
            } completion:^(BOOL finished) {
                
                [imageView removeFromSuperview];
                
                [transitionContext completeTransition:YES];
                
                
            }];
            
//            [imageView removeFromSuperview];
//            //
//                            [transitionContext completeTransition:YES];
        }
         ];
        
        
        
       
    }
    else {
        CGFloat imageViewWidth = [UIScreen mainScreen].bounds.size.width * 0.34375;
        if([UIScreen mainScreen].bounds.size.height == 480)
        {
            imageViewWidth = 120;
        }

        toViewController.view.userInteractionEnabled = YES;
        toViewController.view.alpha = 1.0;
       // [transitionContext.containerView addSubview:toViewController.view];
     //   [transitionContext.containerView addSubview:fromViewController.view];
        UIImageView *imageView = [[UIImageView alloc]initWithImage:_imageToAnimate];
        imageView.frame = CGRectMake(transitionContext.containerView.frame.size.width/2 - imageViewWidth / 2 - 5, 77, imageViewWidth, imageViewWidth);
        imageView.layer.contentsRect = CGRectMake(0, 0, 1, 0.9);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.cornerRadius = imageViewWidth / 2 - 5;
        imageView.layer.masksToBounds = YES;
        [transitionContext.containerView addSubview:imageView];
    
      //  endFrame.origin.x += 320;
        [UIView animateWithDuration:[self transitionDuration:transitionContext]/2 animations:^{
            imageView.frame = _imageRectangle;

        } completion:^(BOOL finished) {
            
        }];
        [UIView animateWithDuration:[self transitionDuration:transitionContext]/2 animations:^{
            fromViewController.view.alpha = 0.0;

            
          //  toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
           // fromViewController.view.frame = endFrame;
        } completion:^(BOOL finished) {
      
            [transitionContext completeTransition:YES];

//            transitionContext.completeTransition(true);
//            
//            [UIApplication sharedApplication].keyWindow!.addSubview(toViewController.view);
        }];
        
    }
}



@end
