//
//  RecentCommentsTableViewController.h
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/02/28.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface RecentCommentsTableViewController : CoreDataTableViewController

// in
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
