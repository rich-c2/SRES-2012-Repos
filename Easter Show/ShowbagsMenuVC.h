//
//  ShowbagsMenuVC.h
//  SRES
//
//  Created by Richard Lee on 15/02/11.
//  Copyright 2011 C2 Media Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "ImageDownload.h"

@class SRESAppDelegate;
@class Showbag;
@class ShowbagsTableCell;

@interface ShowbagsMenuVC : UIViewController <NSXMLParserDelegate, ImageDownloadDelegate> {

	SRESAppDelegate *appDelegate;
	
	UIActivityIndicatorView *loadingSpinner;
	
	Reachability *reach;
	BOOL internetConnectionPresent;
	
	BOOL viewLoaded;
	
	UIView *loadingView;
	
	NSMutableString *currentAttribute;
	
	NSString *idString;
	NSMutableString *titleString;
	NSMutableString *descriptionString;
	NSMutableString *imageURLString;
	NSMutableString *thumbURLString;
	NSMutableString *rrpString;
	NSMutableString *priceString;
	NSMutableString *versionString;
	
	UIButton *cokeOfferButton;
	
	UITableView *menuTable;
	NSMutableArray *showbags;
	NSMutableArray *downloads;
	
	ShowbagsTableCell *loadCell;
	
	UIButton *filterButton1;
	UIButton *filterButton2;
	UIButton *filterButton3;
	UIButton *selectedFilterButton;
	
	NSArray *priceRanges;
	
	CGFloat minPrice;
	CGFloat maxPrice;
	
	BOOL addingShowbag;
	BOOL updatingShowbag;
	
	NSInteger currentID;
	NSXMLParser	*rssParser;
	NSAutoreleasePool *pool;
	BOOL cancelThread;
	Showbag *tempShowbag;
	NSMutableData *receivedData;
	CGFloat totalFileSize;
}

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingSpinner;

@property (assign) BOOL internetConnectionPresent;

@property (assign) BOOL viewLoaded;

@property (nonatomic, retain) IBOutlet UIView *loadingView;

@property (nonatomic, retain) NSString *idString;
@property (nonatomic, retain) NSMutableString *titleString;
@property (nonatomic, retain) NSMutableString *descriptionString;
@property (nonatomic, retain) NSMutableString *imageURLString;
@property (nonatomic, retain) NSMutableString *thumbURLString;
@property (nonatomic, retain) NSMutableString *rrpString;
@property (nonatomic, retain) NSMutableString *priceString;
@property (nonatomic, retain) NSMutableString *versionString;

@property (nonatomic, retain) IBOutlet UIButton *cokeOfferButton;

@property (nonatomic, retain) IBOutlet UITableView *menuTable;
@property (nonatomic, retain) NSMutableArray *showbags;

@property (nonatomic, retain) IBOutlet ShowbagsTableCell *loadCell;

@property (nonatomic, retain) NSArray *priceRanges;

@property (nonatomic, retain) IBOutlet UIButton *filterButton1;
@property (nonatomic, retain) IBOutlet UIButton *filterButton2;
@property (nonatomic, retain) IBOutlet UIButton *filterButton3;
@property (nonatomic, retain) UIButton *selectedFilterButton;

@property (nonatomic, retain) NSXMLParser *rssParser;
@property (nonatomic, retain) NSMutableString *currentAttribute;
@property (assign) BOOL cancelThread;
@property (nonatomic, retain) Showbag *tempShowbag;

@property (nonatomic, retain) NSMutableArray *downloads;

- (void)retrieveXML;
- (void)loadXMLAtURL:(NSString *)_urlString;
- (void)filterShowbags:(id)sender;
- (void)initPriceRanges;
- (NSInteger)getIndexOfItemWithID:(NSInteger)_showbagID;
- (Showbag *)getShowbagWithID:(NSInteger)_showbagID;
- (void)setupNavBar;
- (void)disableDownloads;

@end
