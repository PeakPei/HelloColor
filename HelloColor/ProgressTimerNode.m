//
//  ProgressNode.m
//  HelloColor
//
//  Created by Jeff on 9/21/14.
//  Copyright (c) 2014 Jeff. All rights reserved.
//

#import "ProgressTimerNode.h"

#define HORIZONTAL_START_POINT  CGPointMake(1, 0.5)
#define HORIZONTAL_END_POINT    CGPointMake(0, 0.5)
#define VERTICAL_START_POINT    CGPointMake(0.5, 0)
#define VERTICAL_END_POINT      CGPointMake(0.5, 1)

@implementation ProgressTimerNode {
    SKSpriteNode *_healthBarNode;
}

- (id)initWithMaskingImageName:(NSString *)maskingImageName {
    if (self = [super init]) {
        SKSpriteNode *maskImageNode = [[SKSpriteNode alloc] initWithImageNamed:maskingImageName];
        self.maskNode = maskImageNode;
        
        //NSLog(@"~~~~~~~width: %f~~~~~~~", maskImageNode.size.width);
        _healthBarNode = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithRed:57.0f/255.0f green:181.0f/255.0f blue:74.0f/255.0f alpha:1.0] size:maskImageNode.size];
        
        // make _healthBarNode anchor to the bottom
        _healthBarNode.anchorPoint = VERTICAL_START_POINT;
        _healthBarNode.position = CGPointMake(self.frame.origin.x, self.frame.origin.y - _healthBarNode.size.height/2);
        
        [self addChild:_healthBarNode];
    }
    return self;
}

- (void) setProgress:(CGFloat) progress {
    _healthBarNode.yScale = 1 - progress;
}

@end