//
//  WebViewController.m
//  Closed1
//
//  Created by Nazim on 26/03/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//
#import <UIKit/UIKit.h>

@protocol SelectedClassDelegate <NSObject>

-(void)selectedPassengerDetails: (NSInteger)selectedrow WithSelectedDetails: (nonnull NSArray *)selectedDetails;

@end

@interface FlightClassSelectionViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, weak, nullable)id<SelectedClassDelegate>delegate;
@property(nonatomic)BOOL isPassengerSelectionScreen;
@property(strong, nonatomic, nonnull) NSArray *classListArray;
@property(strong, nonatomic, nonnull)NSDictionary *defaultValues;
@property(strong, nonnull)UIImage *backgrounTableViewImage;
@property(nonatomic) BOOL shouldDisplayLeftAlignment;
@property(nonatomic) BOOL isInfantsShow;

// By adding this its remove the below warning
// pointer is missing a nullability type specifier
NS_ASSUME_NONNULL_BEGIN

-(NSMutableArray *) createDictionaryForPassengerSelcetionScreen;

NS_ASSUME_NONNULL_END
@end
