//
//  TicketPricesVC.m
//  Easter Show
//
//  Created by Richard Lee on 21/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TicketPricesVC.h"

#define LAST_TEXT_VIEW_TAG 7777

@implementation TicketPricesVC

@synthesize contentScrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	for (UIView *subview in self.contentScrollView.subviews) {
		
		if ([subview isKindOfClass:[UITextView class]]) {
			UITextView *tView = (UITextView *)subview;
			tView.contentInset = UIEdgeInsetsMake(0,-8,0,0);
		}
	}
	
	// Content size for the scroll view
	CGRect svFrame = self.contentScrollView.frame;
	UITextView *tView = (UITextView *)[self.view viewWithTag:LAST_TEXT_VIEW_TAG];
	CGFloat sizeHeight = tView.frame.origin.y + tView.frame.size.height;
	
	[self.contentScrollView setContentSize:CGSizeMake(svFrame.size.width, sizeHeight)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


// 'Pop' this VC off the stack (go back one screen)
- (IBAction)goBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)dealloc {
	
	[contentScrollView release];
	
	[super dealloc];
}


@end
