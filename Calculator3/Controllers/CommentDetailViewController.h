//
//  CommentDetailViewController.h
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/03/01.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseShareCommentViewController.h"

@class SharingComment;

// inherits from BaseShareCommentViewController
// A purpose of this view controller is see the sharing comment detail only.
// The difference is public interface for passing data.
@interface CommentDetailViewController : BaseShareCommentViewController

// in
@property (nonatomic, strong) SharingComment *comment;

@end
