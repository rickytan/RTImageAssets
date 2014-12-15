//
//  XcodeIDE.h
//  RTImageAssets
//
//  Created by ricky on 14-12-10.
//  Copyright (c) 2014年 rickytan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class IDEWorkspace;

@interface DVTFilePath : NSObject
@property(readonly) DVTFilePath *symbolicLinkDestinationFilePath;
@property(readonly) NSURL *fileReferenceURL;
@property(readonly) NSDictionary *fileSystemAttributes;
@property(readonly) NSDictionary *fileAttributes;
@property(readonly) NSString *fileTypeAttribute;
@property(readonly) NSArray *sortedDirectoryContents;
@property(readonly) NSArray *directoryContents;
@property(readonly) NSDate *modificationDate;
@property(readonly) BOOL isExcludedFromBackup;
@property(readonly) BOOL isExecutable;
@property(readonly) BOOL isDeletable;
@property(readonly) BOOL isWritable;
@property(readonly) BOOL isReadable;
@property(readonly) BOOL existsInFileSystem;
@property(readonly) NSString *fileName;
@property(readonly) NSURL *fileURL;
@property(readonly) NSString *pathString;
@property(readonly) DVTFilePath *volumeFilePath;
@property(readonly) DVTFilePath *parentFilePath;
@end

@interface IDEWorkspaceWindowController : NSWindowController
@end

@interface IDEWorkspaceArena : NSObject
@property(readonly) IDEWorkspace *workspace;
@property(readonly) DVTFilePath *testResultsFolderPath;
@property(readonly) DVTFilePath *logFolderPath;
@property(readonly) DVTFilePath *indexPrecompiledHeadersFolderPath;
@property(readonly) DVTFilePath *indexFolderPath;
@property(readonly) DVTFilePath *precompiledHeadersFolderPath;
@property(readonly) DVTFilePath *installingBuildFolderPath;
@property(readonly) DVTFilePath *archivingBuildFolderPath;
@property(readonly) DVTFilePath *buildIntermediatesFolderPath;
@end

@interface IDEWorkspace : NSObject
@property BOOL isCleaningBuildFolder;
@property(nonatomic) BOOL finishedLoading;
@property(nonatomic) BOOL pendingFileReferencesAndContainers;
@property BOOL initialContainerScanComplete;
@property(retain, nonatomic) IDEWorkspaceArena *workspaceArena;
@property(readonly) DVTFilePath *wrappedXcode3ProjectPath;
@property(readonly) NSString *representingTitle;
@property(readonly) DVTFilePath *representingFilePath;
@end

@interface DVTLayoutView_ML : NSView
@end

@protocol IBViewDragDelegate <NSObject>
- (BOOL)view:(id)arg1 performDragOperation:(id)arg2;
- (BOOL)view:(id)arg1 prepareForDragOperation:(id)arg2;
- (unsigned long long)view:(id)arg1 draggingEntered:(id)arg2;
- (id)dragTypesForView:(id)arg1;

@optional
- (void)view:(id)arg1 draggingEnded:(id)arg2;
- (void)view:(id)arg1 draggingExited:(id)arg2;
- (void)view:(id)arg1 concludeDragOperation:(id)arg2;
- (unsigned long long)view:(id)arg1 draggingUpdated:(id)arg2;
@end

@protocol IBICMultipartImageViewDelegate <IBViewDragDelegate>
- (id)multipartImageView:(id)arg1 imageForImageRepIdentifier:(id)arg2;
- (id)multipartImageView:(id)arg1 titleForImageRepIdentifier:(id)arg2;
- (void)multipartImageViewWillLayout:(id)arg1;
- (BOOL)multipartImageView:(id)arg1 interceptMouseUp:(id)arg2;
- (BOOL)multipartImageView:(id)arg1 interceptMouseDragged:(id)arg2 withOriginalMouseDown:(id)arg3;
- (BOOL)multipartImageView:(id)arg1 interceptMouseDown:(id)arg2;
- (void)multipartImageView:(id)arg1 userDidEditTitle:(id)arg2;
- (void)multipartImageView:(id)arg1 performDelete:(id)arg2;
@end

@interface IBICMultipartImageView : DVTLayoutView_ML
@property(nonatomic) __weak id <IBICMultipartImageViewDelegate> delegate;
- (id)effectiveOuterBorderColor;
- (id)effectiveTitleColor;
@end
