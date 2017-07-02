//
//  UserDetails+CoreDataProperties.m
//  Closed1
//
//  Created by Nazim on 28/06/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "UserDetails+CoreDataProperties.h"

@implementation UserDetails (CoreDataProperties)

+ (NSFetchRequest<UserDetails *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"UserDetails"];
}

@dynamic city;
@dynamic company;
@dynamic country;
@dynamic econdaryemail;
@dynamic firstName;
@dynamic phoneNumber;
@dynamic profileImage;
@dynamic state;
@dynamic targetBuyers;
@dynamic territory;
@dynamic title;
@dynamic userEmail;
@dynamic userID;
@dynamic userLogin;

@end
