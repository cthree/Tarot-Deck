//
//  C3WFlipsideViewController.m
//  UtilityTest
//
//  Created by Erik Petersen on 3/14/12.
//  Copyright (c) 2012 4MMedia. All rights reserved.
//

#import "C3WFlipsideViewController.h"

@interface C3WFlipsideViewController ()

@end

@implementation C3WFlipsideViewController

@synthesize delegate = _delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

@end
