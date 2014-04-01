//
//  AddConversionUnitViewController.h
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/02/21.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ConversionMeasure;
@class ConversionUnit;

@interface AddConversionUnitViewController : UIViewController

// in
@property (nonatomic, strong) ConversionMeasure *selectingMeasure;
@property (nonatomic) BOOL isAddNewUnitMode;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

// in(when segue from cell accesory. Edit mode) or out(when segue from camera nab bar item)
@property (nonatomic, strong) ConversionUnit *addedUnit;

@end
