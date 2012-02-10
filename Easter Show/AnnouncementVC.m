//
//  AnnouncementVC.m
//  IngredientsXML
//
//  Created by Richard Lee on 9/05/11.
//  Copyright 2011 C2 Media Pty Ltd. All rights reserved.
//

#import "AnnouncementVC.h"


@implementation AnnouncementVC

@synthesize doneButton, delegate, announcementText, announcementTextView;
@synthesize contentScrollView;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	CGFloat minHeight = self.doneButton.frame.origin.y - 10.0;
	
	[self.announcementTextView setFont:[UIFont fontWithName:@"HelveticaNeue" size:15.0]];
	[self.announcementTextView setTextColor:[UIColor whiteColor]];
	[self.announcementTextView setText:self.announcementText];
	
	// Re-size text view
	[self resizeTextView:self.announcementTextView];
	
	// Re-position button if the announcement text is lengthy
	CGFloat textBottomYVal = self.announcementTextView.frame.origin.y + self.announcementTextView.frame.size.height;
	
	if (textBottomYVal > minHeight) {
		
		CGRect newFrame = self.doneButton.frame;
		newFrame.origin.y = self.announcementTextView.frame.origin.y + self.announcementTextView.frame.size.height + 10.0;
		[self.doneButton setFrame:newFrame];
	}
	
	// Re-size scroll view content size
	CGFloat newHeight = self.doneButton.frame.origin.y + self.doneButton.frame.size.height + 10.0;
	CGSize newSize = CGSizeMake(self.contentScrollView.frame.size.width, newHeight);
	[self.contentScrollView setContentSize:newSize];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	self.doneButton = nil;
	self.contentScrollView = nil;
	self.announcementText = nil;
	self.announcementTextView = nil;
}


- (void)close:(id)sender {

	[self.delegate announcementCloseButtonClicked];

}


- (void)resizeTextView:(UITextView *)_textView {
	
	CGRect frame;
	frame = _textView.frame;
	frame.size.height = [_textView contentSize].height;
	_textView.frame = frame;
	
}


- (void)dealloc {
	
	[contentScrollView release];
	[doneButton release];
	[announcementTextView release];
	[announcementText release];
    [super dealloc];
}


@end
