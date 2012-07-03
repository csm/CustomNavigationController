//
//  CustomNavigationController.m
//  WOD
//
//  Created by Casey Marshall on 2/3/11.
//  Copyright 2011 Modal Domains. All rights reserved.
//

#import "CustomNavigationController.h"
#import "CustomViewController+setNavigationController.h"

@implementation CustomNavigationController

@synthesize navigationBar;
@synthesize contentView;
@synthesize delegate;

#define AnimationDuration 0.3
#define AnimationCurve UIViewAnimationCurveEaseInOut

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		viewControllers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id) initWithRootViewController:(UIViewController *)viewController
{
	if (self = [super init])
	{
		if ([viewController isKindOfClass: [CustomViewController class]])
			[((CustomViewController *) viewController) setCustomNavigationController: self];
		if ([viewController isKindOfClass: [CustomTableViewController class]])
			[((CustomTableViewController *) viewController) setCustomNavigationController: self];
		
		viewControllers = [[NSMutableArray alloc] initWithObjects: viewController, nil];
	}
	return self;
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void) loadView
{
	self.view = [[[UIView alloc] initWithFrame: CGRectMake(0, 0, 320, 364)] autorelease];
	self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth
								  | UIViewAutoresizingFlexibleHeight);
	navigationBar = [[UINavigationBar alloc] initWithFrame: CGRectMake(0, 0, 320, 44)];
	navigationBar.delegate = self;
	contentView = [[UIView alloc] initWithFrame: CGRectMake(0, 44, 320, 320)];
	[contentView setClipsToBounds: YES];
	contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth
									| UIViewAutoresizingFlexibleHeight);
	[self.view addSubview: navigationBar];
	[self.view addSubview: contentView];
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	if ([viewControllers count] > 0)
	{
		UIViewController *current = [viewControllers lastObject];
		
		if (delegate != nil)
			[delegate navigationController: self
					willShowViewController: current
								  animated: NO];
		[contentView addSubview: current.view];
		current.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth
										 | UIViewAutoresizingFlexibleHeight);
		[current.view setFrame: contentView.bounds];
		
		NSMutableArray *newItems = [[NSMutableArray alloc] initWithCapacity: [viewControllers count]];
		for (UIViewController *vc in viewControllers)
		{
			[newItems addObject: vc.navigationItem];
			[vc.navigationItem.backBarButtonItem setTarget: self];
			[vc.navigationItem.backBarButtonItem setAction: @selector(backItemTapped:)];
		}
		[navigationBar setItems: newItems];
		[newItems release];
		
		if (delegate != nil)
			[delegate navigationController: self
					 didShowViewController: current
								  animated: NO];
	}
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{
	[viewControllers release];
	[navigationBar release];
	[contentView release];
	[delegate release];
    [super dealloc];
}

#pragma mark -
#pragma mark Navigation methods

struct animation_context
{
	enum { ReplaceControllers, PushController, PopController } action;
	CustomNavigationControllerAnimation animation;
	UIViewController *disappearingController;
	UIViewController *appearingController;
};

- (void) animationDidStop: (NSString *) animationId
				 finished: (BOOL) finished
				  context: (void *) context
{
	if (context != nil)
	{
		struct animation_context *ctx = (struct animation_context *) context;
		if (ctx->disappearingController != nil)
			[ctx->disappearingController.view removeFromSuperview];
		if (delegate != nil)
			[delegate navigationController: self
					 didShowViewController: ctx->appearingController
								  animated: YES];
		free(ctx);
	}
}

- (void) setViewControllers: (NSArray *) vc
				   animated: (BOOL) animated
{
	[self setViewControllers: vc
			   withAnimation: animated ? CustomNavigationControllerAnimationDefault : CustomNavigationControllerAnimationNone];
}

- (void) setViewControllers: (NSArray *) vc
			  withAnimation: (CustomNavigationControllerAnimation) animation
{
	UIViewController *current = nil;
	if ([viewControllers count] > 0)
		current = [viewControllers lastObject];
	UIViewController *newCurrent = [vc lastObject];
	for (UIViewController *c in viewControllers)
	{
		if ([c isKindOfClass: [CustomViewController class]])
			[((CustomViewController *) c) setCustomNavigationController: nil];
		if ([c isKindOfClass: [CustomTableViewController class]])
			[((CustomTableViewController *) c) setCustomNavigationController: nil];
	}
	[viewControllers removeAllObjects];
	[viewControllers addObjectsFromArray: vc];
	
	for (UIViewController *c in viewControllers)
	{
		if ([c isKindOfClass: [CustomViewController class]])
			[((CustomViewController *) c) setCustomNavigationController: self];
		if ([c isKindOfClass: [CustomTableViewController class]])
			[((CustomTableViewController *) c) setCustomNavigationController: self];		
	}
	
	switch (animation)
	{
		case CustomNavigationControllerAnimationTop:
		{
			[contentView addSubview: newCurrent.view];
			[newCurrent.view setFrame: CGRectMake(0, -contentView.bounds.size.height,
												  contentView.bounds.size.width,
												  contentView.bounds.size.height)];
			
			struct animation_context *context = (struct animation_context *) malloc(sizeof(struct animation_context));
			context->action = ReplaceControllers;
			context->animation = animation;
			context->disappearingController = current;
			context->appearingController = newCurrent;
			[UIView beginAnimations: @"SetViewControllersAnimation"
							context: context];
			[UIView setAnimationCurve: AnimationCurve];
			[UIView setAnimationDuration: AnimationDuration];
			[UIView setAnimationDelegate: self];
			[UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
			if (current != nil)
			{
				CGRect currentFrame = current.view.frame;
				currentFrame.origin.y = currentFrame.size.height;
				[current.view setFrame: currentFrame];
			}
			[newCurrent.view setFrame: CGRectMake(0, 0, contentView.bounds.size.width,
												  contentView.bounds.size.height)];
			[UIView commitAnimations];			
		}
			break;
			
		case CustomNavigationControllerAnimationBottom:
		{
			[contentView addSubview: newCurrent.view];
			[newCurrent.view setFrame: CGRectMake(0, contentView.bounds.size.height,
												  contentView.bounds.size.width,
												  contentView.bounds.size.height)];
			
			struct animation_context *context = (struct animation_context *) malloc(sizeof(struct animation_context));
			context->action = ReplaceControllers;
			context->animation = animation;
			context->disappearingController = current;
			context->appearingController = newCurrent;
			[UIView beginAnimations: @"PushViewControllerAnimation"
							context: context];
			[UIView setAnimationCurve: AnimationCurve];
			[UIView setAnimationDuration: AnimationDuration];
			[UIView setAnimationDelegate: self];
			[UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
			if (current != nil)
			{
				CGRect currentFrame = current.view.frame;
				currentFrame.origin.y = -currentFrame.size.height;
				[current.view setFrame: currentFrame];
			}
			[newCurrent.view setFrame: CGRectMake(0, 0, contentView.bounds.size.width,
												  contentView.bounds.size.height)];
			[UIView commitAnimations];			
		}
			break;
			
		case CustomNavigationControllerAnimationRight:
		{
			[contentView addSubview: newCurrent.view];
			[newCurrent.view setFrame: CGRectMake(contentView.bounds.size.width, 0,
												  contentView.bounds.size.width,
												  contentView.bounds.size.height)];
			
			struct animation_context *context = (struct animation_context *) malloc(sizeof(struct animation_context));
			context->action = ReplaceControllers;
			context->animation = animation;
			context->disappearingController = current;
			context->appearingController = newCurrent;
			[UIView beginAnimations: @"PushViewControllerAnimation"
							context: context];
			[UIView setAnimationCurve: AnimationCurve];
			[UIView setAnimationDuration: AnimationDuration];
			[UIView setAnimationDelegate: self];
			[UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
			if (current != nil)
			{
				CGRect currentFrame = current.view.frame;
				currentFrame.origin.x = -currentFrame.size.width;
				[current.view setFrame: currentFrame];
			}
			[newCurrent.view setFrame: CGRectMake(0, 0, contentView.bounds.size.width,
												  contentView.bounds.size.height)];
			[UIView commitAnimations];			
		}
			break;
			
		case CustomNavigationControllerAnimationLeft:
		{
			[contentView addSubview: newCurrent.view];
			[newCurrent.view setFrame: CGRectMake(-contentView.bounds.size.width, 0,
												  contentView.bounds.size.width,
												  contentView.bounds.size.height)];
			
			struct animation_context *context = (struct animation_context *) malloc(sizeof(struct animation_context));
			context->action = ReplaceControllers;
			context->animation = animation;
			context->disappearingController = current;
			context->appearingController = newCurrent;
			[UIView beginAnimations: @"PushViewControllerAnimation"
							context: context];
			[UIView setAnimationCurve: AnimationCurve];
			[UIView setAnimationDuration: AnimationDuration];
			[UIView setAnimationDelegate: self];
			[UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
			if (current != nil)
			{
				CGRect currentFrame = current.view.frame;
				currentFrame.origin.x = currentFrame.size.width;
				[current.view setFrame: currentFrame];
			}
			[newCurrent.view setFrame: CGRectMake(0, 0, contentView.bounds.size.width,
												  contentView.bounds.size.height)];
			[UIView commitAnimations];			
		}
			break;
			
		case CustomNavigationControllerAnimationDefault:
		case CustomNavigationControllerAnimationNone:
		default:
		{
			if (current != nil)
			{
				[current.view removeFromSuperview];
			}
			[contentView addSubview: newCurrent.view];
			if (delegate != nil)
				[delegate navigationController: self
						 didShowViewController: newCurrent
									  animated: NO];
		}
			break;
	}
	
	NSMutableArray *newItems = [[NSMutableArray alloc] initWithCapacity: [viewControllers count]];
	for (UIViewController *c in viewControllers)
	{
		[newItems addObject: c.navigationItem];
		[c.navigationItem.backBarButtonItem setTarget: self];
		[c.navigationItem.backBarButtonItem setAction: @selector(backItemTapped:)];
	}
	[navigationBar setItems: newItems animated: animation != CustomNavigationControllerAnimationNone];
	[newItems release];
}

- (void) pushViewController:(UIViewController *)viewController
				   animated:(BOOL)animated
{
	[self pushViewController: viewController
			   withAnimation: animated ? CustomNavigationControllerAnimationDefault : CustomNavigationControllerAnimationNone];
}

- (void) pushViewController: (UIViewController *) viewController
			  withAnimation: (CustomNavigationControllerAnimation) animation
{
	if (delegate != nil)
		[delegate navigationController: self
				willShowViewController: viewController
							  animated: animation != CustomNavigationControllerAnimationNone];
	
	if ([viewController isKindOfClass: [CustomViewController class]])
		[((CustomViewController *) viewController) setCustomNavigationController: self];
	if ([viewController isKindOfClass: [CustomTableViewController class]])
		[((CustomTableViewController *) viewController) setCustomNavigationController: self];
	UIViewController *current = nil;
	if ([viewControllers count] > 0)
		current = [viewControllers lastObject];
	[viewControllers addObject: viewController];
	
	switch (animation)
	{
		case CustomNavigationControllerAnimationTop:
		{
			[contentView addSubview: viewController.view];
			[viewController.view setFrame: CGRectMake(0, -contentView.bounds.size.height,
													  contentView.bounds.size.width,
													  contentView.bounds.size.height)];
			
			struct animation_context *context = (struct animation_context *) malloc(sizeof(struct animation_context));
			context->action = PushController;
			context->animation = animation;
			context->disappearingController = current;
			context->appearingController = viewController;
			[UIView beginAnimations: @"PushViewControllerAnimation"
							context: context];
			[UIView setAnimationCurve: AnimationCurve];
			[UIView setAnimationDuration: AnimationDuration];
			[UIView setAnimationDelegate: self];
			[UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
			if (current != nil)
			{
				CGRect currentFrame = current.view.frame;
				currentFrame.origin.y = currentFrame.size.height;
				[current.view setFrame: currentFrame];
			}
			[viewController.view setFrame: CGRectMake(0, 0, contentView.bounds.size.width,
													  contentView.bounds.size.height)];
			[UIView commitAnimations];
		}
			break;
			
		case CustomNavigationControllerAnimationBottom:
		{
			[contentView addSubview: viewController.view];
			[viewController.view setFrame: CGRectMake(0, contentView.bounds.size.height,
													  contentView.bounds.size.width,
													  contentView.bounds.size.height)];
			
			struct animation_context *context = (struct animation_context *) malloc(sizeof(struct animation_context));
			context->action = PushController;
			context->animation = animation;
			context->disappearingController = current;
			context->appearingController = viewController;
			[UIView beginAnimations: @"PushViewControllerAnimation"
							context: context];
			[UIView setAnimationCurve: AnimationCurve];
			[UIView setAnimationDuration: AnimationDuration];
			[UIView setAnimationDelegate: self];
			[UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
			if (current != nil)
			{
				CGRect currentFrame = current.view.frame;
				currentFrame.origin.y = -currentFrame.size.height;
				[current.view setFrame: currentFrame];
			}
			[viewController.view setFrame: CGRectMake(0, 0, contentView.bounds.size.width,
													  contentView.bounds.size.height)];
			[UIView commitAnimations];
		}
			break;
			
		case CustomNavigationControllerAnimationLeft:
		{
			[contentView addSubview: viewController.view];
			[viewController.view setFrame: CGRectMake(-contentView.bounds.size.width, 0,
													  contentView.bounds.size.width,
													  contentView.bounds.size.height)];
			
			struct animation_context *context = (struct animation_context *) malloc(sizeof(struct animation_context));
			context->action = PushController;
			context->animation = animation;
			context->disappearingController = current;
			context->appearingController = viewController;
			[UIView beginAnimations: @"PushViewControllerAnimation"
							context: context];
			[UIView setAnimationCurve: AnimationCurve];
			[UIView setAnimationDuration: AnimationDuration];
			[UIView setAnimationDelegate: self];
			[UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
			if (current != nil)
			{
				CGRect currentFrame = current.view.frame;
				currentFrame.origin.x = currentFrame.size.width;
				[current.view setFrame: currentFrame];
			}
			[viewController.view setFrame: CGRectMake(0, 0, contentView.bounds.size.width,
													  contentView.bounds.size.height)];
			[UIView commitAnimations];
		}
			break;
			
		case CustomNavigationControllerAnimationDefault:
		case CustomNavigationControllerAnimationRight:
		{
			[contentView addSubview: viewController.view];
			[viewController.view setFrame: CGRectMake(contentView.bounds.size.width, 0,
													  contentView.bounds.size.width,
													  contentView.bounds.size.height)];
			
			struct animation_context *context = (struct animation_context *) malloc(sizeof(struct animation_context));
			context->action = PushController;
			context->animation = animation;
			context->disappearingController = current;
			context->appearingController = viewController;
			[UIView beginAnimations: @"PushViewControllerAnimation"
							context: context];
			[UIView setAnimationCurve: AnimationCurve];
			[UIView setAnimationDuration: AnimationDuration];
			[UIView setAnimationDelegate: self];
			[UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
			if (current != nil)
			{
				CGRect currentFrame = current.view.frame;
				currentFrame.origin.x = -currentFrame.size.width;
				[current.view setFrame: currentFrame];
			}
			[viewController.view setFrame: CGRectMake(0, 0, contentView.bounds.size.width,
													  contentView.bounds.size.height)];
			[UIView commitAnimations];
		}
			break;
			
		case CustomNavigationControllerAnimationNone:
		default: // no animation
		{
			if (current != nil)
				[current.view removeFromSuperview];
			viewController.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth
													| UIViewAutoresizingFlexibleHeight);
			[contentView addSubview: viewController.view];
			[viewController.view setFrame: contentView.bounds];
			if (delegate != nil)
				[delegate navigationController: self
						 didShowViewController: viewController
									  animated: NO];
		}
			break;
	}
	
	[navigationBar pushNavigationItem: viewController.navigationItem
							 animated: animation != CustomNavigationControllerAnimationNone];
	[navigationBar.topItem.backBarButtonItem setTarget: self];
	[navigationBar.topItem.backBarButtonItem setAction: @selector(backItemTapped:)];
}

- (void) popViewControllerAnimated:(BOOL)animated
{
	[self popViewControllerWithAnimation: animated ? CustomNavigationControllerAnimationDefault : CustomNavigationControllerAnimationNone];
}

- (void) popViewControllerWithAnimation_0: (CustomNavigationControllerAnimation) animation
{
	if ([viewControllers count] == 1)
		return;
	UIViewController *current = [viewControllers lastObject];
	if ([current isKindOfClass: [CustomViewController class]])
		[((CustomViewController *) current) setCustomNavigationController: nil];
	if ([current isKindOfClass: [CustomTableViewController class]])
		[((CustomTableViewController *) current) setCustomNavigationController: nil];
	[viewControllers removeLastObject];
	UIViewController *newCurrent = [viewControllers lastObject];
	
	if (delegate != nil)
		[delegate navigationController: self
				willShowViewController: newCurrent
							  animated: animation != CustomNavigationControllerAnimationNone];
	
	switch (animation)
	{
		case CustomNavigationControllerAnimationTop:
		{
			[contentView addSubview: newCurrent.view];
			[newCurrent.view setFrame: CGRectMake(0, contentView.bounds.size.height,
												  contentView.bounds.size.width,
												  contentView.bounds.size.height)];
			
			struct animation_context *context = (struct animation_context *) malloc(sizeof(struct animation_context));
			context->action = PopController;
			context->animation = animation;
			context->disappearingController = current;
			context->appearingController = newCurrent;
			[UIView beginAnimations: @"PushViewControllerAnimation"
							context: context];
			[UIView setAnimationCurve: AnimationCurve];
			[UIView setAnimationDuration: AnimationDuration];
			[UIView setAnimationDelegate: self];
			[UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
			if (current != nil)
			{
				CGRect currentFrame = current.view.frame;
				currentFrame.origin.y = -currentFrame.size.height;
				[current.view setFrame: currentFrame];
			}
			[newCurrent.view setFrame: CGRectMake(0, 0, contentView.bounds.size.width,
													  contentView.bounds.size.height)];
			[UIView commitAnimations];			
		}
			break;
			
		case CustomNavigationControllerAnimationBottom:
		{
			[contentView addSubview: newCurrent.view];
			[newCurrent.view setFrame: CGRectMake(0, -contentView.bounds.size.height,
												  contentView.bounds.size.width,
												  contentView.bounds.size.height)];
			
			struct animation_context *context = (struct animation_context *) malloc(sizeof(struct animation_context));
			context->action = PopController;
			context->animation = animation;
			context->disappearingController = current;
			context->appearingController = newCurrent;
			[UIView beginAnimations: @"PushViewControllerAnimation"
							context: context];
			[UIView setAnimationCurve: AnimationCurve];
			[UIView setAnimationDuration: AnimationDuration];
			[UIView setAnimationDelegate: self];
			[UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
			if (current != nil)
			{
				CGRect currentFrame = current.view.frame;
				currentFrame.origin.y = currentFrame.size.height;
				[current.view setFrame: currentFrame];
			}
			[newCurrent.view setFrame: CGRectMake(0, 0, contentView.bounds.size.width,
												  contentView.bounds.size.height)];
			[UIView commitAnimations];			
		}
			break;
			
		case CustomNavigationControllerAnimationDefault:
		case CustomNavigationControllerAnimationRight:
		{
			[contentView addSubview: newCurrent.view];
			[newCurrent.view setFrame: CGRectMake(-contentView.bounds.size.width, 0,
												  contentView.bounds.size.width,
												  contentView.bounds.size.height)];
			
			struct animation_context *context = (struct animation_context *) malloc(sizeof(struct animation_context));
			context->action = PopController;
			context->animation = animation;
			context->disappearingController = current;
			context->appearingController = newCurrent;
			[UIView beginAnimations: @"PushViewControllerAnimation"
							context: context];
			[UIView setAnimationCurve: AnimationCurve];
			[UIView setAnimationDuration: AnimationDuration];
			[UIView setAnimationDelegate: self];
			[UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
			if (current != nil)
			{
				CGRect currentFrame = current.view.frame;
				currentFrame.origin.x = currentFrame.size.width;
				[current.view setFrame: currentFrame];
			}
			[newCurrent.view setFrame: CGRectMake(0, 0, contentView.bounds.size.width,
												  contentView.bounds.size.height)];
			[UIView commitAnimations];			
		}
			break;
			
		case CustomNavigationControllerAnimationLeft:
		{
			[contentView addSubview: newCurrent.view];
			[newCurrent.view setFrame: CGRectMake(contentView.bounds.size.width, 0,
												  contentView.bounds.size.width,
												  contentView.bounds.size.height)];
			
			struct animation_context *context = (struct animation_context *) malloc(sizeof(struct animation_context));
			context->action = PopController;
			context->animation = animation;
			context->disappearingController = current;
			context->appearingController = newCurrent;
			[UIView beginAnimations: @"PushViewControllerAnimation"
							context: context];
			[UIView setAnimationCurve: AnimationCurve];
			[UIView setAnimationDuration: AnimationDuration];
			[UIView setAnimationDelegate: self];
			[UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
			if (current != nil)
			{
				CGRect currentFrame = current.view.frame;
				currentFrame.origin.x = -currentFrame.size.width;
				[current.view setFrame: currentFrame];
			}
			[newCurrent.view setFrame: CGRectMake(0, 0, contentView.bounds.size.width,
												  contentView.bounds.size.height)];
			[UIView commitAnimations];			
		}
			break;
			
		case CustomNavigationControllerAnimationNone:
		default:
		{
			[current.view removeFromSuperview];
			[contentView addSubview: newCurrent.view];
			newCurrent.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight
												| UIViewAutoresizingFlexibleWidth);
			[newCurrent.view setFrame: contentView.bounds];
			if (delegate != nil)
				[delegate navigationController: self
						 didShowViewController: newCurrent
									  animated: NO];
		}
			break;
	}
}

- (void) popViewControllerWithAnimation:(CustomNavigationControllerAnimation)animation
{
	[navigationBar popNavigationItemAnimated: animation != CustomNavigationControllerAnimationNone];
}

- (IBAction) backItemTapped: (id) sender
{
	//[self popViewControllerWithAnimation: CustomNavigationControllerAnimationDefault];
}

#pragma mark -
#pragma mark UINavigationBarDelegate methods

- (void)navigationBar:(UINavigationBar *)navigationBar didPushItem:(UINavigationItem *)item
{
}

- (void) navigationBar:(UINavigationBar *)navigationBar didPopItem:(UINavigationItem *)item
{
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPushItem:(UINavigationItem *)item
{
	return YES;
}

- (BOOL) navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
	[self popViewControllerWithAnimation_0: CustomNavigationControllerAnimationDefault];
	return YES;
}

@end
