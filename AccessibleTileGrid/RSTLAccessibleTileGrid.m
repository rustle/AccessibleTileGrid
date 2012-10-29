//
//  RSTLAccessibleTileGrid.m
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

#import "RSTLAccessibleTileGrid.h"

@interface RSTLAccessibleTileGrid ()
@property (nonatomic) NSArray *tiles;
@end

@implementation RSTLAccessibleTileGrid

+ (Class)tileClass
{
	return [RSTLAccessibleTile class];
}

#pragma mark -

- (instancetype)initWithRows:(NSUInteger)rows columns:(NSUInteger)columns accessibilityContainer:(id)accessibilityContainer
{
	self = [super initWithAccessibilityContainer:accessibilityContainer];
	if (self)
	{
		_columns = columns;
		_rows = rows;
	}
	return self;
}

#pragma mark -

- (void)layoutTiles
{
	CGRect frame = self.accessibilityFrame;
	CGFloat tileWidth = frame.size.width / _columns;
	CGFloat tileHeight = frame.size.height / _rows;
	CGRect tileFrame = CGRectMake(0.0f, 0.0f, tileWidth, tileHeight);
	for (NSUInteger column = 0; column < _columns; column++)
	{
		for (NSUInteger row = 0; row < _rows; row++)
		{
			RSTLAccessibleTile *tile = [self tiles][_columns * row + column];
			tile.row = row;
			tile.column = column;
			tileFrame.origin.x = tileWidth * column + frame.origin.x;
			tileFrame.origin.y = tileHeight * row + frame.origin.y;
			tile.accessibilityFrame = tileFrame;
		}
	}
}

- (void)playTileAtPoint:(CGPoint)point
{
	CGRect frame = self.frameRelativeToContainer;
	CGFloat tileWidth = frame.size.width / _columns;
	CGFloat tileHeight = frame.size.height / _rows;
	ASTilePosition position;
	position.column = (NSUInteger)point.x / (NSUInteger)tileWidth;
	position.row = (NSUInteger)point.y / (NSUInteger)tileHeight;
	UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, [NSString stringWithFormat:@"Playing: %@", [self characterAtPosition:position]]);
}

#pragma mark -

#define tile_position _columns * position.row + position.column

- (NSString *)characterAtPosition:(ASTilePosition)position
{
	return [self.tiles[tile_position] character];
}

- (void)setCharacter:(NSString *)character atPosition:(ASTilePosition)position
{
	[self.tiles[tile_position] setCharacter:character];
}

- (NSString *)ownerAtPosition:(ASTilePosition)position
{
	return [self.tiles[tile_position] owner];
}

- (void)setOwner:(NSString *)owner atPosition:(ASTilePosition)position
{
	[self.tiles[tile_position] setOwner:owner];
}

- (bool)isBlockedInAtPosition:(ASTilePosition)position
{
	return [self.tiles[tile_position] isBlockedIn];
}

- (void)setIsBlockedIn:(bool)isBlockedIn atPosition:(ASTilePosition)position
{
	[self.tiles[tile_position] setIsBlockedIn:isBlockedIn];
}

- (NSArray *)tiles
{
	if (_tiles)
		return _tiles;
	NSUInteger count = _columns * _rows;
	NSMutableArray *tiles = [[NSMutableArray alloc] initWithCapacity:count];
	for (NSUInteger i = 0; i < count; i++)
	{
		RSTLAccessibleTile *tile = [[[[self class] tileClass] alloc] initWithAccessibilityContainer:self];
		[tiles addObject:tile];
	}
	_tiles = [tiles copy];
	return tiles;
}

#pragma mark -

- (BOOL)isAccessibilityElement
{
	return NO;
}

- (NSInteger)accessibilityElementCount
{
	return [self.tiles count];
}

- (id)accessibilityElementAtIndex:(NSInteger)index
{
	return self.tiles[index];
}

- (NSInteger)indexOfAccessibilityElement:(id)element
{
	return [self.tiles indexOfObject:element];
}

@end
