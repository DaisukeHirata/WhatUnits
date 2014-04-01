//
//  ConversionMeasure.h
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/03/01.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ConversionClass, ConversionUnit;

@interface ConversionMeasure : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * ratio;
@property (nonatomic, retain) NSSet *units;
@property (nonatomic, retain) ConversionClass *whichClass;
@end

@interface ConversionMeasure (CoreDataGeneratedAccessors)

- (void)addUnitsObject:(ConversionUnit *)value;
- (void)removeUnitsObject:(ConversionUnit *)value;
- (void)addUnits:(NSSet *)values;
- (void)removeUnits:(NSSet *)values;

@end
