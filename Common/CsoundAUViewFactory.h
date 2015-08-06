/*
 * CsoundAUEffectView_ViewFactory.h
 *
 * Copyright (C) 2015 Edward Costello
 *
 */

#import <Cocoa/Cocoa.h>
#import <AudioUnit/AUCocoaUIView.h>
#import "CsoundAUCocoaView.h"

@interface CsoundAUViewFactory : NSObject <AUCocoaUIBase>
{
    IBOutlet CsoundAUCocoaView *uiFreshlyLoadedView;
}
- (NSString *) description;

@end
