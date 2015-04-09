//
//  LPELocat.m
//  Locat
//
//  Created by hetima on 2015/04/07.
//  Copyright (c) 2015 hetima. All rights reserved.
//


#import "External.h"
#import "LPELocat.h"
#import "LPEOpenSavePanelManager.h"
#import "LPEFinderManager.h"

#if 0

id LPENodeObjectForURL(NSURL* url)
{
    return LPENodeObjectForURLString([url absoluteString]);
}


id LPENodeObjectForURLString(NSString* url)
{
    // @"public.file-url" では file: 以外 (x-finder-tag: など) を渡すとクラッシュ
    if (![url hasPrefix:@"file:"]) {
        return nil;
    }

    Class pbc=NSClassFromString(@"FI_TFENodePasteboardItem");
    id pb=((id(*)(id, SEL, ...))objc_msgSend)([pbc alloc], @selector(initWithPasteboardPropertyList:ofType:), url, @"public.file-url");
    struct TFENode* node=((struct TFENode*(*)(id, SEL, ...))objc_msgSend)(pb, NSSelectorFromString(@"node"));
    id result=[FINode nodeFromNodeRef:node->fNodeRef];
    
    return result;
}

#endif


static LPELocat *sharedPlugin;

@implementation LPELocat{
    LPEOpenSavePanelManager* _panelManager;
    LPEFinderManager* _finderManager;
}


+ (BOOL)shouldLoadPlugin
{

    if (floor(NSAppKitVersionNumber) < NSAppKitVersionNumber10_9) {
        NSLog(@"Locat SIMBL Plug-in requires OSX 10.9 or later");
        return NO;
    }
    
    return YES;
}


+(void)install
{
    static dispatch_once_t onceToken;
    if ([self shouldLoadPlugin]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[self alloc] init];
        });
    }else{
        NSLog(@"Locat SIMBL Plug-in was not loaded. shouldLoadPlugin==NO");
    }
}


- (instancetype)init
{
    if (self = [super init]) {
        _panelManager=nil;
        _finderManager=nil;
        
        NSString *appBundleIdentifier = [[NSBundle mainBundle]bundleIdentifier];
        if ([appBundleIdentifier isEqualToString:@"com.apple.finder"]) {
            _finderManager=[[LPEFinderManager alloc]init];
        }else{
            _panelManager=[[LPEOpenSavePanelManager alloc]init];
        }
    }
    
    return self;
}


@end
