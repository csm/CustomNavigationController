//
//  CustomNavigationController.h
//  WOD
//
//  Created by Casey Marshall on 2/3/11.
//  Copyright 2011 Modal Domains. All rights reserved.
//

#import <UIKit/UIKit.h>

// This class is a reimplementation of UINavigationController, reimplemented
// here so it works better when embedded in another view controller.

@class CustomNavigationController;
@protocol CustomNavigationControllerDelegate <NSObject>

- (void) navigationController: (CustomNavigationController *) controller
	   willShowViewController: (UIViewController *) viewController
					 animated: (BOOL) animated;

- (void) navigationController: (CustomNavigationController *) controller
		didShowViewController: (UIViewController *) viewController
					 animated: (BOOL) animated;

@end


typedef enum CustomNavigationControllerAnimation
{
	// No animation.
	CustomNavigationControllerAnimationNone   = 0,
	
	// The new view slides in from the top.
	CustomNavigationControllerAnimationTop    = 1,
	
	// The new view slides in from the bottom.
	CustomNavigationControllerAnimationBottom = 2,
	
	// The new view slides in from the left.
	CustomNavigationControllerAnimationLeft   = 3,
	
	// The new view slides in from the right.
	CustomNavigationControllerAnimationRight  = 4,
	
	// The default animation for the transition.
	CustomNavigationControllerAnimationDefault = 5
} CustomNavigationControllerAnimation;

@interface CustomNavigationController : UIViewController <UINavigationBarDelegate>
{
	UINavigationBar *navigationBar;
	UIView *contentView;
	
	NSMutableArray *viewControllers;
	id<CustomNavigationControllerDelegate> delegate;
}

@property (retain, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (retain, nonatomic) IBOutlet id<CustomNavigationControllerDelegate> delegate;

- (id) initWithRootViewController: (UIViewController *) viewController;

- (void) setViewControllers: (NSArray *) vc
			  withAnimation: (CustomNavigationControllerAnimation) animation;

- (void) setViewControllers:(NSArray *)vc animated: (BOOL) animated;

- (void) pushViewController: (UIViewController *) viewController
			  withAnimation: (CustomNavigationControllerAnimation) animation;
- (void) pushViewController: (UIViewController *) viewController
				   animated: (BOOL) animated;

- (void) popViewControllerWithAnimation: (CustomNavigationControllerAnimation) animation;
- (void) popViewControllerAnimated: (BOOL) animated;

- (IBAction) backItemTapped: (id) sender;

@end
