//
//  CardDetails+CoreDataProperties.m
//  Closed1
//
//  Created by Nazim on 23/06/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "CardDetails+CoreDataProperties.h"

@implementation CardDetails (CoreDataProperties)

+ (NSFetchRequest<CardDetails *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"CardDetails"];
}

@dynamic cardencryptedtext;
@dynamic cardexpirydate;
@dynamic cardimagename;
@dynamic cardname;
@dynamic cardnumber;
@dynamic cvvimageName;
@dynamic cvvtext;
@dynamic userid;

@end
