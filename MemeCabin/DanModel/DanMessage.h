//
//  DanMessage.h
//  MemeCabin
//
//  Created by Aapbd on 11/6/14.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DanMessage : NSObject

@property (nonatomic, strong) NSString *dan_title;
@property (nonatomic, strong) NSString *dan_subtitle;
@property (nonatomic, strong) NSString *dan_url;
@property (nonatomic, strong) NSString *dan_id;
@property (nonatomic, strong) NSString *dan_isPublished;
@property (nonatomic, strong) NSString *dan_counter;

@end
