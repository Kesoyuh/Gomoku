//
//  GGHostListController.h
//  Gomoku
//
//  Created by Changchang on 11/7/17.
//  Copyright © 2017 University of Melbourne. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GCDAsyncSocket;

@protocol GGHostListControllerDelegate;

@interface GGHostListController : UITableViewController

@property (weak, nonatomic) id<GGHostListControllerDelegate> delegate;

@end

@protocol GGHostListControllerDelegate

- (void)controller:(GGHostListController *)controller didJoinGameOnSocket:(GCDAsyncSocket *)socket;
- (void)controller:(GGHostListController *)controller didHostGameOnSocket:(GCDAsyncSocket *)socket;

@end
