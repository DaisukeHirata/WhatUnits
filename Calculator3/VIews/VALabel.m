//
//  VALabel.m
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/02/24.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "VALabel.h"

@implementation VALabel


- (void) drawTextInRect:(CGRect)rect
{
    // draw border
    [[self layer] setBorderColor:[[UIColor darkGrayColor] CGColor]];
    [[self layer] setBorderWidth:0.5];
    
    // resize for 3.5 inch, this implementation depends on font size. it should be fixed.
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    if(screenSize.height != 568.0) {
        // 3.5inch
        CGSize sizeThatFits = [self sizeThatFits:rect.size];
        rect.size.height = MIN(rect.size.height*2.2, sizeThatFits.height*2.2);
    }
    [super drawTextInRect:rect];
}

@end
