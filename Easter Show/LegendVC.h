//
//  LegendVC.h
//  SRES
//
//  Created by Richard Lee on 3/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LegendVCDelegate

- (void)closeLegendVC;

@end

@interface LegendVC : UIViewController {
	
	id <LegendVCDelegate> delegate;

	UIScrollView *contentScrollView;
	
	UIButton *closeButton;
}

@property (nonatomic, retain) id <LegendVCDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIScrollView *contentScrollView;
@property (nonatomic, retain) IBOutlet UIButton *closeButton;

- (void)adjustScrollViewContentHeight;
- (void)closeView:(id)sender;

@end
