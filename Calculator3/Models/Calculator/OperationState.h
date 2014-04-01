//
//  OperationState.h
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/03/01.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "State.h"

@interface OperationState : State

+ (OperationState *)sharedManager;

@end
