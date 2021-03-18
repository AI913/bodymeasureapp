//
//  BRAppDelegate.m
//  BlackRaccon
//
//  Created by Lloyd Sargent on 7/2/12.
//  Copyright (c) 2012 Canna Software Development. All rights reserved.
//

#import "BRAppDelegate.h"

@implementation BRAppDelegate

@synthesize window = _window;



//-----
//
//				application:didFinishLaunchingWithOptions
//
// synopsis:	retval = [self application:application didFinishLaunchingWithOptions:launchOptions];
//					BOOL retval                	-
//					UIApplication *application 	-
//					NSDictionary *launchOptions	-
//
// description:	application is designed to
//
// errors:		none
//
// returns:		Variable of type BOOL
//

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}



//-----
//
//				applicationWillResignActive
//
// synopsis:	[self applicationWillResignActive:application];
//					UIApplication *application	-
//
// description:	applicationWillResignActive is designed to
//
// errors:		none
//
// returns:		none
//

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}



//-----
//
//				applicationDidEnterBackground
//
// synopsis:	[self applicationDidEnterBackground:application];
//					UIApplication *application	-
//
// description:	applicationDidEnterBackground is designed to
//
// errors:		none
//
// returns:		none
//

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}



//-----
//
//				applicationWillEnterForeground
//
// synopsis:	[self applicationWillEnterForeground:application];
//					UIApplication *application	-
//
// description:	applicationWillEnterForeground is designed to
//
// errors:		none
//
// returns:		none
//

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}



//-----
//
//				applicationDidBecomeActive
//
// synopsis:	[self applicationDidBecomeActive:application];
//					UIApplication *application	-
//
// description:	applicationDidBecomeActive is designed to
//
// errors:		none
//
// returns:		none
//

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}



//-----
//
//				applicationWillTerminate
//
// synopsis:	[self applicationWillTerminate:application];
//					UIApplication *application	-
//
// description:	applicationWillTerminate is designed to
//
// errors:		none
//
// returns:		none
//

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
