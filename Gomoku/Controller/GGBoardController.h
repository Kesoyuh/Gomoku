//
//  GGBoardController.h
//  Gomoku
//
//  Created by Changchang on 27/5/17.
//  Copyright © 2017 University of Melbourne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GGBoardView.h"
#import "GGPlayer.h"

typedef NS_ENUM(NSInteger, GGMode)
{
    GGModeSingle,
    GGModeDouble
};

@interface GGBoardController : UIViewController <GGBoardViewDelegate>

@property (weak, nonatomic) IBOutlet GGBoardView *boardView;
@property (assign, nonatomic) enum GGMode gameMode;



@end
