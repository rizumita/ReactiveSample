//
// Created by rizumita on 2013/03/12.
//


#import <ReactiveCocoa/ReactiveCocoa/RACSignal.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "TwitterManager.h"
#import "ReactiveCocoa.h"
#import "EXTScope.h"


@interface TwitterManager ()
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) ACAccountType *accountType;
@property (nonatomic, strong) ACAccount *account;


@end

@implementation TwitterManager
{

}
+ (TwitterManager *)sharedManager {
    static TwitterManager *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.accountStore = [[ACAccountStore alloc] init];
        self.accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    }
    return self;
}

- (RACSignal *)requestAccessToAccounts {
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        [self.accountStore requestAccessToAccountsWithType:self.accountType options:nil completion:^(BOOL granted, NSError *error) {
            if (granted) {
                NSArray *accounts = [self.accountStore accountsWithAccountType:self.accountType];
                if (accounts.count > 0) {
                    self.account = accounts[0];
                    [subscriber sendNext:nil];
                } else {
                    [subscriber sendError:[NSError errorWithDomain:@"ERRORDOMAIN" code:0 userInfo:nil]];
                }
            } else {
                [subscriber sendError:(error ? error : [NSError errorWithDomain:@"ERRORDOMAIN" code:0 userInfo:nil])];
            }

            [subscriber sendCompleted];
        }];

        return [RACDisposable disposableWithBlock:nil];
    }];

    return signal;
}

- (RACSignal *)fetchName {
    @weakify(self);
    RACSignal *signal = [RACSignal startWithScheduler:[RACScheduler scheduler] subjectBlock:^(RACSubject *subject) {
        @strongify(self);
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/users/show.json?screen_name=%@", self.account.username]];
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:nil];
        request.account = self.account;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (error) {
                [subject sendError:error];
            } else {
                NSError *subError;
                NSDictionary *status = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&subError];
                if (subError) {
                    [subject sendError:subError];
                } else if (status[@"name"]) {
                    [subject sendNext:status[@"name"]];
                } else {
                    [subject sendError:[NSError errorWithDomain:@"ERRORDOMAIN" code:2 userInfo:nil]];
                }
            }

            [subject sendCompleted];
        }];
    }];

    return signal;
}

@end