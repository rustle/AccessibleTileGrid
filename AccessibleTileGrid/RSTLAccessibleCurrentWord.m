//
//  RSTLAccessibleCurrentWord.m
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

#import "RSTLAccessibleCurrentWord.h"
#import "RSTLAccessibleCurrentWordTile.h"

@implementation RSTLAccessibleCurrentWord
{
	NSUInteger index;
	BOOL isAccessibilityElement;
}

+ (Class)tileClass
{
	return [RSTLAccessibleCurrentWordTile class];
}

- (instancetype)initWithRows:(NSUInteger)rows columns:(NSUInteger)columns accessibilityContainer:(id)accessibilityContainer
{
	self = [super initWithRows:rows columns:columns accessibilityContainer:accessibilityContainer];
	if (self)
	{
		isAccessibilityElement = YES;
		if ([self.tiles count])
			[self.tiles[0] setSelected:YES];
	}
	return self;
}

- (void)playTileAtPoint:(CGPoint)point
{
	CGRect frame = self.frameRelativeToContainer;
	CGFloat tileWidth = frame.size.width / self.columns;
	CGFloat tileHeight = frame.size.height / self.rows;
	ASTilePosition position;
	position.column = (NSUInteger)point.x / (NSUInteger)tileWidth;
	position.row = (NSUInteger)point.y / (NSUInteger)tileHeight;
	// This announcement is currently getting interupted by the screen reader reading the words label and adjustable trait.
	// Hacky temporary fix tells the screen reader that we're no longer an accessibility element and then sends focus back after notification finishes
	isAccessibilityElement = NO;
	__block id observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIAccessibilityAnnouncementDidFinishNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
		self->isAccessibilityElement = YES;
		[[NSNotificationCenter defaultCenter] removeObserver:observer];
		// This could be where we'd actually remove the tile and possibly send a screen change notification to give focus to where the tile is now located
		// For now we'll give focus back to self
		UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self);
	}];
	UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, [NSString stringWithFormat:@"Removing: %@", [self characterAtPosition:position]]);
}

- (BOOL)isAccessibilityElement
{
	return isAccessibilityElement;
}

- (NSString *)accessibilityLabel
{
	return @"Current word";
}

- (NSString *)accessibilityValue
{
	NSMutableString *string = [NSMutableString string];
	for (RSTLAccessibleCurrentWordTile *tile in self.tiles)
	{
		if ([tile selected])
		{
			[string appendFormat:@"Your selection is %@. ", tile.accessibilityLabel];
			break;
		}
	}
	// If we had a game dictionary, we could use only the letter by letter spelling when the
	// word isn't in the dictionary
	[string appendString:@"Your current word is "];
	for (RSTLAccessibleTile *tile in self.tiles)
	{
		[string appendString:tile.character];
	}
	[string appendString:@"\n"];
	for (RSTLAccessibleTile *tile in self.tiles)
	{
		[string appendFormat:@"%@\n", tile.character];
	}
	
	return string;
}

- (NSString *)accessibilityHint
{
	return [NSString stringWithFormat:@"Double tap to remove selected tile from the current word. Three finger swipe left or right to change tile position in word."];
}

- (UIAccessibilityTraits)accessibilityTraits
{
	return [super accessibilityTraits] | UIAccessibilityTraitAdjustable | UIAccessibilityTraitButton;
}

- (void)accessibilityIncrement
{
	if (index + 1 < [self.tiles count])
	{
		[self.tiles[index] setSelected:NO];
		index++;
		[self.tiles[index] setSelected:YES];
	}
}

- (void)accessibilityDecrement
{
	if (index > 0)
	{
		[self.tiles[index] setSelected:NO];
		index--;
		[self.tiles[index] setSelected:YES];
	}
}

- (void)swap:(RSTLAccessibleCurrentWordTile *)currentTile nextTile:(RSTLAccessibleCurrentWordTile *)nextTile
{
	NSString *character = currentTile.character;
	NSString *owner = currentTile.owner;
	bool isBlockedIn = currentTile.isBlockedIn;
	currentTile.character = nextTile.character;
	currentTile.owner = nextTile.owner;
	currentTile.isBlockedIn = nextTile.isBlockedIn;
	nextTile.character = character;
	nextTile.owner = owner;
	nextTile.isBlockedIn = isBlockedIn;
}

// The UIAccessibilityAnnouncementNotifications here shouldn't be necessary, still working out where the bug is that's making
// UIAccessibilityPageScrolledNotification not announce anything

- (BOOL)shuffleRight
{
	if ([self.tiles count] < 2)
		return NO;
	if (index == [self.tiles count] - 1)
	{
		UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Unable to move letter right");
		return NO;
	}
	RSTLAccessibleCurrentWordTile *currentTile = self.tiles[index];
	[self accessibilityIncrement];
	RSTLAccessibleCurrentWordTile *nextTile = self.tiles[index];
	[self swap:currentTile nextTile:nextTile];
//	UIAccessibilityPostNotification(UIAccessibilityPageScrolledNotification, [NSString stringWithFormat:@"Moved %@ right", nextTile.character]);
	UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, [NSString stringWithFormat:@"Moved %@ right", nextTile.character]);
	return YES;
}

- (BOOL)shuffleLeft
{
	if ([self.tiles count] < 2)
		return NO;
	if (index == 0)
	{
		UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Unable to move letter left");
		return NO;
	}
	RSTLAccessibleCurrentWordTile *currentTile = self.tiles[index];
	[self accessibilityDecrement];
	RSTLAccessibleCurrentWordTile *nextTile = self.tiles[index];
	[self swap:currentTile nextTile:nextTile];
//	UIAccessibilityPostNotification(UIAccessibilityPageScrolledNotification, [NSString stringWithFormat:@"Moved %@ left", nextTile.character]);
	UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, [NSString stringWithFormat:@"Moved %@ left", nextTile.character]);
	return YES;
}

- (BOOL)accessibilityScroll:(UIAccessibilityScrollDirection)direction
{
	if ([self.tiles count] < 2)
		return NO;
	switch (direction) {
		case UIAccessibilityScrollDirectionLeft:
			return [self shuffleLeft];
		case UIAccessibilityScrollDirectionRight:
			return [self shuffleRight];
		default:
			break;
	}
	return NO;
}

@end
