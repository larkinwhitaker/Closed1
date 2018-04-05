//
//  InappPurchaseTermViewController.m
//  Closed1
//
//  Created by Nazim on 02/03/18.
//  Copyright © 2018 Alkurn. All rights reserved.
//

#import "InappPurchaseTermViewController.h"
#import "WebViewController.h"
#import "UINavigationController+NavigationBarAttribute.h"
#import "CommonFunction.h"

@interface InappPurchaseTermViewController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation InappPurchaseTermViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController configureNavigationBar:self];
    self.navigationItem.titleView = [CommonFunction createNavigationView:@"Terms & Conditions" withView:self.view];
}

#pragma mark:- TableView Delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        
        return cell;
        
    }else if (indexPath.row == 1){
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConditionCell"];
        
        UIButton *termButton = (UIButton *)[cell viewWithTag:1];
        [termButton addTarget:self action:@selector(termsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *privacyButton = (UIButton *)[cell viewWithTag:2];
        [privacyButton addTarget:self action:@selector(privacyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
        
    }else{
        return [UITableViewCell new];
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return  400;
    }else if (indexPath.row ==1){
        return 101;
    }else{
        return 0;
    }
}


- (IBAction)privacyButtonTapped:(id)sender {
    
    WebViewController *webView = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    webView.title = @"Privacy Policy";
    webView.urlString = @"https://closed1app.com/privacy-policy/";
    [self.navigationController pushViewController:webView animated:YES];
    
}
- (IBAction)termsButtonTapped:(id)sender {
    
    WebViewController *webView = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    webView.title = @"Terms & Conditions";
    webView.urlString = @"https://closed1app.com/terms-of-service/";
    [self.navigationController pushViewController:webView animated:YES];
    
    
}

@end
