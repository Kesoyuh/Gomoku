//
//  GGBoardController.m
//  Gomoku
//
//  Created by Changchang on 27/5/17.
//  Copyright © 2017 University of Melbourne. All rights reserved.
//

#import "GGBoardController.h"

@interface GGBoardController () {
    GGBoard *board;
    GGPlayerType playerType;
    
}

@end

@implementation GGBoardController

- (void)viewDidLoad {
    [super viewDidLoad];
    board = [[GGBoard alloc] init];
    playerType = GGPlayerTypeBlack;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.boardView addGestureRecognizer: tap];
}

- (void)handleTap:(UITapGestureRecognizer *)tapGestureRecognizer {
    CGPoint location = [tapGestureRecognizer locationInView:self.boardView];
    
    GGPoint point = [self.boardView findPointWithLocation:location];
    
    if([board canMoveAtPoint:point]) {
        GGMove *move = [[GGMove alloc] initWithPlayer:playerType point:point];
        [board makeMove:move];
        [self.boardView insertPieceAtPoint:point playerType:playerType];
        if ([board checkWinAtPoint:point]) {
            [self handleWin];
            NSLog(@"win %ld", (long)playerType);
        }
        if (playerType == GGPlayerTypeBlack) {
            playerType = GGPlayerTypeWhite;
        } else {
            playerType = GGPlayerTypeBlack;
        }
    }
}

- (void)handleWin{
    NSString *alertTitle;
    if (playerType == GGPlayerTypeBlack) {
        alertTitle = @"Black Win!";
    } else {
        alertTitle = @"White Win!";
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
    self.boardView.userInteractionEnabled = NO;
}


- (IBAction)btnReset_click:(UIButton *)sender {

    [board initBoard];
    self.boardView.userInteractionEnabled = YES;
    [self.boardView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
}
@end
