//
//  ViewUtility.h
//  NyaruDBControl
//
//  Created by Kelp on 2013/04/09.
//
//

#import <Foundation/Foundation.h>

@interface ViewUtility : NSObject

+ (id)searchViewIn:(NSView *)view kindOf:(Class)aClass deep:(NSUInteger)deep;

@end
