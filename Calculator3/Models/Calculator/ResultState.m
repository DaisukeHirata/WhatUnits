//
//  ResultState.m
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/03/01.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "ResultState.h"
#import "Context.h"
#import "OperandAState.h"
#import "OperationState.h"

@implementation ResultState

static ResultState *sharedState = nil;

+ (ResultState *)sharedManager {
    if (sharedState == nil) {
        sharedState = [[self alloc] init];
    }
	return sharedState;
}

- (void)inputNumber:(NSString *)number withContext:(Context *)context
{
    [context clearDisplay];
    [context addDisplayNumber:number];
    context.state = [OperandAState sharedManager];
}

- (void)inputOperation:(Operation *)operation withContext:(Context *)context
{
    [context saveDisplayNumberToOperandA];
    context.operation = operation;
    context.state = [OperationState sharedManager];
}


- (void)inputEqualWithContext:(Context *)context
{
    // do nothing
}

- (void)inputClearWithContext:(Context* )context
{
    [context clearOperandA];
    [context clearOperandB];
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
    context.state = [OperandAState sharedManager];
}

- (void)inputBackspace:(Context *)context
{
    [context clearOperandA];
    [context clearOperandB];
    [context clearDisplay];
    context.state = [OperandAState sharedManager];
}

- (void)inputSign:(Context *)context
{
    [context inverseSignDisplayOtherwiseInitWithNegativeZero:YES];
    context.state = [OperandAState sharedManager];
}
@end
