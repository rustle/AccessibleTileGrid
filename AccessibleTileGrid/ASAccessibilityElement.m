//
//  ASAccessibilityElement.m
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

@implementation ASAccessibilityElement

- (instancetype)initWithAccessibilityContainer:(id)container
{
	if ([container isKindOfClass:[container class]])
		return [self initWithAccessibilityContainer:container view:container];
	return [super initWithAccessibilityContainer:container];
}

- (instancetype)initWithAccessibilityContainer:(id)container view:(UIView *)view
{
	self = [super initWithAccessibilityContainer:container];
	if (self)
	{
		self.accessibilityViewContainer = view;
	}
	return self;
}

- (CGRect)accessibilityFrame
{
	UIView *container = [self accessibilityViewContainer];
	if (container == nil)
		return [super accessibilityFrame];
	// accessibilityFrame is in screen coordinates, so do some hoop jumping to convert
	UIWindow *window = [container window];
	if (window == nil)
		return self.frameRelativeToContainer;
	CGRect frame = self.frameRelativeToContainer;
	frame = [container convertRect:frame toView:window];
	frame = [window convertRect:frame toWindow:nil];
	return frame;
}

@end
