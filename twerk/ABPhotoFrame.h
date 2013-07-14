//
//  ABPhotoFrame.h
//  twerk
//
//  Created by Adam Bell on 7/12/2013.
//  Copyright (c) 2013 Adam Bell. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ABPhotoFrame;

@protocol ABPhotoFrameDelegate <NSObject>

- (void)photoFrameTapped:(ABPhotoFrame *)photoFrame;
- (void)photoFrameDoubleTapped:(ABPhotoFrame *)photoFrame;
- (void)photoFrameLongPressBegan:(ABPhotoFrame *)photoFrame;
- (void)photoFrameLongPressEnded:(ABPhotoFrame *)photoFrame;

@end

@interface ABPhotoFrame : UICollectionViewCell
{
    UIImageView *_imageView;
    __strong UIImage *_image;
}

@property (nonatomic, assign) id<ABPhotoFrameDelegate> delegate;
@property (nonatomic, assign) NSInteger index;

- (void)setImage:(UIImage *)image;
- (UIImage *)image;

@end
