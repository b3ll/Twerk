//
//  ABGifViewController.m
//  twerk
//
//  Created by Adam Bell on 7/13/2013.
//  Copyright (c) 2013 Adam Bell. All rights reserved.
//

#import "ABGifView.h"
#import "AnimatedGif.h"

@interface ABGifView ()

@end

@implementation ABGifView

- (id)initWithGifURL:(NSURL *)gifURL andSize:(CGSize)size
{
    self = [super init];
    if (self != nil)
    {
        _animatedImageView = [AnimatedGif getAnimationForGifAtUrl:gifURL];
        _animatedImageView.userInteractionEnabled = YES;
        _animatedImageView.bounds = CGRectMake(0.0, 0.0, size.width, size.height);
        [self addSubview:_animatedImageView];
        
        UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(dismiss:)];
        swipeGesture.direction = UISwipeGestureRecognizerDirectionDown;
        [_animatedImageView addGestureRecognizer:swipeGesture];
        [self addGestureRecognizer:swipeGesture];
        
        _imgurAPI = [[ImgurAPI alloc] init];
        
        _gifURL = gifURL;
        
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
    }
    
    return self;
}

- (void)share
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Twitter", @"Copy GIF", @"Copy Link", nil];
    [actionSheet showInView:self];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        NSData *gifData = [[NSData alloc] initWithContentsOfURL:_gifURL];
        
#error Change Client ID
        
        [ImgurAPI uploadPhoto:gifData
                        title:@""
                  description:@""
                imgurClientID:@"CLIENT ID"
              completionBlock:^(NSString *result) {
                  [tweetSheet setInitialText:[NSString stringWithFormat:@"Go Go Gadget Gif! %@", result]];
                  [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:tweetSheet animated:YES completion:nil];
              } failureBlock:^(NSURLResponse *response, NSError *error, NSInteger status) {
                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Failed"
                                                                  message:@"Please check your internet connection and try again :("
                                                                 delegate:nil
                                                        cancelButtonTitle:@"Okay"
                                                        otherButtonTitles:nil, nil];
                  [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                      [alert show];
                  }];
              }];
    }
    else if (buttonIndex == 1)
    {
        //copy to clipboard
        
        [[UIPasteboard generalPasteboard] setData:[NSData dataWithContentsOfURL:_gifURL] forPasteboardType:(__bridge NSString *)kUTTypeGIF];
    }
    else
    {
        NSData *gifData = [[NSData alloc] initWithContentsOfURL:_gifURL];

#error Change Client ID
        
        [ImgurAPI uploadPhoto:gifData
                        title:@""
                  description:@""
                imgurClientID:@"CLIENT_ID"
              completionBlock:^(NSString *result) {
                  [[UIPasteboard generalPasteboard] setString:result];
              } failureBlock:^(NSURLResponse *response, NSError *error, NSInteger status) {
                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Failed"
                                                                  message:@"Please check your internet connection and try again :("
                                                                 delegate:nil
                                                        cancelButtonTitle:@"Okay"
                                                        otherButtonTitles:nil, nil];
                  [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                      [alert show];
                  }];
              }];
    }
}

- (void)presentInView:(UIView *)view
{
    [view addSubview:self];
    
    self.frame = view.bounds;
    
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareButton setBackgroundImage:[UIImage imageNamed:@"Share.png"] forState:UIControlStateNormal];
    shareButton.frame = CGRectMake(20, self.bounds.size.height - 32 - 20, 32, 32);
    [shareButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:shareButton];
    
    CGRect centeredRect = CGRectMake((self.bounds.size.width - _animatedImageView.bounds.size.width) / 2,
                                     0.0,
                                     _animatedImageView.bounds.size.width,
                                     _animatedImageView.bounds.size.height);
    _animatedImageView.frame = CGRectOffset(centeredRect, 0, self.bounds.size.height);
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
                         _animatedImageView.frame = CGRectOffset(_animatedImageView.frame, 0, -self.bounds.size.height);
                     } completion:^(BOOL finished) {
                         //
                     }];
}

- (void)dismiss:(UISwipeGestureRecognizer *)swipeGesture
{
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
                         _animatedImageView.frame = CGRectOffset(_animatedImageView.frame, 0, self.bounds.size.height);
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

- (void)viewDidAppear:(BOOL)animated
{
    //self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    
    [_animatedImageView startAnimating];
}

@end


