//
// Created by rizumita on 2013/03/12.
//


#import <Foundation/Foundation.h>

@class ACAccountStore;
@class ACAccountType;


@interface TwitterManager : NSObject

+ (TwitterManager *)sharedManager;

- (RACSignal *)requestAccessToAccounts;

- (RACSignal *)fetchName;
@end