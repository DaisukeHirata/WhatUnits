//
//  ConversionUnitTableViewController.h
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/02/23.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "CoreDataTableViewController.h"

@class ConversionMeasure;
@class ConversionUnit;

@interface ConversionUnitTableViewController : CoreDataTableViewController

// in
@property (nonatomic, strong) ConversionMeasure *selectingMeasure;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

// out  in(for auto cell selection)
@property (nonatomic, strong) ConversionUnit *selectedUnit;

@end
