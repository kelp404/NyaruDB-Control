//
//  NyaruControlAppDelegate.m
//  NyaruDBControl
//
//  Created by Kelp on 2013/03/27.
//
//

#import "NyaruControlAppDelegate.h"
#import <NyaruDB/NyaruDB.h>


@implementation NyaruControlAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NyaruDB *db = [[NyaruDB alloc] initWithPath:@"/tmp/NyaruDB"];
    [db collectionForName:@"test"];
    // Insert code here to initialize your application
}

@end
