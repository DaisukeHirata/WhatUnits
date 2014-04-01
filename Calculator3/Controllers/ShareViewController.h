//
//  ShareViewController.h
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/02/28.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseShareCommentViewController.h"

@class ConversionMeasure;
@class ConversionUnit;

// inherits from BaseShareCommentViewController
@interface ShareViewController : BaseShareCommentViewController

// in
@property (nonatomic, strong) ConversionMeasure *conversionMeasure; // selected conversion measure in CalculatorViewController
@property (nonatomic, strong) ConversionUnit *conversionUnit;       // selected conversion unit in CalculatorViewController
@property (nonatomic, strong) NSString *sourceValueString;
@property (nonatomic, strong) NSString *convertedValueString;
@end
