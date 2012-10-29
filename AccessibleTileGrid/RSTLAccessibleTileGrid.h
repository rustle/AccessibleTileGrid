//
//  RSTLAccessibleTileGrid.h
//
//  Created by Doug Russell
//  Copyright (c) 2012 Doug Russell. All rights reserved.
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//  http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "ASAccessibilityElement.h"
#import "RSTLAccessibleTile.h"

typedef struct {
	NSUInteger row;
	NSUInteger column;
} ASTilePosition;

@interface RSTLAccessibleTileGrid : ASAccessibilityElement

+ (Class)tileClass;

@property (nonatomic, readonly) NSArray *tiles;
@property (nonatomic, readonly) NSUInteger rows;
@property (nonatomic, readonly) NSUInteger columns;

- (instancetype)initWithRows:(NSUInteger)rows columns:(NSUInteger)columns accessibilityContainer:(id)accessibilityContainer;

- (void)layoutTiles;

// Point should be relative to frameRelativeToContainer
- (void)playTileAtPoint:(CGPoint)point;

- (NSString *)characterAtPosition:(ASTilePosition)position;
- (void)setCharacter:(NSString *)character atPosition:(ASTilePosition)position;

- (NSString *)ownerAtPosition:(ASTilePosition)position;
- (void)setOwner:(NSString *)owner atPosition:(ASTilePosition)position;

- (bool)isBlockedInAtPosition:(ASTilePosition)position;
- (void)setIsBlockedIn:(bool)isBlockedIn atPosition:(ASTilePosition)position;

@end
