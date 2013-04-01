//
//  MainWindowController.m
//  NyaruDBControl
//
//  Created by Kelp on 2013/03/29.
//
//

#import "MainWindowController.h"
#import "NyaruControlAppDelegate.h"
#import "CollectionsViewController.h"
#import "CollectionViewController.h"
#import <NyaruDB/NyaruDB.h>


@interface MainWindowController ()

@end



@implementation MainWindowController


+ (NSString *)nibName
{
    return @"MainWindow";
}


#pragma mark - Window Events
- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // show open panel
    [self clickOpenPath:nil];
}

#pragma mark - Window delegates
- (void)windowWillClose:(NSNotification *)notification
{
    [(NyaruControlAppDelegate *)[[NSApplication sharedApplication] delegate] removeWindowFromPool:self];
}

#pragma mark - Actions
- (IBAction)pressEnter:(NSTextField *)sender
{
    if (sender.stringValue.length > 0) {
        [self setupDatabase];
    }
}

#pragma mark Buttons
- (IBAction)clickOpenPath:(NSMenuItem *)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanCreateDirectories:YES];
    [panel setAllowsMultipleSelection:NO];
    
    if (sender.tag == 1) {      // ~/
        [panel setDirectoryURL:[NSURL fileURLWithPath:NSHomeDirectory()]];
    }
    else if (sender.tag == 2) { // /tmp
        [panel setDirectoryURL:[NSURL fileURLWithPath:@"/tmp"]];
    }
    else {      // iPhone Simulator
        NSURL *applicationSupport = [[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask].lastObject;
        [panel setDirectoryURL:[applicationSupport URLByAppendingPathComponent:@"iPhone Simulator"]];
    }
    
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSOKButton) {
            [_path setStringValue:panel.URL.path];
        }
        else {
            [_path setStringValue:@"/tmp/NyaruDB"];
        }
        [self setupDatabase];
    }];
}


#pragma mark - Setup
- (void)setupDatabase
{
    if (_db) {
        [_db close];
    }
    
    self.window.title = [NSString stringWithFormat:@"NyaruDB Control - %@", _path.stringValue];
    @try {
        _db = [[NyaruDB alloc] initWithPath:_path.stringValue];
    }
    @catch (__unused NSException *exception) {
        NSAlert *alert = [NSAlert new];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert setMessageText:@"NyaruDB Control"];
        [alert setInformativeText:@"Data loading failed!"];
        [alert runModal];
    }
    while (_split.subviews.count > 0) {
        [_split.subviews.lastObject removeFromSuperview];
    }
    
    // collections view
    _collections = [[CollectionsViewController alloc] initWithNibName:[CollectionsViewController nibName] bundle:nil];
    _collections.db = _db;
    [_split addSubview:_collections.view];
    
    // collection view
    _collection = [[CollectionViewController alloc] initWithNibName:[CollectionViewController nibName] bundle:nil];
    [_split addSubview:_collection.view];
}


@end
