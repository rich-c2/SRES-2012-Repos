//
//  CustomTabBarItem.m
//  CustomTabBar
//
//  Created by Richard Lee on 27/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomTabBarItem.h"


@implementation CustomTabBarItem

@synthesize customHighlightedImage;
@synthesize customStdImage;

- (void) dealloc
{
    [customHighlightedImage release]; customHighlightedImage=nil;
    [customStdImage release]; customStdImage=nil;   
    [super dealloc];
}

-(UIImage *) selectedImage
{
    return self.customHighlightedImage;
}

-(UIImage *) unselectedImage
{
    return self.customStdImage;
}

@end
