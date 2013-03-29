//
//  NyaruControlAppDelegate.m
//  NyaruDBControl
//
//  Created by Kelp on 2013/03/27.
//
//

#import "NyaruControlAppDelegate.h"
#import "MainWindowController.h"


@implementation NyaruControlAppDelegate


#pragma mark - View Events
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // setup variables
    _windowPool = [NSMutableArray new];
    
    // setup the first window
    MainWindowController *window = [[MainWindowController alloc] initWithWindowNibName:[MainWindowController nibName]];
    [window showWindow:self];
    [_windowPool addObject:window];
}

// click icon on Dock
- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    if (_windowPool.count > 0) {
        MainWindowController *window = [_windowPool objectAtIndex:0];
        [window.window makeKeyAndOrderFront:self];
    }
    return flag;
}

#pragma mark Menu
- (IBAction)clickNewWindow:(id)sender
{
    MainWindowController *window = [[MainWindowController alloc] initWithWindowNibName:[MainWindowController nibName]];
    [window showWindow:self];
    [_windowPool addObject:window];
}

- (void)removeWindowFromPool:(id)window
{
    [_windowPool removeObject:window];
}


@end
