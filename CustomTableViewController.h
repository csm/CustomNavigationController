//
//  CustomTableViewController.h
//  WOD
//
//  Created by Casey Marshall on 2/4/11.
//  Copyright 2011 Modal Domains. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavigationController.h"

@interface CustomTableViewController : UITableViewController
{
	CustomNavigationController *customNavigationController;
}

@property (readonly, nonatomic) CustomNavigationController *customNavigationController;

@end
