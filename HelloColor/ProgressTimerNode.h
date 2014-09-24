
//
//  ProgressNode.h
//  HelloColor
//
//  Created by Jeff on 9/21/14.
//  Copyright (c) 2014 Jeff. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface ProgressTimerNode : SKCropNode {
    CGFloat _progress;
}

- (id)initWithMaskingImageName:(NSString *)maskingImageName;

- (void)setProgress:(CGFloat)progress;
@end
