//
//  MoreVC.m
//  Easter Show
//
//  Created by Richard Lee on 10/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MoreVC.h"
#import "ShowbagsMenuVC.h"
#import "FoodMenuVC.h"
#import "OffersMenuVC.h"

@implementation MoreVC

@synthesize menuArray, menuTable; // cellLabelImageNames, loadCell;
@synthesize managedObjectContext;

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

- (void)viewDidLoad {
	
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	// Add button to Navigation Title 
	UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 66.0, 22.0)];
	[image setBackgroundColor:[UIColor clearColor]];
	[image setImage:[UIImage imageNamed:@"screenTitle-more.png"]];
	
	self.navigationItem.titleView = image;
	[image release];
	
	NSArray *tempArray = [[NSArray alloc] initWithObjects:@"Showbags", @"Shopping", @"Food", @"Carnival", @"About", nil];
	
	self.menuArray = tempArray;
	[tempArray release];
	
	/*self.cellLabelImageNames = [[NSArray alloc] initWithObjects:@"moreTableCellLabel-showbags.png", @"moreTableCellLabel-shopping.png", 
								@"moreTableCellLabel-food.png", @"moreTableCellLabel-carnival.png", @"moreTableCellLabel-offers.png", nil];*/
	
	// Clear coloured cell separators
	[self.menuTable setSeparatorColor:[UIColor clearColor]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	//self.cellLabelImageNames = nil;
	self.menuArray = nil;
	self.menuTable = nil;
	//self.loadCell = nil;
	self.managedObjectContext = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)dealloc {
	
	//[cellLabelImageNames release];
	[menuArray release];
	[menuTable release];
	//[loadCell release];
	
	[managedObjectContext release];
	
    [super dealloc];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.menuArray count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	//MoreTableCell *cell = (MoreTableCell *)[tableView dequeueReusableCellWithIdentifier:[MoreTableCell reuseIdentifier]];
	
	static NSString *kCellID = @"cellID";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
	
    if (cell == nil) {
		
		/*
		[[NSBundle mainBundle] loadNibNamed:@"MoreTableCell" owner:self options:nil];
        cell = loadCell;
        self.loadCell = nil;*/
		
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID] autorelease];
    }
    
    // Configure the cell...
	/*cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	NSString *imageFilename = [self.cellLabelImageNames objectAtIndex:[indexPath row]];
	NSArray *stringParts = [imageFilename componentsSeparatedByString:@"."];
	NSString *selectedImageFilename = [NSString stringWithFormat:@"%@-on.%@", [stringParts objectAtIndex:0], [stringParts objectAtIndex:1]];
	
	UIImage *cellImage = [UIImage imageNamed:imageFilename];
	cell.unselectedLabelImage = cellImage;
	
	UIImage *selectedImage = [UIImage imageNamed:selectedImageFilename];
	cell.selectedLabelImage = selectedImage;
	
	cell.labelImage.image = cellImage;
	
	CGRect currFrame = cell.labelImage.frame;
	[cell.labelImage setFrame:CGRectMake(currFrame.origin.x, currFrame.origin.y, cellImage.size.width, cellImage.size.height)];*/
	
	cell.textLabel.text = [self.menuArray objectAtIndex:[indexPath row]];
    
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSString *selectedVC = [self.menuArray objectAtIndex:[indexPath row]];
	
	if ([selectedVC isEqualToString:@"Showbags"]) {
		
		ShowbagsMenuVC *showbagsMenuVC = [[ShowbagsMenuVC alloc] initWithNibName:@"ShowbagsMenuVC" bundle:nil];
		[showbagsMenuVC setManagedObjectContext:self.managedObjectContext];
		
		[self.navigationController pushViewController:showbagsMenuVC animated:YES];
		[showbagsMenuVC release];
	}
	/*else if ([selectedVC isEqualToString:@"Shopping"]) {
		
		ShoppingMenuVC *shoppingMenuVC = [[ShoppingMenuVC alloc] initWithNibName:@"ShoppingMenuVC" bundle:nil];
		[self.navigationController pushViewController:shoppingMenuVC animated:YES];
		[shoppingMenuVC release];
	}
	else if ([selectedVC isEqualToString:@"Carnival"]) {
		
		CarnivalMenuVC *carnivalMenuVC = [[CarnivalMenuVC alloc] initWithNibName:@"CarnivalMenuVC" bundle:nil];
		[self.navigationController pushViewController:carnivalMenuVC animated:YES];
		[carnivalMenuVC release];
	}*/
	else if ([selectedVC isEqualToString:@"Food"]) {
		
		FoodMenuVC *foodMenuVC = [[FoodMenuVC alloc] initWithNibName:@"FoodMenuVC" bundle:nil];
		[foodMenuVC setManagedObjectContext:self.managedObjectContext];
		
		[self.navigationController pushViewController:foodMenuVC animated:YES];
		[foodMenuVC release];
	}
}


@end
