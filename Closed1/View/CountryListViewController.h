//
//  CountryListViewController.h
//  Mappd
//
//  Created by Nazim on 13/12/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CountryListDelegate <NSObject>

-(void)selectedCountry: (NSString *)countryName;

@end

@interface CountryListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic) NSArray *countrListArray;
@property(nonatomic, weak) id<CountryListDelegate>delegate;

@end
