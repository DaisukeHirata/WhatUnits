//
//  ConversionUnit+Helper.m
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/02/23.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "ConversionUnit+Helper.h"
#import "ConversionMeasure+Helper.h"
#import "WhatUnitsFetcher.h"

@implementation ConversionUnit (Helper)


// simple load api
+ (ConversionUnit *)unitWithCloudInfo:(NSDictionary *)unitDictionary
               inManagedObjectContext:(NSManagedObjectContext *)context
{
    ConversionUnit *unit = nil;
    
    NSString *unique = unitDictionary[WHATUNITS_UNIT_ID];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ConversionUnit"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", unique];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        // handle error here
    } else if  ([matches count]) {
        unit = [matches firstObject];
    } else {
        unit = [NSEntityDescription insertNewObjectForEntityForName:@"ConversionUnit"
                                             inManagedObjectContext:context];
        unit.unique = unique;
        
        unit.title = [unitDictionary valueForKey:WHATUNITS_UNIT_TITLE];
        unit.overview = [unitDictionary valueForKey:WHATUNITS_UNIT_DESCRIPTION];
        unit.imageURL = [[WhatUnitsFetcher URLforUnitPhoto:unitDictionary
                                             format:WhatUnitsPhotoFormatLarge] absoluteString];
        unit.thumbnailURL = [[WhatUnitsFetcher URLforUnitPhoto:unitDictionary
                                                 format:WhatUnitsPhotoFormatSquare] absoluteString];
        NSString *valueString = [unitDictionary valueForKey:WHATUNITS_UNIT_VALUE];
        unit.value = @([valueString doubleValue]);
        // set measure relation
        unit.whichMeasure = [ConversionMeasure measureWithCloudInfo:unitDictionary
                                             inManagedObjectContext:context];
        NSError *error = nil;
        [context save:&error];
        if(error){
            NSLog(@"could not save data : %@", error);
        }
    }
    
    return unit;
}

// bulk load api
+ (void)loadUnitsFromCloudArray:(NSArray *)units // of Cloud NSDictionary
       intoManagedObjectContext:(NSManagedObjectContext *)context
{
    // inefficient way . should be improved later 50:34
    for (NSDictionary *unit in units) {
        [self unitWithCloudInfo:unit inManagedObjectContext:context];
    }
    
}

// return a first object
+ (ConversionUnit *)firstObjectByConversionMeasure:(ConversionMeasure *)measure
                         InManagedObjectContext:(NSManagedObjectContext *)context
{
    ConversionUnit *unit = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ConversionUnit"];
    request.predicate = [NSPredicate predicateWithFormat:@"whichMeasure.name = %@", measure.name];
    
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"whichMeasure.name"
                                                              ascending:YES
                                                               selector:@selector(localizedStandardCompare:)]];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    if (!matches || error) {
        NSLog(@"error3");
        // handle error here
    } else if  ([matches count]) {
        unit = [matches firstObject];
    } else {
        NSLog(@"error4");
    }
    return unit;
}


+ (ConversionUnit *)saveUnit:(ConversionUnit *)inputUnit inManagedObjectContext:(NSManagedObjectContext *)context
{
    ConversionUnit *unit = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ConversionUnit"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", inputUnit.unique];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        // error
        unit = nil; // not necessary. it's for readability
    } else if  ([matches count]) {
        // update
        unit = [matches firstObject];
    } else {
        // insert
        unit = [NSEntityDescription insertNewObjectForEntityForName:@"ConversionUnit"
                                             inManagedObjectContext:context];
    }
    
    if (unit) {
        unit.unique       = inputUnit.unique;
        unit.title        = inputUnit.title;
        unit.overview     = inputUnit.overview;
        unit.imageURL     = inputUnit.imageURL;
        unit.thumbnailURL = inputUnit.thumbnailURL;
        unit.value        = inputUnit.value;
        unit.whichMeasure = inputUnit.whichMeasure;
        NSError *error = nil;
        [context save:&error];
        if(error) {
            NSLog(@"could not save data : %@", error);
        }
    }
    
    return unit;
}


@end
