//
//  IAGenerateOperation.m
//  RTImageAssets
//
//  Created by ricky on 14-12-10.
//  Copyright (c) 2014年 rickytan. All rights reserved.
//

#import "IAGenerateOperation.h"

#import "IAImageSet.h"

@interface IAImageSet (Generate)
- (void)generate3xIfNeeded;
- (void)generate2xIfNeeded;
- (void)generate1xIfNeeded;
- (void)generateMissing;
@end

@interface IAGenerateOperation ()
@property (nonatomic, strong) IAImageAssets *imageAssets;
@end

@implementation IAGenerateOperation

+ (instancetype)operationWithAssets:(IAImageAssets *)assets
{
    IAGenerateOperation *op = [[IAGenerateOperation alloc] init];
    op.imageAssets = assets;
    //op.name = assets.bundle.bundlePath.lastPathComponent;
    return op;
}

- (void)main
{
    for (IAImageSet *set in self.imageAssets.imageSets) {
        [set generateMissing];
    }
}

@end
