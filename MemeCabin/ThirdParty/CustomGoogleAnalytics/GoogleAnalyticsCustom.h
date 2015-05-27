//
//  GoogleAnalyticsCustom.h
//  MemeCabin
//
//  Created by Aapbd on 10/20/14.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GoogleAnalyticsCustom : UIViewController

@property (nonatomic, retain) NSString *screenName;
+(GoogleAnalyticsCustom *) getSharedInstance;
-(void) setCurrentScreenName:(NSString *)screen;
-(void) setEmployeeTrackingId;
-(void) accessFile:(NSString *)action withName:(NSString *)name;
-(void) appBackgroundTrackingTime:(int)sec;
-(void) clickEventViewController:(NSString *)action;
-(void) trackEventViewController:(NSString *)action;
-(void) videoProgressTracking:(int)percentage withVideoName:(NSString *)videoName;

@end









