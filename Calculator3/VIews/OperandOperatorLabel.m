//
//  VALabel.m
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/02/24.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "OperandOperatorLabel.h"

@implementation OperandOperatorLabel

#define RECT_HEIGHT_FOR_THREE_POINT_FIVE_INCH 60
#define RECT_HEIGHT_FOR_FOUR_INCH 80
#define RECT_BORDER_WIDTH 0.5
#define SCREEN_SIZE_FOUR_INCH 568.0
- (void) drawTextInRect:(CGRect)rect
{
    // draw border
    [[self layer] setBorderColor:[[UIColor darkGrayColor] CGColor]];
    [[self layer] setBorderWidth:RECT_BORDER_WIDTH];
    
    // resize label size
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    if(screenSize.height == SCREEN_SIZE_FOUR_INCH)  rect.size.height = RECT_HEIGHT_FOR_FOUR_INCH;               // 4inch
    else                                            rect.size.height = RECT_HEIGHT_FOR_THREE_POINT_FIVE_INCH;   // 3.5inch
    
    // dran text
    [self drawAttributedText:rect];
}


#define CORNER_OFFSET_WIDTH 7.0
#define CORNER_OFFSET_SCALE_FACTOR 0.04
- (void)drawAttributedText:(CGRect)rect {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentRight;

    //UIFont *cornerFont = [UIFont fontWithName:@"HelveticaNeue-ThinItalic"
    UIFont *cornerFont = [UIFont fontWithName:self.font.fontName
                                         size:self.font.pointSize];
    
    NSAttributedString *cornerText = [[NSAttributedString alloc] initWithString:self.text
                                                                     attributes:@{
                                                                        NSParagraphStyleAttributeName : paragraphStyle,
                                                                        NSFontAttributeName : cornerFont,
                                                                        NSForegroundColorAttributeName : self.textColor
                                                                     }];
    
    CGRect textBounds;
    //draw the attributes in the right bottom corner
    
    CGFloat rectWidth = rect.size.width;
    CGFloat rectHeight = rect.size.height;
    textBounds.origin = CGPointMake(rectWidth  - cornerText.size.width  - CORNER_OFFSET_WIDTH,
                                    rectHeight - cornerText.size.height - (CORNER_OFFSET_SCALE_FACTOR*rectHeight));
    
    textBounds.size = [cornerText size];
    [cornerText drawInRect:textBounds];
}

@end
