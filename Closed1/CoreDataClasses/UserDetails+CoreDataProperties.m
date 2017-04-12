//
//  UserDetails+CoreDataProperties.m
//  Closed1
//
//  Created by Nazim on 11/04/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "UserDetails+CoreDataProperties.h"

@implementation UserDetails (CoreDataProperties)

+ (NSFetchRequest<UserDetails *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"UserDetails"];
}

@dynamic firstName;
@dynamic lastName;
@dynamic userEmail;
@dynamic userID;
@dynamic userLogin;
@dynamic title;
@dynamic company;
@dynamic city;
@dynamic country;
@dynamic territory;
@dynamic econdaryemail;
@dynamic profileImage;

@end
