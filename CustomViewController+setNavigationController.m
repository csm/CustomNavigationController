//
//  CustomViewController+setNavigationController.m
//  WOD
//
//  Created by Casey Marshall on 2/4/11.
//  Copyright 2011 Modal Domains. All rights reserved.
//

#import "CustomViewController+setNavigationController.h"


@implementation CustomViewController (setNavigationController)

- (void) setCustomNavigationController: (CustomNavigationController *) c
{
	if (customNavigationController != nil)
		[customNavigationController release];
	customNavigationController = c;
	[customNavigationController retain];
}

@end

@implementation CustomTableViewController (setNavigationController)

- (void) setCustomNavigationController: (CustomNavigationController *) c
{
	if (customNavigationController != nil)
		[customNavigationController release];
	customNavigationController = c;
	[customNavigationController retain];
}

@end