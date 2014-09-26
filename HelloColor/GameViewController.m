//
//  GameViewController.m
//  HelloColor
//
//  Created by Jeff on 9/19/14.
//  Copyright (c) 2014 Jeff. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"

@import AVFoundation;

@interface GameViewController() {
    bool iadsOnTop;
    bool iadsBannerIsVisible;
    ADBannerView* theBanner;
}
@property (nonatomic) AVAudioPlayer * backgroundMusicPlayer;
@end

@implementation GameViewController {
    NSUserDefaults * _settings;
}

- (void)viewWillLayoutSubviews {
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    
    [super viewWillLayoutSubviews];
    
    
    
    
    
    
    // for iAds
    // plist of game data
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"GameData" ofType:@"plist"];
    NSMutableDictionary *rootData = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    if ([[rootData objectForKey:@"enable-ad"] boolValue])
        [self showThinBanner];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Configure the view.
    //SKView * skView = (SKView *)self.view;
    SKView * skView = (SKView *)self.subviewForGameScene;
    
    if (!skView.scene) {
        _settings = [NSUserDefaults standardUserDefaults];
        if([_settings objectForKey:@"sound"] == nil) {
            [_settings setObject:@"YES" forKey:@"sound"];
        }
    }
    
    NSString * musicPlaySetting = [_settings objectForKey:@"sound"];
    
    NSError *error;
    NSURL * backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"bgm" withExtension:@"m4a"];
    self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
    
    self.backgroundMusicPlayer.numberOfLoops = -1;
    [self.backgroundMusicPlayer prepareToPlay];
    
    if ([musicPlaySetting isEqualToString:@"YES"]) {
        // Add Background Music
        [self.backgroundMusicPlayer play];
    }
    
    skView.showsFPS = NO;
    skView.showsNodeCount = NO;
    
    // Create and configure the scene.
    SKScene * scene = [GameScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];

}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(void) turnOffSound {
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    [self.backgroundMusicPlayer stop];
    [_settings setObject:@"NO" forKey:@"sound"];
}

-(void) turnOnSound {
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:nil];
    [self.backgroundMusicPlayer play];
    [_settings setObject:@"YES" forKey:@"sound"];
}

-(void) switchSound {
    
    NSLog(@"~~~~~switch, isSound:%d~~~~~", [self isSound]);
    if ([self isSound]) {
        [self turnOffSound];
    }else{
        [self turnOnSound];
    }
}

-(BOOL) isSound {
    NSString * musicPlaySetting = [_settings objectForKey:@"sound"];
    if ([musicPlaySetting isEqualToString:@"YES"]){
        return YES;
    }else{
        return NO;
    }
}


// For iAd
- (void) showThinBanner {
    iadsBannerIsVisible = YES;
    theBanner = [[ADBannerView alloc] initWithFrame:CGRectZero];
    [theBanner setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    theBanner.delegate = self;
    
    // put the banner at bottom
    theBanner.frame = CGRectMake(0, self.view.frame.size.height-theBanner.frame.size.height, theBanner.frame.size.width, theBanner.frame.size.height);
    [self.view addSubview:theBanner];
}

// run automatically without you calling them
- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    NSLog(@"Banner has loaded");
    iadsBannerIsVisible = YES;
    [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
    // banner.frame = CGRectMake(0, [CSGameData sharedData].screenSize.height - banner.frame.size.height, banner.frame.size.width, banner.frame.size.height);
    [UIView commitAnimations];
}

// occurs when tapping the ad and it takes over…
- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
    NSLog(@"Banner view is beginning an ad action");
    BOOL shouldExecuteAction = YES; // your app implements this method if (!willLeave && shouldExecuteAction){
    // insert code here to suspend any services that might conflict with the advertisement, for example, you might pause the game with an NSNotification like this...
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PauseScene" object:nil]; //optional
    return shouldExecuteAction;
}

// runs when the banner is done being fullscreen…
-(void) bannerViewActionDidFinish:(ADBannerView *)banner {
    NSLog(@"banner is done being fullscreen");
    //Unpause the game if you paused it previously.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UnPauseScene" object:nil]; //optional
}

// runs when the app failed to receive an ad. If the banner is visible (the placeholder for the ad) it animate out of the way. In this case, it moves down off-frame.
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
/*    if (iadsBannerIsVisible == YES) {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        // Assumes the banner view is placed at the bottom of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, banner.frame.size.height);
        [UIView commitAnimations];
        iadsBannerIsVisible = NO;
    
        NSLog(@"banner unavailable");
    }*/
}

// need to create an NSNotification to listen out for the purchase, then call this…
-(void) removeAds {
    if (iadsBannerIsVisible == YES)  {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        // Assumes the banner view is placed at the bottom of the screen.
        theBanner.frame = CGRectOffset(theBanner.frame, 0, theBanner.frame.size.height);
        [UIView commitAnimations];
        iadsBannerIsVisible = NO;
        NSLog(@"hiding banner");
        [theBanner cancelBannerViewAction];
    }
}

@end
