//
//  gameBoardNode.h
//  gameBoard
//
//  Created by Jeff on 9/12/14.
//  Copyright (c) 2014 Jeff. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameBoardNode : SKSpriteNode

- (id)initWithGameBoardSize:(CGSize)size;

- (void) startNewGame;
- (void) resetGameBoard;
- (void) setGameOver;
- (BOOL) isGameReady;
- (BOOL) isGameOver;

- (NSUInteger) getLevel;
- (NSTimeInterval) getRealStartTime;

- (void) touchedBox:(CGPoint)touchedPosition;

-(void) doGameboardActionBegan:(SKNode *)node touches:(NSSet *)touches;

@end
