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
    int timeSecBlack;
    int timeMinBlack;
    int timeSecWhite;
    int timeMinWhite;
    NSTimer *timer;
    
}

@property (weak, nonatomic) IBOutlet UILabel *timerWhiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerBlackLabel;

- (IBAction)btnReset_TouchUp:(UIButton *)sender;
- (IBAction)btnUndo_TouchUp:(UIButton *)sender;
- (IBAction)btnBack_TouchUp:(UIButton *)sender;

@end

@implementation GGBoardController

- (void)viewDidLoad {
    [super viewDidLoad];
    board = [[GGBoard alloc] init];
    playerType = GGPlayerTypeBlack;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.boardView.delegate = self;
    [self startTimer];
    
}

- (void)startTimer {
    // initialize the timer label
    timeSecBlack = 0;
    timeMinBlack = 0;
    timeSecWhite = 0;
    timeMinWhite = 0;
    
    NSString* timeNow = [NSString stringWithFormat:@"%02d:%02d", timeMinBlack, timeSecBlack];
    
    self.timerWhiteLabel.text = timeNow;
    self.timerBlackLabel.text = timeNow;
    
    [timer invalidate];
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    
}

- (void)stopTimer
{
    [timer invalidate];
    timer = nil;
}

- (void)timerTick:(NSTimer *)timer {
    if (playerType == GGPlayerTypeBlack) {
        timeSecBlack++;
        if (timeSecBlack == 60)
        {
            timeSecBlack = 0;
            timeMinBlack++;
        }
        //Format the string 00:00
        NSString* timeNow = [NSString stringWithFormat:@"%02d:%02d", timeMinBlack, timeSecBlack];
        self.timerBlackLabel.text= timeNow;
    } else {
        timeSecWhite++;
        if (timeSecWhite == 60)
        {
            timeSecWhite = 0;
            timeMinWhite++;
        }
        //Format the string 00:00
        NSString* timeNow = [NSString stringWithFormat:@"%02d:%02d", timeMinWhite, timeSecWhite];
        self.timerWhiteLabel.text= timeNow;
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
    [self stopTimer];
}

- (void)boardView:(GGBoardView *)boardView didTapOnPoint:(GGPoint)point {
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


- (IBAction)btnReset_TouchUp:(UIButton *)sender {

    [board initBoard];
    self.boardView.userInteractionEnabled = YES;
    playerType = GGPlayerTypeBlack;
    [self startTimer];
    [self.boardView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
}

- (IBAction)btnUndo_TouchUp:(UIButton *)sender {
    
}

- (IBAction)btnBack_TouchUp:(UIButton *)sender {
    [timer invalidate];
    timer = nil;
    [self dismissViewControllerAnimated:NO completion:nil];
}
@end
