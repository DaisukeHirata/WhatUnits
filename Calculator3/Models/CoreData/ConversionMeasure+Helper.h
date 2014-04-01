//
//  ConversionMeasure+Helper.h
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/02/23.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "ConversionMeasure.h"

@interface ConversionMeasure (Helper)

+ (ConversionMeasure *)measureWithCloudInfo:(NSDictionary *)unitDictionary
                     inManagedObjectContext:(NSManagedObjectContext *)context;

+ (ConversionMeasure *)firstObjectInManagedObjectContext:(NSManagedObjectContext *)context;

+ (ConversionMeasure *)searchMeasure:(NSString *)name
                           className:(NSString *)className
              inManagedObjectContext:(NSManagedObjectContext *)context;

+ (NSMutableArray *)measureNameArrayByClassName:(NSString *)className inManagedObjectContext:(NSManagedObjectContext *)context;
@end
