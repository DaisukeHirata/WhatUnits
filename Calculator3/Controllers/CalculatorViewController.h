//
//  CalculatorViewController.h
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/02/19.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ConversionMeasure;
@class ConversionUnit;
@class ShufflingLabel;

@interface CalculatorViewController : UIViewController
@property (nonatomic, readonly) ConversionMeasure *conversionMeasure; // selected conversion measure currently
                                                                    // (first it's on the left hand side)
@property (nonatomic, readonly) ConversionUnit *conversionUnit;       // selected conversion unit currently
                                                                    // (first it's on the right hand side)
@property (weak, nonatomic, readonly) IBOutlet UILabel *display;
@property (weak, nonatomic, readonly) IBOutlet ShufflingLabel *conversionDisplay;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@end
