//
//  ABPieIndicator.m
//  twerk
//
//  Created by Adam Bell on 7/14/2013.
//  Copyright (c) 2013 Adam Bell. All rights reserved.
//

#import "ABPieIndicator.h"

@implementation ABPieIndicator

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _percent = 0.0;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    
    if (_percent == 0.0f)
        _percent = 1.0001f;
    if (_percent == 1.0f)
        _percent = 0.0000000001f;
    
    float timePercentage = _percent - 0.25f;
    float percentageAngle = timePercentage * (2 * M_PI);
    
    //NSLog(@"%f", timePercentage);
    
	CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(contextRef, [self bounds]);
    
	// save the context
	CGContextSaveGState(contextRef);
	
	// allow antialiasing
	CGContextSetAllowsAntialiasing(contextRef, TRUE);
    
    CGContextSetFillColorWithColor(contextRef, [[UIColor whiteColor] CGColor]);
    CGContextSetStrokeColorWithColor(contextRef, [[UIColor whiteColor] CGColor]);
	CGContextSetLineWidth(contextRef, 1.0f);
    
    // Create Inner and Outer Frames
    
    CGRect strokeRect = self.bounds;
    strokeRect.origin.x += 8;
    strokeRect.origin.y += 8;
    strokeRect.size.width -= 16;
    strokeRect.size.height -= 16;
    
    CGRect fillRect = strokeRect;
    /* fillRect.origin.x += 15;
     fillRect.origin.y += 15;
     fillRect.size.width -= 30;
     fillRect.size.height -= 30;*/
    
    // Draw a circle (fill only)
    //CGContextFillEllipseInRect(contextRef, fillRect);
    
    // Draw a circle (border only)
    //CGContextStrokeEllipseInRect(contextRef, strokeRect);
        
    CGContextBeginPath(contextRef);
    CGContextMoveToPoint(contextRef, self.bounds.size.width / 2, fillRect.origin.y);
    CGContextAddLineToPoint(contextRef, self.bounds.size.width / 2, self.bounds.size.height / 2);
    CGContextAddArc(contextRef, self.bounds.size.width / 2, self.bounds.size.height / 2, fillRect.size.width / 2, M_PI + (M_PI / 2), percentageAngle, 0);
    CGContextAddLineToPoint(contextRef, self.bounds.size.width / 2, self.bounds.size.height / 2);
    CGContextClosePath(contextRef);
	CGContextFillPath(contextRef);
    
	// restore the context
	CGContextRestoreGState(contextRef);
}

- (void)setPercent:(float)currentPercent
{
    _percent = currentPercent;
    [self setNeedsDisplay];
}


@end
