//
//  UIImage+Calculator.h
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/02/23.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Calculator)
// makes a copy at a diffrent size
- (UIImage *)imageByScallingToSize:(CGSize)size;

// applies filter
- (UIImage *)imageByApplyingFilterName:(NSString *)filterName;

+ (UIImage*)createPlaceHolderImageWithDiagonalText:(NSString*)text inRect:(CGRect) rect withColor:(UIColor *)color;
@end
