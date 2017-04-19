//
//  ContactDetails+CoreDataProperties.m
//  Closed1
//
//  Created by Nazim on 19/04/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "ContactDetails+CoreDataProperties.h"

@implementation ContactDetails (CoreDataProperties)

+ (NSFetchRequest<ContactDetails *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"ContactDetails"];
}

@dynamic designation;
@dynamic imageURL;
@dynamic title;
@dynamic userID;
@dynamic userName;
@dynamic company;
@dynamic userEmail;

    - (NSString *) firstLetter
    {
        [self willAccessValueForKey: @"firstLetter"];
        NSString *firstLetter = [[[self userName] substringToIndex: 1] uppercaseString];
        [self didAccessValueForKey: @"firstLetter"];
        return firstLetter;
    }
@end
