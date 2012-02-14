//
//  AboutMenuVC.m
//  Easter Show
//
//  Created by Richard Lee on 14/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AboutMenuVC.h"
#import "BasicInfoVC.h"

@implementation AboutMenuVC


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


- (IBAction)basicInfoButtonClicked:(id)sender {

	BasicInfoVC *basicInfoVC = [[BasicInfoVC alloc] initWithNibName:@"BasicInfoVC" bundle:nil];
	
	// Pass the selected object to the new view controller.
	[self.navigationController pushViewController:basicInfoVC animated:YES];
	[basicInfoVC release];
}


- (IBAction)ticketPricesButtonClicked:(id)sender {

	BasicInfoVC *basicInfoVC = [[BasicInfoVC alloc] initWithNibName:@"BasicInfoVC" bundle:nil];
	
	// Pass the selected object to the new view controller.
	[self.navigationController pushViewController:basicInfoVC animated:YES];
	[basicInfoVC release];
}


- (IBAction)transportInfoButtonClicked:(id)sender {

	BasicInfoVC *basicInfoVC = [[BasicInfoVC alloc] initWithNibName:@"BasicInfoVC" bundle:nil];
	
	// Pass the selected object to the new view controller.
	[self.navigationController pushViewController:basicInfoVC animated:YES];
	[basicInfoVC release];
}


- (IBAction)parkingButtonClicked:(id)sender {

	BasicInfoVC *basicInfoVC = [[BasicInfoVC alloc] initWithNibName:@"BasicInfoVC" bundle:nil];
	
	// Pass the selected object to the new view controller.
	[self.navigationController pushViewController:basicInfoVC animated:YES];
	[basicInfoVC release];
}


- (IBAction)generalSafetyButtonClicked:(id)sender {

	BasicInfoVC *basicInfoVC = [[BasicInfoVC alloc] initWithNibName:@"BasicInfoVC" bundle:nil];
	
	// Pass the selected object to the new view controller.
	[self.navigationController pushViewController:basicInfoVC animated:YES];
	[basicInfoVC release];
}


- (IBAction)partnersButtonClicked:(id)sender {

	BasicInfoVC *basicInfoVC = [[BasicInfoVC alloc] initWithNibName:@"BasicInfoVC" bundle:nil];
	
	// Pass the selected object to the new view controller.
	[self.navigationController pushViewController:basicInfoVC animated:YES];
	[basicInfoVC release];
}


- (IBAction)contactUsButtonClicked:(id)sender {

	BasicInfoVC *basicInfoVC = [[BasicInfoVC alloc] initWithNibName:@"BasicInfoVC" bundle:nil];
	
	// Pass the selected object to the new view controller.
	[self.navigationController pushViewController:basicInfoVC animated:YES];
	[basicInfoVC release];
}


@end