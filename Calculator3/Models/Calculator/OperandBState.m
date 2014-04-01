//
//  OperandBState.m
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/03/01.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "OperandBState.h"
#import "Context.h"
#import "OperationState.h"
#import "ResultState.h"
#import "OperandAState.h"

@implementation OperandBState

static OperandBState *sharedState = nil;

+ (OperandBState *)sharedManager {
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
    [context saveDisplayNumberToOperandB];
    [context doOperation];
    context.operation = operation;
    [context saveDisplayNumberToOperandA];
    context.state = [OperationState sharedManager];
}

- (void)inputEqualWithContext:(Context *)context
{
    [context saveDisplayNumberToOperandB];
    [context doOperation];
    context.state = [ResultState sharedManager];
}

- (void)inputClearWithContext:(Context* )context
{
    [context clearOperandB];
    [context clearDisplay];
}

- (void)inputAllClearWithContext:(Context *)context
{
    [context clearOperandA];
    [context clearOperandB];
    [context clearDisplay];
    context.state = [OperandAState sharedManager];
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




