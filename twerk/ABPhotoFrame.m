//
//  ABPhotoFrame.m
//  twerk
//
//  Created by Adam Bell on 7/12/2013.
//  Copyright (c) 2013 Adam Bell. All rights reserved.
//

#import "ABPhotoFrame.h"

#define DEFAULT_INSET 4
#define DEFAULT_HEIGHT 60
#define DEFAULT_WIDTH 44

@implementation ABPhotoFrame

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        _imageView = [[UIImageView alloc] initWithFrame:CGRectInset(self.bounds, DEFAULT_INSET - 1, DEFAULT_INSET + 2)];
        _imageView.frame = CGRectOffset(_imageView.frame, 0, -4);
        _imageView.backgroundColor = [UIColor blackColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_imageView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(tapped:)];
        tapGesture.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tapGesture];
        
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(doubleTapped:)];
        doubleTapGesture.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTapGesture];
        
        //UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self
        //                                                                                             action:@selector(longPressed:)];
        //longPressGesture.minimumPressDuration = 0.5;
        //[self addGestureRecognizer:longPressGesture];
        self.autoresizesSubviews = YES;
    }
    return self;
}

- (void)longPressed:(UILongPressGestureRecognizer *)longPress
{
    switch (longPress.state)
    {
        case UIGestureRecognizerStateBegan:
            [self.delegate photoFrameLongPressBegan:self];
            self.transform = CGAffineTransformMakeScale(1.25, 1.25);
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            self.transform = CGAffineTransformIdentity;
            [self.delegate photoFrameLongPressEnded:self];
            break;
        default:
            break;
    }
}

- (void)doubleTapped:(UITapGestureRecognizer *)tapGesture
{
    [self.delegate photoFrameDoubleTapped:self];
}

- (void)tapped:(UITapGestureRecognizer *)tapGesture
{
    [self.delegate photoFrameTapped:self];
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    _imageView.image = image;
}

- (UIImage *)image
{
    return _image;
}

@end
