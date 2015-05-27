//
//  GoogleAnalyticsCustom.m
//  MemeCabin
//
//  Created by Aapbd on 10/20/14.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import "GoogleAnalyticsCustom.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "AppDelegate.h"

@interface GoogleAnalyticsCustom ()

@end

@implementation GoogleAnalyticsCustom
@synthesize screenName;
static GoogleAnalyticsCustom *sharedInstance = nil;

+(GoogleAnalyticsCustom *)getSharedInstance
{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}

- (void)viewDidLoad
{
    if (self.screenName != nil)
    {
        [super viewDidLoad];
        id tracker = [[GAI sharedInstance] trackerWithTrackingId:TRACKING_ID];
        [tracker set:kGAIScreenName value:self.screenName];
        [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    }
}

-(void)setCurrentScreenName:(NSString *)screen
{
    self.screenName = screen;
    id tracker = [[GAI sharedInstance] trackerWithTrackingId:TRACKING_ID];
    [tracker set:kGAIScreenName value:self.screenName];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

-(void)setEmployeeTrackingId
{
    id tracker = [[GAI sharedInstance] trackerWithTrackingId:TRACKING_ID];
    [tracker set:[GAIFields customDimensionForIndex:1] value:@"ENCRYPTED_EMPLOYEE_ID_STRING"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Custom Events"
                                                         action:@"Authentication"
                                                          label:@""
                                                          value:nil] build]];
}

-(void)accessFile:(NSString *)action withName:(NSString *)name
{
    id tracker = [[GAI sharedInstance] trackerWithTrackingId:TRACKING_ID];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Content Access"
                                                         action:action
                                                          label:name
                                                          value:nil] build]];
}

-(void)videoProgressTracking:(int)percentage withVideoName:(NSString *)videoName
{
    id tracker = [[GAI sharedInstance] trackerWithTrackingId:TRACKING_ID];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Custom Events"
                                                          action:[NSString stringWithFormat:@"Video %d %%",percentage]
                                                           label:videoName
                                                           value:nil] build]];
}

-(void)appBackgroundTrackingTime:(int)sec
{
    id tracker = [[GAI sharedInstance] trackerWithTrackingId:TRACKING_ID];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Custom Events"
                                                          action:@"App Was In Background"
                                                           label:@"App Was In Background"
                                                           value:[NSNumber numberWithInt:sec]] build]];
}

-(void)clickEventViewController:(NSString *)action
{
    id tracker = [[GAI sharedInstance] trackerWithTrackingId:TRACKING_ID];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Custom Events"
                                                          action:[NSString stringWithFormat:@"Clicked - %@",action]
                                                           label:nil
                                                           value:nil] build]];
}

-(void)trackEventViewController:(NSString *)action
{
    id tracker = [[GAI sharedInstance] trackerWithTrackingId:TRACKING_ID];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Custom Events"
                                                          action:action
                                                           label:nil
                                                           value:nil] build]];
}

@end

















