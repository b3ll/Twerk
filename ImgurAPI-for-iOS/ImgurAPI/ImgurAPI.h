//
//  ImgurAPI.h
//  ImgurAPI
//
//  Created by Kodam Shindo on 12/04/21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImgurAPI : NSObject
{
}

+ (void)uploadPhoto:(NSData*)imageData title:(NSString*)title
        description:(NSString*)description
      imgurClientID:(NSString*)clientID
    completionBlock:(void(^)(NSString* result))completion
       failureBlock:(void(^)(NSURLResponse *response, NSError *error, NSInteger status))failureBlock;
@end
