//
//  State.h
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/03/01.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Context;
@class Operation;
@class CalcNumber;

@interface State : NSObject

/**
 * input Number
 */
- (void)inputNumber:(NSString *)number withContext:(Context *)context;

/**
 * input operator(四則演算記号)
 */
- (void)inputOperation:(Operation *)operation withContext:(Context *)context;

/**
 * input equal
 */
- (void)inputEqualWithContext:(Context *)context;


/**
 * input clear
 */
- (void)inputClearWithContext:(Context* )context;

/**
 * input all clear
 */
- (void)inputAllClearWithContext:(Context *)context;


/**
 * input period
 */
- (void)inputPeriod:(Context *)context;

/**
 * input backspace
 */
- (void)inputBackspace:(Context *)context;

/**
 * input +_- inverse sign
 */
- (void)inputSign:(Context *)context;


@end
