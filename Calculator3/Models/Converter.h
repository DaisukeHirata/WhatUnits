//
//  Converter.h
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/02/22.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ConversionMeasure;
@class ConversionUnit;

@interface Converter : NSObject

@property (nonatomic, strong) ConversionMeasure *measure;   // selected measure on the left hand side
@property (nonatomic, strong) ConversionUnit *unit;         // selected unit on the right hand side
@property (nonatomic) BOOL scientificNotationMode;          //

/*!
 * @methon init
 * Designated initializer
 */
- (instancetype)init;


/*!
 * @method convertAnswer:
 * Receives displayString. Convert it's unit to property's unit.
 */
- (NSString *)convertAnswer:(NSString *)displayString;

@end

