//
//  ContactDetails+CoreDataProperties.m
//  Closed1
//
//  Created by Nazim on 14/04/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "ContactDetails+CoreDataProperties.h"

@implementation ContactDetails (CoreDataProperties)

+ (NSFetchRequest<ContactDetails *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"ContactDetails"];
}

@dynamic company;
@dynamic designation;
@dynamic imageURL;
@dynamic userID;
@dynamic userName;
@dynamic city;
@dynamic country;
@dynamic secondaryemail;
@dynamic territory;
@dynamic title;
@dynamic userEmail;
@dynamic userLogin;


- (NSString *) firstLetter
{
    [self willAccessValueForKey: @"firstLetter"];
    NSString *firstLetter = [[[self userName] substringToIndex: 1] uppercaseString];
    [self didAccessValueForKey: @"firstLetter"];
    return firstLetter;
}

-(NSString *) fullName
{
    [self willAccessValueForKey:@"fullName"];
    NSString * fullName = [NSString stringWithFormat:@"%@",[self userName]];
    [self didAccessValueForKey:@"fullName"];
    return fullName;
}

@end
