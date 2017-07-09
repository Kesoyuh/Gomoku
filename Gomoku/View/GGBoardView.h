//
//  Board.h
//  Gomoku
//
//  Created by Changchang on 27/5/17.
//  Copyright © 2017 University of Melbourne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GGPlayer.h"

@protocol GGBoardViewDelegate;

@interface GGBoardView : UIView

@property (nonatomic, weak) id <GGBoardViewDelegate> delegate;

- (GGPoint)findPointWithLocation:(CGPoint)location;
- (void)insertPieceAtPoint:(GGPoint)point playerType:(GGPlayerType)playerType;

@end

@protocol GGBoardViewDelegate <NSObject>

- (void)boardView:(GGBoardView *)boardView didTapOnPoint:(GGPoint)point;

@end
