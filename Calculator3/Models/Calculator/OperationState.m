//
//  OperationState.m
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/03/01.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "OperationState.h"
#import "Context.h"
#import "OperandAState.h"
#import "OperandBState.h"
#import "ResultState.h"

@implementation OperationState

static OperationState *sharedState = nil;

+ (OperationState *)sharedManager {
    if (sharedState == nil) {
        sharedState = [[self alloc] init];
    }
	return sharedState;
}

- (void)inputNumber:(NSString *)number withContext:(Context *)context
{
    [context clearDisplay];
    [context addDisplayNumber:number];
    context.state = [OperandBState sharedManager];
}

- (void)inputOperation:(Operation *)operation withContext:(Context *)context
{
    context.operation = operation;
}

- (void)inputEqualWithContext:(Context *)context
{
    [context updateDisplayNumberWithNumber:context.operandA];
    context.state = [ResultState sharedManager];
}

- (void)inputClearWithContext:(Context* )context
{
    [context clearOperandA];
    [context clearDisplay];
    context.state = [OperandAState sharedManager];
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
    [context clearDisplay];
    [context addDisplayPeriod];
    context.state = [OperandBState sharedManager];
}

- (void)inputBackspace:(Context *)context
{
    context.operation = nil;
    context.state = [OperandAState sharedManager];
}

- (void)inputSign:(Context *)context
{
    [context inverseSignDisplayOtherwiseInitWithNegativeZero:YES];
    context.state = [OperandBState sharedManager];
}


@end
