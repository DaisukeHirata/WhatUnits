//
//  Context.h
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/03/01.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import <Foundation/Foundation.h>

@class State;
@class CalcNumber;
#include "Operation.h"

@interface Context : NSObject

@property (nonatomic, strong) State* state;                 // caluculator state
@property (nonatomic, strong) Operation *operation;         // caluculator operator
@property (nonatomic, strong) NSDecimalNumber *operandA;    // caluculator operandA, inside memory

// execute operation and display result
- (void)doOperation;

// update display string
- (void)updateDisplayNumber;

// update display string with parameter
- (void)updateDisplayNumberWithNumber:(NSDecimalNumber *)number;

// add num string to display string
- (void)addDisplayNumber:(NSString *)number;

// add period to display string
- (void)addDisplayPeriod;

// delete one character from display string
- (void)backspaceDisplay;

// inverse the sign of display string
- (void)inverseSignDisplayOtherwiseInitWithNegativeZero:(BOOL)negativeZero;

// save display string to operand A
- (void)saveDisplayNumberToOperandA;

// save display string to operand B
- (void)saveDisplayNumberToOperandB;

// clear operand A
- (void)clearOperandA;

// clear operand B
- (void)clearOperandB;

// clear display string
- (void)clearDisplay;

// copy operandA to operandB
- (void)copyOperandAtoOperandB;


@end

