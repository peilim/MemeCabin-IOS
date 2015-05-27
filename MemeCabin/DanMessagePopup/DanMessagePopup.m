//
//  DanMessagePopup.m
//  MemeCabin
//
//  Created by Himel on 11/18/14.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import "DanMessagePopup.h"

@implementation DanMessagePopup

@synthesize delegate;

- (id)initWithDelegate:(id)AlertDelegate label1:(NSString *)label1 label2:(NSString *)label2 button1stTitle:(NSString *)button1stTitle button2ndTitle:(NSString *)button2ndTitle button3rdTitle:(NSString *)button3rdTitle button4thTitle:(NSString *)button4thTitle showTopBlackBar:(BOOL)showTopBlackBar
{
    CGRect frame;
    if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeLeft || [[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeRight)
        frame = CGRectMake(0.0, 0.0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);
    else
        frame = CGRectMake(0.0, 0.0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    
    self = [super initWithFrame:frame];
    if (self) {
        
        
        self.delegate = AlertDelegate;
        //self.alpha = 0.95;
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        
        CGFloat lbl1_h =  [self getSizeForText:label1 maxWidth:269 fontSize:17*padFactor].height;
        CGFloat lbl2_h = [self getSizeForText:label2 maxWidth:269 fontSize:13*padFactor].height;
        
        //Label 1
        UILabel *label_1 = [[UILabel alloc] initWithFrame:CGRectMake(3, 1, 269*padFactor, lbl1_h)];
        [label_1 setBackgroundColor:[UIColor clearColor]];
        label_1.text = label1;
        label_1.numberOfLines = 0;
        label_1.textAlignment = NSTextAlignmentCenter;
        label_1.font = [UIFont systemFontOfSize:17*padFactor];
        label_1.textColor = [UIColor colorWithRed:253 green:0 blue:76 alpha:1];
        
        //Label 2
        UILabel *label_2 = [[UILabel alloc] initWithFrame:CGRectMake(3, lbl1_h-(lbl1_h*0.01), 269*padFactor, lbl2_h)];
        [label_2 setBackgroundColor:[UIColor clearColor]];
        label_2.text =label2;
        label_2.numberOfLines = 0;
        label_2.textAlignment = NSTextAlignmentCenter;
        label_2.font = [UIFont systemFontOfSize:13*padFactor];
        
        UIView *topBlackView;
        CGFloat blackBarHeight = 0;
        if (showTopBlackBar)
        {
            blackBarHeight = 30*padFactor;
            
            UIView *topBlackViewBg = [[UIView alloc] initWithFrame:
                            CGRectMake(0, 0, 272*padFactor, blackBarHeight)];
            //[topBlackViewBg setBackgroundColor:[UIColor clearColor]];
            
            topBlackView = [[UIView alloc] initWithFrame:
                            CGRectMake(1, 1, 272*padFactor-2, blackBarHeight)];
            [topBlackView setBackgroundColor:[UIColor blackColor]];
            
            UILabel *lbl_quick_note = [[UILabel alloc] init];
            lbl_quick_note.frame = CGRectMake(3, 0, topBlackView.frame.size.width, topBlackView.frame.size.height);
            [lbl_quick_note setTextColor:[UIColor whiteColor]];
            [lbl_quick_note setTextAlignment:NSTextAlignmentCenter];
            [lbl_quick_note setText:@"QUICK NOTE FROM DAN:"];
            
            [topBlackView addSubview:lbl_quick_note];
            [topBlackViewBg addSubview:topBlackView];
        }
        
        
        //Label View
        UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, blackBarHeight, 272*padFactor, lbl1_h+lbl2_h+5)];
        topView.backgroundColor = [UIColor whiteColor];
        UIImageView *topViewBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popup_white_bar.png"]];
        topViewBg.frame = CGRectMake(0, 0, 272*padFactor, lbl1_h+lbl2_h+5);
        
        NSLog(@"topView H=%f",topView.frame.size.height);
        
        //Add Label to View
        [topView addSubview:topViewBg];
        [topView addSubview:label_1];
        [topView addSubview:label_2];
        
        
        //Button 1
        UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
        button1.frame = CGRectMake(0, 0, 272*padFactor, 50*padFactor);
        [button1 setBackgroundImage:[UIImage imageNamed:@"popup_btn.png"] forState:UIControlStateNormal];
        [button1 setTitle:button1stTitle forState:UIControlStateNormal];
        [button1 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        button1.titleLabel.font = [UIFont boldSystemFontOfSize:18*padFactor];
        button1.titleLabel.textAlignment = NSTextAlignmentCenter;
        button1.tag = 1000;
        [button1 addTarget:self action:@selector(onBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        //Button 2
        UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
        button2.frame = CGRectMake(0, button1.frame.origin.y+button1.frame.size.height, 272*padFactor, 50*padFactor);
        [button2 setBackgroundImage:[UIImage imageNamed:@"popup_btn.png"] forState:UIControlStateNormal];
        [button2 setTitle:button2ndTitle forState:UIControlStateNormal];
        [button2 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        button2.titleLabel.font = [UIFont boldSystemFontOfSize:18*padFactor];
        button2.titleLabel.textAlignment = NSTextAlignmentCenter;
        button2.tag = 1001;
        [button2 addTarget:self action:@selector(onBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        //Button 3
        UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
        button3.frame = CGRectMake(0, button2.frame.origin.y+button2.frame.size.height, 272*padFactor, 50*padFactor);
        [button3 setBackgroundImage:[UIImage imageNamed:@"popup_btn.png"] forState:UIControlStateNormal];
        [button3 setTitle:button3rdTitle forState:UIControlStateNormal];
        [button3 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        button3.titleLabel.font = [UIFont boldSystemFontOfSize:18*padFactor];
        button3.titleLabel.textAlignment = NSTextAlignmentCenter;
        button3.tag = 1002;
        [button3 addTarget:self action:@selector(onBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        //Button 4
        UIButton *button4 = [UIButton buttonWithType:UIButtonTypeCustom];
        button4.frame = CGRectMake(0, button3.frame.origin.y+button3.frame.size.height, 272*padFactor, 50*padFactor);
        [button4 setBackgroundImage:[UIImage imageNamed:@"popup_btn.png"] forState:UIControlStateNormal];
        [button4 setTitle:button4thTitle forState:UIControlStateNormal];
        [button4 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        button4.titleLabel.font = [UIFont boldSystemFontOfSize:18*padFactor];
        button4.titleLabel.textAlignment = NSTextAlignmentCenter;
        button4.tag = 1003;
        [button4 addTarget:self action:@selector(onBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        CGFloat ButtonView_H;
        if (button3rdTitle == nil && button4thTitle == nil)
        {
            ButtonView_H = button1.frame.size.height+
            button2.frame.size.height;
            button2.titleLabel.font = [UIFont boldSystemFontOfSize:15*padFactor];
        }
        else if (button4thTitle == nil)
        {
            ButtonView_H = button1.frame.size.height+
            button2.frame.size.height+
            button3.frame.size.height;
        }
        else
            ButtonView_H = button1.frame.size.height+
            button2.frame.size.height+
            button3.frame.size.height+
            button4.frame.size.height;
        
        //Button View
        UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, topView.frame.size.height+blackBarHeight, 272*padFactor, ButtonView_H)];
        
        if (button3rdTitle == nil && button4thTitle == nil)
        {
            [buttonView addSubview:button1];
            [buttonView addSubview:button2];
        }
        else if (button4thTitle == nil)
        {
            [buttonView addSubview:button1];
            [buttonView addSubview:button2];
            [buttonView addSubview:button3];
        }
        else
        {
            [buttonView addSubview:button1];
            [buttonView addSubview:button2];
            [buttonView addSubview:button3];
            [buttonView addSubview:button4];
        }
        
        
        CGRect holderFrame = CGRectMake(0, 0, 272*padFactor, topView.frame.size.height+buttonView.frame.size.height+blackBarHeight);
        holderView = [[UIView alloc] initWithFrame:CGRectMake((int)((self.frame.size.width-holderFrame.size.width)/2.0), ((self.frame.size.height-holderFrame.size.height)/2.0), 272*padFactor, topView.frame.size.height+buttonView.frame.size.height+blackBarHeight)];
        holderView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                                      UIViewAutoresizingFlexibleRightMargin |
                                      UIViewAutoresizingFlexibleTopMargin |
                                      UIViewAutoresizingFlexibleBottomMargin;
        
        
        if (showTopBlackBar)
        {
            [holderView addSubview:topBlackView];
            [holderView addSubview:topView];
            [holderView addSubview:buttonView];
            
        }
        else
        {
            [holderView addSubview:topView];
            [holderView addSubview:buttonView];
        }
        
        [self addSubview:holderView];
    }
    return self;
}

-(void)onBtnPressed:(id)sender
{
    UIButton *button = (UIButton *)sender;
    int button_index = button.tag-1000;
    
    if ([delegate respondsToSelector:@selector(danMessagePopupView:clickedButtonAtIndex:)]) {
        [delegate danMessagePopupView:self clickedButtonAtIndex:button_index];
    }
    
    [self animateHide];
}

-(void)show
{
    [[UIAppDelegate window] addSubview:self];
    [self animateShow];
}

- (void)animateHide
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation
                                      animationWithKeyPath:@"transform"];
    
    CATransform3D scale1 = CATransform3DMakeScale(1.0, 1.0, 1);
    CATransform3D scale2 = CATransform3DMakeScale(0.5, 0.5, 1);
    CATransform3D scale3 = CATransform3DMakeScale(0.0, 0.0, 1);
    
    NSArray *frameValues = [NSArray arrayWithObjects:
                            [NSValue valueWithCATransform3D:scale1],
                            [NSValue valueWithCATransform3D:scale2],
                            [NSValue valueWithCATransform3D:scale3],
                            nil];
    [animation setValues:frameValues];
    
    NSArray *frameTimes = [NSArray arrayWithObjects:
                           [NSNumber numberWithFloat:0.0],
                           [NSNumber numberWithFloat:0.5],
                           [NSNumber numberWithFloat:0.9],
                           nil];
    [animation setKeyTimes:frameTimes];
    
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.duration = 0.1;
    
    [holderView.layer addAnimation:animation forKey:@"hide"];
    [self performSelector:@selector(removeFromSuperview) withObject:self afterDelay:0.105];
    
}

- (void)animateShow
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation
                                      animationWithKeyPath:@"transform"];
    
    CATransform3D scale1 = CATransform3DMakeScale(0.5, 0.5, 1);
    CATransform3D scale2 = CATransform3DMakeScale(1.2, 1.2, 1);
    CATransform3D scale3 = CATransform3DMakeScale(0.9, 0.9, 1);
    CATransform3D scale4 = CATransform3DMakeScale(1.0, 1.0, 1);
    
    NSArray *frameValues = [NSArray arrayWithObjects:
                            [NSValue valueWithCATransform3D:scale1],
                            [NSValue valueWithCATransform3D:scale2],
                            [NSValue valueWithCATransform3D:scale3],
                            [NSValue valueWithCATransform3D:scale4],
                            nil];
    [animation setValues:frameValues];
    
    NSArray *frameTimes = [NSArray arrayWithObjects:
                           [NSNumber numberWithFloat:0.0],
                           [NSNumber numberWithFloat:0.5],
                           [NSNumber numberWithFloat:0.9],
                           [NSNumber numberWithFloat:1.0],
                           nil];
    [animation setKeyTimes:frameTimes];
    
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.duration = 0.2;
    
    [holderView.layer addAnimation:animation forKey:@"show"];
}

- (CGSize)getSizeForText:(NSString *)text maxWidth:(CGFloat)width fontSize:(float)fontSize {
    CGSize constraintSize;
    constraintSize.height = MAXFLOAT;
    constraintSize.width = width;
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont systemFontOfSize:fontSize], NSFontAttributeName,
                                          nil];
    CGRect frame = CGRectZero;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        frame = [text boundingRectWithSize:constraintSize
                                   options:NSStringDrawingUsesLineFragmentOrigin
                                attributes:attributesDictionary
                                   context:nil];
    }
    /*
    CGRect frame = [text boundingRectWithSize:constraintSize
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:attributesDictionary
                                      context:nil];*/
    
    CGSize stringSize = frame.size;
    return stringSize;
}

@end
