//
//  JobProfile+CoreDataProperties.h
//  Closed1
//
//  Created by Nazim on 05/06/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "JobProfile+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface JobProfile (CoreDataProperties)

+ (NSFetchRequest<JobProfile *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *compnay;
@property (nullable, nonatomic, copy) NSString *territory;
@property (nullable, nonatomic, copy) NSString *targetBuyers;
@property (nullable, nonatomic, copy) NSString *currentPoistion;

@end

NS_ASSUME_NONNULL_END
