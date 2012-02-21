//
//  ParkingVC.h
//  Easter Show
//
//  Created by Richard Lee on 21/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParkingVC : UIViewController {
	
	UIScrollView *contentScrollView;
}

@property (nonatomic, retain) IBOutlet UIScrollView *contentScrollView;

- (IBAction)goBack:(id)sender;

@end
