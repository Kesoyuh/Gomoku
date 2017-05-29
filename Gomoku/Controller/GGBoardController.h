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

@interface GGBoardController : UIViewController <GGBoardViewDelegate>

@property (weak, nonatomic) IBOutlet GGBoardView *boardView;

- (IBAction)btnReset_click:(UIButton *)sender;

@end
