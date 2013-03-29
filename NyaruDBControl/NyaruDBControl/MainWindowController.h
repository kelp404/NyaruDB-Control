//
//  MainWindowController.h
//  NyaruDBControl
//
//  Created by Kelp on 2013/03/29.
//
//

#import <Cocoa/Cocoa.h>

@interface MainWindowController : NSWindowController <NSWindowDelegate> {
    IBOutlet NSTextField *_path;
}


+ (NSString *)nibName;

#pragma mark - Button Events
- (IBAction)clickOpenPath:(id)sender;


@end
