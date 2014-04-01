//
//  ConversionMeasure+Helper.m
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/02/23.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "ConversionMeasure+Helper.h"
#import "ConversionClass+Helper.h"
#import "WhatUnitsAPI.h"

@implementation ConversionMeasure (Helper)

// conversion measure getter. if it does not exists in database, then create it
// and return it.
+ (ConversionMeasure *)measureWithCloudInfo:(NSDictionary *)unitDictionary
                     inManagedObjectContext:(NSManagedObjectContext *)context
{
    ConversionMeasure *measure = nil;
    
    NSString *name  = [unitDictionary valueForKey:WHATUNITS_UNIT_MEASURE];
    NSString *classname = [unitDictionary valueForKey:WHATUNITS_UNIT_CLASS];
    NSString *ratioString = [unitDictionary valueForKey:WHATUNITS_UNIT_MEASURE_RATIO];
    NSNumber *ratio = @([ratioString doubleValue]);
    if ([name length] && ratio) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ConversionMeasure"];
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@ AND whichClass.name = %@", name, classname];
        
        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if (!matches || error || ([matches count] > 1)) {
            // handle error
        } else if (![matches count]) {
            measure = [NSEntityDescription insertNewObjectForEntityForName:@"ConversionMeasure"
                                                 inManagedObjectContext:context];
            measure.name  = name;
            measure.ratio = ratio;
            // set class relation
            measure.whichClass  = [ConversionClass classWithName:classname inManagedObjectContext:context];
            NSError *error = nil;
            [context save:&error];
            if(error){
                NSLog(@"could not save data : %@", error);
            }
        } else {
            measure = [matches lastObject];
        }
    }
    
    return measure;
}

// return a first object
+ (ConversionMeasure *)firstObjectInManagedObjectContext:(NSManagedObjectContext *)context
{
    ConversionMeasure *measure = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ConversionMeasure"];
    request.predicate = nil;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                              ascending:YES
                                                               selector:@selector(localizedStandardCompare:)]];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    if (!matches || error) {
        // handle error here
        NSLog(@"error1");
    } else if  ([matches count]) {
        measure = [matches firstObject];
    } else {
        NSLog(@"error2");
    }
    return measure;
}

+ (ConversionMeasure *)searchMeasure:(NSString *)name
                           className:(NSString *)className
              inManagedObjectContext:(NSManagedObjectContext *)context
{
    ConversionMeasure *measure = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ConversionMeasure"];
    //request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@ AND whichClass.name = %@", name, className];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        // error
    } else if (![matches count]) {
        // error
    } else {
        measure = [matches lastObject];
    }
    
    return measure;
}

+ (NSMutableArray *)measureNameArrayByClassName:(NSString *)className inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSMutableArray *measureNames = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ConversionMeasure"];
    request.predicate = [NSPredicate predicateWithFormat:@"whichClass.name = %@", className];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error) {
        // error
    } else if ([matches count]) {
        measureNames = [[NSMutableArray alloc] init];
        for (ConversionMeasure *measure in matches) {
            [measureNames addObject:measure.name];
        }
    }
    
    return measureNames;
}


@end
