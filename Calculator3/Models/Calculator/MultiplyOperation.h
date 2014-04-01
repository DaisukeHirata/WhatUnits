//
//  MultiplyOperation.h
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/03/02.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "Operation.h"

@interface MultiplyOperation : Operation
+ (Operation *)sharedManager;
- (NSString *)calculationOperandA:(NSDecimalNumber *)opeA withOperandB:(NSDecimalNumber *)opeB;
@end
