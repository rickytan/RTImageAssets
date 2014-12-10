//
//  IAGenerateOperation.h
//  RTImageAssets
//
//  Created by ricky on 14-12-10.
//  Copyright (c) 2014年 rickytan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IAImageAssets;

@interface IAGenerateOperation : NSOperation
@property (nonatomic, readonly) IAImageAssets *imageAssets;

+ (instancetype)operationWithAssets:(IAImageAssets *)assets;
@end
