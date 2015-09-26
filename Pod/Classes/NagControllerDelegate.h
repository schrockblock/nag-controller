//
//  NagControllerDelegate.h
//  
//
//  Created by Cliff Spencer on 9/13/15.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NagResponse) {
    NagResponseWillRate,
    NagResponseNeverRate,
    NagResponseRateLater,
    NagResponseHasRated,
    NagResponseWillBuy,
    NagResponseNeverBuy,
    NagResponseBuyLater,
    NagResponseHasBought
};


@protocol NagControllerDelegate <NSObject>
@optional
- (void)didPerformNag:(NSString *)eventName withResponse:(NagResponse)response;
@end
