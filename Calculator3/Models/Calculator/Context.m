//
//  Context.m
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/03/01.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "Context.h"

@implementation Context

- (void)doOperation{}
- (void)updateDisplayNumber{}
- (void)updateDisplayNumberWithNumber:(NSDecimalNumber *)number{}
- (void)addDisplayNumber:(NSString *)number{}
- (void)addDisplayPeriod{}
- (void)backspaceDisplay{}
- (void)inverseSignDisplayOtherwiseInitWithNegativeZero:(BOOL)negativeZero{}
- (void)saveDisplayNumberToOperandA{}
- (void)saveDisplayNumberToOperandB{}
- (void)clearOperandA{}
- (void)clearOperandB{}
- (void)clearDisplay{}
- (void)copyOperandAtoOperandB{}

@end
