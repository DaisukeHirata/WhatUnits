//
//  DisplayFormatter.h
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/02/22.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DisplayFormatter : NSObject
@property (nonatomic, readonly) NSNumberFormatter *inDecimal;
@property (nonatomic, readonly) NSNumberFormatter *inScientific;
@end
