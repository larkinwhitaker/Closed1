//
//  CountryListViewController.m
//  Mappd
//
//  Created by Nazim on 13/12/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "CountryListViewController.h"

@interface CountryListViewController ()

@property (nonatomic,strong) NSMutableArray *activeSectionTitles;
//map each Label in "activeSectionTitles" to the section in the table
//that should be scrolled to when the label is clicked
@property (nonatomic,strong) NSMutableDictionary *activeSectionIndices;
@property (weak, nonatomic) IBOutlet UISearchBar *sesrchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic) NSArray *filteredArray;

@end

@implementation CountryListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.filteredArray = self.countrListArray;
    [self loadCountryList];
    
}

-(void)loadCountryList
{
    //[UILocalizedIndexedCollation currentCollation] is used to generate the index labels
    //that will be placed on the right side of the table.
    //count the number of letters in the localized alphabet(the right side labels).
    NSInteger indexLabelLettersCount = [[UILocalizedIndexedCollation currentCollation] sectionTitles].count;
    
    //hint to the objectivec about how many element our array will store. This is basically
    //equivalent to [[NSMutableArray alloc] init]; and we could have used that too.
    //NOTE: the size of the array is still 0, even after initWithCapacity:
    NSMutableArray *allSections = [[NSMutableArray alloc] initWithCapacity:indexLabelLettersCount];
    
    //populate the the table array with an empty array for each index label(right side letter)
    for (int i = 0; i < indexLabelLettersCount; i++) {
        [allSections addObject:[NSMutableArray array]];
    }
    
    
    
    //loop thru each U.S state and add then to the correct section of the table array
    for(NSString *theState in self.filteredArray){
        
        //this code determines which section of the table array the U.S state name belongs in.
        //sectionForObject: - pass the object whose's location we are tyring to determine
        //collationStringSelector: a method on the given object that returns a string. This
        //stirng is used to determine the correct section.
        NSInteger sectionNumber = [[UILocalizedIndexedCollation currentCollation] sectionForObject:theState collationStringSelector:@selector(lowercaseString)];
        //we now know the section it belongs in. Add the state name to that section.
        [allSections[sectionNumber] addObject:theState];
    }//for
    
    //we will store our table data. This will store the sorted data
    NSMutableArray *sortedArray = [[NSMutableArray alloc] init];
    self.activeSectionIndices = [NSMutableDictionary dictionary];
    self.activeSectionTitles = [NSMutableArray array];
    
    
    //loop through the index array(Right side letters)
    //the goal is to filter out all the index labels for which we dont have content
    //we'll create a new array to store these filtered labels
    for (int i = 0; i < indexLabelLettersCount; i++) {
        
        //get all the U.S states for the current section(index)
        NSArray *statesForSection = allSections[i];
        //get the label for the current section
        NSString *indexTitleForSection = [[UILocalizedIndexedCollation currentCollation] sectionTitles][i];
        
        //if we have content for this index
        if (statesForSection.count > 0) {
            
            //then add it to our new filtered array of labels
            [self.activeSectionTitles addObject:indexTitleForSection];
            
            //why not sort the arrays in this section??
            NSArray *tmpSectionStates = allSections[i];
            //sort the array
            tmpSectionStates = [tmpSectionStates sortedArrayUsingSelector:@selector(compare:)];
            //add the sorted section to our sorted Table Array
            [sortedArray addObject:tmpSectionStates];
        }
        
        //each time we add a label to self.activeSectionTitles it will grow by one.
        //if we don't have any states for the current section, the array size won't change
        //(self.activeSectionTitles.count - 1) indicates the last index of the array.
        //the goal here is to map each label to it's index in self.activeSectionTitles
        //if an index label does not have content, it should map to the last section
        //that had content. In this case, that will be self.activeSectionTitles.count - 1,
        //which is the last index that had content.
        //if the array does not have content we'll end up with a negative number. therefore
        //we take the max of zero to avoid that
        NSNumber *index = [NSNumber numberWithInt:MAX(self.activeSectionTitles.count - 1, 0)];
        
        //map the index label to it's position in self.activeSectionTitles
        self.activeSectionIndices[indexTitleForSection] = index;
        
    }
    
    
    
    self.filteredArray = sortedArray;
}

- (IBAction)backButtonTapped:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark:- Tableview Delegate

- (NSInteger)numberOfSectionsInTableView: (UITableView *) tableView{
    return self.filteredArray.count;
}
//number of rows in sections
- (NSInteger)tableView: (UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *arr = self.filteredArray[section];
    return arr.count;
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    //cell.textLabel.text = [self.filteredArray objectAtIndex:indexPath.row];
    
    NSArray *arr = self.filteredArray[indexPath.section];//get the current section array
    cell.textLabel.text = arr[indexPath.row];//get the row for the current section
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (self.delegate != nil) {
        
        NSArray *arr = self.filteredArray[indexPath.section];//get the current section array
        [self.delegate selectedCountry:arr[indexPath.row]];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

//return the header for each section of the table
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return self.activeSectionTitles[section];
}

//return an array of index labels that should appear on the ride side of the table view
//a,b,c,d,e etc
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    //simple use [UILocalizedIndexedCollation currentCollation]
    NSArray *letterIndexLabels = [[UILocalizedIndexedCollation currentCollation] sectionTitles];
    return letterIndexLabels;
    
}

//each time the user clicks the index click(Labels on the right of the table)
//this method is called.
//it should return the section of the table view that should be scrolled to.
-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    
    //title - the label that was clicked
    //index - the index that was clicked(for the label).
    
    //earlier we mapped each Label to a section in the table view
    //so we now know which section to scroll to.
    return [self.activeSectionIndices[title] integerValue];
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (![searchBar.text  isEqual: @""]) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[c] %@", searchBar.text];
        self.filteredArray = [self.countrListArray filteredArrayUsingPredicate:predicate];
        [self loadCountryList];
        [self.tableView reloadData];

    }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [self.sesrchBar setShowsCancelButton:YES animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [self.sesrchBar setShowsCancelButton:NO animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    self.sesrchBar.text = @"";
    [self.sesrchBar resignFirstResponder];
    self.filteredArray = self.countrListArray;
    [self loadCountryList];
    [self.tableView reloadData];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [self.sesrchBar resignFirstResponder];
}



@end
