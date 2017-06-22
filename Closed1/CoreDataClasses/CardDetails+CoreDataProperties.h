//
//  CardDetails+CoreDataProperties.h
//  Closed1
//
//  Created by Nazim on 23/06/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import "CardDetails+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface CardDetails (CoreDataProperties)

+ (NSFetchRequest<CardDetails *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *cardencryptedtext;
@property (nullable, nonatomic, copy) NSString *cardexpirydate;
@property (nullable, nonatomic, copy) NSString *cardimagename;
@property (nullable, nonatomic, copy) NSString *cardname;
@property (nullable, nonatomic, copy) NSString *cardnumber;
@property (nullable, nonatomic, copy) NSString *cvvimageName;
@property (nullable, nonatomic, copy) NSString *cvvtext;
@property (nonatomic) int64_t userid;

@end

NS_ASSUME_NONNULL_END
