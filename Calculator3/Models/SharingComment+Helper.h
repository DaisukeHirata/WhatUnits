//
//  SharingComment+Helper.h
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/02/28.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "SharingComment.h"

@interface SharingComment (Helper)

+ (void)loadUnitsFromCommentsArray:(NSArray *)comments                  // of Comments NSDictionary
          intoManagedObjectContext:(NSManagedObjectContext *)context;

@end
