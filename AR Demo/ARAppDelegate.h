//
//  ARAppDelegate.h
//  AR Demo
//
//  Created by Matthew Henderson on 8/26/12.
//  Copyright (c) 2012 Matthew Henderson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ARViewController;

@interface ARAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ARViewController *viewController;

@end
