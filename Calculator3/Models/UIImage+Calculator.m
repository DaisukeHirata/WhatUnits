//
//  UIImage+Calculator.m
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/02/23.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "UIImage+Calculator.h"

@implementation UIImage (Calculator)

- (UIImage *)imageByScallingToSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizedImage;
}

#define STANDARD_RECT_SIZE 60.0

+ (UIImage*) createPlaceHolderImageWithDiagonalText:(NSString*)text inRect:(CGRect) rect withColor:(UIColor *)color
{
    // Create Image Graphinc Context
    // rect size is twice as big as parameter size for nicer image quality.
    CGRect tmpRect = CGRectMake(0, 0, rect.size.width*2, rect.size.height*2);
    UIGraphicsBeginImageContext(tmpRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    CGRect stringRect = CGRectMake(0, image.size.height/2, image.size.width, image.size.height/2);
    
    CGContextSaveGState(context);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create the gradient
    CGColorRef startColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0].CGColor;
    CGColorRef endColor = color.CGColor;
    NSArray *colors = @[(__bridge id)startColor, (__bridge id)endColor];
    CGFloat locations[] = { 0.0, 1.0 };
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef) colors, locations);
    CGContextDrawLinearGradient(context, gradient, CGPointMake(stringRect.origin.x, stringRect.origin.y), CGPointMake(stringRect.origin.x + stringRect.size.width, stringRect.origin.y), 0);
    
    // Create text
    CGContextSetFillColorWithColor(context, [UIColor darkGrayColor].CGColor);
    NSString *string = text;
    int fontSize = [UIImage fontSizeByTextLength:text] * (rect.size.width / STANDARD_RECT_SIZE);
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:fontSize*2];
    
    // Rotate the context 45 degrees (convert to radians)
    CGAffineTransform transform1 = CGAffineTransformMakeRotation(-45.0 * M_PI/180.0);
    CGContextConcatCTM(context, transform1);
    
    // Move the context back into the view
    CGContextTranslateCTM(context, -stringRect.size.height, 0);
    
    /// Make a copy of the default paragraph style
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    /// Set line break mode
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    /// Set text alignment
    paragraphStyle.alignment = NSTextAlignmentCenter;
    // Draw the string
    [string drawInRect:stringRect
        withAttributes:@{ NSFontAttributeName:font,
                          NSParagraphStyleAttributeName:paragraphStyle }];
    
    // Clean up
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    
    CGContextRestoreGState(context);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // resize to specified rect size!!
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0.0);
    [newImage drawInRect:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

+ (unsigned int) fontSizeByTextLength:(NSString *)text
{
    int fontSize;
    
    NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:text];
    
    if (attrText.size.width < 30)       fontSize = 19;
    else if (attrText.size.width < 40)  fontSize = 18;
    else if (attrText.size.width < 60)  fontSize = 15;
    else if (attrText.size.width < 80)  fontSize = 13;
    else if (attrText.size.width < 110) fontSize = 10;
    else if (attrText.size.width < 195) fontSize = 8;
    else                                fontSize = 7;
    
    return fontSize;
}

- (UIImage *)imageByApplyingFilterName:(NSString *)filterName
{
    UIImage *filteredImage = self;
    
    // step1: create CIImage object
    CIImage *inputImage = [CIImage imageWithCGImage:[self CGImage]];
    if (inputImage) {
        // step2: get the filter
        CIFilter *filter = [CIFilter filterWithName:filterName];
        // step3: provide argument
        [filter setValue:inputImage forKey:kCIInputImageKey];
        // step4: get output image
        CIImage *outputImage = [filter outputImage];
        if (outputImage) {
            filteredImage = [UIImage imageWithCIImage:outputImage];
            if (filteredImage) {
                // step5: draw it into a new image
                UIGraphicsBeginImageContextWithOptions(self.size, YES, 0.0);
                [filteredImage drawAtPoint:CGPointZero];
                filteredImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
        }
    }

    return filteredImage;
}

@end
