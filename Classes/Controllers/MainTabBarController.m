//
//  MainTabBarController.m
//  newsyc
//
//  Created by Grant Paul on 3/30/11.
//  Copyright 2011 Xuzz Productions, LLC. All rights reserved.
//

#import <HNKit/HNKit.h>

#import "UIActionSheet+Context.h"
#import "UIColor+Orange.h"
#import "ForceClearNavigationBar.h"

#import "MainTabBarController.h"
#import "SubmissionListController.h"
#import "MoreController.h"
#import "NavigationController.h"


@implementation MainTabBarController

- (UITabBarItem *)_tabBarItemWithTitle:(NSString *)title imageName:(NSString *)imageName {
    UITabBarItem *item = nil;

    if ([UITabBarItem instancesRespondToSelector:@selector(initWithTitle:image:selectedImage:)]) {
        UIImage *image = [UIImage imageNamed:[imageName stringByAppendingString:@"7.png"]];
        UIImage *selectedImage = [UIImage imageNamed:[imageName stringByAppendingString:@"7-selected.png"]];
        item = [[UITabBarItem alloc] initWithTitle:title image:image selectedImage:selectedImage];
    } else {
        UIImage *image = [UIImage imageNamed:[imageName stringByAppendingString:@".png"]];
        item = [[UITabBarItem alloc] initWithTitle:title image:image tag:0];
    }

    return [item autorelease];
}

- (id)initWithSession:(HNSession *)session_ {
    if ((self = [super init])) {
        session = [session_ retain];

        if (![session isAnonymous] && [[HNSessionController sessionController] numberOfSessions] != 1) {
            [self setTitle:[[session user] identifier]];
        } else {
            [self setTitle:@"Hacker News"];
        }

        HNEntryList *homeList = [HNEntryList session:session entryListWithIdentifier:kHNEntryListIdentifierSubmissions];
        home = [[[SubmissionListController alloc] initWithSource:homeList] autorelease];
        [home setTitle:@"Hacker News"];
        [home setTabBarItem:[self _tabBarItemWithTitle:@"Home" imageName:@"home"]];
        
        HNEntryList *newList = [HNEntryList session:session entryListWithIdentifier:kHNEntryListIdentifierNewSubmissions];
        latest = [[[SubmissionListController alloc] initWithSource:newList] autorelease];
        [latest setTitle:@"New Submissions"];
        [latest setTabBarItem:[self _tabBarItemWithTitle:@"New" imageName:@"new"]];

        more = [[[MoreController alloc] initWithSession:session] autorelease];
        [more setTitle:@"More"];
        [more setTabBarItem:[[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:0] autorelease]];

        NSMutableArray *viewControllers = [NSMutableArray arrayWithObjects:home, latest, profile, search, more, nil];

        if ([self respondsToSelector:@selector(topLayoutGuide)]) {
            for (NSUInteger i = 0; i < viewControllers.count; i++) {
                // iOS 7 Hack: use a navigation controller to fix the children's layout guides, but force a clear navigation bar so it doesn't show up.
                UINavigationController *navigationController = [[UINavigationController alloc] initWithNavigationBarClass:[ForceClearNavigationBar class] toolbarClass:nil];
                [navigationController pushViewController:[viewControllers objectAtIndex:i] animated:NO];
                [viewControllers replaceObjectAtIndex:i withObject:navigationController];
            }
        }

        [self setViewControllers:viewControllers];

        [self setDelegate:self];
    }
    
    return self;
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[self navigationItem] setRightBarButtonItem:composeItem];

    // XXX: Fix iOS 6 bug with a tab bar controller in a navigation controller.
    [self setViewControllers:[self viewControllers]];
    [[self selectedViewController] setWantsFullScreenLayout:YES];

    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"disable-orange"]) {
        if ([[self tabBar] respondsToSelector:@selector(setBarTintColor:)]) {
            [[self tabBar] setTintColor:[UIColor mainOrangeColor]];
        } else {
            [[self tabBar] setSelectedImageTintColor:[UIColor mainOrangeColor]];
        }
    } else {
        if ([[self tabBar] respondsToSelector:@selector(setBarTintColor:)]) {
            [[self tabBar] setTintColor:nil];
        }

        [[self tabBar] setSelectedImageTintColor:nil];
    }
}

- (void)loadView {
    [super loadView];
    
    composeItem = [[BarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composePressed)];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [[self navigationItem] setRightBarButtonItem:nil];
    
    [composeItem release];
    composeItem = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self navigationItem] setRightBarButtonItem:composeItem];
}

AUTOROTATION_FOR_PAD_ONLY

@end
