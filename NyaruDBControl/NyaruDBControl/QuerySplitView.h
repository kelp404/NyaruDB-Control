//
//  QuerySplitView.h
//  NyaruDBControl
//
//  Created by Kelp on 2013/04/09.
//
//

#import <Cocoa/Cocoa.h>

@class CoffeeCocoa;


@interface QuerySplitView : NSSplitView

@property (strong, nonatomic) IBOutlet NSTextView *textQuery;
@property (strong, nonatomic) CoffeeCocoa *coffee;

@end
