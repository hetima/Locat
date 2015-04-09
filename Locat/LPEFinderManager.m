//
//  LPEFinderManager.m
//  Locat
//
//  Created by hetima on 2015/04/07.
//  Copyright (c) 2015年 hetima. All rights reserved.
//


#import "External.h"
#import "LPEFinderManager.h"

@implementation LPEFinderManager{
    BOOL _isPanelOpen;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isPanelOpen=NO;

        [[NSDistributedNotificationCenter defaultCenter]addObserver:self selector:@selector(notePanelAppear:) name:LPEOpenSavePanelAppearNote object:nil];
        [[NSDistributedNotificationCenter defaultCenter]addObserver:self selector:@selector(notePanelDisappear:) name:LPEOpenSavePanelDisappearNote object:nil];


        [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask handler:^NSEvent *(NSEvent *event) {
            if([self handleFinderWindowKeyDown:event]){
                return nil;
            }
            return event;
        }];

    }
    return self;
}


- (void)notePanelAppear:(NSNotification*)note
{
    _isPanelOpen=YES;
}


- (void)notePanelDisappear:(NSNotification*)note
{
    _isPanelOpen=NO;
}


- (BOOL)handleFinderWindowKeyDown:(NSEvent*)event
{
    if (!_isPanelOpen) {
        return NO;
    }
    unsigned short key=[event keyCode];
    if(!(key==36||key==76)){
        return NO;
    }

    NSEventModifierFlags flag=[event modifierFlags];
    

    BOOL shift= (flag & (NSShiftKeyMask|NSCommandKeyMask))==NSShiftKeyMask ? YES:NO;
    BOOL alt= (flag & (NSAlternateKeyMask|NSCommandKeyMask))==NSAlternateKeyMask ? YES:NO;
    
    if(!(shift||alt)){
        return NO;
    }
    
    BOOL result;
    
    if(alt){
        result=[self locateSelectionOrTaeget];
    }else{
        result=[self locateTargetOrSelection];
    }
    return result;
}


- (BOOL)locateTargetOrSelection
{
    NSString* target=[self currentTarget];
    if (target) {
        [self locate:target];
        return YES;
    }
    NSString* selection=[self currentSelection];
    if (selection) {
        [self locate:selection];
        return YES;
    }
   
    return NO;
}


- (BOOL)locateSelectionOrTaeget
{
    NSString* selection=[self currentSelection];
    if (selection) {
        [self locate:selection];
        return YES;
    }
    NSString* target=[self currentTarget];
    if (target) {
        [self locate:target];
        return YES;
    }
   
    return NO;
}


- (void)locate:(NSString*)string
{
    [[NSDistributedNotificationCenter defaultCenter]postNotificationName:LPELocatedNote object:string userInfo:nil deliverImmediately:YES];
}




//TFENode の中身はリークしているかもしない。 NodeDisposeNodeRef() とかあるっぽい

- (NSString*)currentTarget
{
    id winCtl=((id(*)(id, SEL, ...))objc_msgSend)(NSClassFromString(@"TGlobalWindowController"),
        NSSelectorFromString(@"frontmostBrowserWindowControllerIncludingDesktop"));
    id containerCtl=((id(*)(id, SEL, ...))objc_msgSend)(winCtl, NSSelectorFromString(@"activeContainer"));
    
    NSString* targetPath=nil;
    //target
    struct TFENode target;
    //struct TString string;
    target.fNodeRef=nil;
    //string.fString=nil;
    
    ((void(*)(void*, id, SEL, ...))objc_msgSend_stret)(&target, containerCtl, NSSelectorFromString(@"target"));
    targetPath=[self pathForNode:&target];
    
    return targetPath;
}


- (NSString*)currentSelection
{
    id winCtl=((id(*)(id, SEL, ...))objc_msgSend)(NSClassFromString(@"TGlobalWindowController"),
        NSSelectorFromString(@"frontmostBrowserWindowControllerIncludingDesktop"));
    id containerCtl=((id(*)(id, SEL, ...))objc_msgSend)(winCtl, NSSelectorFromString(@"activeContainer"));
    
    NSString* selectionPath=nil;
    
    //selection
    struct TFENodeVector selection;
    selection._begin=nil;
    selection._end=nil;
    selection._end_cap=nil;
    
    unsigned long long count=((unsigned long long(*)(id, SEL, ...))objc_msgSend)(containerCtl, NSSelectorFromString(@"getSelectedNodes:upTo:"), &selection, 1);
    if (count>0) {
        struct TFENode* firstSelection=selection._begin;
        selectionPath=[self pathForNode:firstSelection];
    }

    return selectionPath;
}


- (NSString*)currentSelectionDirectory
{
    NSString* selection=[self currentSelection];
    if (![selection hasSuffix:@"/"]) {
        selection=[selection stringByDeletingLastPathComponent];
    }

    return selection;
}


- (NSString*)pathForNode:(struct TFENode*)node
{
    NSString* result=nil;
    struct TString string;
    string.fString=nil;
    
    ((void(*)(void*, id, SEL, ...))objc_msgSend_stret)(&string, NSClassFromString(@"TGlobalWindowController"), NSSelectorFromString(@"urlForNode:"), node);
    if (string.fString) {
        result=[NSString stringWithString:(__bridge NSString*)string.fString];
        CFRelease(string.fString); //release して良いのかどうか
        string.fString=nil;
        if (![result hasPrefix:@"file:"]) {
            result=nil;
        }
    }
    
    return result;
}

@end
