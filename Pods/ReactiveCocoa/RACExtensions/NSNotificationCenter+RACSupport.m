//
//  NSNotificationCenter+RACSupport.m
//  ReactiveCocoa
//
//  Created by Josh Abernathy on 5/10/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "NSNotificationCenter+RACSupport.h"
#import <EXTScope.h>

@implementation NSNotificationCenter (RACSupport)

- (RACSignal *)rac_addObserverForName:(NSString *)notificationName object:(id)object {
	@unsafeify(object);
	return [[RACSignal createSignal:^(id<RACSubscriber> subscriber) {
		@strongify(object);
		id observer = [self addObserverForName:notificationName object:object queue:nil usingBlock:^(NSNotification *note) {
			[subscriber sendNext:note];
		}];

		return [RACDisposable disposableWithBlock:^{
			[NSNotificationCenter.defaultCenter removeObserver:observer];
		}];
	}] setNameWithFormat:@"-rac_addObserverForName: %@ object: %@", notificationName, object];
}

@end
