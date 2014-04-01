//
//  SharingComment.h
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/03/08.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SharingComment : NSManagedObject

@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSString * conversionClass;
@property (nonatomic, retain) NSString * convertedValue;
@property (nonatomic, retain) NSString * measureName;
@property (nonatomic, retain) NSString * sourceValue;
@property (nonatomic, retain) NSString * thumbnailURL;
@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) NSString * unitTitle;
@property (nonatomic, retain) NSDate * uploadDate;
@property (nonatomic, retain) NSString * uploadDay;
@property (nonatomic, retain) NSString * photoId;

@end
