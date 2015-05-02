//
//  LPEOpenSavePanelManager.m
//  Locat
//
//  Created by hetima on 2015/04/07.
//  Copyright (c) 2015 hetima. All rights reserved.
//

#import "External.h"
#import "LPEOpenSavePanelManager.h"
#import "LPELocat.h"

@implementation LPEOpenSavePanelManager{
    //__weak FIFinderViewGutsController* _gutsCtl;
    __weak NSWindow* _panel;
    BOOL _isViewServiceApplication;
    int _xpc_owner_pid;
}


- (instancetype)init
{
    if (self = [super init]) {
        _panel=nil;
        _isViewServiceApplication=NO;
        _xpc_owner_pid=0;
        
        // xpc
        if([[[NSApplication sharedApplication]className]isEqualToString:@"NSViewServiceApplication"]){
            _isViewServiceApplication=YES;
            KZRMETHOD_SWIZZLING_("NSOpenPanelServicePanel", "initWithPID:", id, call, sel)
            ^id(id slf, int arg1)
            {
                id result=call(slf, sel, arg1);
                _xpc_owner_pid=arg1;
                return result;
            }_WITHBLOCK;
            
            KZRMETHOD_SWIZZLING_("NSSavePanelServicePanel", "initWithPID:", id, call, sel)
            ^id(id slf, int arg1)
            {
                id result=call(slf, sel, arg1);
                _xpc_owner_pid=arg1;
                return result;
            }_WITHBLOCK;
        }
        
/*
        
        KZRMETHOD_SWIZZLING_("FIFinderViewGutsController", "windowOrderedIn", void, call, sel)
        ^(id slf)
        {
            call(slf, sel);
            [self panelDidAppear:slf];
        }_WITHBLOCK;
        
        KZRMETHOD_SWIZZLING_("FIFinderViewGutsController", "windowOrderedOut", void, call, sel)
        ^(id slf)
        {
            [self panelWillDisappear:slf];
            call(slf, sel);
        }_WITHBLOCK;
 */

        
        KZRMETHOD_SWIZZLING_("NSSavePanel", "orderWindow:relativeTo:", void, call, sel)
        ^(id slf, NSWindowOrderingMode arg1, long long arg2)
        {
            if (arg1==NSWindowAbove) {
                //_initContentView で実行済み
                //[self panelDidAppear:slf];
            }else{
                [self panelWillDisappear:slf];
            }
            call(slf, sel, arg1, arg2);
        }_WITHBLOCK;
        
        
        KZRMETHOD_SWIZZLING_("NSSavePanel", "_initContentView", void, call, sel)
        ^(id slf)
        {
            call(slf, sel);
            //orderWindow:relativeTo: では完全じゃないのでここで
            [self panelDidAppear:slf];
            
            //probably FinderKit was loaded
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                //select popup with cmd-key
                KZRMETHOD_SWIZZLING_("FILocationPopUp", "retargetFromMenuItem:", void, call, sel)
                ^(id slf, id arg1)
                {
                    id delegate=[slf delegate];
                    if ([[delegate className]isEqualToString:@"FIFinderViewGutsController"]) {
                        if ([self interceptLocationPopUp:slf item:arg1]) {
                            return;
                        }
                    }
                    call(slf, sel, arg1);
                    
                }_WITHBLOCK;
            });
            
        }_WITHBLOCK;
        
    }
    return self;
}


- (void)noteLocated:(NSNotification*)note
{
    NSString* urlString=[note object];
    if (!_panel || ![urlString isKindOfClass:[NSString class]]) {
        return;
    }
    
    if ([self locateURLString:urlString]) {
        [self activateApplication];
    }
}


- (void)panelDidAppear:(NSWindow*)panel
{
    if (!_panel) {
        _panel=panel;
        [[NSDistributedNotificationCenter defaultCenter]addObserver:self selector:@selector(noteLocated:) name:LPELocatedNote object:nil];
        [[NSDistributedNotificationCenter defaultCenter]postNotificationName:LPEOpenSavePanelAppearNote object:nil  userInfo:nil deliverImmediately:YES];
    }
}


- (void)panelWillDisappear:(NSWindow*)panel
{
    if (_panel) {
        [[NSDistributedNotificationCenter defaultCenter]removeObserver:self name:LPELocatedNote object:nil];
        [[NSDistributedNotificationCenter defaultCenter]postNotificationName:LPEOpenSavePanelDisappearNote object:nil  userInfo:nil deliverImmediately:YES];
        _panel=nil;
    }
}


- (BOOL)locateURLString:(NSString*)urlString
{
    NSWindow* panel=_panel;
    if (!panel) {
        return NO;
    }
    
    NSURL* url=[NSURL URLWithString:urlString];
    if (!url) {
        return NO;
    }
    
    // -[NSOpenPanel performDragOperation:] をシミュレート
    // NSNavFinderViewFileBrowser
    NSView* navView=((id(*)(id, SEL, ...))objc_msgSend)(panel, NSSelectorFromString(@"_navView"));
    SEL setSelectedURLs=NSSelectorFromString(@"setSelectedURLs:");
    if (navView && [navView respondsToSelector:setSelectedURLs]) {
        NSArray* ary=@[url];
        
        ((void(*)(id, SEL, ...))objc_msgSend)(navView, setSelectedURLs, ary);
        
        //この後 _saveMode も呼んでいるけど
        
        return YES;
    }else{
        LOG(@"navView nil");
    }

    return NO;
}

- (void)activateApplication
{
    NSRunningApplication* app;

    if (_isViewServiceApplication) {
        if (_xpc_owner_pid==0) {
            return;
        }
        app=[NSRunningApplication runningApplicationWithProcessIdentifier:_xpc_owner_pid];
    }else{
        app=[NSRunningApplication currentApplication];
    }
    
    [app activateWithOptions:(/*NSApplicationActivateAllWindows |*/ NSApplicationActivateIgnoringOtherApps)];
    
}


- (BOOL)interceptLocationPopUp:(id)locationPopUp item:(NSMenuItem*)item
{
    NSEvent* event=[NSApp currentEvent];
    NSEventModifierFlags flag=[event modifierFlags];
    //select popup with cmd-key
    if ((flag & NSDeviceIndependentModifierFlagsMask)==NSCommandKeyMask) {
        id nodeObj=[item representedObject];
        SEL slctr=NSSelectorFromString(@"previewItemURL");
        if (![[nodeObj className]isEqualToString:@"FITNode"] || ![nodeObj respondsToSelector:slctr]) {
            return NO;
        }
        NSURL *result=((NSURL *(*)(id, SEL, ...))objc_msgSend)(nodeObj, slctr);
        NSString* path=[result path];
        BOOL isDir=NO;
        [[NSFileManager defaultManager]fileExistsAtPath:path isDirectory:&isDir];
        if (isDir) {
            [[NSWorkspace sharedWorkspace]selectFile:nil inFileViewerRootedAtPath:[result path]];
            [locationPopUp selectItemAtIndex:0];
            return YES;
        }
    }
    
    return NO;
}

@end
