//
//  LOLAppDelegate.m
//  loldb
//
//  Created by Andrew Pouliot on 12/12/11.
//  Copyright (c) 2011 Darknoon. All rights reserved.
//

#import "LOLAppDelegate.h"

#import "LOLDatabase.h"

@implementation LOLAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
	
	NSLog(@"Starting database operations");
	NSLog(@"Reading");
	
	NSString *cacheName = @"somestuff.lol";
	NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:cacheName];
	
	LOLDatabase *db = [[LOLDatabase alloc] initWithPath:path];
	__block NSDictionary *buttons = nil;
	[db accessCollection:@"shit" withBlock:^(id<LOLDatabaseAccessor>accessor) {
		//Do a bunch of unnecessary work for timing purposes
		NSDictionary *blahTemp = nil;
		for (int i=0; i<10000; i++) {
			@autoreleasepool {
				blahTemp = [accessor dictionaryForKey:[[NSString alloc] initWithFormat:@"fuckbuttons-%d", i]];
			}
		}
		buttons = [accessor dictionaryForKey:@"fuckbuttons"];
	}];
	
	NSLog(@"Writing");
	
	[db accessCollection:@"shit" withBlock:^(id<LOLDatabaseAccessor> accessor) {
		NSDictionary *whatItShouldBe = [[NSDictionary alloc] initWithObjectsAndKeys:@"ladida", @"whatever", [NSNumber numberWithDouble:CFAbsoluteTimeGetCurrent()], @"somenumber", nil];
		//An insert test
		for (int i=0; i<10000; i++) {
			@autoreleasepool {
				[accessor setDictionary:whatItShouldBe forKey:[[NSString alloc] initWithFormat:@"fuckbuttons-%d", i]];
				
			}
		}
		
		[accessor setDictionary:whatItShouldBe forKey:@"fuckbuttons"];
	}];
	
	NSLog(@"Current buttons: %@", buttons);
		
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	/*
	 Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	 Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	 */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	/*
	 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	 If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	 */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	/*
	 Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	 */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	/*
	 Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	 */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	/*
	 Called when the application is about to terminate.
	 Save data if appropriate.
	 See also applicationDidEnterBackground:.
	 */
}

@end
