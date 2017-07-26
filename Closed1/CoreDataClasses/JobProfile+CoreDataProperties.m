//
//  JobProfile+CoreDataProperties.m
//  Closed1
//
//  Created by Nazim on 08/07/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "JobProfile+CoreDataProperties.h"

@implementation JobProfile (CoreDataProperties)

+ (NSFetchRequest<JobProfile *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"JobProfile"];
}

@dynamic compnay;
@dynamic currentPoistion;
@dynamic targetBuyers;
@dynamic territory;
@dynamic title;
@dynamic jobid;

@end
