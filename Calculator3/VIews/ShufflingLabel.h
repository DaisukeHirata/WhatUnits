//
//  ShufflingLabel.h
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/02/20.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShufflingLabel : UILabel
// animate label text with random value for a while and set text
- (void)setTextWithShufflingAnimation:(NSString *)text;
@end
