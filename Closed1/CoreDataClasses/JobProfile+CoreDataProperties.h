//
//  JobProfile+CoreDataProperties.h
//  Closed1
//
//  Created by Nazim on 08/07/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "JobProfile+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface JobProfile (CoreDataProperties)

+ (NSFetchRequest<JobProfile *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *compnay;
@property (nullable, nonatomic, copy) NSString *currentPoistion;
@property (nullable, nonatomic, copy) NSString *targetBuyers;
@property (nullable, nonatomic, copy) NSString *territory;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *jobid;

@end

NS_ASSUME_NONNULL_END
