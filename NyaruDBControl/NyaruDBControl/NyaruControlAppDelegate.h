//
//  NyaruControlAppDelegate.h
//  NyaruDBControl
//
//  Created by Kelp on 2013/03/27.
//
//

#import <Cocoa/Cocoa.h>

@class MainWindowController;

@interface NyaruControlAppDelegate : NSObject <NSApplicationDelegate> {
    NSMutableArray *_windowPool;
}

#pragma mark - Menus
@property (strong, nonatomic) IBOutlet NSMenu *menuCollection;

#pragma mark - Actions
- (IBAction)newWindow:(id)sender;

#pragma mark - Methods
// for windows in window pool
- (void)removeWindowFromPool:(id)window;

@end
