//
//  JobProfile+CoreDataProperties.m
//  Closed1
//
//  Created by Nazim on 05/06/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "JobProfile+CoreDataProperties.h"

@implementation JobProfile (CoreDataProperties)

+ (NSFetchRequest<JobProfile *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"JobProfile"];
}

@dynamic title;
@dynamic compnay;
@dynamic territory;
@dynamic targetBuyers;
@dynamic currentPoistion;

@end
