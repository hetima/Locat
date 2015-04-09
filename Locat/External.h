//
//  External.h
//  Locat
//
//  Created by hetima on 2015/04/07.
//  Copyright (c) 2015 hetima. All rights reserved.
//


#import <AppKit/AppKit.h>


//FinderKit

struct TFENode {
    struct OpaqueNodeRef *fNodeRef;
};

struct TFENodeVector {
    struct TFENode *_begin;
    struct TFENode *_end;
    struct TFENode *_end_cap;
};

struct TString {
    CFStringRef fString;
};



#if 0

//not used
//__attribute__((visibility("hidden")))
@interface FI_TFENodePasteboardItem : NSObject <NSPasteboardReading, NSPasteboardWriting>
{
    struct TFENode _node;
}

+ (unsigned long long)readingOptionsForType:(id)arg1 pasteboard:(id)arg2;
+ (id)readableTypesForPasteboard:(id)arg1;
@property(readonly, nonatomic) const struct TFENode *node; // @synthesize node=_node;
- (id)pasteboardPropertyListForType:(id)arg1;
- (unsigned long long)writingOptionsForType:(id)arg1 pasteboard:(id)arg2;
- (id)writableTypesForPasteboard:(id)arg1;
- (id)copyURLForType:(id)arg1;
- (id)initWithPasteboardPropertyList:(id)arg1 ofType:(id)arg2;
- (id)initWithNode:(const struct TFENode *)arg1;

@end



//not used
@interface FILocationPopUp : NSPopUpButton

/*
 delegate:
 Open/SavePanel では FIFinderViewGutsController
 TitlebarPopover では NSDocumentTitlebarPopoverViewService
 */

+ (void)initialize;
@property BOOL shouldAllowTargetingCloud; // @synthesize shouldAllowTargetingCloud=_shouldAllowTargetingCloud;
@property BOOL shouldShowKeyEquivalents; // @synthesize shouldShowKeyEquivalents=_shouldShowKeyEquivalents;
@property(copy) NSArray *ubiquityContainerURLs; // @synthesize ubiquityContainerURLs=_ubiquityContainerURLs;
@property BOOL shouldIncludeAncestors; // @synthesize shouldIncludeAncestors=_shouldIncludeAncestors;
@property BOOL shouldShowFavorites; // @synthesize shouldShowFavorites=_shouldShowFavorites;
@property BOOL shouldShowDevices; // @synthesize shouldShowDevices=_shouldShowDevices;
- (BOOL)performKeyEquivalent:(id)arg1;
- (void)menuNeedsUpdate:(id)arg1;
- (void)adjustLocationPopUpConfiguration;
- (void)ubiquityIdentityChanged:(id)arg1;
- (void)addOtherSection;
- (void)addFavoritesItems;
- (void)addRecentsItems:(const struct TFENodeVector *)arg1;
- (void)addDevicesItems;
- (void)addICloudAndSubfolders;
- (struct TFENode)iCloudContainerToUse;
- (id)imageForCloudFolder:(const struct TFENode *)arg1;
- (struct TFENodeVector)cloudFolders;
- (void)addTargetItems;
- (void)_addMenuItemsForParentNode:(struct TFENode *)arg1 sectionTitleKey:(struct __CFString *)arg2;
- (void)addMenuItemForNode:(const struct TFENode *)arg1;
- (void)addSeparatorAndSectionTitle:(struct __CFString *)arg1;
- (void)getRequiredICloudContainer:(struct TFENode *)arg1;
- (void)getAlternateICloudContainer:(id *)arg1;
- (void)setAlternateICloudContainer:(id)arg1 name:(id)arg2;
- (BOOL)nodeIsInsideCloud:(const struct TFENode *)arg1;
- (BOOL)nodeIsAnyICloudDocumentsFolder:(const struct TFENode *)arg1;
- (BOOL)inMovePanel;
- (id)recentPlaces;
- (void)otherLocation:(id)arg1;
- (void)retargetFromMenuItem:(id)arg1;
@property BOOL shouldShowCloud;
@property(retain) NSURL *directoryURL;
- (void)setTargetNode:(const struct TFENode *)arg1;
@property id delegate; // @dynamic delegate;
- (struct TFENode)targetNode;
- (void)didChangeTarget:(const struct TFENode *)arg1;
- (BOOL)isSavePanel;
- (void)finalize;
- (void)dealloc;
- (id)initWithCoder:(id)arg1;
- (id)initWithFrame:(struct CGRect)arg1;
- (void)_commonLocationPopUpInit;

@end

//not used
@interface FIFinderViewGutsController : NSViewController

@property(nonatomic) BOOL isSavePanel; // OpenPanel だと NO
- (id)activeLocationPopUp;
@end

#endif

#if 0

//DesktopServicesPriv

@interface FINode : NSObject <NSCopying>

+ (id)nodeFromNodeRef:(struct OpaqueNodeRef *)arg1;
- (id)original;
- (id)copyWithZone:(struct _NSZone *)arg1;
- (id)mutableCopy;
- (void *)asTNode;
- (struct OpaqueNodeRef *)nodeRef;

@end

@interface FITNode : FINode
{
    void *_node[10];
}

- (id)description;
- (oneway void)release;
- (oneway void)releaseUnderMonitor;
- (void *)asTNode;
- (struct TNode *)asTNodeObject;
- (void)finalize;
- (void)dealloc;
- (void)deleteTNode;

@end

#endif





#if 0
//Finder

@interface TBrowserContainerController : NSResponder
- (struct TFENode)target;
- (void)browserSelectionChanged;
- (unsigned long long)getSelectedNodes:(struct TFENodeVector *)arg1 upTo:(unsigned long long)arg2;


@interface TGlobalWindowController : NSResponder
+ (id)frontmostBrowserWindowController; //TBrowserWindowController
+ (id)frontmostBrowserWindowControllerForScreen:(id)arg1;
+ (id)frontmostBrowserWindowControllerIncludingDesktop;
+ (id)frontmostBrowserWindowControllerExcludingDesktop;
+ (struct TString)urlForNode:(const struct TFENode *)arg1;
+ (struct TFENode)nodeForUrl:(const struct TString *)arg1;
+ (id)globalWindowController;

- (void)browserWindowDidBecomeMain:(id)arg1;
@end

@interface TBrowserWindowController : TBaseBrowserWindowController
- (struct TFENode)target;
@property(retain, nonatomic) TBrowserContainerController *activeContainer; // @synthesize activeContainer=_activeContainer;
- (void)containerSelectionChanged:(TBrowserContainerController*)arg1;
- (void)tabDidBecomeActive:(id)arg1;
- (void)windowDidBecomeMain:(id)arg1;

@end
#endif

#if 0
//ViewBridge.framework

@interface NSViewServiceBridge : NSViewBridge

@property(readonly) NSViewServiceMarshal *viewServiceMarshal; // @synthesize viewServiceMarshal=_marshal;
- (int)processIdentifier;
@end

@interface NSViewServiceApplication : NSApplication
@end

#endif


#if 0
//com.apple.appkit.xpc.openAndSavePanelService.xpc
@interface NSOpenPanelServicePanel : NSOpenPanel <NSOpenSaveServicePanelProtocol>
- (id)initWithPID:(int)arg1;

@end

@interface NSSavePanelServicePanel : NSSavePanel <NSOpenSaveServicePanelProtocol>
- (id)initWithPID:(int)arg1;

@end


#endif
