//
//  ConversionClass.h
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/03/01.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ConversionMeasure;

@interface ConversionClass : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *measures;
@end

@interface ConversionClass (CoreDataGeneratedAccessors)

- (void)addMeasuresObject:(ConversionMeasure *)value;
- (void)removeMeasuresObject:(ConversionMeasure *)value;
- (void)addMeasures:(NSSet *)values;
- (void)removeMeasures:(NSSet *)values;

@end
