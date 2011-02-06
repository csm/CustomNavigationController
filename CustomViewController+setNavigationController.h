//
//  CustomViewController+setNavigationController.h
//  WOD
//
//  Created by Casey Marshall on 2/4/11.
//  Copyright 2011 Modal Domains. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomViewController.h"
#import "CustomTableViewController.h"
#import "CustomNavigationController.h"

@interface CustomViewController (setNavigationController)

- (void) setCustomNavigationController: (CustomNavigationController *) c;

@end

@interface CustomTableViewController (setNavigationController)

- (void) setCustomNavigationController: (CustomNavigationController *) c;

@end