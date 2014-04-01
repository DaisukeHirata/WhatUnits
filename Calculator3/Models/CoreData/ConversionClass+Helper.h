//
//  ConversionClass+Helper.h
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/02/25.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "ConversionClass.h"

@interface ConversionClass (Helper)

+ (ConversionClass *)classWithName:(NSString *)name
            inManagedObjectContext:(NSManagedObjectContext *)context;

+ (NSDictionary *)colors;
@end
