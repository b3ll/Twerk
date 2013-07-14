//
//  ABPhotoDock.m
//  twerk
//
//  Created by Adam Bell on 7/12/2013.
//  Copyright (c) 2013 Adam Bell. All rights reserved.
//

#import "ABPhotoDock.h"

#define DEFAULT_INSET 12.0
#define X_PADDING 12.0
#define MAX_VISIBLE_PHOTOS 6

static NSString *kPhotoFrameCell = @"kPhotoFrameCell";

@implementation ABPhotoDock

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        /*UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = X_PADDING;
        layout.sectionInset = UIEdgeInsetsMake(0.0, DEFAULT_INSET, 0.0, 0.0);*/
        
        LXReorderableCollectionViewFlowLayout *reorderLayout = [[LXReorderableCollectionViewFlowLayout alloc] init];
        reorderLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        reorderLayout.minimumLineSpacing = X_PADDING;
        reorderLayout.sectionInset = UIEdgeInsetsMake(0.0, DEFAULT_INSET, 0.0, DEFAULT_INSET);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds
                                             collectionViewLayout:reorderLayout];
        [_collectionView registerClass:[ABPhotoFrame class] forCellWithReuseIdentifier:kPhotoFrameCell];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.clipsToBounds = NO;
        [self addSubview:_collectionView];
        
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
    }
    return self;
}

- (void)addImage:(UIImage *)image
{
    if (_photos == nil)
        _photos = [[NSMutableArray alloc] init];
    [_photos addObject:image];
    [_collectionView reloadData];
    
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_photos.count -1 inSection:0]
                            atScrollPosition:UICollectionViewScrollPositionRight
                                    animated:YES];
}

- (void)clearAllImages
{        
    [_photos removeAllObjects];
    
    [_collectionView performBatchUpdates:^{
        [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    }
                              completion:nil];
}

- (void)reloadData
{
    [_collectionView reloadData];
}
#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ABPhotoFrame *photoFrame = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoFrameCell
                                                                         forIndexPath:indexPath];
    photoFrame.image = _photos[indexPath.row];
    photoFrame.index = indexPath.row;
    photoFrame.delegate = self;
    return photoFrame;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _photos.count;
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    UIImage *photo = [_photos objectAtIndex:fromIndexPath.item];
    [_photos removeObjectAtIndex:fromIndexPath.item];
    [_photos insertObject:photo atIndex:toIndexPath.item];
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPathWillBeRemoved:(NSIndexPath *)fromIndexPath
{
    //  ABPhotoFrame *frame = (ABPhotoFrame *)[collectionView cellForItemAtIndexPath:fromIndexPath];
    //  [frame removeFromSuperview];
    [_photos removeObjectAtIndex:fromIndexPath.row];
}

#pragma mark - ABPhotoFrameDelegate

- (void)photoFrameTapped:(ABPhotoFrame *)photoFrame
{
    [self.delegate photoFrameTapped:photoFrame];
}

- (void)photoFrameDoubleTapped:(ABPhotoFrame *)photoFrame
{
    [self.photos removeObject:photoFrame.image];
    [_collectionView reloadData];
}

- (void)photoFrameLongPressBegan:(ABPhotoFrame *)photoFrame
{
    [self.delegate photoFrameLongPressBegan:photoFrame];
}

- (void)photoFrameLongPressEnded:(ABPhotoFrame *)photoFrame
{
    [self.delegate photoFrameLongPressEnded:photoFrame];
}

@end
