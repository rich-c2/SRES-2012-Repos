//
//  AnnouncementVC.h
//  IngredientsXML
//
//  Created by Richard Lee on 9/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AnnouncementDelegate

- (void)announcementCloseButtonClicked;

@end

@interface AnnouncementVC : UIViewController {

	id <AnnouncementDelegate> delegate;
	UIButton *doneButton;
	NSString *announcementText;
	UITextView *announcementTextView;
	UIScrollView *contentScrollView;
	BOOL lockDown;
}

@property (nonatomic, retain) id <AnnouncementDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIButton *doneButton;
@property (nonatomic, retain) NSString *announcementText;
@property (nonatomic, retain) IBOutlet UITextView *announcementTextView;
@property (nonatomic, retain) IBOutlet UIScrollView *contentScrollView;
@property (assign) BOOL lockDown;

- (void)close:(id)sender;
- (void)resizeTextView:(UITextView *)_textView;

@end
