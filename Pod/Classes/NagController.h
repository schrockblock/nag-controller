//
//  NagController.h
//  BostonTMap
//
//  Created by Elliot Schrock on 5/27/15.
//
//

#import <Foundation/Foundation.h>
#import "NagControllerDelegate.h"

@interface NagController : NSObject
@property (strong, nonatomic) NSString *ratingTitle;
@property (strong, nonatomic) NSString *ratingMessage;
@property (strong, nonatomic) NSString *ratingURLStr;

@property (strong, nonatomic) NSString *upgradeTitle;
@property (strong, nonatomic) NSString *upgradeMessage;
@property (strong, nonatomic) NSString *upgradeURLStr;

@property (nonatomic) NSUInteger nagDelaySeconds;
@property (weak, nonatomic) id<NagControllerDelegate> delegate;

- (void)startNag;
@end
