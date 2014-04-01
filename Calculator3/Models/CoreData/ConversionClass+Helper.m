//
//  ConversionClass+Helper.m
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/02/25.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "ConversionClass+Helper.h"

@implementation ConversionClass (Helper)

+ (ConversionClass *)classWithName:(NSString *)name
              inManagedObjectContext:(NSManagedObjectContext *)context
{
    ConversionClass *class = nil;
    
    if ([name length]) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ConversionClass"];
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
        
        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if (!matches || error || ([matches count] > 1)) {
            // handle error
        } else if (![matches count]) {
            class       = [NSEntityDescription insertNewObjectForEntityForName:@"ConversionClass"
                                                        inManagedObjectContext:context];
            class.name  = name;
            NSError *error = nil;
            [context save:&error];
            if(error){
                NSLog(@"could not save data : %@", error);
            }
        } else {
            class = [matches lastObject];
        }
    }
    
    return class;
}

+ (NSDictionary *)colors
{
    return @{@"Money"       : [self hexToUIColor:@"FFD119" alpha:1.0],
             @"Distance"    : [self hexToUIColor:@"38AD26" alpha:1.0],
             @"Weight"      : [self hexToUIColor:@"987D45" alpha:1.0],
             @"Area"        : [self hexToUIColor:@"3775CB" alpha:1.0],
             @"Volume"      : [self hexToUIColor:@"3775CB" alpha:1.0],
             @"Height"      : [self hexToUIColor:@"006000" alpha:1.0],
             @"Age"         : [self hexToUIColor:@"AB4D4C" alpha:1.0],
             @"Speed"       : [self hexToUIColor:@"828282" alpha:1.0],
             @"Sound Level" : [self hexToUIColor:@"B04EB2" alpha:1.0]};
}

+ (UIColor*) hexToUIColor:(NSString *)hex alpha:(CGFloat)a{
	NSScanner *colorScanner = [NSScanner scannerWithString:hex];
	unsigned int color;
	[colorScanner scanHexInt:&color];
	CGFloat r = ((color & 0xFF0000) >> 16)/255.0f;
	CGFloat g = ((color & 0x00FF00) >> 8) /255.0f;
	CGFloat b =  (color & 0x0000FF) /255.0f;
	return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

@end
