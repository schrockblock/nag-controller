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

static NSString * const LastNaggedKey = @"lastNagged";
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
        self.nagDelaySeconds = 17;
    }
    return self;
}


- (void)startNag
{
    int appOpens = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"numberOfAppOpens"];
    if (appOpens % 3 == 0) {
        if (![self lastNagged] || [[self lastNagged] isBefore:[[NSDate date] incrementUnit:NSCalendarUnitDay by:-2]]) {
            if ([self canNagRating]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.nagDelaySeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.isRatingNag = YES;
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:self.ratingTitle
                                                                    message:self.ratingMessage
                                                                   delegate:self
                                                          cancelButtonTitle:@"I already have!"
                                                          otherButtonTitles:@"Yes, I'd be delighted!",@"Nope, I will never rate your app",@"Mmm, not right now",nil];
                    [alert show];
                    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:LastNaggedKey];
                });
            }else if ([self canNagApp]){
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.nagDelaySeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.isRatingNag = NO;
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:self.upgradeTitle
                                                                    message:self.upgradeMessage
                                                                   delegate:self
                                                          cancelButtonTitle:@"Mmm, maybe later"
                                                          otherButtonTitles:@"Yes, I'd be delighted!",@"I prefer clicking on ads to support you",nil];
                    [alert show];
                    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:LastNaggedKey];
                });
            }
        }
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

- (NSDate *)lastNagged
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:LastNaggedKey];
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
