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
