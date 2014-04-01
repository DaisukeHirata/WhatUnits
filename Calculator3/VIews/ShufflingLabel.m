//
//  ShufflingLabel.m
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/02/20.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "ShufflingLabel.h"

@interface ShufflingLabel()
@property (nonatomic) long long from;   // now private only. it's better setting this property from outside.
@property (nonatomic) long long to;     // now private only. it's better setting this property from outside.
                                        // better to have animation duration also.
@end

@implementation ShufflingLabel

- (void)setTextWithShufflingAnimation:(NSString *)text
{
    // set timer which does shuffling animation and set text.
    [NSTimer scheduledTimerWithTimeInterval:0.01f
                                     target:self
                                   selector:@selector(updateLabelTextWithShufflingAnimation:)
                                   userInfo:@{@"text": text }
                                    repeats:YES];
}

- (void)updateLabelTextWithShufflingAnimation:(NSTimer*)timer
{
    static int conversionAnimationTimerCount = 0;
    
    if (conversionAnimationTimerCount < 40) {
        self.text = [[NSString alloc] initWithFormat:@"%lld", (arc4random() % (self.to - self.from)) + self.from];
    } else {
        // stop
        NSString *text = ((NSDictionary*)timer.userInfo)[@"text"];
        [timer invalidate];
        timer = nil;
        conversionAnimationTimerCount = 0;
        self.text = text;
    }
    
    conversionAnimationTimerCount++;
}

- (long long)from
{
    // value itself is not important. it's for a fun viewing.
    static long long from = 1000000000;
    return from;
}

- (long long)to
{
    // value itself is not important. it's for a fun viewing.
    static long long to = 9999999999;
    return to;
}

@end
