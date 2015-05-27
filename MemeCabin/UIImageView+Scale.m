//
//  UIImageView+Scale.m
//  MemeCabin
//
//  Created by Himel on 12/29/14.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import "UIImageView+Scale.h"

@implementation UIImageView (Scale)

#pragma mark - Image Scale Down
-(void) setImageWithScaleDownOnly:(UIImage *)image {
    if (image) {
        if([self isRetinaDisplay])
            image = [UIImage imageWithCGImage:image.CGImage
                                        scale:1.0
                                  orientation:image.imageOrientation];// UIImageOrientationUp];
        
        BOOL smallImage = (image.size.width < self.frame.size.width
                           && image.size.height < self.frame.size.height);
        self.contentMode = (smallImage)? UIViewContentModeCenter : UIViewContentModeScaleAspectFit;
    }
    
    self.image = image;
}

#pragma mark - isRetina Display
- (BOOL) isRetinaDisplay
{
    int scale = 1.0;
    UIScreen *screen = [UIScreen mainScreen];
    if([screen respondsToSelector:@selector(scale)])
        scale = screen.scale;
    
    if(scale == 2.0f) return YES;
    else return NO;
}

@end
