//
//  MultiplyOperation.m
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/03/02.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "MultiplyOperation.h"

@implementation MultiplyOperation
static MultiplyOperation *sharedState = nil;
+ (MultiplyOperation *)sharedManager {
    if (sharedState == nil) {
        sharedState = [[self alloc] init];
    }
	return sharedState;
}

- (NSString *)calculationOperandA:(NSDecimalNumber *)opeA withOperandB:(NSDecimalNumber *)opeB
{
    NSString *result = nil;
    
    NSLog(@"%@ * %@", opeA, opeB);
    
    @try {
        NSDecimalNumber *resultNumer = [opeA decimalNumberByMultiplyingBy:opeB];
        result = [resultNumer stringValue];
    }
    @catch (NSException* ex) {
        if ([ex.name isEqualToString:NSDecimalNumberDivideByZeroException]) {
            result = @"Error Divide by Zero";
        } else if ([ex.name isEqualToString:NSDecimalNumberOverflowException]) {
            result = @"Error Overflow";
        } else if ([ex.name isEqualToString:NSDecimalNumberUnderflowException]) {
            result = @"Error Underflow";
        } else if ([ex.name isEqualToString:NSDecimalNumberExactnessException]) {
            result = @"Error Exactness";
        } else {
            result = @"Error Unknown";
        }
    }
    
    return result;
}
@end
