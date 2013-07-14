//
//  ABViewController.m
//  twerk
//
//  Created by Adam Bell on 7/12/2013.
//  Copyright (c) 2013 Adam Bell. All rights reserved.
//

#import "ABViewController.h"

#define TIMER_WIDTH 160.0
#define MAX_TIMER_TICKS 20
#define BUTTON_WIDTH 44.0
#define BUTTON_PADDING 20.0

@interface ABViewController ()

@end

@implementation ABViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = @{AVVideoCodecKey: AVVideoCodecJPEG};
    [_stillImageOutput setOutputSettings:outputSettings];
    
    _captureSession = [[AVCaptureSession alloc] init];
    
    NSError *error;
    AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo]
                                                                               error:&error];
    [_captureSession setSessionPreset:AVCaptureSessionPresetMedium];
    [_captureSession addInput:captureInput];
    [_captureSession addOutput:_stillImageOutput];
    [_captureSession startRunning];
    
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    _previewLayer.frame = CGRectOffset([[UIScreen mainScreen] bounds], 0, -20);
    [self.view.layer addSublayer:_previewLayer];
    
    _previewImageView = [[UIImageView alloc] initWithFrame:_previewLayer.frame];
    _previewImageView.contentMode = UIViewContentModeScaleAspectFill;
    _previewImageView.backgroundColor = [UIColor clearColor];
    _previewImageView.userInteractionEnabled = YES;
    [self.view addSubview:_previewImageView];
    
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    self.view.backgroundColor = [UIColor blackColor];
    
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in _stillImageOutput.connections)
    {
        for (AVCaptureInputPort *captureInputPort in connection.inputPorts)
        {
            if ([captureInputPort.mediaType isEqual:AVMediaTypeVideo])
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection)
        {
            break;
        }
    }
    
    _photoDock = [[ABPhotoDock alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 80, self.view.bounds.size.width, 80)];
    _photoDock.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _photoDock.delegate = self;
    _photoDock.clipsToBounds = NO;
    [self.view addSubview:_photoDock];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(takePhoto)];
    tapGesture.numberOfTapsRequired = 1;
    [_previewImageView addGestureRecognizer:tapGesture];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(switchPhoto:)];
    [_previewImageView addGestureRecognizer:panGesture];
    
    _currentPhotoIndex = 0;
    
    _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                      action:@selector(burst:)];
    _longPressGesture.minimumPressDuration = 0.5;
    [_previewImageView addGestureRecognizer:_longPressGesture];
    
    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    clearButton.frame = CGRectMake(BUTTON_PADDING, BUTTON_PADDING, BUTTON_WIDTH, BUTTON_WIDTH);
    [clearButton setBackgroundImage:[UIImage imageNamed:@"Clear.png"] forState:UIControlStateNormal];
    [clearButton addTarget:_photoDock action:@selector(clearAllImages) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:clearButton];
    
    _autoreverseToggle = [UIButton buttonWithType:UIButtonTypeCustom];
    _autoreverseToggle.frame = CGRectOffset(clearButton.frame, 78, 0.0);
    [_autoreverseToggle setBackgroundImage:[UIImage imageNamed:@"Autoreverse-Disabled.png"] forState:UIControlStateNormal];
    [_autoreverseToggle setBackgroundImage:[UIImage imageNamed:@"Autoreverse.png"] forState:UIControlStateHighlighted];
    [_autoreverseToggle setBackgroundImage:[UIImage imageNamed:@"Autoreverse.png"] forState:UIControlStateSelected];
    [_autoreverseToggle addTarget:self action:@selector(toggleAutoreverse) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_autoreverseToggle];
    
    UIButton *enhanceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    enhanceButton.frame = CGRectOffset(_autoreverseToggle.frame, 78, 0.0);
    [enhanceButton setBackgroundImage:[UIImage imageNamed:@"Enhance.png"] forState:UIControlStateNormal];
    [enhanceButton addTarget:self action:@selector(enhance) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:enhanceButton];
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.frame = CGRectMake(self.view.bounds.size.width - BUTTON_WIDTH - BUTTON_PADDING, BUTTON_PADDING, BUTTON_WIDTH, BUTTON_WIDTH);
    [doneButton setBackgroundImage:[UIImage imageNamed:@"Done.png"] forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(composeGif) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:doneButton];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"machinegun" ofType:@"aiff"];
    NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &_machineGun);
    
    _burstMode = kBurstModeDisabled;
}

- (void)enhance
{
    if (_photoDock.photos.count > 0)
    {
        UIViewController *vc = [[R1PhotoEffectsSDK sharedManager] photoEffectsControllerForImage:_photoDock.photos[_currentPhotoIndex] delegate:self cropSupport:NO];
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)photoEffectsEditingViewController:(R1PhotoEffectsEditingViewController *)controller didFinishWithImage:(UIImage *)image
{
    [self dismissViewControllerAnimated:YES completion:nil];
    _photoDock.photos[_currentPhotoIndex] = image;
    [_photoDock reloadData];
}

- (void)toggleAutoreverse
{
    _autoreverseToggle.selected = !_autoreverseToggle.selected;
}

- (void)switchPhoto:(UIPanGestureRecognizer *)panGesture
{
    if (_photoDock.photos.count == 0)
        return;
    
    switch (panGesture.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            [panGesture setTranslation:CGPointZero inView:self.view];
            _firstPhoto = YES;
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translation = [panGesture translationInView:self.view];
            
            if (translation.x < -40.0)
            {
                if (_firstPhoto)
                {
                    _firstPhoto = NO;
                }
                else
                {
                    _currentPhotoIndex--;
                }
                
                if (_currentPhotoIndex < 0)
                {
                    _currentPhotoIndex = 0;
                }
                
                [panGesture setTranslation:CGPointZero inView:self.view];
            }
            
            if (translation.x > 40.0f)
            {
                if (_firstPhoto)
                {
                    _firstPhoto = NO;
                }
                else
                {
                    _currentPhotoIndex++;
                }
                
                if (_currentPhotoIndex > _photoDock.photos.count - 1)
                {
                    _currentPhotoIndex = _photoDock.photos.count - 1;
                }
                
                [panGesture setTranslation:CGPointZero inView:self.view];
            }
            
            _previewImageView.image = _photoDock.photos[_currentPhotoIndex];
            
            break;
        }
            
        case UIGestureRecognizerStateEnded:
        {
            _previewImageView.image = nil;
            break;
        }
        default:
            break;
    }
}

- (void)burst:(UILongPressGestureRecognizer *)longPress
{
    switch (longPress.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            _burstTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                           target:self
                                                         selector:@selector(takePhoto)
                                                         userInfo:nil
                                                          repeats:YES];
            _burstMode = kBurstModeBegan;
            [[NSRunLoop mainRunLoop] addTimer:_burstTimer forMode:NSRunLoopCommonModes];
            
            CGPoint currentTouchPoint = [longPress locationInView:self.view];
            CGRect timerFrame = CGRectMake(currentTouchPoint.x - (TIMER_WIDTH / 2.0), currentTouchPoint.y - (TIMER_WIDTH / 2.0), TIMER_WIDTH, TIMER_WIDTH);
            _timerIndicator = [[ABPieIndicator alloc] initWithFrame:timerFrame];
            _timerIndicator.transform = CGAffineTransformMakeScale(0.3, 0.3);
            _timerIndicator.alpha = 0.0;
            [self.view addSubview:_timerIndicator];
            
            _timerTick = 0;
            
            [UIView animateWithDuration:0.3
                             animations:^{
                                 _timerIndicator.transform = CGAffineTransformIdentity;
                                 _timerIndicator.alpha = 1.0;
                             }];
            
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
            
            animation.duration = 0.20f;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            animation.fromValue = [NSNumber numberWithFloat:0.9f];
            animation.toValue = [NSNumber numberWithFloat:1.0f];
            
            [_previewLayer addAnimation:animation forKey:@"scaleAnimationReverse"];
            _previewLayer.transform = CATransform3DIdentity;
            [_burstTimer invalidate];
            _burstTimer = nil;
            
            _burstMode = kBurstModeDisabled;
            
            [UIView animateWithDuration:0.3
                             animations:^{
                                 _timerIndicator.transform = CGAffineTransformMakeScale(0.3, 0.3);
                                 _timerIndicator.alpha = 0.0;
                             }
                             completion:^(BOOL finished) {
                                 [_timerIndicator removeFromSuperview];
                                 _timerIndicator = nil;
                             }];
            break;
        }
        default:
            break;
    }
}

static inline double radians (double degrees) {return degrees * M_PI/180;}
UIImage* rotate(UIImage* src, UIImageOrientation orientation)
{
    UIGraphicsBeginImageContext(src.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orientation == UIImageOrientationRight) {
        CGContextRotateCTM (context, radians(90));
    } else if (orientation == UIImageOrientationLeft) {
        CGContextRotateCTM (context, radians(-90));
    } else if (orientation == UIImageOrientationDown) {
        // NOTHING
    } else if (orientation == UIImageOrientationUp) {
        CGContextRotateCTM (context, radians(90));
    }
    
    [src drawAtPoint:CGPointMake(0, 0)];
    
    return UIGraphicsGetImageFromCurrentImageContext();
}

- (void)composeGif
{
    if (_photoDock.photos.count == 0)
        return;
    
    NSUInteger frameCount = _photoDock.photos.count;
    
    NSDictionary *fileProperties = @{
                                     (__bridge id)kCGImagePropertyGIFDictionary: @{
                                             (__bridge id)kCGImagePropertyGIFLoopCount: @0,
                                             }
                                     };
    
    NSDictionary *frameProperties = @{
                                      (__bridge id)kCGImagePropertyGIFDictionary: @{
                                              (__bridge id)kCGImagePropertyGIFDelayTime: @0.1f,                                               }
                                      };
    
    NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
    NSURL *fileURL = [documentsDirectoryURL URLByAppendingPathComponent:@"Jiff.gif"];
    
    CGImageDestinationRef destination = NULL;
    
    if (_autoreverseToggle.selected)
    {
        destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)fileURL, kUTTypeGIF, frameCount + frameCount - 1, NULL);
    }
    else
    {
        destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)fileURL, kUTTypeGIF, frameCount, NULL);
    }
    
    CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)fileProperties);
    
    for (NSUInteger i = 0; i < frameCount; i++) {
        @autoreleasepool {
            UIImage *image = rotate([_photoDock.photos[i] copy], UIImageOrientationDown);
            CGImageDestinationAddImage(destination, image.CGImage, (__bridge CFDictionaryRef)frameProperties);
        }
    }
    
    if (_autoreverseToggle.selected)
    {
        for (int i = (frameCount - 2); i >= 0; i--) {
            @autoreleasepool {
                UIImage *image = rotate([_photoDock.photos[i] copy], UIImageOrientationDown);
                CGImageDestinationAddImage(destination, image.CGImage, (__bridge CFDictionaryRef)frameProperties);
            }
        }
    }
    
    if (!CGImageDestinationFinalize(destination)) {
        NSLog(@"failed to finalize image destination");
    }
    CFRelease(destination);
    
    UIImage *referenceImage = _photoDock.photos[0];
    
    ABGifView *gifView = [[ABGifView alloc] initWithGifURL:fileURL andSize:referenceImage.size];
    [gifView presentInView:self.view];
}

- (void)takePhoto
{
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in _stillImageOutput.connections)
    {
        for (AVCaptureInputPort *captureInputPort in connection.inputPorts)
        {
            if ([captureInputPort.mediaType isEqual:AVMediaTypeVideo])
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection)
        {
            break;
        }
    }
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    
    animation.duration = 0.05f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.fromValue = [NSNumber numberWithFloat:1.0f];
    animation.toValue = [NSNumber numberWithFloat:0.9f];
    animation.autoreverses = YES;
    
    if (_burstMode == kBurstModeBegan)
    {
        _burstMode = kBurstModeRunning;
        animation.autoreverses = NO;
        [_previewLayer addAnimation:animation forKey:@"animateScale"];
        _previewLayer.transform = CATransform3DMakeScale(0.9, 0.9, 1.0);
    }
    else if (_burstMode == kBurstModeRunning)
    {
        _timerTick++;
        [_timerIndicator setPercent:_timerTick / (float)MAX_TIMER_TICKS];
        
        if (_timerTick == MAX_TIMER_TICKS)
        {
            _longPressGesture.enabled = NO;
            _longPressGesture.enabled = YES;
        }
    }
    else
    {
        animation.autoreverses = YES;
        [_previewLayer addAnimation:animation forKey:@"animateScale"];
    }
    
    
    [_stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection
                                                   completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                       
                                                       if (error != nil)
                                                           return;
                                                       
                                                       NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                       UIImage *image = [[UIImage alloc] initWithData:imageData];
                                                       [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                           
                                                           if (_burstMode == kBurstModeRunning)
                                                               AudioServicesPlaySystemSound(_machineGun);
                                                           
                                                           [_photoDock addImage:image];
                                                       }];
                                                       
                                                   }];
}

- (void)photoFrameTapped:(ABPhotoFrame *)photoFrame
{
    _previewImageView.image = _photoDock.photos[photoFrame.index];
    _currentPhotoIndex = photoFrame.index;
    [self performSelector:@selector(removePhotoPreview) withObject:nil afterDelay:0.5];
}

- (void)removePhotoPreview
{
    _previewImageView.image = nil;
}

- (void)photoFrameLongPressBegan:(ABPhotoFrame *)photoFrame
{
    _previewImageView.image = _photoDock.photos[photoFrame.index];
}

- (void)photoFrameLongPressEnded:(ABPhotoFrame *)photoFrame
{
    _previewImageView.image = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
