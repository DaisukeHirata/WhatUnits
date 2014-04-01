//
//  ConversionUnit+Helper.h
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/02/23.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "ConversionUnit.h"

@interface ConversionUnit (Helper)

// simple load api
+ (ConversionUnit *)unitWithCloudInfo:(NSDictionary *)unitDictionary
               inManagedObjectContext:(NSManagedObjectContext *)context;

// bulk load api
+ (void)loadUnitsFromCloudArray:(NSArray *)units // of Cloud NSDictionary
       intoManagedObjectContext:(NSManagedObjectContext *)context;

+ (ConversionUnit *)firstObjectByConversionMeasure:(ConversionMeasure *)measure
                            InManagedObjectContext:(NSManagedObjectContext *)context;

+ (ConversionUnit *)saveUnit:(ConversionUnit *)unit inManagedObjectContext:(NSManagedObjectContext *)context;

@end
