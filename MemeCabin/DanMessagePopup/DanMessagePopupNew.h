//
//  DanMessagePopupNew.h
//  MemeCabin
//
//  Created by Hemal on 3/5/15.
//  Copyright (c) 2015 appbd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DanMessageNew.h"
@protocol DanMessagePopupNewViewDelegate;

@interface DanMessagePopupNew : UIView
@property(nonatomic,strong)NSString *titleText;
@property(nonatomic,strong)UILabel *headerLabel;
@property(nonatomic,strong)UIImageView *headerLabelView;
@property(nonatomic,strong)UIImageView *backgroundImageView;
//@property(nonatomic,strong)UIImageView *deviderImageview1;
//@property(nonatomic,strong)UIImageView *deviderImageview2;
//@property(nonatomic,strong)UIImageView *deviderImageview3;
//@property(nonatomic,strong)UIImageView *deviderImageview4;
//@property(nonatomic,strong)UIImageView *deviderImageview5;
@property(nonatomic,strong)UIButton *closeButton;

@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UILabel *subTitleLabel;

@property(nonatomic,strong)UIView *buttonBgView;
@property(nonatomic,strong)UIView *containerView;
@property(nonatomic,strong)UIButton *topButton;
@property(nonatomic,strong)UIButton *middleButton;
@property(nonatomic,strong)UIButton *bottomButton;
@property(nonatomic,weak)id<DanMessagePopupNewViewDelegate>danMessagePopupNewDelegate;
@property(nonatomic,strong)DanMessageNew *danMsgNew;
- (instancetype)initWithFrame:(CGRect)frame title:(DanMessageNew*)danMessageNew;
@end


@protocol DanMessagePopupNewViewDelegate <NSObject>
@optional
-(void)dismissDanMessagePopupNew:(DanMessagePopupNew*)danMsgNew WithIndex:(int)buttonIndex;
@end
