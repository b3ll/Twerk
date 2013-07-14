//
//  ABGifViewController.h
//  twerk
//
//  Created by Adam Bell on 7/13/2013.
//  Copyright (c) 2013 Adam Bell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Twitter/Twitter.h>
#import <MessageUI/MessageUI.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "ImgurAPI.h"

@interface ABGifView : UIView <UIActionSheetDelegate>
{
    UIImageView *_animatedImageView;
    
    ImgurAPI *_imgurAPI;
    
    NSURL *_gifURL;
}

- (id)initWithGifURL:(NSURL *)gifURL andSize:(CGSize)size;
- (void)presentInView:(UIView *)view;

@end
