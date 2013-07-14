//
//  ABPhotoDock.h
//  twerk
//
//  Created by Adam Bell on 7/12/2013.
//  Copyright (c) 2013 Adam Bell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABPhotoFrame.h"
#import "LXReorderableCollectionViewFlowLayout.h"

@protocol ABPhotoDockDelegate <NSObject>

- (void)photoFrameTapped:(ABPhotoFrame *)photoFrame;
- (void)photoFrameLongPressBegan:(ABPhotoFrame *)photoFrame;
- (void)photoFrameLongPressEnded:(ABPhotoFrame *)photoFrame;

@end

@interface ABPhotoDock : UIView <UICollectionViewDataSource, UICollectionViewDelegate, LXReorderableCollectionViewDataSource, LXReorderableCollectionViewDelegateFlowLayout, ABPhotoFrameDelegate>
{
    UICollectionView *_collectionView;
}

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, assign) id<ABPhotoFrameDelegate> delegate;

- (void)addImage:(UIImage *)image;
- (void)clearAllImages;
- (void)reloadData;

@end
