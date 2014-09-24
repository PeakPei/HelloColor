//
//  InfoView.m
//  HelloColor
//
//  Created by Jeff on 9/24/14.
//  Copyright (c) 2014 Jeff. All rights reserved.
//

#import "InfoView.h"

@implementation InfoView


- (void)baseInit {
    [self setBackgroundColor:[UIColor greenColor]];
}

- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"~~~~~~here~~~~~~~~~");
    self = [super initWithFrame:frame];
    if (self) {
        [self baseInit];
    }
    return self;
}

@end
