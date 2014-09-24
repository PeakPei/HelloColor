//
//  Info.m
//  HelloColor
//
//  Created by Jeff on 9/13/14.
//  Copyright (c) 2014 Jeff. All rights reserved.
//

#import "InfoScene.h"
#import "GameScene.h"

@implementation InfoScene {
    SKLabelNode *_homeLabel;
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        NSLog(@"~~~~Info Scene~~~~");
        
        /* Setup your scene here */
        self.backgroundColor = [SKColor colorWithRed:57.0f/255.0f green:181.0f/255.0f blue:74.0f/255.0f alpha:1.0];
        
        _homeLabel = [SKLabelNode labelNodeWithFontNamed:@"Nokian"];
        _homeLabel.text = @"< HOME";
        _homeLabel.fontSize = 16;
        _homeLabel.fontColor = [SKColor whiteColor];
        _homeLabel.position = CGPointMake(50, CGRectGetMaxY(self.frame)-30);
        _homeLabel.userInteractionEnabled = NO;
        [self addChild:_homeLabel];
        
        // intro
        SKLabelNode *introLabel = [SKLabelNode labelNodeWithFontNamed:@"ArialHebrew"];
        introLabel.text = @"This is a simple game for CPSC682 assignment.";
        introLabel.fontSize = 14;
        introLabel.fontColor = [SKColor greenColor];
        introLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)-100);
        [self addChild:introLabel];
        
        // Author
        SKLabelNode *guideLabel = [SKLabelNode labelNodeWithFontNamed:@"Minercraftory"];
        guideLabel.text = @"How to play:";
        guideLabel.fontSize = 16;
        guideLabel.fontColor = [SKColor whiteColor];
        guideLabel.position = CGPointMake(CGRectGetMidX(self.frame), 320);
        [self addChild:guideLabel];
        
        // guide node
        SKTextureAtlas *_atlas = [SKTextureAtlas atlasNamed:@"sprite"];
        SKSpriteNode *guide = [SKSpriteNode spriteNodeWithTexture:[_atlas textureNamed:@"text-guide"]];
        guide.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame)+50);
        [guide runAction:
         [SKAction repeatActionForever:
          [SKAction sequence:@[[SKAction moveByX:0 y:-5 duration:0.3],[SKAction moveByX:0 y:5 duration:0.3]]]
          ]
         ];
        [self addChild:guide];
        
        // Author
        SKLabelNode *authorLabel = [SKLabelNode labelNodeWithFontNamed:@"Minercraftory"];
        authorLabel.text = @"Author: Jeff";
        authorLabel.fontSize = 14;
        authorLabel.fontColor = [SKColor whiteColor];
        authorLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)-315);
        [self addChild:authorLabel];
        
        // Website
        SKLabelNode *webLabel = [SKLabelNode labelNodeWithFontNamed:@"Minercraftory"];
        webLabel.text = @"Website: jeffw.us";
        webLabel.fontSize = 14;
        webLabel.fontColor = [SKColor whiteColor];
        webLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)-335);
        [self addChild:webLabel];
        
        SKLabelNode *acknowledgementLabel = [SKLabelNode labelNodeWithFontNamed:@"headline"];
        acknowledgementLabel.text = @"Acknowledgement:";
        acknowledgementLabel.fontSize = 16;
        acknowledgementLabel.fontColor = [SKColor colorWithRed:10/255.0f green:115/255.0f blue:184/225.0f alpha:1.0];
        acknowledgementLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)-365);
        [self addChild:acknowledgementLabel];
        
        SKLabelNode *namesLabel = [SKLabelNode labelNodeWithFontNamed:@"ArialHebrew"];
        namesLabel.text = @"Dr.Pargas, TA.Joshua";
        namesLabel.fontSize = 16;
        namesLabel.fontColor = [SKColor colorWithRed:10/255.0f green:115/255.0f blue:184/225.0f alpha:1.0];
        namesLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)-385);
        [self addChild:namesLabel];
        
    }
    return self;
}

-(void)didMoveToView:(SKView *)view {
    [super didMoveToView:view];
    
/*
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(100, 100, 110, 300)];
   //  webView.delegate = self;
    NSURL *url = [NSURL URLWithString:@"http://www.test.de"];
                  NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
                  [webView loadRequest:request];
                  [self.view addSubview:webView];*/
}

-(void) homeLabelPressed {
    SKTransition * reveal = [SKTransition fadeWithDuration: 0.5];
    SKScene * homeScene = [[GameScene alloc] initWithSize:self.size];
    [self.view presentScene:homeScene transition:reveal];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    if ([node isEqual:_homeLabel]) {        
        // NSLog(@"~~~~~touched: %@~~~~~~", node.name);
        [self homeLabelPressed];
    }
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
}



@end
