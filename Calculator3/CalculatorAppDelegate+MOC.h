//
//  CalculatorAppDelegate+MOC.h
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/02/23.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "CalculatorAppDelegate.h"

@interface CalculatorAppDelegate (MOC)


- (void)saveContext:(NSManagedObjectContext *)managedObjectContext;

// Create managed object context attaches to a calculator database
- (NSManagedObjectContext *)createMainQueueManagedObjectContext;

@end
