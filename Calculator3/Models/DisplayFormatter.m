//
//  DisplayFormatter.m
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/02/22.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "DisplayFormatter.h"

@interface DisplayFormatter()
@property (nonatomic, strong, readwrite) NSNumberFormatter *inDecimal;
@property (nonatomic, strong, readwrite) NSNumberFormatter *inScientific;
@end

@implementation DisplayFormatter

#pragma mark Formatter for display

- (NSNumberFormatter *)inDecimal
{
    // lazy instantiation
    if (!_inDecimal) {
        // add commas to number every 3 digits.
        // This format specifier is not sophisticated though working. should be fixed later.
        _inDecimal = [[NSNumberFormatter alloc] init];
        [_inDecimal setPositiveFormat:@"#,##0.###############################"];
    }
    return _inDecimal;
}

- (NSNumberFormatter *)inScientific
{
    // lazy instantiation
    if (!_inScientific) {
        _inScientific = [[NSNumberFormatter alloc] init];
        [_inScientific setNumberStyle:NSNumberFormatterScientificStyle];
        [_inScientific setMaximumFractionDigits:3];
        [_inScientific setGroupingSeparator:@","];
    }
    return _inScientific;
}

@end
