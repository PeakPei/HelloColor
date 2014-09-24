//
//  GameScene.m
//  HelloColor
//
//  Created by Jeff on 9/19/14.
//  Copyright (c) 2014 Jeff. All rights reserved.
//

#import "GameScene.h"
#import "ButtonNode.h"
#import "ViewController.h"
#import "gameBoardNode.h"

#import "ProgressTimerNode.h"

#define GAME_TIME 60
#define CYCLES_PER_SECOND (1.0f/GAME_TIME)

@implementation GameScene {
    SKTextureAtlas *_atlas;
    NSMutableDictionary *_gameData; // or NSDictionary
 
    SKSpriteNode *_logo;
    ButtonNode *_playButton;
    ButtonNode *_scoreButton;
    ButtonNode *_muteButton;
    ButtonNode *_rateButton;
    ButtonNode *_shareButton;
    ButtonNode *_infoButton;
    
    GameBoardNode *_gameboardNode;
    BOOL _isGameStoped;
    
    SKLabelNode *_levelLabel;
    SKLabelNode *_timerLabel;
    NSInteger _timerCounter;
    NSTimer *_timer;
    
    ProgressTimerNode *_progressTimerNode;
    
    SKSpriteNode *_restartButton;
}

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.backgroundColor = [SKColor colorWithRed:0 green:0 blue:0 alpha:1.0];

        _atlas = [SKTextureAtlas atlasNamed:@"sprite"];
        
        // plist of game data
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"GameData" ofType:@"plist"];
        NSMutableDictionary *rootData = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        
        if ([[rootData objectForKey:@"enable-ad"] boolValue]) { // enable ad
            if(size.height == 480) { // 3.5 inch
                _gameData = [rootData objectForKey:@"iphone-3.5-with-ad"];
                
            } else if (size.height == 568) { // 4 inch
                _gameData = [rootData objectForKey:@"iphone-4.3-with-ad"];
            }
        } else { // disenable ad
            if(size.height == 480) { // 3.5 inch
                _gameData = [rootData objectForKey:@"iphone-3.5-non-ad"];
                
            } else if (size.height == 568) { // 4 inch
                _gameData = [rootData objectForKey:@"iphone-4.3-non-ad"];
            }
        }
        
        if (_gameData) {
            // Background
            NSString *backgourdTextureName = [_gameData objectForKey:@"background-texture"];
            SKSpriteNode *background = [SKSpriteNode spriteNodeWithTexture:[_atlas textureNamed:backgourdTextureName]];
            
            if (background) {
                background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
                [self addChild:background];
            }
            
            // Level background
            SKSpriteNode *levelBackground = [SKSpriteNode spriteNodeWithTexture:[_atlas textureNamed:@"level-background"]];
            levelBackground.name = @"levelBackground";
            CGFloat levelBgY = [[_gameData objectForKey:@"level-bg-Y"] floatValue];
            levelBackground.position = CGPointMake(CGRectGetMidX(self.frame), levelBgY);
            [self addChild:levelBackground];
            
            // Gameboard
            SKSpriteNode *gameBoard = [SKSpriteNode spriteNodeWithTexture:[_atlas textureNamed:@"gameboard"]];
            gameBoard.name = @"gameBoard";
            CGFloat gameboardY = [[_gameData objectForKey:@"gameboard-Y"] floatValue];
            gameBoard.position = CGPointMake(CGRectGetMidX(self.frame), gameboardY);
            [self addChild:gameBoard];
            
            // Logo
            _logo = [SKSpriteNode spriteNodeWithTexture:[_atlas textureNamed:@"text-logo"]];
            _logo.name = @"logo";
            CGFloat logoY = [[_gameData objectForKey:@"logo-Y"] floatValue];
            _logo.position = CGPointMake(CGRectGetMidX(self.frame), logoY);
            [self addChild:_logo];
            [_logo runAction:
             [SKAction repeatActionForever:
              [SKAction sequence:@[[SKAction moveByX:0 y:-5 duration:0.3],[SKAction moveByX:0 y:5 duration:0.3]]]
              ]
             ];
            
            // Gameboard Buttons
            CGFloat boardButtonY = [[_gameData objectForKey:@"buttons-gameboard-Y"] floatValue];
            
            // SOLVE: capturing self strongly in this block is likely to lead to a retain cycle
            __weak typeof(self) weakSelf = self;
            
            // Play Button
            SKTexture *playButtonDefault = [_atlas textureNamed:@"button-play-up"];
            SKTexture *playButtonPressed = [_atlas textureNamed:@"button-play-down"];
            _playButton = [[ButtonNode alloc] initWithDefaultTexture:playButtonDefault andTouchedTexture:playButtonPressed];
            _playButton.name = @"playButton";
            CGFloat playButtonX = [[_gameData objectForKey:@"button-play-X"] floatValue];
            _playButton.position = CGPointMake(playButtonX, boardButtonY);
            [_playButton setMethod: ^ (void) { [weakSelf playButtonPressed]; } ];
            [self addChild:_playButton];
            
            // Score Button
            SKTexture *scoreButtonDefault = [_atlas textureNamed:@"button-score-up"];
            SKTexture *scoreButtonPressed = [_atlas textureNamed:@"button-score-down"];
            _scoreButton = [[ButtonNode alloc] initWithDefaultTexture:scoreButtonDefault andTouchedTexture:scoreButtonPressed];
            _scoreButton.name = @"scoreButton";
            CGFloat scoreButtonX = [[_gameData objectForKey:@"button-score-X"] floatValue];
            _scoreButton.position = CGPointMake(scoreButtonX, boardButtonY);
            [self addChild:_scoreButton];
            
            
            // Copyright
            SKSpriteNode *textCopyright = [SKSpriteNode spriteNodeWithTexture:[_atlas textureNamed:@"text-copyright"]];
            textCopyright.name = @"textCopyright";
            CGFloat copyrightY = [[_gameData objectForKey:@"copyright-Y"] floatValue];
            NSLog(@"~~~~~~~%f~~~~~~~", copyrightY);
            textCopyright.position = CGPointMake(CGRectGetMidX(self.frame), copyrightY);
            [self addChild:textCopyright];
            
            // Other buttons
            CGFloat buttonsY = [[_gameData  objectForKey:@"buttons-Y"] floatValue];
            
            // Mute Button
            SKTexture *muteButtonDefault = [_atlas textureNamed:@"button-mute-up"];
            SKTexture *muteButtonTouched = [_atlas textureNamed:@"button-mute-down"];
            _muteButton = [[ButtonNode alloc] initWithDefaultTexture:muteButtonDefault andTouchedTexture:muteButtonTouched];
            _muteButton.name = @"muteButton";
            CGFloat muteButtonX = [[_gameData objectForKey:@"button-mute-X"] floatValue];
            _muteButton.position = CGPointMake(muteButtonX, buttonsY);
            [_muteButton setMethod: ^ (void) {
                ViewController * viewController = (ViewController *) weakSelf.view.window.rootViewController;
                [viewController switchSound]; }];
            [self addChild:_muteButton];
            
            // Rate Button
            SKTexture *rateButtonDefault = [_atlas textureNamed:@"button-rate-up"];
            SKTexture *rateButtonTouched = [_atlas textureNamed:@"button-rate-down"];
            _rateButton = [[ButtonNode alloc] initWithDefaultTexture:rateButtonDefault andTouchedTexture:rateButtonTouched];
            _rateButton.name = @"rateButton";
            CGFloat rateButtonX = [[_gameData objectForKey:@"button-rate-X"] floatValue];
            _rateButton.position = CGPointMake(rateButtonX, buttonsY);
            [_rateButton setMethod: ^ (void) {}];
            [self addChild:_rateButton];
            
            // Share Button
            SKTexture *shareButtonDefault = [_atlas textureNamed:@"button-share-up"];
            SKTexture *shareButtonTouched = [_atlas textureNamed:@"button-share-down"];
            _shareButton = [[ButtonNode alloc] initWithDefaultTexture:shareButtonDefault andTouchedTexture:shareButtonTouched];
            _shareButton.name = @"shareButton";
            CGFloat shareButtonX = [[_gameData objectForKey:@"button-share-X"] floatValue];
            _shareButton.position = CGPointMake(shareButtonX, buttonsY);
            [_shareButton setMethod: ^ (void) {}];
            [self addChild:_shareButton];
            
            // Info Button
            SKTexture *infoButtonDefault = [_atlas textureNamed:@"button-info-up"];
            SKTexture *infoButtonTouched = [_atlas textureNamed:@"button-info-down"];
            _infoButton = [[ButtonNode alloc] initWithDefaultTexture:infoButtonDefault andTouchedTexture:infoButtonTouched];
            _infoButton.name = @"infoButton";
            CGFloat infoButtonX = [[_gameData objectForKey:@"button-info-X"] floatValue];
            _infoButton.position = CGPointMake(infoButtonX, buttonsY);
            [_infoButton setMethod: ^ (void) {}];
            [self addChild:_infoButton];
            
            // Level text
            _levelLabel = [SKLabelNode labelNodeWithFontNamed:@"Minercraftory"];
            // NSLog(@"Fonts:%@", [UIFont familyNames]);
            _levelLabel.name = @"levelLabel";
            _levelLabel.text = @"00";
            _levelLabel.fontSize = 37;
            _levelLabel.fontColor = [SKColor whiteColor];
            _levelLabel.xScale = 0.85;
            CGFloat levelTextX = [[_gameData objectForKey:@"level-text-X"] floatValue];
            CGFloat levelTextY = [[_gameData objectForKey:@"level-text-Y"] floatValue];
            _levelLabel.position = CGPointMake(levelTextX, levelTextY);
            [self addChild:_levelLabel];
            
            // Count down progress
            _progressTimerNode = [[ProgressTimerNode alloc] initWithMaskingImageName:@"countdownCircle"];
            _progressTimerNode.name = @"progressTimerNode";
            _progressTimerNode.userInteractionEnabled = NO; // for restart touches;
            CGFloat progressTimerNodeX = [[_gameData objectForKey:@"progress-timer-X"] floatValue];
            CGFloat progressTimerNodeY = [[_gameData objectForKey:@"progress-timer-Y"] floatValue];
            _progressTimerNode.position = CGPointMake(progressTimerNodeX, progressTimerNodeY);
            [self addChild:_progressTimerNode];
            _progressTimerNode.hidden = YES;
            
            
            // Count down text
            _timerLabel = [SKLabelNode labelNodeWithFontNamed:@"Nokian"];
            _timerLabel.name = @"timerLabel";
            //_timerLabel.userInteractionEnabled = NO; // for restart touches;
            _timerLabel.text = [NSString stringWithFormat:@"%d", GAME_TIME];
            _timerLabel.fontSize = 28;
            _timerLabel.fontColor = [SKColor whiteColor];
            CGFloat timerTextX = [[_gameData objectForKey:@"timer-text-X"] floatValue];
            CGFloat timerTextY = [[_gameData objectForKey:@"timer-text-Y"] floatValue];
            _timerLabel.position = CGPointMake(timerTextX, timerTextY);
            [self addChild:_timerLabel];
            
            _isGameStoped = YES;
        
        }

    }
    return self;
}

- (void)playButtonPressed {
    [_logo setHidden:YES];
    [_playButton setHidden:YES];
    [_scoreButton setHidden:YES];
    [self startNewGame];
    
}

- (void) startNewGame {
    _isGameStoped = NO;
    
    if (!_gameboardNode) {
        CGFloat gameboardWith = [[_gameData objectForKey:@"gameboard-Node-width"] floatValue];
        CGFloat gameboardWHeight = [[_gameData objectForKey:@"gameboard-Node-height"] floatValue];
        CGFloat gameboardNodeX = [[_gameData objectForKey:@"gameboard-Node-X"] floatValue];
        CGFloat gameboardNodeY = [[_gameData objectForKey:@"gameboard-Node-Y"] floatValue];
        _gameboardNode = [[GameBoardNode alloc] initWithGameBoardSize:CGSizeMake(gameboardWith, gameboardWHeight)];
        _gameboardNode.position = CGPointMake(gameboardNodeX, gameboardNodeY);
        [self addChild:_gameboardNode];
    }
    
    [_gameboardNode startNewGame];
    
    _levelLabel.text = @"00";
    
    [self setGameStartTime]; // wait for the countdown frames animated
}

- (void) setGameOver {
    _isGameStoped = YES;
    [_timer invalidate];
    [_gameboardNode setGameOver];
}

- (void) setGameStartTime {
    [_timer invalidate];
    _timerCounter = GAME_TIME;
    _timerLabel.text = [NSString stringWithFormat:@"%d", _timerCounter];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerCount) userInfo:nil repeats:YES];
    
    // self.startTime = CACurrentMediaTime(); // for progress
}

- (void) timerCount {
    if ([_gameboardNode isGameReady]) {
        --_timerCounter;
        if (0 <= _timerCounter) {
            if (_timerCounter < 10) {
                _timerLabel.text = [NSString stringWithFormat:@"0%d", _timerCounter];
            } else {
                _timerLabel.text = [NSString stringWithFormat:@"%d", _timerCounter];
            }
        } else
            [self setGameOver];
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [ButtonNode doButtonsActionEnded:self touches:touches withEvent:event];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [ButtonNode doButtonsActionBegan:self touches:touches withEvent:event];

    if (!_isGameStoped) {
        [_gameboardNode doGameboardActionBegan:self touches:touches];
        
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInNode:self];
        SKNode *node = [self nodeAtPoint:location];
        // NSLog(@"~~~~~touched: %@~~~~~~", node.name);
        for (SKNode *child in [_progressTimerNode children]) {
            if ([node isEqual:child]) {
                [self startNewGame];
                [_progressTimerNode setProgress:0];
            }
        }
    }
}

- (void) updateLevelInfo {
    NSInteger level = [_gameboardNode getLevel];
    if (0 <= level && 9 >= level) {
        _levelLabel.text = [NSString stringWithFormat:@"0%d", level];
    } else {
        _levelLabel.text = [NSString stringWithFormat:@"%d", level];
    }
}

-(void)update:(CFTimeInterval)currentTime {
    [super update:currentTime];
    
    if ([_gameboardNode isGameReady]) {
        [self updateLevelInfo];
        
        CGFloat secondsElapsed = currentTime - [_gameboardNode getRealStartTime];
        CGFloat progress = secondsElapsed / GAME_TIME;
        if (progress > 1) {
            [_progressTimerNode setProgress:1];
        } else {
            [_progressTimerNode setProgress:progress];
        }
    }
}

@end
