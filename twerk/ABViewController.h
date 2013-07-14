//
//  ABViewController.h
//  twerk
//
//  Created by Adam Bell on 7/12/2013.
//  Copyright (c) 2013 Adam Bell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "ABPhotoDock.h"
#import "ABGifView.h"
#import "ABPieIndicator.h"

#import "R1PhotoEffectsSDK.h"

typedef enum  {
    kBurstModeBegan = 0,
    kBurstModeRunning,
    kBurstModeDisabled
    } BurstMode;

@interface ABViewController : UIViewController <ABPhotoFrameDelegate, R1PhotoEffectsEditingViewControllerDelegate>
{
    AVCaptureStillImageOutput *_stillImageOutput;
    AVCaptureSession *_captureSession;
    
    ABPhotoDock *_photoDock;
    
    NSInteger _currentPhotoIndex;
    
    UIImageView *_previewImageView;
    
    UILongPressGestureRecognizer *_longPressGesture;
    
    BOOL _firstPhoto;
    
    NSTimer *_burstTimer;
    BurstMode _burstMode;
    
    NSInteger _timerTick;
    
    ABPieIndicator *_timerIndicator;
    UIButton *_autoreverseToggle;
    
    AVCaptureVideoPreviewLayer *_previewLayer;
    
    SystemSoundID _machineGun;
}


@end
