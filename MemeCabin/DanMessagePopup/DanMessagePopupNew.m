//
//  DanMessagePopupNew.m
//  MemeCabin
//
//  Created by Hemal on 3/5/15.
//  Copyright (c) 2015 appbd. All rights reserved.
//

#import "DanMessagePopupNew.h"

@implementation DanMessagePopupNew

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */


- (instancetype)initWithFrame:(CGRect)frame title:(DanMessageNew*)danMessageNew{
    self = [super initWithFrame:frame];
    if (self) {
        self.danMsgNew=danMessageNew;
        self.titleText=self.danMsgNew.dan_title;
        self.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f];
        //if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone)[self setupViewforiPhone];
        //else [self setupViewforiPad];
        [self setupView];
    }
    return self;
}
-(void)setupViewforiPad
{
    int popupHeight=284;
    int popupWidth=350;
    self.containerView=[[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width-popupWidth)/2, (self.frame.size.height-popupHeight)/2,popupWidth,popupHeight)];
    self.containerView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:1.0f];
    [self addSubview:self.containerView];
    
    self.backgroundImageView=[[UIImageView alloc] initWithFrame:self.containerView.bounds];
    self.backgroundImageView.backgroundColor=[UIColor whiteColor];
    self.backgroundImageView.image=[UIImage imageNamed:@"popup.png"];
    [self.containerView addSubview:self.backgroundImageView];
    
    self.titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, 14, self.containerView.frame.size.width-40, 80)];
    self.titleLabel.text=self.titleText;
    self.titleLabel.textColor=[UIColor darkGrayColor];
    self.titleLabel.textAlignment=NSTextAlignmentCenter;
    self.titleLabel.numberOfLines=0;
    
    self.titleLabel.font=[UIFont systemFontOfSize:22];
    [self.containerView addSubview:self.titleLabel];
    
    //
    //    self.deviderImageview1=[[UIImageView alloc] initWithFrame:CGRectMake(2, 100, self.containerView.frame.size.width-4, 3)];
    //    self.deviderImageview1.backgroundColor=[UIColor clearColor];
    //    self.deviderImageview1.image=[UIImage imageNamed:@"popupdarkline.png"];
    //    [self.containerView addSubview:self.deviderImageview1];
    
    //    self.yesButton=[[UIButton alloc] initWithFrame:CGRectMake(2, 103, self.containerView.frame.size.width-4, 57)];
    //    [self.yesButton setBackgroundImage:[UIImage imageNamed:@"popupitembg.png"] forState:UIControlStateNormal];
    //    [self.yesButton setTitle:@"Move Bookmark Here" forState:UIControlStateNormal];
    //    [self.yesButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    //    [self.yesButton addTarget:self action:@selector(yesButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    //    [self.yesButton.titleLabel setFont:[UIFont boldSystemFontOfSize:22]];
    //    [self.containerView addSubview:self.yesButton];
    
    //    self.deviderImageview2=[[UIImageView alloc] initWithFrame:CGRectMake(2, 160, self.containerView.frame.size.width-4, 3)];
    //    self.deviderImageview2.backgroundColor=[UIColor clearColor];
    //    self.deviderImageview2.image=[UIImage imageNamed:@"popupdarkline.png"];
    //    [self.containerView addSubview:self.deviderImageview2];
    
    //    self.donotshowButton=[[UIButton alloc] initWithFrame:CGRectMake(2, 163, self.containerView.frame.size.width-4, 57)];
    //    [self.donotshowButton setTitle:@"Go to Bookmark" forState:UIControlStateNormal];
    //    [self.donotshowButton setBackgroundImage:[UIImage imageNamed:@"popupitembg.png"] forState:UIControlStateNormal];
    //    [self.donotshowButton.titleLabel setFont:[UIFont boldSystemFontOfSize:22]];
    //    [self.donotshowButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    //    [self.donotshowButton addTarget:self action:@selector(donotshowButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    //    [self.containerView addSubview:self.donotshowButton];
    
    //    self.deviderImageview3=[[UIImageView alloc] initWithFrame:CGRectMake(2, 220, self.containerView.frame.size.width-4, 3)];
    //    self.deviderImageview3.backgroundColor=[UIColor clearColor];
    //    self.deviderImageview3.image=[UIImage imageNamed:@"popupdarkline.png"];
    //    [self.containerView addSubview:self.deviderImageview3];
    
    //    self.cancelButton=[[UIButton alloc] initWithFrame:CGRectMake(2, 223, self.containerView.frame.size.width-4, 57)];
    //    [self.cancelButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    //    [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    //    [self.cancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:22]];
    //    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"popupitembg.png"] forState:UIControlStateNormal];
    //    [self.cancelButton addTarget:self action:@selector(cancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    //    [self.containerView addSubview:self.cancelButton];
    
    //    self.deviderImageview4=[[UIImageView alloc] initWithFrame:CGRectMake(2, 280, self.containerView.frame.size.width-4, 3)];
    //    self.deviderImageview4.backgroundColor=[UIColor clearColor];
    //    self.deviderImageview4.image=[UIImage imageNamed:@"popupdarkline.png"];
    //    [self.containerView addSubview:self.deviderImageview4];
}

-(void)setupView
{
    int headerTitleHight = 0;
    int titleHight;
    int subtitleHeight;
    int popupHeight;
    int popupWidth;
    
    int deviderHeight;
    int buttonHeight;
    //int deviderMargin=2;
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        headerTitleHight=[self getSizeForText:self.danMsgNew.dan_title maxWidth:self.frame.size.width-55 fontSize:14].height + 10;
        subtitleHeight=[self getSizeForText:self.danMsgNew.dan_subtitle maxWidth:self.frame.size.width-55 fontSize:12].height+10;
        
        if(self.danMsgNew.dan_url.length > 1)
        {
            if(([self.danMsgNew.dan_url rangeOfString:@"http"].location != NSNotFound) || ([self.danMsgNew.dan_url rangeOfString:@"https"].location != NSNotFound) || ([self.danMsgNew.dan_url rangeOfString:@"www"].location != NSNotFound))
            {
                popupHeight=144+headerTitleHight+subtitleHeight;
            }
            else
                popupHeight=104+headerTitleHight+subtitleHeight;
            
        }
        else
        {
            popupHeight=104+headerTitleHight+subtitleHeight;
        }
        
        popupWidth=285;
        deviderHeight=2;
        buttonHeight=40;
    }
    else
    {
        headerTitleHight=[self getSizeForText:self.danMsgNew.dan_title maxWidth:self.frame.size.width-55 fontSize:17].height+30;
        subtitleHeight=[self getSizeForText:self.danMsgNew.dan_subtitle maxWidth:self.frame.size.width-400 fontSize:15].height+50;
        
        if(self.danMsgNew.dan_url.length > 1)
        {
            if(([self.danMsgNew.dan_url rangeOfString:@"http"].location != NSNotFound) || ([self.danMsgNew.dan_url rangeOfString:@"https"].location != NSNotFound) || ([self.danMsgNew.dan_url rangeOfString:@"www"].location != NSNotFound))
            {
                popupHeight=196+headerTitleHight+subtitleHeight;
            }
            else
                popupHeight=140+headerTitleHight+subtitleHeight;
            
        }
        else
        {
            popupHeight=140+headerTitleHight+subtitleHeight;
        }
        
        
        
        popupWidth=350;
        deviderHeight=3;
        buttonHeight=57;
        
    }
    
    self.containerView=[[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width-popupWidth)/2, (self.frame.size.height-popupHeight)/2,popupWidth,popupHeight)];
    self.containerView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:1.0f];
    
    [self addSubview:self.containerView];
    
    self.backgroundImageView=[[UIImageView alloc] initWithFrame:self.containerView.bounds];
    self.backgroundImageView.backgroundColor=[UIColor whiteColor];
    self.backgroundImageView.image=[UIImage imageNamed:@"popupnewbg.png"];
    [self.containerView addSubview:self.backgroundImageView];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        self.headerLabel=[[UILabel alloc]initWithFrame:CGRectMake(1, 2, self.containerView.frame.size.width-2, headerTitleHight)];
        self.headerLabel.font=[UIFont boldSystemFontOfSize:14];
        self.headerLabelView = [[UIImageView alloc] initWithFrame:self.headerLabel.frame];
        self.headerLabelView.frame = self.headerLabel.frame;
        
    }
    
    else
    {
        self.headerLabel=[[UILabel alloc]initWithFrame:CGRectMake(2, 2, self.containerView.frame.size.width-4, headerTitleHight)];
        self.headerLabel.font=[UIFont boldSystemFontOfSize:17];
        self.headerLabelView = [[UIImageView alloc] initWithFrame:self.headerLabel.frame];
        self.headerLabelView.frame = self.headerLabel.frame;
    }
    
    self.headerLabel.numberOfLines = 0;
    self.headerLabel.backgroundColor=[UIColor clearColor];//[UIColor colorWithRed:0 green:0 blue:0 alpha:0.9f];
    self.headerLabel.text=self.danMsgNew.dan_title.length >=64 ? [self.danMsgNew.dan_title substringToIndex:64] : self.danMsgNew.dan_title;//@"QUICK NOTE FROM DAN: THIS IS BANGLAESH HELLO GUYS";
    
    self.headerLabel.textColor=[UIColor colorWithRed:127.0f/255.0f green:39.0f/255.0f blue:166.0f/255.0f alpha:1.0f];
    self.headerLabel.textAlignment=NSTextAlignmentCenter;
    self.headerLabelView.image = [UIImage imageNamed:@"popup_titlebg.png"];
    [self.containerView addSubview:self.headerLabelView];
    [self.containerView addSubview:self.headerLabel];
    
    //    self.deviderImageview5=[[UIImageView alloc] initWithFrame:CGRectMake(deviderMargin,self.headerLabel.frame.origin.y+self.headerLabel.frame.size.height, self.containerView.frame.size.width-(deviderMargin*2), deviderHeight)];
    //
    //    self.deviderImageview5.backgroundColor=[UIColor clearColor];
    //    self.deviderImageview5.image=[UIImage imageNamed:@"popupdarkline.png"];
    //    [self.containerView addSubview:self.deviderImageview5];
    
    
    /*
     if ([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
     {
     //self.titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, self.deviderImageview5.frame.origin.y+self.deviderImageview5.frame.size.height, self.containerView.frame.size.width-20, titleHight)];
     self.titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 100, self.containerView.frame.size.width-20, titleHight)];
     self.titleLabel.font=[UIFont boldSystemFontOfSize:16];
     }
     
     else
     {
     //self.titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, self.deviderImageview5.frame.origin.y+self.deviderImageview5.frame.size.height, self.containerView.frame.size.width-40, titleHight)];
     self.titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, 100, self.containerView.frame.size.width-40, titleHight)];
     self.titleLabel.font=[UIFont boldSystemFontOfSize:22];
     }
     
     
     self.titleLabel.textColor = [UIColor colorWithRed:253 green:0 blue:76 alpha:1];
     self.titleLabel.text=self.danMsgNew.dan_title;
     
     self.titleLabel.textAlignment=NSTextAlignmentCenter;
     self.titleLabel.numberOfLines=0;
     [self.containerView addSubview:self.titleLabel];*/
    
    
    if ([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        self.subTitleLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, self.headerLabel.frame.origin.y+self.headerLabel.frame.size.height+10, self.containerView.frame.size.width-20,subtitleHeight)];
        self.subTitleLabel.font=[UIFont systemFontOfSize:12];
    }
    
    else
    {
        self.subTitleLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, self.headerLabel.frame.origin.y+self.headerLabel.frame.size.height+10, self.containerView.frame.size.width-40,subtitleHeight)];
        self.subTitleLabel.font=[UIFont systemFontOfSize:15];
    }
    
    
    self.subTitleLabel.text=self.danMsgNew.dan_subtitle;
    self.subTitleLabel.textColor=[UIColor blackColor];//[UIColor colorWithRed:137.0/255.0 green:137.0/255.0 blue:137.0/255.0 alpha:1.0f];
    self.subTitleLabel.backgroundColor = [UIColor clearColor];
    self.subTitleLabel.textAlignment=NSTextAlignmentLeft;
    self.subTitleLabel.numberOfLines=0;
    
    [self.containerView addSubview:self.subTitleLabel];
    
    
    //    self.deviderImageview1=[[UIImageView alloc] initWithFrame:CGRectMake(deviderMargin, self.subTitleLabel.frame.origin.y+self.subTitleLabel.frame.size.height, self.containerView.frame.size.width-(deviderMargin*2), deviderHeight)];
    //    self.deviderImageview1.backgroundColor=[UIColor clearColor];
    //    self.deviderImageview1.image=[UIImage imageNamed:@"popupdarkline.png"];
    //    [self.containerView addSubview:self.deviderImageview1];
    
    //self.topButton=[[UIButton alloc] initWithFrame:CGRectMake(2, self.deviderImageview1.frame.origin.y+self.deviderImageview1.frame.size.height, self.containerView.frame.size.width-4, buttonHeight)];
    self.topButton=[[UIButton alloc] initWithFrame:CGRectMake(2, self.subTitleLabel.frame.origin.y+self.subTitleLabel.frame.size.height+10, self.containerView.frame.size.width-4, buttonHeight)];
    
    [self.topButton setBackgroundImage:[UIImage imageNamed:@"popup_topbottom.png"] forState:UIControlStateNormal];
    
    [self.topButton setTitle:self.danMsgNew.dan_topBtnTxt forState:UIControlStateNormal];
    [self.topButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.topButton addTarget:self action:@selector(yesButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.topButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    //[self.containerView addSubview:self.topButton];
    
    if(self.danMsgNew.dan_url.length>1 || self.danMsgNew.dan_url.length == 0)
    {
        if((([self.danMsgNew.dan_url rangeOfString:@"http"].location == NSNotFound) && ([self.danMsgNew.dan_url rangeOfString:@"https"].location == NSNotFound) && ([self.danMsgNew.dan_url rangeOfString:@"www"].location == NSNotFound)))
        {
            self.topButton.frame = CGRectMake(self.topButton.frame.origin.x, self.topButton.frame.origin.y, self.topButton.frame.size.width, 0);
        }
        else
        {
            [self.containerView addSubview:self.topButton];
        }
        
    }
    
    //    self.deviderImageview2=[[UIImageView alloc] initWithFrame:CGRectMake(deviderMargin, self.yesButton.frame.origin.y+self.yesButton.frame.size.height, self.containerView.frame.size.width-(deviderMargin*2), deviderHeight)];
    //    self.deviderImageview2.backgroundColor=[UIColor clearColor];
    //    self.deviderImageview2.image=[UIImage imageNamed:@"popupdarkline.png"];
    //    [self.containerView addSubview:self.deviderImageview2];
    
    
    
    //self.middleButton=[[UIButton alloc] initWithFrame:CGRectMake(2,self.deviderImageview2.frame.origin.y+self.deviderImageview2.frame.size.height, self.containerView.frame.size.width-4, buttonHeight)];
    self.middleButton=[[UIButton alloc] initWithFrame:CGRectMake(2,self.topButton.frame.origin.y+self.topButton.frame.size.height, self.containerView.frame.size.width-4, buttonHeight)];
    [self.middleButton setTitle:self.danMsgNew.dan_middleBtnTxt forState:UIControlStateNormal];
    
    [self.middleButton setBackgroundImage:[UIImage imageNamed:@"popup_middle.png"] forState:UIControlStateNormal];
    
    [self.middleButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [self.middleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.middleButton addTarget:self action:@selector(donotshowButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.middleButton];
    
    //    self.deviderImageview3=[[UIImageView alloc] initWithFrame:CGRectMake(deviderMargin,self.donotshowButton.frame.origin.y+self.donotshowButton.frame.size.height, self.containerView.frame.size.width-(deviderMargin*2), deviderHeight)];
    //    self.deviderImageview3.backgroundColor=[UIColor clearColor];
    //    self.deviderImageview3.image=[UIImage imageNamed:@"popupdarkline.png"];
    //    [self.containerView addSubview:self.deviderImageview3];
    
    
    //self.bottomButton=[[UIButton alloc] initWithFrame:CGRectMake(2,self.deviderImageview3.frame.origin.y+self.deviderImageview3.frame.size.height, self.containerView.frame.size.width-4, buttonHeight)];
    self.bottomButton=[[UIButton alloc] initWithFrame:CGRectMake(2,self.middleButton.frame.origin.y+self.middleButton.frame.size.height, self.containerView.frame.size.width-4, buttonHeight)];
    [self.bottomButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.bottomButton setTitle:self.danMsgNew.dan_bottomBtnTxt forState:UIControlStateNormal];
    
    [self.bottomButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [self.bottomButton setBackgroundImage:[UIImage imageNamed:@"popup_topbottom.png"] forState:UIControlStateNormal];
    [self.bottomButton addTarget:self action:@selector(cancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.bottomButton];
    
    
    //    self.deviderImageview4=[[UIImageView alloc] initWithFrame:CGRectMake(deviderMargin, self.cancelButton.frame.origin.y+self.cancelButton.frame.size.height, self.containerView.frame.size.width-(deviderMargin*2), deviderHeight)];
    //    self.deviderImageview4.backgroundColor=[UIColor clearColor];
    //    self.deviderImageview4.image=[UIImage imageNamed:@"popupdarkline.png"];
    //    [self.containerView addSubview:self.deviderImageview4];
}
- (CGSize)getSizeForText:(NSString *)text maxWidth:(CGFloat)width fontSize:(float)fontSize {
    CGSize constraintSize;
    constraintSize.height = MAXFLOAT;
    constraintSize.width = width;
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont systemFontOfSize:fontSize], NSFontAttributeName,
                                          nil];
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    {
        text = [NSString stringWithString:text];
    }
    CGRect frame = [text boundingRectWithSize:constraintSize
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:attributesDictionary
                                      context:nil];
    
    CGSize stringSize = frame.size;
    return stringSize;
}
#pragma mark - DanMessageNewPopup Controller IBActions

-(void)yesButtonTapped:(id)sender{
    if ([self.danMessagePopupNewDelegate respondsToSelector:@selector(dismissDanMessagePopupNew:WithIndex:)]) {
        [self.danMessagePopupNewDelegate dismissDanMessagePopupNew:self WithIndex:0];
    }
}
-(void)donotshowButtonTapped:(id)sender{
    if ([self.danMessagePopupNewDelegate respondsToSelector:@selector(dismissDanMessagePopupNew:WithIndex:)]) {
        [self.danMessagePopupNewDelegate dismissDanMessagePopupNew:self WithIndex:1];
    }
}
-(void)cancelButtonTapped:(id)sender{
    if ([self.danMessagePopupNewDelegate respondsToSelector:@selector(dismissDanMessagePopupNew:WithIndex:)]) {
        [self.danMessagePopupNewDelegate dismissDanMessagePopupNew:self WithIndex:2];
    }
}

@end
