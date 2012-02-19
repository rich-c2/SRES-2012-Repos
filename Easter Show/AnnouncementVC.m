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
@synthesize lockDown;

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
	
	// If the app is in lockDown mode then hide the doneButton
	// so the user cannot proceed beyond this screen
	if (self.lockDown) 
		[self.doneButton setHidden:YES];
		
	// Display the assigned text
	[self.announcementTextView setText:self.announcementText];
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
	self.announcementText = nil;
	self.announcementTextView = nil;
}


- (void)close:(id)sender {

	[self.delegate announcementCloseButtonClicked];
}


- (void)dealloc {
	
	[contentScrollView release];
	[doneButton release];
	[announcementTextView release];
	[announcementText release];
    [super dealloc];
}


@end
