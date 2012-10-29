//
//  RSTLContainerGLKView.m
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

#import "RSTLContainerGLKView.h"

@interface RSTLContainerGLKView ()
@property (nonatomic) NSMutableArray *accessibilityElements;
@end

@implementation RSTLContainerGLKView

- (void)resetAccessibilityElements
{
	[self.accessibilityElements removeAllObjects];
}

- (NSMutableArray *)accessibilityElements
{
	if (_accessibilityElements)
		return _accessibilityElements;
	_accessibilityElements = [NSMutableArray new];
	return _accessibilityElements;
}

- (void)addAccessibilityElement:(UIAccessibilityElement *)element
{
	if (element)
		[self.accessibilityElements addObject:element];
}

- (BOOL)isAccessibilityElement
{
	return NO;
}

- (NSInteger)accessibilityElementCount
{
	return [self.accessibilityElements count];
}

- (id)accessibilityElementAtIndex:(NSInteger)index
{
	return self.accessibilityElements[index];
}

- (NSInteger)indexOfAccessibilityElement:(id)element
{
	return [self.accessibilityElements indexOfObject:element];
}

@end
