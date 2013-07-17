//
//  HTAppDelegate.m
//  TOLOTFlickr
//
//  Created by tanabe on 13/05/14.
//  Copyright (c) 2013年 Hideaki Tanabe. All rights reserved.
//

#import "HTAppDelegate.h"

#import "HTMainViewController.h"
#import "HTConfigViewController.h"
#import "HTFlickrAPIRequester.h"
#import "GAI.h"

@interface HTAppDelegate()
@property HTMainViewController *firstViewController;
@property HTConfigViewController *configViewController;

@end

@implementation HTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    
    _firstViewController = [[HTMainViewController alloc] initWithNibName:@"HTMainViewController" bundle:nil];
    
    _configViewController = [[HTConfigViewController alloc] initWithNibName:@"HTConfigViewController" bundle:nil];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:_firstViewController];
    navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = @[navigationController, _configViewController];
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    // Exceptionのトラッキングはしない
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // トラッキング間隔は10秒
    [GAI sharedInstance].dispatchInterval = 10;
    // デバック出力はしない
    [GAI sharedInstance].debug = NO;
    // 通信にはHTTPSを使用する
    [[GAI sharedInstance].defaultTracker setUseHttps:YES];
    // トラッキングIDを設定
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-73660-20"];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    HTFlickrAPIRequester *flickrAPIRequester = [HTFlickrAPIRequester getInstance];
    [flickrAPIRequester fetchAccessToken:url
                            complete:^{
                                [_firstViewController showImages];
                            }];
    return YES;
}

@end
