//
//  RSTLAccessibleTile.m
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

#import "RSTLAccessibleTile.h"

@implementation RSTLAccessibleTile

- (NSString *)accessibilityLabel
{
	if (!self.character.length)
	{
		return @"empty tile";
	}
	// \n makes the screen reader pause a little before and after the character since it's the most important piece of information
	// and can be hard to here correctly without the pause
	return [NSString stringWithFormat:@"Grid letter\n%@\nthat is owned by %@ is %@blocked in and is at row %d and column %d", self.character, [self.owner length] ? self.owner : @"no one", self.isBlockedIn ? @"" : @"not ", self.row, self.column];
}

- (NSString *)accessibilityHint
{
	return [NSString stringWithFormat:@"Double tap this tile to add it to the current word."];
}

- (UIAccessibilityTraits)accessibilityTraits
{
	return [super accessibilityTraits] | UIAccessibilityTraitButton;
}

@end
