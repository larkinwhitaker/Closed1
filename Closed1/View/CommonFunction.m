//
//  CommonFunction.m
//  Airhob
//
//  Created by mYwindow on 22/03/17.
//  Copyright © 2017 mYwindow Inc. All rights reserved.
//

#import "CommonFunction.h"

@implementation CommonFunction 


+(UIView *)createNavigationView: (NSString *)title withView: (UIView *)view;
{
    UIView* _headerTitleSubtitleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    _headerTitleSubtitleView.backgroundColor = [UIColor clearColor];
    _headerTitleSubtitleView.autoresizesSubviews = YES;
    
    CGRect titleFrame =  CGRectMake(0, 8, 200, 24);;
    UILabel *titleView = [[UILabel alloc] initWithFrame:titleFrame] ;
    titleView.backgroundColor = [UIColor clearColor];
    titleView.font = [UIFont boldSystemFontOfSize:16.0];
    titleView.textAlignment = NSTextAlignmentCenter;
    titleView.textColor = [UIColor whiteColor];
    titleView.text = title;
    [_headerTitleSubtitleView addSubview:titleView];

    CGRect subtitleFrame = CGRectMake(0, 22, 200, 44-24);
    UILabel *subtitleView = [[UILabel alloc] initWithFrame:subtitleFrame];
    subtitleView.backgroundColor = [UIColor clearColor];
    subtitleView.font = [UIFont systemFontOfSize:13.0];
    subtitleView.textAlignment = NSTextAlignmentCenter;
    subtitleView.textColor = [UIColor colorWithRed:250.0/255.0 green:199.0/255.0 blue:205.0/255.0 alpha:1.0];
    subtitleView.text = @"";
    subtitleView.adjustsFontSizeToFitWidth = YES;//Label Font wiil be reduced if not enought space available
    [_headerTitleSubtitleView addSubview:subtitleView];
    
    CGFloat widthDiff = subtitleView.frame.size.width - titleView.frame.size.width;
    if (widthDiff < 0) {
        
        CGFloat newX = widthDiff / 2;
        CGRect frame = subtitleView.frame;
        frame.origin.x = newX;
    }else{
        
        CGFloat newX = widthDiff / 2;
        CGRect frame = titleView.frame;
        frame.origin.x = newX;
        
    }
    return _headerTitleSubtitleView;
}

@end
