//
//  LegendVC.m
//  SRES
//
//  Created by Richard Lee on 3/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LegendVC.h"

#define IMAGE_VIEW_TAG 1000

@implementation LegendVC

@synthesize contentScrollView, delegate, closeButton;

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
	
	[self adjustScrollViewContentHeight];
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
}


- (void)adjustScrollViewContentHeight {
	
	CGFloat imageHeight = 696.0;
	
	CGFloat newContentHeight = 21.0 + imageHeight + 60.0;	
	
	[self.contentScrollView setContentSize:CGSizeMake(320.0, newContentHeight)];
}


- (IBAction)closeView:(id)sender {

	[self.delegate closeLegendVC];

}


- (void)dealloc {
    [super dealloc];
}


@end
