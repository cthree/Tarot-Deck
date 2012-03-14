//
//  C3WFlipsideViewController.h
//  UtilityTest
//
//  Created by Erik Petersen on 3/14/12.
//  Copyright (c) 2012 4MMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class C3WFlipsideViewController;

@protocol C3WFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(C3WFlipsideViewController *)controller;
@end

@interface C3WFlipsideViewController : UIViewController

@property (weak, nonatomic) id <C3WFlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
