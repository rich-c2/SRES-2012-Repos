//
//  CustomTabBarItem.h
//  CustomTabBar
//
//  Created by Richard Lee on 27/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CustomTabBarItem : UITabBarItem {
    
	UIImage *customHighlightedImage;
	UIImage *customStdImage;
}

@property (nonatomic, retain) UIImage *customHighlightedImage;
@property (nonatomic, retain) UIImage *customStdImage;

@end
