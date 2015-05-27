//
//  DanMessagePopup.h
//  MemeCabin
//
//  Created by Himel on 11/18/14.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface DanMessagePopup : UIView
{
    UIView *holderView;
    //CGFloat padFactor;
}

//@property (nonatomic, assign) BOOL showTopBlackBar;

@property (nonatomic, assign) id delegate;
- (id)initWithDelegate:(id)AlertDelegate label1:(NSString *)label1 label2:(NSString *)label2 button1stTitle:(NSString *)button1stTitle button2ndTitle:(NSString *)button2ndTitle button3rdTitle:(NSString *)button3rdTitle button4thTitle:(NSString *)button4thTitle showTopBlackBar:(BOOL)showTopBlackBar;
- (void)show;

@end

@protocol DanMessagePopupDelegate
- (void) danMessagePopupView:(DanMessagePopup *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
@end
