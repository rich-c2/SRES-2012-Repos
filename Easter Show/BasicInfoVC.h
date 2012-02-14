//
//  BasicInfoVC.h
//  Easter Show
//
//  Created by Richard Lee on 14/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BasicInfoVC : UIViewController {

	UIScrollView *contentScrollView;
}

@property (nonatomic, retain) IBOutlet UIScrollView *contentScrollView;

- (IBAction)goBack:(id)sender;

@end
