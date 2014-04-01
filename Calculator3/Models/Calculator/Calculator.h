//
//  Calculator.h
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/02/25.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "Context.h"

@interface Calculator : Context

@property (nonatomic) BOOL error;               // indicate error happend or not

/*!
 * @methon init
 * Designated initializer
 */
- (instancetype) init;

/*!
 * @method input:
 * Receives input into the calculator.
 *
 * Valid characters:
 *
 *     Digits:    .0123456789
 *
 *     Operators: +-×/=
 *
 *     Commands:  🔙    Delete
 *                C     Clear
 *
 * @throws NSInvalidArgumentException when character is not valid.
 */
- (void) input:(NSString *) character;


/*!
 * @method operatorDisplayValue
 * Provides the value in the calculator’s current operator
 */
- (NSString *) operatorDisplayValue;


/*!
 * @method operandOperatorStrings
 */
+ (NSArray *)operandOperatorStrings;


/*!
 * @method newDisplayString
 * Provides the value in the calculator’s current operator
 */
- (NSString *) newDisplayString;

/*!
 * @method newConversionDisplayString
 * Provides the value in the calculator’s current operator
 */
- (NSString *) newConversionDisplayString;

@end
