//
//  gameBoardNode.m
//  gameBoard
//
//  Created by Jeff on 9/12/14.
//  Copyright (c) 2014 Jeff. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "gameBoardNode.h"

#define NUMBER_OF_BOXES_PER_ROW 8
#define NUMBER_OF_BOXES_PER_COL NUMBER_OF_BOXES_PER_ROW
#define NUMBER_OF_BOXES (NUMBER_OF_BOXES_PER_ROW * NUMBER_OF_BOXES_PER_ROW)
#define BOX_INTERVAL 3
#define GAME_BOARD_BOUND 5

#define GAME_DIFFICULTY 50 // between 1~255, the smaller the harder.

#define NUMBER_OF_COUNTDOWN_FRAMES 3

@implementation GameBoardNode {
    SKSpriteNode *_gameBoard;
    CGFloat _boxWidth, _boxHeight;
    
    NSMutableArray *_colorBoxArray;
    SKSpriteNode *_solutionColorBoxPointer;
    
    NSUInteger _level;
    
    SKSpriteNode *_countdownNode;
    NSArray *_countdownFrames;
    SKSpriteNode *_gameoverNode;
    
    BOOL _isGameReady;
    BOOL _isGameOver;
    NSTimeInterval _startTime;
}

- (id)initWithGameBoardSize:(CGSize)boardSize {
    self = [super init];
    if (self) {
        _level = 0;
        
        _gameBoard = [[SKSpriteNode alloc] initWithColor:[UIColor whiteColor] size:boardSize];
        [self addChild:_gameBoard];
        
        
        _colorBoxArray = [[NSMutableArray alloc] initWithCapacity:(NSUInteger)NUMBER_OF_BOXES];
        
        _boxWidth = (boardSize.width - (GAME_BOARD_BOUND*2) - (NUMBER_OF_BOXES_PER_ROW-1)*BOX_INTERVAL) / (CGFloat)NUMBER_OF_BOXES_PER_ROW;
        _boxHeight = _boxWidth;
        
        CGFloat originX = self.frame.origin.x - boardSize.width/2 + _boxWidth/2;
        CGFloat originY = self.frame.origin.y - boardSize.height/2 + _boxHeight/2;
        
        CGSize boxSize = CGSizeMake(_boxWidth, _boxHeight);
        
        CGFloat curPositionInRow = originX+GAME_BOARD_BOUND;
        for (int row = 0; row < NUMBER_OF_BOXES_PER_ROW; ++row, curPositionInRow += (_boxWidth+BOX_INTERVAL)) {
            CGFloat curPositionInCol = originY+GAME_BOARD_BOUND;
            for (int col = 0; col < NUMBER_OF_BOXES_PER_COL; ++col, curPositionInCol += (_boxHeight+BOX_INTERVAL)) {
                SKSpriteNode *colorBoxNode = [[SKSpriteNode alloc] initWithColor:[UIColor redColor] size:boxSize];
                colorBoxNode.name = @"colorBox";
                colorBoxNode.position = CGPointMake(curPositionInRow, curPositionInCol);
                [_colorBoxArray addObject:colorBoxNode];
                [self addChild:colorBoxNode];
            }
        }
        
        
        SKTextureAtlas *gameboardAnimatedAtlas = [SKTextureAtlas atlasNamed:@"gameboard"];
        
        // for the countdown textures
        NSMutableArray *countdownFrames = [NSMutableArray array];
        for (NSInteger i = NUMBER_OF_COUNTDOWN_FRAMES; i > 0; --i) {
            NSString *textureName = [NSString stringWithFormat:@"gameboard_countdown_%ld", (long)i];
            SKTexture *temp = [gameboardAnimatedAtlas textureNamed:textureName];
            [countdownFrames addObject:temp];
        }
        [countdownFrames addObject:[gameboardAnimatedAtlas textureNamed:@"gameboard_countdown_go"]];
        _countdownFrames = countdownFrames;

        _countdownNode = [SKSpriteNode spriteNodeWithTexture:_countdownFrames[0]];
        _countdownNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        [self addChild:_countdownNode];
        
        // for the gameover texture
        _gameoverNode = [SKSpriteNode spriteNodeWithTexture:[gameboardAnimatedAtlas textureNamed:@"gameboard_over"]];
        _gameoverNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        _gameoverNode.hidden = YES;
        [self addChild:_gameoverNode];
        
        // [self startNewGame];
    }
    return self;
}

- (void)startNewGame {
    _isGameOver = NO;
    _isGameReady = NO;
    _level = 0;
    SKAction *countdownToStart = [SKAction performSelector:@selector(countdownToStart) onTarget:self];
    SKAction *resetGameBoard = [SKAction performSelector:@selector(resetGameBoard) onTarget:self];
    [self runAction:[SKAction sequence:@[countdownToStart, resetGameBoard]]];
    // [self countdownToStart];
    //[self resetGameBoard];
}

- (void)setGameOver {
    _isGameOver = YES;
    _level = 0;
    
    _gameoverNode.hidden = NO;
    [_gameoverNode runAction:
     [SKAction repeatActionForever:
      [SKAction sequence:@[[SKAction moveByX:-1 y:0 duration:0.05],
                           [SKAction moveByX:2 y:0 duration:0.1],
                           [SKAction moveByX:-1 y:0 duration:0.05]]]
      ]
     ];
    
    SKAction *fadeOut = [SKAction fadeOutWithDuration:0.0f];
    for (SKSpriteNode *colorBox in _colorBoxArray)
        [colorBox runAction:fadeOut];
}

- (BOOL) isGameOver {
    return _isGameOver;
}

- (void)resetGameBoard {
    UIColor *color1, *color2;
    [self generateSimilarColor:&color1 anotherColor:&color2];
    SKAction *fadeIn = [SKAction fadeInWithDuration:0.3f];
    for (SKSpriteNode *colorBox in _colorBoxArray) {
        colorBox.color = color1;
        [colorBox runAction:fadeIn];
    }
    NSInteger solutionIndex = arc4random() % [_colorBoxArray count];
    _solutionColorBoxPointer = _colorBoxArray[solutionIndex];
    _solutionColorBoxPointer.color = color2;
    
    [_gameoverNode removeAllActions];
    _gameoverNode.hidden = YES;
    _isGameOver = NO;
}


- (void)touchedBox:(CGPoint)touchedPosition {
    CGFloat touchedX = touchedPosition.x - self.frame.origin.x + _boxWidth/2;
    CGFloat touchedY = touchedPosition.y - self.frame.origin.y + _boxHeight/2;
    for (SKSpriteNode *colorBox in _colorBoxArray) {
        if (touchedX >= colorBox.position.x && touchedX <= colorBox.position.x+_boxWidth &&
            touchedY >= colorBox.position.y && touchedY <= colorBox.position.y+_boxHeight) {
            if ([colorBox isEqual:_solutionColorBoxPointer]) { // if find the color
                [self runAction:[SKAction playSoundFileNamed:@"button-in.m4a" waitForCompletion:NO]];
                ++_level;
                [self resetGameBoard];
            }
        }
    }
}

- (void) doGameboardActionBegan:(SKNode *)node touches:(NSSet *)touches {
     for (UITouch *touch in touches) {
         CGPoint location = [touch locationInNode:node];
         [self touchedBox:location];
     }
}

- (void)countdownToStart {
    SKAction *fadeIn = [SKAction  fadeInWithDuration:.0f];
    SKAction *countdownAction = [SKAction animateWithTextures:_countdownFrames
                                                 timePerFrame:1.0f];
    SKAction *fadeOut = [SKAction fadeOutWithDuration:.0f];
    SKAction *setReady = [SKAction performSelector:@selector(setGameReady) onTarget:self];
    // SKAction *group = [SKAction group:@[countdownAction, fadeOut]];
    // [_countdownNode runAction:[SKAction repeatAction:group count:1] withKey:@"countdown"];
    NSArray *sequenceActions = @[fadeIn, countdownAction, fadeOut, setReady];
    [_countdownNode runAction:[SKAction sequence:sequenceActions] withKey:@"countdown"];
}

- (void)setGameReady {
    _isGameReady = YES;
    _startTime = CACurrentMediaTime();
    _level = 1;
}

- (BOOL)isGameReady {
    return _isGameReady;
}

- (void)generateSimilarColor:(UIColor **)color1 anotherColor:(UIColor **)color2 {
    #define ARC4RANDOM_MAX 0x100000000
    CGFloat r = ((double)arc4random() / ARC4RANDOM_MAX);
    CGFloat g = ((double)arc4random() / ARC4RANDOM_MAX);
    CGFloat b = ((double)arc4random() / ARC4RANDOM_MAX);
    CGFloat a = ((double)arc4random() / ARC4RANDOM_MAX);
    a = 1.0f;
    *color1 = [UIColor colorWithRed:r green:g blue:b alpha:a];

    CGFloat colorSimilarity = GAME_DIFFICULTY / (CGFloat)_level;
    colorSimilarity = 0.4f/log(2+(_level/2));
    if (a * (1+colorSimilarity) > 1.0) a *= (1-colorSimilarity);
    else a *= (1+colorSimilarity);
  
    *color2 = [UIColor colorWithRed:r green:g blue:b alpha:a];
    
    // randomly swap to colors
    if (arc4random()%2 == 0) {
        UIColor *tmp = *color1;
        *color1 = *color2;
        *color2 = tmp;
    }
}

- (NSUInteger) getLevel {
    return _level;
}

- (NSTimeInterval) getRealStartTime {
    return _startTime;
}

@end
