//
//  JGTourTip.h
//

#import <UIKit/UIKit.h>
#import "CMPopTipView.h"

@interface NZTourTip : UIView <CMPopTipViewDelegate>
-(id)initWithViews:(NSArray *)viewArray withMessages:(NSArray *)messageArray onScreen:(UIView *)baseView;
-(void)showTourTip;
@property (nonatomic) BOOL isComeFromImmunization;


@property (nonatomic, strong) CMPopTipView * popUpView;

@end
