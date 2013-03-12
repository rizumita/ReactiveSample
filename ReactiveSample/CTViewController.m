//
//  CTViewController.m
//  ReactiveSample
//
//  Created by 和泉田 領一 on 2013/03/11.
//  Copyright (c) 2013年 CAPH. All rights reserved.
//

#import "CTViewController.h"
#import "ReactiveCocoa.h"
#import "EXTScope.h"
#import "TwitterManager.h"

@interface CTViewController ()

@end

@implementation CTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [self.usernameTextField.rac_textSignal subscribeNext:^(NSString *text) {
        self.logInButton.hidden = (text.length == 0);
    }];

//    [[RACSignal combineLatest:@[self.usernameTextField.rac_textSignal, self.passwordTextField.rac_textSignal] reduce:^(NSString *username, NSString *password) {
//        return @(username.length == 0 || password.length == 0);
//    }] subscribeNext:^(NSNumber *hidden) {
//        self.logInButton.hidden = hidden.boolValue;
//    }];

    @weakify(self);
    [[self.twitterButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *button) {
        [[[[TwitterManager sharedManager] requestAccessToAccounts] sequenceNext:^{
            return [[TwitterManager sharedManager] fetchName];
        }] subscribeNext:^(NSString *name) {
            @strongify(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.twitterLabel.text = name;
            });
        }          error:^(NSError *error) {
            @strongify(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.twitterLabel.text = error.localizedDescription;
            });
        }];
    }];
}

- (void)presentError:(NSError *)error {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alertView show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
