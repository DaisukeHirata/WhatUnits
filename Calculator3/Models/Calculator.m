#import "Calculator.h"
#import "DisplayFormatter.h"

// These string constants contain the characters that the input: method accepts.
NSString *Operators = @"+−×÷";
NSString *Equals    = @"=";
NSString *Digits    = @"0123456789.";
NSString *Period    = @".";
NSString *Delete    = @"🔙";
NSString *Clear     = @"C";
NSString *Sign      = @"+_−";
NSString *Zero      = @"0";
NSString *Minus     = @"−";


@interface Calculator()
@property (nonatomic, strong) NSMutableString *display;     // The calculator display (the value a harwdare-based calculator
                                                            // shows on its LCD screen).
@property (nonatomic, strong) NSDecimalNumber *operand;     // An instance can represent any number that can be expressed as
                                                            // mantissa x 10^exponent where mantissa is a decimal integer up to
                                                            // 38 digits long, and exponent is an integer from –128 through 127.
@property (nonatomic, strong) NSString *operator;
@property (nonatomic, strong) NSDecimalNumber *lastOperandForChaining;
@property (nonatomic, strong) DisplayFormatter *formatter;
@property (nonatomic, copy) NSString *lastDisplay;
@property (nonatomic, copy) NSString *lastOperatorDisplay;
@end


@implementation Calculator

#pragma mark Lifecycle

// designated initializer
- (instancetype) init
{
   if ((self = [super init])) {
      self.display = [NSMutableString stringWithFormat:@"0"];;
      self.operator = nil;
   }
   return self;
}


#pragma mark Calculator Operation

/*
 * The input: method accepts the characters in the string constants
 * Operators, Equals, Digits, Period Delete, and Clear.
 *
 * The results of this method's computations are stored in display.
 * This method uses operand, and operator in its calculations.
 */
- (void) input:(NSString *) input_character
{
    static BOOL isLastCharacterOperator = NO;
    BOOL bad_character = NO;
    self.calculationDone = NO;
    
    NSLog(@"%@", self.lastInputCharacter);
   
    // Is input_character in Digits?
    if ([Digits rangeOfString: input_character].length) {
        if (isLastCharacterOperator) {
            // Set the display to input_character.
            [self.display setString: input_character];
            isLastCharacterOperator = NO;
        }
        // Is input_character a digit, or is a period while a period has not been added to display?
        else if (![input_character isEqualToString: (NSString *)Period] ||
                 [self.display rangeOfString: (NSString *)Period].location == NSNotFound) {
            // Add input_character to display.
            [self.display appendString:input_character];
        }
    }
    // Is input character SignOperator ?
    else if ([input_character isEqualToString:(NSString *)Sign]) {
        // A lot of calculators provide a way of inputting negative value as pressing 'digit' then '+/-'.
        // However pressing '+/-' then 'digit' is better operation I thought.
        // Apple's iOS 7 calc does, but it has some bugs. so I try this up right.
        
        if (isLastCharacterOperator && ![self.lastInputCharacter isEqualToString:Equals]) {
            self.display = [NSMutableString stringWithFormat:@"-0"];
        } else {
            NSRange searchInfinity = [self.display rangeOfString:Minus];
            if (searchInfinity.location == NSNotFound) {
                // positive value
                // insert '-' into the head of the current display number
                self.display = [NSMutableString stringWithFormat:@"-%@", self.display];
            } else {
                // negative value
                // remove '-' from the current display number
                [self.display replaceOccurrencesOfString:(NSString *)Minus
                                              withString:@""
                                                 options:0
                                                   range:NSMakeRange(0, [self.display length])];
            }
        }
        isLastCharacterOperator = NO;
        self.lastOperatorDisplay = @"";
        self.operator = nil;
    }
    // Is input_character in Operators or is it Equals?
    else if ([Operators rangeOfString:input_character].length || [input_character isEqualToString:Equals]) {
      
        if (!self.operator && ![input_character isEqualToString:(NSString *)Equals]) {
            // input_character is this calculation's operator.
            //
            // Save the operand and the operator.
            self.operand  = [NSDecimalNumber decimalNumberWithString:self.displayString];
            self.operator = input_character;
        }
        else if ([Operators rangeOfString:self.lastInputCharacter].length ||
                 ([self.lastInputCharacter isEqualToString:Equals] && [Operators rangeOfString:input_character].length)) {
            // just change operator
            self.operator = input_character;
        }
        else {
            // input_character is in Operators or Equals.
            //
            // Perform the computation indicated by the saved operator between the saved operand and display.
            // Place the result in display.
            if (self.operator) {
                NSDecimalNumber *operand2;
                if ([self.lastInputCharacter isEqualToString:Equals] &&
                    [input_character isEqualToString:Equals]) {
                    operand2 = self.lastOperandForChaining;
                } else {
                    operand2 = [NSDecimalNumber decimalNumberWithString:self.displayString];
                    //self.operator = input_character;
                }
                @try {
                    switch ([Operators rangeOfString: self.operator].location) {
                        case 0:
                            self.operand = [self.operand decimalNumberByAdding:operand2];
                            break;
                        case 1:
                            self.operand = [self.operand decimalNumberBySubtracting:operand2];
                            break;
                        case 2:
                            self.operand = [self.operand decimalNumberByMultiplyingBy:operand2];
                            break;
                        case 3:
                            self.operand = [self.operand decimalNumberByDividingBy:operand2];
                            break;
                    }
                    [self.display setString: [self.operand stringValue]];
                    // Save the operation (if this is a chained computation).
                    self.lastOperandForChaining = operand2;
                }
                @catch (NSException* ex) {
                    if ([ex.name isEqualToString:NSDecimalNumberDivideByZeroException]) {
                        [self.display setString: @"Error Divide by Zero"];
                    } else if ([ex.name isEqualToString:NSDecimalNumberOverflowException]) {
                        [self.display setString: @"Error Overflow"];
                    } else if ([ex.name isEqualToString:NSDecimalNumberUnderflowException]) {
                        [self.display setString: @"Error Underflow"];
                    } else if ([ex.name isEqualToString:NSDecimalNumberExactnessException]) {
                        [self.display setString: @"Error Exactness"];
                    } else {
                        [self.display setString: @"Error Unknown"];
                    }
                }
                self.calculationDone = YES;
            }
        }
        isLastCharacterOperator = YES;
    }
    // Is input_character Delete?
    else if ([input_character isEqualToString:Delete]) {
        // Remove the rightmost character from display.
        NSInteger index_of_char_to_remove = [self.display length] - 1;
        if (index_of_char_to_remove >= 0) {
            [self.display deleteCharactersInRange:NSMakeRange(index_of_char_to_remove, 1)];
            isLastCharacterOperator = NO;
        }
    }
    // Is input_character Clear?
    else if ([input_character isEqualToString:Clear]) {
        // If there's something in self.display, clear it.
        if ([self.display length]) {
            [self.display setString:[NSString string]];
        }
        self.operator = nil;
        self.operand = nil;
        self.calculationDone = YES;
        self.lastOperatorDisplay = @"";
    }
    else {
        // input_character is an unexpected (invalid) character.
        bad_character = TRUE;
        self.calculationDone = YES;
    }
    
    if (bad_character) {
        // Raise exception for unexpected character.
        NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException
                                                         reason:@"The input_character parameter contains an unexpected value."
                                                       userInfo:@{@"arg0": input_character}];
        [exception raise];
    }
    
    self.lastInputCharacter = input_character;
}


#pragma mark Display string generator

/*
 * The displayString method rerutns a copy of display.
 */
- (NSString *) displayString
{
   if ([self.display length]) {
      return [self.display copy];
   }
   return Zero;
}

/*
 * The displayValue method rerutns a copy of display.
 */
- (NSString *) displayValue
{
    
    NSString* displayValue;
    
    NSString *displayStr = [self displayString];
    
    // This display string includes 'Error' when exception occured
    NSRange searchInfinity = [displayStr rangeOfString:@"Error"];
    if (searchInfinity.location == NSNotFound) {
        if (self.calculationDone || [self.lastInputCharacter isEqualToString:Equals]) {
            double displayInDouble = [displayStr doubleValue];
            NSNumber *displayNumber = @(displayInDouble);
            if ([displayStr isEqualToString:Zero] ||
                (displayInDouble < 9999999999999999.f && displayInDouble > 0.000001f) ||
                (displayInDouble > -9999999999999999.f && displayInDouble < -0.000001f) ) {
                displayValue = [self.formatter.inDecimal stringFromNumber:displayNumber];
            } else {
                displayValue = [self.formatter.inScientific stringFromNumber:displayNumber];
            }
        } else if (![Operators rangeOfString:self.lastInputCharacter].length){
            displayValue = [self.formatter.inDecimal stringFromNumber:@([displayStr doubleValue])];
        } else {
            // +-*/
            displayValue = self.lastDisplay;
        }
        self.error = NO;
    } else {
        // set an error string
        displayValue = displayStr;
        self.error = YES;
    }
    
    self.lastDisplay = displayValue;
    
    return displayValue;
}

/*
 * The operatorValue method rerutns calculator's current operator.
 */
- (NSString *) operatorDisplayValue
{
    NSString *operatorDisplayValue;
    
    if ([Operators rangeOfString:self.lastInputCharacter].length) {
        operatorDisplayValue = self.lastInputCharacter;
    } else {
        operatorDisplayValue = self.lastOperatorDisplay;
    }
    self.lastOperatorDisplay = operatorDisplayValue;
    
    return operatorDisplayValue;
}

#pragma mark Formatter getter

- (DisplayFormatter *)formatter
{
    // lazy instantiation
    if (!_formatter) _formatter = [[DisplayFormatter alloc] init];
    return _formatter;
}

- (NSString *)lastInputCharacter
{
    // lazy instantiation
    if (!_lastInputCharacter) _lastInputCharacter = [NSString stringWithFormat:@"%@", @"0" ];
    return _lastInputCharacter;
}

+ (NSArray *)operandOperatorStrings
{
    return @[@"C",@"🔙",@"+_−",@"÷",@"7",@"8",@"9",@"×",@"4",@"5",@"6",@"−",@"1",@"2",@"3",@"+",@"Tab",@"0",@".",@"="];
}



@end
