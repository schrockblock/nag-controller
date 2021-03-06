//
//  NagController.m
//  BostonTMap
//
//  Created by Elliot Schrock on 5/27/15.
//
//
#import <UIkit/UIKit.h>
#import "NagController.h"
#import "NSDate+RelativeTime.h"

@interface NagController ()
@property (nonatomic) BOOL isRatingNag;


@end

static NSString * const ShouldNagRatingKey = @"should_nag_rating";
static NSString * const ShouldNagAppKey = @"should_nag_app";
static int const AffirmativeIndex = 1;
static int const AlreadyHaveIndex = 0;
static int const NeverIndex = 2;

@implementation NagController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.ratingTitle = @"Sorry to interrupt,";
        self.ratingMessage = @"...but would you mind terribly taking a moment to rate this app?";
        self.upgradeTitle = @"Hey!";
        self.upgradeMessage = @"You seem to be enjoying the app, would you like to help support an independent app developer and download the paid version?";
        
        self.upgradeCancelButtonTitle = @"Mmm, maybe later";
        self.upgradeYesButtonTitle = @"Yes, I'd be delighted!";
        self.upgradeNoButtonTitle = @"I prefer clicking on ads to support you";
        
        self.ratingCancelButtonTitle = @"I already have!";
        self.ratingYesButtonTitle = @"Yes, I'd be delighted!";
        self.ratingNoButtonTitle = @"Nope, I will never rate your app";
        self.ratingLaterButtonTitle = @"Mmm, not right now";
        
        self.nagDelaySeconds = 17;
    }
    return self;
}


- (void)startNag
{
    if ([self canNagRating]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.nagDelaySeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.isRatingNag = YES;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:self.ratingTitle
                                                            message:self.ratingMessage
                                                           delegate:self
                                                  cancelButtonTitle:self.ratingCancelButtonTitle
                                                  otherButtonTitles:self.ratingYesButtonTitle,self.ratingNoButtonTitle,self.ratingLaterButtonTitle,nil];
            [alert show];
        });
    }else if ([self canNagApp]){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.nagDelaySeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.isRatingNag = NO;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:self.upgradeTitle
                                                            message:self.upgradeMessage
                                                           delegate:self
                                                  cancelButtonTitle:self.upgradeCancelButtonTitle
                                                  otherButtonTitles:self.upgradeYesButtonTitle,self.upgradeNoButtonTitle,nil];
            [alert show];
        });
    }
}

- (BOOL)canNagRating
{
    BOOL result = NO;
    if (self.ratingURLStr) {
        if (![[NSUserDefaults standardUserDefaults] objectForKey:ShouldNagRatingKey]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ShouldNagRatingKey];
        }
        result = [[NSUserDefaults standardUserDefaults] boolForKey:ShouldNagRatingKey];
    }
    return result;
}

- (BOOL)canNagApp
{
    BOOL result = NO;
    if (!self.upgradeURLStr) {
        if (![[NSUserDefaults standardUserDefaults] objectForKey:ShouldNagAppKey]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ShouldNagAppKey];
        }
        result = [[NSUserDefaults standardUserDefaults] boolForKey:ShouldNagAppKey];
    }
    return result;
}

#pragma mark - alertView delegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    id <NagControllerDelegate> delegate = self.delegate;
    NSString *nagEvent;
    NagResponse nagResponse;
    
    if (self.isRatingNag) {
        nagEvent = @"NagRate-v1";
        
        switch (buttonIndex) {
            case AffirmativeIndex:
            {
                nagResponse = NagResponseWillRate;
                NSString *iTunesLink = self.ratingURLStr;
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ShouldNagRatingKey];
            }
                break;
            case AlreadyHaveIndex:
            {
                nagResponse =NagResponseHasRated;
            }
                break;
            case NeverIndex:
            {
                nagResponse = NagResponseNeverRate;
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ShouldNagRatingKey];
            }
                break;
                
            default:
            {
                nagResponse = NagResponseRateLater;
            }
                break;
        }
    }else{
        nagEvent = @"NagBuy-v1";
        
        switch (buttonIndex) {
            case AffirmativeIndex:
            {
                nagResponse = NagResponseWillBuy;
                NSString *iTunesLink = self.upgradeURLStr;
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ShouldNagAppKey];
            }
                break;
            case AlreadyHaveIndex:
            {
                nagResponse =NagResponseHasBought;
            }
                break;
            case NeverIndex:
            {
                nagResponse = NagResponseNeverBuy;
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ShouldNagAppKey];
            }
                break;
                
            default:
            {
                nagResponse = NagResponseBuyLater;
            }
                break;
        }
    }
    
    if ([delegate respondsToSelector:@selector(didPerformNag:withResponse:)]) {
        [delegate didPerformNag:nagEvent withResponse:nagResponse];
    }
}

@end
