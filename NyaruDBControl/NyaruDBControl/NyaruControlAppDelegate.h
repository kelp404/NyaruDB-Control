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

- (IBAction)clickNewWindow:(id)sender;

- (void)removeWindowFromPool:(id)window;

@end
