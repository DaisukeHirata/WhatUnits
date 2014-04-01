//
//  WhatUnitsAPI.h
//  Calculator3
//
//  Created by Daisuke Hirata on 2014/02/23.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ConversionUnit;

// key paths to photos or places at top-level of WhatUnits results
#define WHATUNITS_RESULTS_UNITS @"units.unit"
#define WHATUNITS_RESULTS_PLACES @"places.place"

// keys (paths) to values in a photo dictionary
#define WHATUNITS_UNIT_TITLE @"title"
#define WHATUNITS_UNIT_DESCRIPTION @"description"
#define WHATUNITS_UNIT_ID @"id"
#define WHATUNITS_UNIT_OWNER @"ownername"
#define WHATUNITS_UNIT_UPLOAD_DATE @"dateupload" // in seconds since 1970
#define WHATUNITS_UNIT_PLACE_ID @"place_id"
#define WHATUNITS_UNIT_CLASS @"class"
#define WHATUNITS_UNIT_MEASURE @"measure"
#define WHATUNITS_UNIT_MEASURE_RATIO @"measureratio"
#define WHATUNITS_UNIT_VALUE @"value"

// keys (paths) to values in a places dictionary (from TopPlaces)
#define WHATUNITS_PLACE_NAME @"_content"
#define WHATUNITS_PLACE_ID @"place_id"

// keys applicable to all types of WhatUnits dictionaries
#define WHATUNITS_LATITUDE @"latitude"
#define WHATUNITS_LONGITUDE @"longitude"
#define WHATUNITS_TAGS @"tags"

#define WHATUNITS_SHARING_THUMBNAIL_DATA @"thumbnail_data"
#define WHATUNITS_SHARING_THUMBNAIL_IMAGE @"thumbnail_image"
#define WHATUNITS_SHARING_PHOTO_ID @"photo_id"
#define WHATUNITS_SHARING_COMMENT_ID @"id"
#define WHATUNITS_SHARING_SOURCE_VALUE @"source_value"
#define WHATUNITS_SHARING_CONVERTED_VALUE @"converted_value"
#define WHATUNITS_SHARING_UNIT_TITLE @"unit_title"
#define WHATUNITS_SHARING_MEASURE_NAME @"measure"
#define WHATUNITS_SHARING_CLASS_NAME @"class"
#define WHATUNITS_SHARING_COMMENT @"comment"
#define WHATUNITS_SHARING_UPLOAD_DATE @"dateupload"
#define WHATUNITS_MIMETYPE @"image/jpeg"

typedef enum {
	WhatUnitsPhotoFormatSquare = 1,    // thumbnail
	WhatUnitsPhotoFormatLarge = 2,     // normal size
	WhatUnitsPhotoFormatOriginal = 64  // high resolution
} WhatUnitsPhotoFormat;


@interface WhatUnitsAPI : NSObject

+ (NSURL *)URLforUnitPhoto:(NSDictionary *)photo format:(WhatUnitsPhotoFormat)format;

+ (NSURL *)URLforAllConversionUnits;

+ (NSURL *)URLforCommentPhoto:(NSDictionary *)commentInfo;

+ (void)uploadConversionUnit:(ConversionUnit *)unit
                     success:(void (^)())success
                     failure:(void (^)())failure;

+ (void)uploadSharingComment:(NSDictionary *)sharingInfo
                     success:(void (^)())success
                     failure:(void (^)())failure;

+ (void)getSharingCommentsIntoManagedObjectContext:(NSManagedObjectContext *)context
                                           success:(void (^)())success
                                           failure:(void (^)())failure;

+ (void)getConversionUnitsIntoManagedObjectContext:(NSManagedObjectContext *)context
                                           success:(void (^)())success
                                           failure:(void (^)())failure;

@end
