//
//  CustomTableViewController.m
//  WOD
//
//  Created by Casey Marshall on 2/4/11.
//  Copyright 2011 Modal Domains. All rights reserved.
//

#import "CustomTableViewController.h"


@implementation CustomTableViewController

@synthesize customNavigationController;

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[customNavigationController release];
    [super dealloc];
}

@end

