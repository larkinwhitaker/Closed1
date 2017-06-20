//
//  ClosedResverResponce.h
//  Closed1
//
//  Created by Nazim on 02/04/17.
//  Copyright © 2017 Alkurn. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ServerFailedDelegate <NSObject>

-(void)serverFailedWithTitle: (NSString *)title SubtitleString: (NSString *)subtitle;

@end

@interface ClosedResverResponce : NSObject

+(ClosedResverResponce *)sharedInstance;
-(NSArray *)getResponceFromServer: (NSString *)URLName  DictionartyToServer:(NSDictionary *)dictionaryToServer IsEncodingRequires: (BOOL) isEncoding;
-(void)invalidateCurrentRunningTask;
@property(nonatomic,weak)id<ServerFailedDelegate>delegate;


@end


