//
//  MoreVC.m
//  Easter Show
//
//  Created by Richard Lee on 10/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MoreVC.h"
#import "CustomTabBarItem.h"
#import "ShowbagsMenuVC.h"
#import "FoodMenuVC.h"
#import "OffersMenuVC.h"
#import "CarnivalMenuVC.h"
#import "ShoppingMenuVC.h"
#import "AboutMenuVC.h"

@implementation MoreVC

@synthesize managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
		CustomTabBarItem *tabItem = [[CustomTabBarItem alloc] initWithTitle:@"" image:nil tag:0];
        
        tabItem.customHighlightedImage = [UIImage imageNamed:@"more-tab-button-on.png"];
        tabItem.customStdImage = [UIImage imageNamed:@"more-tab-button.png"];
        self.tabBarItem = tabItem;
        [tabItem release];
        tabItem = nil;
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

- (void)viewDidLoad {
	
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	// Hide navigation bar
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	self.managedObjectContext = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)dealloc {
	
	[managedObjectContext release];
	
    [super dealloc];
}


- (IBAction)showbagsButtonClicked:(id)sender {

	ShowbagsMenuVC *showbagsMenuVC = [[ShowbagsMenuVC alloc] initWithNibName:@"ShowbagsMenuVC" bundle:nil];
	[showbagsMenuVC setManagedObjectContext:self.managedObjectContext];
	
	[self.navigationController pushViewController:showbagsMenuVC animated:YES];
	[showbagsMenuVC release];
}


- (IBAction)carnivalButtonClicked:(id)sender {

	CarnivalMenuVC *carnivalMenuVC = [[CarnivalMenuVC alloc] initWithNibName:@"CarnivalMenuVC" bundle:nil];
	[carnivalMenuVC setManagedObjectContext:self.managedObjectContext];
	
	[self.navigationController pushViewController:carnivalMenuVC animated:YES];
	[carnivalMenuVC release];
}


- (IBAction)foodButtonClicked:(id)sender {

	FoodMenuVC *foodMenuVC = [[FoodMenuVC alloc] initWithNibName:@"FoodMenuVC" bundle:nil];
	[foodMenuVC setManagedObjectContext:self.managedObjectContext];
	
	[self.navigationController pushViewController:foodMenuVC animated:YES];
	[foodMenuVC release];
}


- (IBAction)shoppingButtonClicked:(id)sender {

	ShoppingMenuVC *shoppingMenuVC = [[ShoppingMenuVC alloc] initWithNibName:@"ShoppingMenuVC" bundle:nil];
	[shoppingMenuVC setManagedObjectContext:self.managedObjectContext];
	
	[self.navigationController pushViewController:shoppingMenuVC animated:YES];
	[shoppingMenuVC release];
}


- (IBAction)aboutButtonClicked:(id)sender {

	AboutMenuVC *aboutMenuVC = [[AboutMenuVC alloc] initWithNibName:@"AboutMenuVC" bundle:nil];
	
	// Pass the selected object to the new view controller.
	[self.navigationController pushViewController:aboutMenuVC animated:YES];
	[aboutMenuVC release];
}


@end
