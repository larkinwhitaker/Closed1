//
//  CustomListViewController.h
///
//  WebViewController.m
//  Closed1
//
//  Created by Nazim on 26/03/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListViewCell.h"
#import <CoreLocation/CoreLocation.h>

@protocol SelectedCountryDelegate <NSObject>

@optional
-(void)getSelectedIndex: (NSInteger)selectedIndex SelectedProgram:(NSString *)selectedProgram;

@end

@interface CustomListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIScrollViewDelegate, UISearchDisplayDelegate, CLLocationManagerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchbar;
@property(nonatomic) NSString *SearchBarPlaceholder;
@property(nonatomic, strong)  NSMutableArray *listArray;
@property(strong, nonatomic) NSMutableArray *filteredArray;
@property(nonatomic) CGFloat heightOFRow;
@property(nonatomic, weak) id<SelectedCountryDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *sectionArray;
//@property(nonatomic, strong)NSString *tableHeadingText;
@end
