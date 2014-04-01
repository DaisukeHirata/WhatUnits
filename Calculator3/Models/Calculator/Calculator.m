//
//  Calculator.m
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/02/25.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "Calculator.h"
#import "DisplayFormatter.h"
#import "Operation.h"
#import "AddOperation.h"
#import "SubtractOperation.h"
#import "MultiplyOperation.h"
#import "DevideOperation.h"
#import "State.h"
#import "OperandAState.h"
#import "OperandBState.h"

// These string constants contain the characters that the input: method accepts.
NSString *Operators = @"+−×÷";
NSString *Equals    = @"=";
NSString *Digits    = @"0123456789.";
NSString *Digit     = @"0123456789";
NSString *Period    = @".";
NSString *Delete    = @"🔙";
NSString *Clear     = @"C";
NSString *Sign      = @"+_−";
NSString *Zero      = @"0";
NSString *Minus     = @"−";


@interface Calculator()

@property (nonatomic, strong) NSMutableString *display;     // The calculator display (the value a
                                                            // harwdare-based calculator shows on its LCD screen).
@property (nonatomic, strong) DisplayFormatter *formatter;
@property (nonatomic, strong) State *state;                 // 電卓の状態を表すクラス
@property (nonatomic, strong) Operation *operation;         // 電卓は演算子を持ちます。
@property (nonatomic, strong) NSDecimalNumber *operandA;    // 電卓はメモリAを持ちます。
// An instance can represent any number that can be expressed
// as mantissa x 10^exponent where mantissa is a decimal
// integer up to 38 digits long, and exponent is an integer from –128 through 127.
@property (nonatomic, strong) NSDecimalNumber *operandB;    // 電卓はメモリAを持ちます。
@property (nonatomic, strong) NSMutableString *disppp;      //
@property (nonatomic, strong) NSMutableString *dispconv;    //

@end


@implementation Calculator

#pragma mark Calculator Operation
/*
 * The input: method accepts the characters in the string constants
 * Operators, Equals, Digits, Period Delete, and Clear.
 *
 * The results of this method's computations are stored in display.
 * This method uses operand, and operator in its calculations.
 */
- (void) input:(NSString *) inputCharacter
{
    [self newInput:inputCharacter];
}

- (void) newInput:(NSString *) inputCharacter
{
    if ([Digit rangeOfString: inputCharacter].length) {
        
        [self.state inputNumber:inputCharacter withContext:self];
        
    } else if ([Operators rangeOfString:inputCharacter].length) {
        
        if ([inputCharacter isEqualToString:@"+"]) {
            [self.state inputOperation:[AddOperation sharedManager] withContext:self];
        } else if ([inputCharacter isEqualToString:@"−"]) {
            [self.state inputOperation:[SubtractOperation sharedManager] withContext:self];
        } else if ([inputCharacter isEqualToString:@"×"]) {
            [self.state inputOperation:[MultiplyOperation sharedManager] withContext:self];
        } else if ([inputCharacter isEqualToString:@"÷"]) {
            [self.state inputOperation:[DevideOperation sharedManager] withContext:self];
        }
        
    } else if ([inputCharacter isEqualToString:Clear]) {
        
        [self.state inputClearWithContext:self];
        
    } else if ([inputCharacter isEqualToString:Equals]) {
        
        [self.state inputEqualWithContext:self];
        
    } else if ([inputCharacter isEqualToString:Period]) {
        
        [self.state inputPeriod:self];
        
    } else if ([inputCharacter isEqualToString:Delete]) {
        
        [self.state inputBackspace:self];
        
    } else if ([inputCharacter isEqualToString:Sign]) {
        
        [self.state inputSign:self];
    
    } else {
        
        NSLog(@"bad char!!");
    }
    
    
    NSLog(@"display %@", self.disppp);
}

- (void) doOperation
{
    NSString *result = [self.operation calculationOperandA:self.operandA withOperandB:self.operandB];
    [self.dispconv setString:result];
    NSLog(@"calc end %@", result);
    
    // This display string includes 'Error' when exception occured
    NSRange searchInfinity = [result rangeOfString:@"Error"];
    NSString *displayString;
    if (searchInfinity.location == NSNotFound) {
        
        self.error = NO;
        double displayInDouble = [result doubleValue];
        NSNumber *displayNumber = @(displayInDouble);
        if ([result isEqualToString:Zero] ||
            (displayInDouble <  9999999999999999.f && displayInDouble >  0.000001f) ||
            (displayInDouble > -9999999999999999.f && displayInDouble < -0.000001f) ) {
            
            displayString = [self.formatter.inDecimal stringFromNumber:displayNumber];
            
        } else {
            
            displayString = [self.formatter.inScientific stringFromNumber:displayNumber];
            
        }
        
    } else {
        
        // set an error string
        self.error = YES;
        displayString = result;
    }
    
    [self.disppp setString:displayString];
}

- (void) addDisplayNumber:(NSString *)number
{
    if ([self.disppp isEqualToString:@"0"]) {
        [self.disppp setString:number];
        [self.dispconv setString:number];
    } else if ([self.disppp isEqualToString:@"-0"]) {
        self.disppp = [NSMutableString stringWithFormat:@"-%@", number];
        self.dispconv = [NSMutableString stringWithFormat:@"-%@", number];
    } else {
        [self.disppp appendString:number];
        [self.dispconv appendString:number];
    }
    NSLog(@"add display number %@", number);
}

- (void)addDisplayPeriod
{
    if ([self.disppp rangeOfString:Period].location == NSNotFound) {
        [self.disppp appendString:Period];
        [self.dispconv appendString:Period];
    }
}

- (void)backspaceDisplay
{
    if ([self.disppp length] == 1) {
        [self clearDisplay];
    } else if ([self.disppp isEqualToString:@"0."]) {
        [self clearDisplay];
    } else if ([self.disppp length] == 2 && [[self.disppp substringWithRange:NSMakeRange(0, 1)] isEqualToString: @"-"]) {
        [self clearDisplay];
    } else if ([self.disppp isEqualToString:@"-0."]) {
        [self clearDisplay];
    } else {
        NSInteger index_of_char_to_remove = [self.disppp length] - 1;
        if (index_of_char_to_remove >= 0) {
            [self.disppp deleteCharactersInRange:NSMakeRange(index_of_char_to_remove, 1)];
            [self.dispconv deleteCharactersInRange:NSMakeRange(index_of_char_to_remove, 1)];
        }
    }
}

- (void)inverseSignDisplayOtherwiseInitWithNegativeZero:(BOOL)negativeZero
{
    if (negativeZero) {
        [self.disppp setString:@"-0"];
        [self.dispconv setString:@"-0"];
    } else {
        NSRange searchInfinity = [self.disppp rangeOfString:Minus];
        if (searchInfinity.location == NSNotFound) {
            // positive value
            // insert '-' into the head of the current display number
            self.disppp = [NSMutableString stringWithFormat:@"-%@", self.disppp];
            self.dispconv = [NSMutableString stringWithFormat:@"-%@", self.disppp];
        } else {
            // negative value
            // remove '-' from the current display number
            [self.disppp replaceOccurrencesOfString:(NSString *)Minus
                                          withString:@""
                                             options:0
                                               range:NSMakeRange(0, [self.disppp length])];
            [self.dispconv setString:self.disppp];
        }
    }
}

- (void)clearDisplay
{
    [self.disppp setString:@"0"];
    [self.dispconv setString:@"0"];
}

- (void)clearOperandA
{
    self.operandA = [NSDecimalNumber decimalNumberWithString:@"0"];
}

- (void)clearOperandB
{
    self.operandB = [NSDecimalNumber decimalNumberWithString:@"0"];
}

- (void)saveDisplayNumberToOperandA
{
    self.operandA = [NSDecimalNumber decimalNumberWithString:self.disppp];
}

- (void)saveDisplayNumberToOperandB
{
    self.operandB = [NSDecimalNumber decimalNumberWithString:self.disppp];
}

- (void)updateDisplayNumber
{
    NSLog(@"update1 %@", self.disppp);
}

- (void)updateDisplayNumberWithNumber:(NSDecimalNumber *)number
{
    [self.disppp setString: [number stringValue]];
    NSLog(@"update2 %@", self.disppp);
}

#pragma mark - property

@synthesize operandA = _operandA;

- (NSDecimalNumber *)operandA
{
    if (!_operandA) {
        _operandA = [NSDecimalNumber decimalNumberWithString:@"0"];
    }
    return _operandA;
}

- (NSDecimalNumber *)operandB
{
    if (!_operandB) {
        _operandB = [NSDecimalNumber decimalNumberWithString:@"0"];
    }
    return _operandB;
}

@synthesize state = _state;
- (State *)state
{
    if (!_state) {
        _state = [OperandAState sharedManager];
    }
    return _state;
}

- (NSMutableString *)disppp
{
    if (!_disppp) {
        _disppp = [[NSMutableString alloc] init];
        [_disppp appendString:@"0"];
    }
    return _disppp;
}

- (NSMutableString *)dispconv
{
    if (!_dispconv) {
        _dispconv = [[NSMutableString alloc] init];
        [_dispconv appendString:@"0"];
    }
    return _dispconv;
}

#pragma mark Lifecycle

// designated initializer
- (instancetype) init
{
    if ((self = [super init])) {
    }
    return self;
}


#pragma mark Display string generator


- (NSString *) newDisplayString
{
    return self.disppp;
}

- (NSString *) newConversionDisplayString
{
    return self.dispconv;
}

/*
 * The operatorValue method rerutns calculator's current operator.
 */
- (NSString *) operatorDisplayValue
{
    NSString *operatorDisplayValue;
    
    if ([self.operation isKindOfClass:[AddOperation class]]) {
        operatorDisplayValue = @"+";
    } else if ([self.operation isKindOfClass:[SubtractOperation class]]) {
        operatorDisplayValue = @"−";
    } else if ([self.operation isKindOfClass:[MultiplyOperation class]]) {
        operatorDisplayValue = @"×";
    } else if ([self.operation isKindOfClass:[DevideOperation class]]) {
        operatorDisplayValue = @"÷";
    } else {
        operatorDisplayValue = @"";
    }

    return operatorDisplayValue;
}

#pragma mark Formatter getter

- (DisplayFormatter *)formatter
{
    // lazy instantiation
    if (!_formatter) _formatter = [[DisplayFormatter alloc] init];
    return _formatter;
}

+ (NSArray *)operandOperatorStrings
{
    return @[@"C",@"🔙",@"+_−",@"÷",@"7",@"8",@"9",@"×",@"4",@"5",@"6",@"−",@"1",@"2",@"3",@"+",@"Tab",@"0",@".",@"="];
}



@end
