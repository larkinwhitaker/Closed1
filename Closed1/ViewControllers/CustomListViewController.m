//
//  CustomListViewController.m
//
//  WebViewController.m
//  Closed1
//
//  Created by Nazim on 26/03/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//
#import "CustomListViewController.h"
#import "MBProgressHUD.h"

@interface CustomListViewController ()
@property (strong, nonatomic) IBOutlet UIButton *closeButton;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIView *customNavigationBar;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;
@property (strong, nonatomic) UISearchDisplayController *searchController;
@property (strong, nonatomic) NSArray *airportListArray;
@property(nonatomic)  CLLocationManager *locationManager;
@property(nonatomic) CLGeocoder *geocoder;
@property(nonatomic)  CLPlacemark *placemark;
;

@end
static NSString *cellIdentifier = @"ListViewCell";
NSString *sectionHeadingText = @"";
@implementation CustomListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustumNavigationBar];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    
    [self.searchbar sizeToFit];
    self.searchbar.tintColor =  [UIColor colorWithRed:225.0/255.0 green:60.0/255.0 blue:80.0/255.0 alpha:1.0];
    [self.searchbar setDelegate:self];
    [self setSearchController:[[UISearchDisplayController alloc] initWithSearchBar:self.searchbar
                                                                contentsController:self]];
    UINib *nib = [UINib nibWithNibName:@"ListViewCell" bundle:nil];
    [self.searchController.searchResultsTableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
    [self.tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
    [self.searchController setSearchResultsDataSource:self];
    [self.searchController setSearchResultsDelegate:self];
    [self.searchController setDelegate:self];
    _filteredArray = self.listArray;
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    headerView.backgroundColor = [UIColor whiteColor];
    UIButton *headerViewButton = [[UIButton alloc]initWithFrame:headerView.frame];
    [headerView addSubview:headerViewButton];
    [headerViewButton addTarget:self action:@selector(currentLocationButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    headerView.backgroundColor = [UIColor clearColor];
    UIImageView *headerviewImage = [[UIImageView alloc]initWithFrame:CGRectMake(20, 10, 20, 20)];
    headerviewImage.image = [UIImage imageNamed:@"CurrentLocationImage"];
    
    UILabel *headerViewLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 5 ,self.view.frame.size.width - 50, 30)];
    headerViewLabel.text = @"Current Location";
    headerViewLabel.textColor = [UIColor colorWithRed:38.0/255.0 green:166.0/255.0 blue:154.0/255.0 alpha:1.0];
    [headerView addSubview:headerViewLabel];
    [headerView addSubview:headerviewImage];
    
//    self.tableView.tableHeaderView = headerView;
    
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectZero];

}

-(void)currentLocationButtonTapped:(id)sender
{
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"] && [self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
            [self.locationManager requestWhenInUseAuthorization];
        }
    }
    else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        //Location Services is off from settings
        [self displayAlertControllerForOpenSettings];
        
    }
    else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)
    {
        [[[UIAlertView alloc]initWithTitle:@"Oops!!" message:@"Error while getting current location. Please search your city manually." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        
    }else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways){
        
        [self getCurrentLocation];
    }
    
}

-(void)getCurrentLocation
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Hang on,";
    hud.dimBackground = YES;
    hud.detailsLabelText = @"Fetching your location";
    
    
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.geocoder = [[CLGeocoder alloc] init];
    [self.locationManager startUpdatingLocation];
}

-(void)displayAlertControllerForOpenSettings
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Location service is disabled" message:@"You can enable access to location services for Airhob from the Settings app in your iPhone" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction *openSettings = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^( UIAlertAction *action){
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    
    [alertController addAction:okButton];
    [alertController addAction:openSettings];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}


-(void)displayAlertViewForCurrentLocation
{
    [[[UIAlertView alloc]initWithTitle:@"Oops!" message:@"Unable to fetch your current location. Could you please try again or search your country manually?" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view endEditing:YES];
    
    //    [self.tableView setContentOffset:CGPointZero];
    //    [self.view layoutIfNeeded];
    //    self.searchbar.text = @"";
    //    _filteredArray = self.listArray;
    
}
-(void)createCustumNavigationBar
{
    
    UINavigationBar *custumNavigationBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    [custumNavigationBar  setTintColor:[UIColor whiteColor]];
    [custumNavigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [custumNavigationBar setBarTintColor:[UIColor colorWithRed:34.0/255.0 green:187.0/255.0 blue:187.0/255.0 alpha:1.0]];
    custumNavigationBar.translucent = NO;
    
    UINavigationItem *navigationItem = [[UINavigationItem alloc] init];
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CloseNavigationImage"] style:UIBarButtonItemStylePlain  target:self action:@selector(backButtonTapped:)];
    navigationItem.leftBarButtonItem = leftButton;
    [navigationItem setTitle:self.title];
    custumNavigationBar.items = @[navigationItem];
    
    [self.view addSubview:custumNavigationBar];
}


- (IBAction)backButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)dissmissViewController
{
    [self.navigationController  popViewControllerAnimated:NO];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - TableView Delegate Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self.searchController isActive])
    {
        return _filteredArray.count;
    }else
    {
        return self.listArray.count;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    
    if ([self.searchController isActive])
    {
        return [[_filteredArray objectAtIndex:section]count];
    }else
    {
        return [[self.listArray objectAtIndex:section] count];
    }
    
    
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.heightOFRow;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if(tableView == self.searchDisplayController.searchResultsTableView)
    {
        ListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        cell.imageView.hidden = YES;
        cell.listImageView.hidden = YES;
        cell.subHeading.hidden = YES;
        cell.textLabel.text = [[self.filteredArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        cell.textLabel.textColor = [UIColor darkGrayColor];
        return cell;
        
    }else
    {
        ListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        cell.listImageView.hidden = YES;
        cell.subHeading.hidden = YES;
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.textLabel.text = [[self.listArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        return cell;
    }
    

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView  deselectRowAtIndexPath:indexPath animated:YES];
    
    
    if(self.delegate != nil)
    {
        
        if (tableView == self.searchDisplayController.searchResultsTableView)
        {
            [self.delegate getSelectedIndex:indexPath.row SelectedProgram:[[self.filteredArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }else
        {
            [self.delegate getSelectedIndex:indexPath.row SelectedProgram:[[self.listArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }else
    {
        NSLog(@"Delegate not working");
    }
    
}

#pragma mark - Searchbar Delegate Methods

//-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
//{
//    if ([searchText  isEqualToString:@""])
//    {
//        _filteredArray = _listArray;
//        [_tableView reloadData];
//    }else
//    {
//
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@",searchText]; // if you need case sensitive search avoid '[c]' in the predicate
//    NSArray *searchListArray = [[_listArray objectAtIndex:0] copy];
//    NSArray *filetered = [searchListArray filteredArrayUsingPredicate:predicate];
//    [_filteredArray removeAllObjects];
//    [_filteredArray addObject:filetered];
//    [_tableView  reloadData];
//
//    }
//}
//

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    _filteredArray = self.listArray;
    [_tableView reloadData];
}

#pragma mark - ScrollView Delegates

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}


- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    //    [self.tableView reloadData];
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if ([searchString  isEqualToString:@""])
    {
        _filteredArray = _listArray;
        [_tableView reloadData];
    }else
    {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@",searchString]; // if you need case sensitive search avoid '[c]' in the predicate
        NSArray *searchListArray = [[_listArray objectAtIndex:0] copy];
        NSArray *filetered = [searchListArray filteredArrayUsingPredicate:predicate];
        _filteredArray = [[NSMutableArray alloc]init];
        [_filteredArray addObject:filetered];
        [_tableView  reloadData];
        
    }

    return  YES;
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    [self.locationManager stopUpdatingLocation];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self displayAlertViewForCurrentLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = newLocation;
    [self.geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            _placemark = [placemarks lastObject];
            
            /*
             NSLog(@"%@", self.placemark.region);
             NSLog(@"%@", _placemark.name);
             NSLog(@"%@", _placemark.thoroughfare);
             NSLog(@"%@", _placemark.subThoroughfare);
             NSLog(@"%@", _placemark.locality);
             NSLog(@"%@", _placemark.subLocality);
             NSLog(@"%@", placemark.administrativeArea);
             NSLog(@"%@", placemark.subAdministrativeArea);
             NSLog(@"%@", placemark.postalCode);
             NSLog(@"%@", placemark.ISOcountryCode);
             NSLog(@"%@", placemark.country);
             NSLog(@"%@", placemark.inlandWater);
             NSLog(@"%@", placemark.ocean);
             NSLog(@"%@", placemark.areasOfInterest);
             */
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self.locationManager stopUpdatingLocation];
            
        } else {
            NSLog(@"%@", error.debugDescription);
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self.locationManager stopUpdatingLocation];
            [self displayAlertViewForCurrentLocation];
        }
    } ];
    
    
}




@end
