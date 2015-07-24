/*
 * CsoundAUEffectView_ViewFactory.h
 *
 * Copyright (C) 2015 Edward Costello
 *
 */

#import <Cocoa/Cocoa.h>
#import <AudioUnit/AUCocoaUIView.h>
#import "CsoundAUView.h"

@interface CsoundAUViewFactory : NSObject <AUCocoaUIBase>
{
    IBOutlet CsoundAUView *uiFreshlyLoadedView;
}
- (NSString *) description;

@end
