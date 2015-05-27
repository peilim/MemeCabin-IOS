//
//  Photo.h
//  MemeCabin
//
//  Created by AAPBD Mac mini on 11/09/2014.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MemePhoto : NSObject

@property (strong, nonatomic) NSString *photoID;
@property (strong, nonatomic) NSString *photoTitle;
@property (strong, nonatomic) NSString *photoCategory;
@property (strong, nonatomic) NSString *photoLike;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *photoMyFavorite;
@property (strong, nonatomic) NSString *photoMyLike;

@property (strong, nonatomic) NSString *photoUploadby;
@property (strong, nonatomic) NSString *photoUploaddate;
@property (strong, nonatomic) NSString *photoViewCount;
@property (strong, nonatomic) NSString *baseURL;

@property (strong, nonatomic) NSString *thumb100BaseURL;
@property (strong, nonatomic) NSString *thumb250BaseURL;
@property (nonatomic) int totalMeme;

@property (strong, nonatomic) NSString *photoStatus;

@property (strong, nonatomic) NSString *photoURL;

@property (strong, nonatomic) NSString *thumb100URL;
@property (strong, nonatomic) NSString *thumb250URL;

//Trending
@property (strong, nonatomic) NSString *allLike;
@property (strong, nonatomic) NSString *daytotalLike;
@property (strong, nonatomic) NSString *daySeventotalLike;
@property (strong, nonatomic) NSString *dayThirtytotalLike;
@property (strong, nonatomic) NSString *dayNinetytotalLike;

//Local database
@property (strong, nonatomic) NSString *isLiked;
@property (strong, nonatomic) NSString *isViewed;
@property (strong, nonatomic) NSString *isFavourite;
@property (strong, nonatomic) NSString *syncStatus;

+(NSMutableArray *)loadImagesWithURL:(NSString *)url;

@end
