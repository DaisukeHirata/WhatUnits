//
//  Converter.m
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/02/22.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "Converter.h"
#import "ConversionMeasure.h"
#import "ConversionUnit.h"
#import "DisplayFormatter.h"

@interface Converter()
@property (nonatomic, strong) DisplayFormatter *formatter;
@end

@implementation Converter

#pragma mark Lifecycle

// designated initializer
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.scientificNotationMode = NO;
    }
    return self;
}

#pragma mark convert function

- (NSString *)convertAnswer:(NSString *)displayString
{
    NSString *convertedAnswer;
    
    // This display string includes 'Error' when exception occured
    NSRange searchInfinity = [displayString rangeOfString:@"Error"];
    if (searchInfinity.location == NSNotFound) {
        // convert calculation
        NSDecimalNumber *displayDecimalNumber   = [NSDecimalNumber decimalNumberWithString:displayString];
        NSDecimalNumber *unitValueDecimalNumber = [NSDecimalNumber decimalNumberWithDecimal:[self.unit.value decimalValue]];
        
        NSDecimalNumber *measureRatioDecimalNumber =
            [NSDecimalNumber decimalNumberWithDecimal:[self.measure.ratio decimalValue]];
        NSDecimalNumber *unitRatioDecimalNumber =
            [NSDecimalNumber decimalNumberWithDecimal:[self.unit.whichMeasure.ratio decimalValue]];
        
        @try {
            
            NSDecimalNumber *normalizedDisplayDecimalNumber =
                [displayDecimalNumber decimalNumberByMultiplyingBy:measureRatioDecimalNumber];
            NSDecimalNumber *normalizedUnitValueDecimalNumber =
                [unitValueDecimalNumber decimalNumberByMultiplyingBy:unitRatioDecimalNumber];
            
            NSDecimalNumber *convertedDecimalNumber
                = [normalizedDisplayDecimalNumber decimalNumberByDividingBy:normalizedUnitValueDecimalNumber];
            // conversionDisplay can be switchable scientific notation or not
            if (self.scientificNotationMode && ![displayString isEqualToString:@"0"]) {
                NSNumber *displayNumber = @([convertedDecimalNumber doubleValue]);
                convertedAnswer = [self.formatter.inScientific stringFromNumber:displayNumber];
            } else {
                NSNumber *displayNumber = @([convertedDecimalNumber doubleValue]);
                convertedAnswer = [self.formatter.inDecimal stringFromNumber:displayNumber];
            }
        }
        @catch (NSException* ex) {
            convertedAnswer = @"Convert Error";
        }
    } else {
        // set empty string to display
        convertedAnswer = @"";
    }
    
    return convertedAnswer;
}

- (NSString *)convertAnswerInDecimalNotation:(NSString *)displayString
{
    return nil;
}

- (NSString *)convertAnswerInScientificNotation:(NSString *)displayString
{
    return nil;
}

#pragma mark Formatter getter

- (DisplayFormatter *)formatter
{
    // lazy instantiation
    if (!_formatter) _formatter = [[DisplayFormatter alloc] init];
    return _formatter;
}

@end
