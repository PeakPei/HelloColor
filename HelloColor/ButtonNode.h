//
//  ButtonNode.h
//  HelloColor
//
//  Created by Jeff on 9/19/14.
//  Copyright (c) 2014 Jeff. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef void (^AnonBlock)();

@interface ButtonNode : SKSpriteNode
-(id) initWithDefaultTexture:(SKTexture *) defaultTexture andTouchedTexture:(SKTexture *)touchedTexture;
-(void) setMethod:(void (^)()) returnMethod;
-(void) runMethod;
+(void) removeButtonPressed:(NSArray *) nodes;
+(BOOL) isButtonPressed:(NSArray *) nodes;
+(void) doButtonsActionBegan:(SKNode *)node touches:(NSSet *)touches withEvent:(UIEvent *)event;
+(void) doButtonsActionEnded:(SKNode *)node touches:(NSSet *)touches withEvent:(UIEvent *)event;
@end
