//
//  OperandAState.m
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/03/01.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "OperandAState.h"
#import "Context.h"
#import "OperationState.h"
#import "ResultState.h"

@implementation OperandAState

static OperandAState *sharedState = nil;

+ (OperandAState *)sharedManager {
    if (sharedState == nil) {
        sharedState = [[self alloc] init];
    }
	return sharedState;
}

- (void)inputNumber:(NSString *)number withContext:(Context *)context
{
    [context addDisplayNumber:number];
}

- (void)inputOperation:(Operation *)operation withContext:(Context *)context
{
    [context saveDisplayNumberToOperandA];
    context.operation = operation;
    context.state = [OperationState sharedManager];
}

- (void)inputEqualWithContext:(Context *)context
{
    [context saveDisplayNumberToOperandA];
    [context updateDisplayNumberWithNumber:context.operandA];
    context.state = [ResultState sharedManager];
}

- (void)inputClearWithContext:(Context* )context
{
    [context clearOperandA];
    [context clearDisplay];
}

- (void)inputAllClearWithContext:(Context *)context
{
    [context clearOperandA];
    [context clearOperandB];
    [context clearDisplay];
}

- (void)inputPeriod:(Context *)context
{
    [context addDisplayPeriod];
}

- (void)inputBackspace:(Context *)context
{
    [context backspaceDisplay];
}

- (void)inputSign:(Context *)context
{
    [context inverseSignDisplayOtherwiseInitWithNegativeZero:NO];
}

@end

