//
//  ViewUtility.m
//  NyaruDBControl
//
//  Created by Kelp on 2013/04/09.
//
//

#import "ViewUtility.h"

@implementation ViewUtility

+ (id)searchViewIn:(NSView *)view kindOf:(Class)aClass deep:(NSUInteger)deep
{
    for (id subView in view.subviews) {
        if ([subView isKindOfClass:aClass]) {
            return subView;
        }
        else if (deep > 0) {
            id result = [self searchViewIn:subView kindOf:aClass deep:deep - 1];
            if (result)
                return result;
        }
    }

    return nil;
}

@end
