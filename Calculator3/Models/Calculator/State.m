//
//  State.m
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/03/01.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "State.h"

@implementation State

- (void)inputNumber:(NSString *)number withContext:(Context *)context {}
- (void)inputOperation:(Operation *)operation withContext:(Context *)context {}
- (void)inputEqualWithContext:(Context *)context {}
- (void)inputClearWithContext:(Context* )context {}
- (void)inputAllClearWithContext:(Context *)context {}
- (void)inputPeriod:(Context *)context {}
- (void)inputBackspace:(Context *)context {}
- (void)inputSign:(Context *)context {}

@end


