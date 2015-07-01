//
//  XcodeIDE.h
//  RTImageAssets
//
//  Created by ricky on 14-12-10.
//  Copyright (c) 2014年 rickytan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class IDEWorkspace;
@class IDEWorkspaceSettings;
@class IDEWorkspaceSharedSettings;
@class IDEWorkspaceUserSettings;

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
@property(retain, nonatomic) IDEWorkspaceSharedSettings *sharedSettings;
@property(retain, nonatomic) IDEWorkspaceUserSettings *userSettings;
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

@protocol IDEApplicationEventDelegate <NSObject>
@optional
- (BOOL)application:(id)arg1 shouldSendEvent:(id)arg2;
@end


@interface DVTApplication : NSApplication
- (id)addActionMonitorWithHandlerBlock:(id)arg1;
@end


@interface IDEApplication : DVTApplication <NSMenuDelegate>
@property(retain) id <IDEApplicationEventDelegate> eventDelegate; // @synthesize
@end


@interface IBICAbstractCatalogItem : NSObject <NSCoding>
@property(readonly, nonatomic) NSSet *children; // @synthesize children=_children;
@property(readonly, nonatomic) IBICAbstractCatalogItem *parent; // @synthesize parent=_parent;
@property(readonly, nonatomic) NSDate *manifestModificationDate; // @synthesize manifestModificationDate=_manifestModificationDate;
@property(readonly, nonatomic) NSDate *modificatoinDate; // @synthesize modificatoinDate=_modificatoinDate;
@property(copy, nonatomic) NSURL *absoluteFileURL; // @synthesize absoluteFileURL=_absoluteFileURL;
@property(copy, nonatomic) NSString *explicitContainingDirectory; // @synthesize explicitContainingDirectory=_explicitContainingDirectory;
@property(copy, nonatomic) NSString *fileName; // @synthesize fileName=_fileName;
@property long long changeCount; // @synthesize changeCount=_changeCount;
@property(readonly, nonatomic) NSArray *displayOrderedChildren;
@property(readonly) NSString *absoluteManifestFilePath;
@property(readonly) NSData *manifestFileData;
@property(readonly) NSString *manifestFileName;
@property(readonly, nonatomic) NSString *relativeFilePathFromRoot;
@property(readonly, nonatomic) NSString *relativeIdentifierPath;
@property(copy, nonatomic) NSString *absoluteFilePath;
@property(readonly, nonatomic) BOOL canBeEmbeddedInFolder;
@property(readonly, nonatomic) BOOL canHaveChildren;
@property(readonly, nonatomic) NSString *identifier;
@property(readonly, nonatomic) NSString *displayName;
@end

@interface IBICFolder : IBICAbstractCatalogItem
- (BOOL)fileStructureSnapshotChildWouldMapToModelChild:(id)arg1;
- (void)replaceChildrenFromFileSystemSnapshot:(id)arg1 results:(id)arg2;
- (Class)itemClassForDirectoryExtension:(id)arg1;
- (id)imageSetWithFileName:(id)arg1;
- (id)imageSetWithName:(id)arg1;
- (id)folderForFileName:(id)arg1;
- (id)childWithFileName:(id)arg1;
- (id)validatedFileNameForProposedDisplayName:(id)arg1;
- (id)enclosingFolderIncludingReceiver;
- (BOOL)canBeEmbeddedInFolder;
- (BOOL)canHaveChildren;
- (id)identifier;
- (id)displayName;
- (id)descriptionShortClassName;

@end

@interface IBICCatalog : IBICFolder
- (void)replaceChildrenWithDiskContent:(id)arg1;
- (BOOL)canBeEmbeddedInFolder;
- (BOOL)canHaveChildren;
- (id)displayName;
- (id)allIconSets;
- (id)allImageSets;
- (id)catalog;
- (id)descriptionShortClassName;

@end


@interface IBICMultipartImage : IBICAbstractCatalogItem
{
}

+ (Class)repIdentifierClass;
+ (Class)slotClass;
+ (id)pluralTypeNameForIssues;
+ (id)typeNameForIssues;
+ (id)keysThatImpactImageName;
+ (id)fileNameForImageSetName:(id)arg1;
+ (Class)imageRepClass;
+ (id)fileExtension;
+ (id)defaultInstanceForPlatforms:(id)arg1;
+ (id)defaultImageName;
+ (Class)classForDirectoryExtension:(id)arg1;
+ (id)multipartImageClassesInImportOrder;
+ (id)multipartImageClasses;
+ (id)allocWithZone:(struct _NSZone *)arg1;
- (void)populateMutatorsToAddRequiredChildCounterparts:(id)arg1;
- (id)suggestedFileNameForImageRepInSlot:(id)arg1;
- (void)populateIssues:(id)arg1 context:(id)arg2;
- (void)assertChildIsLegalToAdd:(id)arg1;
- (id)pluralTypeNameForIssues;
- (id)typeNameForIssues;
- (id)descriptionShortClassName;
- (id)imageRepForImageRepIdentifier:(id)arg1;
- (id)imageRepForSlot:(id)arg1;
- (id)imageRepForIdentifier:(id)arg1;
- (id)childForIdentifier:(id)arg1;
- (BOOL)canBeEmbeddedInFolder;
- (BOOL)canHaveChildren;
- (id)identifier;
- (id)displayName;
@property(copy, nonatomic) NSString *imageName;
- (id)validatedFileNameForProposedImageName:(id)arg1;
- (id)enclosingMultipartImageIncludingReceiver;

@end


@interface IBICMappedMultipartImage : IBICMultipartImage
{
}

+ (id)orderedSlotComponentClasses;
+ (double)currentContentsJSONVersionNumber;
+ (double)latestUnderstoodContentsJSONVersionNumber;
+ (double)earliestUnderstoodContentsJSONVersionNumber;
- (id)contentsDictionary;
- (void)populateContentsJSONImageEntry:(id)arg1 forImageRep:(id)arg2;
- (BOOL)shouldIncludeImageRepInContentsJSON:(id)arg1;
- (void)replaceChildrenFromFileSystemSnapshot:(id)arg1 results:(id)arg2;
- (id)imageRepsByMergingLooseFilesContentFromSnapshot:(id)arg1 withJSONReferencedContent:(id)arg2 results:(id)arg3;
- (id)imageRepsFromContentsJSONImageEntries:(id)arg1 results:(id)arg2;
- (id)imageRepFromImageEntry:(id)arg1 results:(id)arg2;
- (id)validatedContentsJSONImageEntriesFromSnapshot:(id)arg1 results:(id)arg2;
- (id)readContentsJSONFromSnapshot:(id)arg1 results:(id)arg2;
- (BOOL)fileStructureSnapshotChildWouldMapToModelChild:(id)arg1;
- (id)manifestFileData;
- (id)manifestFileName;
- (id)orderedSlotComponentClasses;

@end



@interface IBICAppIconSet : IBICMappedMultipartImage
{
    BOOL _preRendered;
}

+ (id)pluralTypeNameForIssues;
+ (id)typeNameForIssues;
+ (id)fileExtension;
+ (id)defaultInstanceForPlatforms:(id)arg1;
+ (id)defaultImageName;
+ (double)currentContentsJSONVersionNumber;
+ (double)latestUnderstoodContentsJSONVersionNumber;
+ (double)earliestUnderstoodContentsJSONVersionNumber;
+ (Class)imageRepClass;
@property(nonatomic, getter=isPreRendered) BOOL preRendered; // @synthesize preRendered=_preRendered;
- (id)descriptionShortClassName;
- (id)contentsDictionary;
- (id)readContentsJSONFromSnapshot:(id)arg1 results:(id)arg2;
- (id)suggestedFileNameForImageRepInSlot:(id)arg1;
- (id)childForIdentifier:(id)arg1;
- (id)imageRepForIdentifier:(id)arg1;
- (id)imageRepForImageRepIdentifier:(id)arg1;
- (id)imageRepForSlot:(id)arg1;

@end

@interface IBICLaunchImageSet : IBICMappedMultipartImage
{
}

+ (id)pluralTypeNameForIssues;
+ (id)typeNameForIssues;
+ (id)fileExtension;
+ (id)defaultInstanceForPlatforms:(id)arg1;
+ (id)defaultImageName;
+ (double)currentContentsJSONVersionNumber;
+ (double)latestUnderstoodContentsJSONVersionNumber;
+ (double)earliestUnderstoodContentsJSONVersionNumber;
+ (Class)imageRepClass;
- (id)descriptionShortClassName;
- (id)validatedContentsJSONImageEntriesFromSnapshot:(id)arg1 results:(id)arg2;
- (id)suggestedFileNameForImageRepInSlot:(id)arg1;
- (id)childForIdentifier:(id)arg1;
- (id)imageRepForIdentifier:(id)arg1;
- (id)imageRepForImageRepIdentifier:(id)arg1;
- (id)imageRepForSlot:(id)arg1;

@end


@interface IBICMultipartImageRepSlot : NSObject
{
    NSDictionary *_componentsByClass;
}

+ (id)orderedComponentClasses;
+ (id)defaultSlot;
+ (id)emptySlot;
+ (id)allocWithZone:(struct _NSZone *)arg1;
+ (id)slotWithComponents:(id)arg1;
+ (id)slotWithComponents:(id *)arg1 count:(unsigned long long)arg2;
- (id)requiredPointSize;
- (id)requiredPixelSize;
- (id)suggestedRepNameForMultipartImageSetName:(id)arg1;
- (id)detailAreaKey;
- (id)requiredFileName;
- (id)displayName;
- (id)description;
- (id)stringRepresentation;
- (id)shortDisplayNameDefiningItem;
- (unsigned long long)hash;
- (BOOL)isEqual:(id)arg1;
- (BOOL)isEqualToMultipartImageRepSlot:(id)arg1;
- (long long)compareDisplayOrder:(id)arg1;
- (id)slotComponentsForClasses:(id)arg1;
- (id)slotComponentForClass:(Class)arg1;
- (void)enumerateOrderedSlotComponentsAndValues:(id)arg1;
- (id)initWithComponents:(id)arg1;
- (void)captureComponents;

@end



@interface IBICMultipartImageRep : IBICAbstractCatalogItem
+ (id)keysThatImpactDisplayOrder;
+ (id)validSourceImageExtensions;
+ (id)imageRepWithRepIdentifier:(id)arg1;
+ (id)imageRepWithSlot:(id)arg1 fileName:(id)arg2 andUnassigned:(BOOL)arg3;
+ (Class)slotClass;
+ (Class)multiplartImageClass;
+ (Class)repIdentifierClass;
+ (id)allocWithZone:(struct _NSZone *)arg1;
@property(copy, nonatomic) NSData *imageData; // @synthesize imageData=_imageData;
@property(copy, nonatomic) IBICMultipartImageRepSlot *slot; // @synthesize slot=_slot;
@property(nonatomic, getter=isUnassigned) BOOL unassigned; // @synthesize unassigned=_unassigned;
- (id)suggestedFileName;
@property(readonly) NSValue *imageDataPixelSize;
@property(readonly) NSValue *requiredPointSize;
@property(readonly) NSValue *requiredPixelSize;
- (void)populateIssues:(id)arg1 context:(id)arg2;
- (BOOL)updateModificationDatesWithMutationResult:(id)arg1;
- (void)setImageDataFromPath:(id)arg1;
- (BOOL)fileStructureSnapshotChildWouldMapToModelChild:(id)arg1;
- (long long)compareDisplayOrder:(id)arg1;
- (void)replaceChildrenFromFileSystemSnapshot:(id)arg1 results:(id)arg2;
- (id)fileWrapperRepresentationWithOptions:(unsigned long long)arg1;
- (id)parent;
- (void)enumerateDescriptionAttributeComponents:(id)arg1;
- (BOOL)isBrokenFileReference;
- (id)identifier;
- (id)structuredIdentifier;
- (BOOL)canBeEmbeddedInFolder;
- (BOOL)canHaveChildren;
- (id)descriptionShortClassName;
- (BOOL)isMinimallyFitForCompiling;
@property(readonly) NSString *shortDisplayName;
- (id)displayName;
- (id)initWithSlot:(id)arg1;

@end


@interface IBICIconSetRep : IBICMultipartImageRep
{
}

+ (id)outputImageExtension;
+ (Class)multiplartImageClass;
+ (Class)repIdentifierClass;
+ (id)imageRepWithSlot:(id)arg1 fileName:(id)arg2 andUnassigned:(BOOL)arg3;
+ (id)imageRepWithRepIdentifier:(id)arg1;
- (BOOL)isMinimallyFitForCompiling;
- (BOOL)isImageDataSizedProperly;
- (id)descriptionShortClassName;
- (void)setSlot:(id)arg1;
- (id)slot;
- (id)structuredIdentifier;
- (id)parent;
- (id)initWithSlot:(id)arg1;

@end


@interface IBICCatalogSynchronizer : NSObject
+ (id)synchronizerForCatalogAtPath:(NSString *)path;
- (void)preventSynchronizationDuring:(id)arg1;
- (BOOL)isSynchronizationEnabled;
- (void)enableSynchronization;
- (void)disableSynchronization;
- (void)applyMutationToModelAndScheduleForDisk:(id)arg1;
- (id)replaceCatalogWithContentsOfPathWhileItIsKnowThatSyncOperationsAreNotInflightAndAreDisabled:(id)arg1;
- (id)replaceCatalogWithContentsOfPath:(id)arg1;
- (void)validateBatchedChanges:(id)arg1;
- (void)validateChangesToDiskIfNeeded;
- (void)validateChangesFromDiskIfNeeded;
- (void)resetContentFromDisk;
@property(readonly) IBICCatalog *catalog;
- (void)primitiveInvalidate;
- (id)init;
- (id)initByTakingOwnershipsOfCatalog:(id)arg1;

// Remaining properties
@property(readonly, nonatomic, getter=isValid) BOOL valid;
@end

@interface DTAssetiLifeDelegate : NSObject
@end
