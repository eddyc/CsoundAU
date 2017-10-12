/*
 * CsoundAUHTMLView.mm
 *
 * Copyright (C) 2015 Edward Costello
 *
 */

#import "CsoundAUHTMLView.h"
#import "JSONParserObjC.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <WebKit/WebKit.h>

@implementation CsoundAUHTMLView

static WebView *webView;
static NSMutableArray *parameters;
static NSMutableDictionary *parameterIndices;

- (void)synchroniseUIWithParameterValues
{
    for (UInt32 i = 0; i < parameters.count; ++i) {
        
        Float32 value;
        NSAssert (AudioUnitGetParameter(mAU, i, kAudioUnitScope_Global, 0, &value) == noErr,
                  @"[CsoundAUView priv_synchronizeUIWithParameterValues] (x.1)");
        JSObjectRef function = [parameters[i][@"JSCallback"] JSObject];
        JSContextRef ctx = [[webView mainFrame] globalContext];
        NSLog(@"%f\n", value);
        JSValueRef obj = JSValueMakeNumber(ctx, value);
        JSObjectCallAsFunction(ctx, function, NULL, 1, &obj, NULL);
    }
}

- (CsoundAUHTMLView *)initWithBundle:(NSBundle *)bundle
                       configuration:(NSDictionary *)configuration
                          parameters:(NSMutableArray *)inParameters
                           audioUnit:(AudioUnit)inAU
{
    
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"WebKitDeveloperExtras"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    size_t width = 400;
    
    if (configuration[@"ViewWidth"] != nil) {
        
        width = [configuration[@"ViewWidth"] intValue];
    }
    
    size_t height = 400;
    
    if (configuration[@"ViewHeight"] != nil) {
        
        height = [configuration[@"ViewHeight"] intValue];
    }
    
    NSString *viewFileName = @"index";
    
    if (configuration[@"ViewFileName"] != nil) {
        
        viewFileName = configuration[@"ViewFileName"];
    }
    
    self = [self initWithFrame:NSMakeRect(0, 0, width, height)];

    if (webView == nil) {
       
        webView = [[WebView alloc] initWithFrame:NSMakeRect(0, 0, width, height)];
        [webView setResourceLoadDelegate:self];
        [webView setFrameLoadDelegate:self];
        NSURL *url = [bundle URLForResource:viewFileName withExtension:@"html"];
        [[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:url]];
        parameters = inParameters;
        parameterIndices = [[NSMutableDictionary alloc] initWithCapacity:parameters.count];
        
        for (size_t i = 0; i < inParameters.count; ++i) {
           
            parameterIndices[parameters[i][@"name"]] = [NSNumber numberWithInteger:i];
        }
    }
    else {
        
        [self addSubview:webView];
    }
    
    if (mAU) {
        
        [self priv_removeListeners];
    }
    
    mAU = inAU;
    
    [self priv_addListeners:parameters.count];
    [self synchroniseUIWithParameterValues];

    return self;
}



- (void)priv_eventListener:(void *)inObject
                     event:(const AudioUnitEvent *)inEvent
                     value:(Float32)inValue
{
    switch (inEvent->mEventType) {
        case kAudioUnitEvent_ParameterValueChange: {
            
            UInt32 parameterID = inEvent->mArgument.mParameter.mParameterID;
            JSObjectRef function = [parameters[parameterID][@"JSCallback"] JSObject];
            JSContextRef ctx = [[webView mainFrame] globalContext];
            JSValueRef obj = JSValueMakeNumber(ctx, inValue);
            JSObjectCallAsFunction(ctx, function, NULL, 1, &obj, NULL);
            break;
        }
        default: {
            
            break;
        }
    }
}

- (void)webView:(WebView *)sender resource:(id)identifier didFinishLoadingFromDataSource:(WebDataSource *)dataSource
{
    [webView setAlphaValue:0];
    [self addSubview:webView];
    [[NSAnimationContext currentContext] setDuration:.3];
    [[webView animator] setAlphaValue:1];
}


- (void)webView:(WebView *)webView didClearWindowObject:(WebScriptObject *)windowObject forFrame:(WebFrame *)frame
{
    [windowObject setValue:self forKey:@"AudioUnit"];
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    [self synchroniseUIWithParameterValues];
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)selector
{
    if (selector == @selector(parameterFromJavascript:value:)) {
    
        return NO;
    }
    else if (selector == @selector(functionFromJavascript:object:)) {
        
        return NO;
    }
    
    return YES;
}


+ (NSString *)webScriptNameForSelector:(SEL)sel
{
    if (sel == @selector(parameterFromJavascript:value:)) {
        
        return @"setParameter";
    }
    else if (sel == @selector(functionFromJavascript:object:)) {
        
        return @"getParameterCallback";
    }
    else {
        
        return nil;
    }
}

- (void)functionFromJavascript:(NSString *)parameterName object:(WebScriptObject *)object
{
    NSString *key = parameterIndices[parameterName];
    NSMutableDictionary *parameter = parameters[[key integerValue]];
    parameter = [parameter mutableCopy];
    parameter[@"JSCallback"] = object;
    parameters[[key integerValue]] = parameter;
}

- (void)parameterFromJavascript:(NSString *)parameterName value:(Float32)value
{
    AudioUnitParameter parameter = {mAU, (int)[parameterIndices[parameterName] integerValue], kAudioUnitScope_Global, 0};
    
    NSAssert(AUParameterSet(mAUEventListener,
                            NULL,
                            &parameter,
                            (Float32)value, 0) == noErr,
             @"[CsoundAUView valueChanged:] AUParameterSet()");
}


@end
