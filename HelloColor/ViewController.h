//
//  ViewController.h
//  HelloColor
//

//  Copyright (c) 2014 Jeff. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <iAd/iAd.h>

@interface ViewController : UIViewController <ADBannerViewDelegate>

-(void) turnOffSound;
-(void) turnOnSound;
-(void) switchSound;
-(BOOL) isSound;

@end
