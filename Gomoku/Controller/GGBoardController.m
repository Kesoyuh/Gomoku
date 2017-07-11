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
    GGPlayer *AI;
    int timeSecBlack;
    int timeMinBlack;
    int timeSecWhite;
    int timeMinWhite;
    NSTimer *timer;
    
    
}

@property (weak, nonatomic) IBOutlet UILabel *timerWhiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerBlackLabel;


@end

@implementation GGBoardController

- (void)viewDidLoad {
    [super viewDidLoad];
    board = [[GGBoard alloc] init];
    
    
    // First piece will always be black
    playerType = GGPlayerTypeBlack;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.boardView.delegate = self;
    
    if (_gameMode == GGModeSingle) {
        [self choosePlayerType];
    } else {
        [self startTimer];
    }
}

- (void)choosePlayerType {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请选择先后手" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionBlack = [UIAlertAction actionWithTitle:@"先手" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self startTimer];
        AI = [[GGPlayer alloc] initWithPlayer:GGPlayerTypeWhite];
    }];
    UIAlertAction *actionWhite = [UIAlertAction actionWithTitle:@"后手" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self startTimer];
        AI = [[GGPlayer alloc] initWithPlayer:GGPlayerTypeBlack];
        [self AIPlayWithMove:nil];
    }];
    [alert addAction:actionBlack];
    [alert addAction:actionWhite];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)AIPlayWithMove:(GGMove *)move {
    self.boardView.userInteractionEnabled = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [AI update:move];
        GGMove *AIMove = [AI getMove];
        [board makeMove:AIMove];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.boardView insertPieceAtPoint:AIMove.point playerType:AIMove.playerType];
            if ([board checkWinAtPoint:AIMove.point]) {
                [self handleWin];
                NSLog(@"win %ld", (long)playerType);
            } else {
                [self switchPlayer];
                self.boardView.userInteractionEnabled = YES;
            }
        });
        
    });
    
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

- (void)switchPlayer {
    if (playerType == GGPlayerTypeBlack) {
        playerType = GGPlayerTypeWhite;
    } else {
        playerType = GGPlayerTypeBlack;
    }
}

#pragma mark - GGBoardViewDelegate

- (void)boardView:(GGBoardView *)boardView didTapOnPoint:(GGPoint)point {
    
    if([board canMoveAtPoint:point]) {
        
        GGMove *move = [[GGMove alloc] initWithPlayer:playerType point:point];
        [board makeMove:move];
        
        [boardView insertPieceAtPoint:point playerType:playerType];
        
        if ([board checkWinAtPoint:point]) {
            [self handleWin];
            NSLog(@"win %ld", (long)playerType);
        } else {
            [self switchPlayer];
            
            if (_gameMode == GGModeSingle) {
                [self AIPlayWithMove:move];
            }
        }
    }
}


#pragma mark - IBAction

- (IBAction)btnReset_TouchUp:(UIButton *)sender {
    [self stopTimer];
    [board initBoard];
    self.boardView.userInteractionEnabled = YES;
    playerType = GGPlayerTypeBlack;
    [self.boardView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if (_gameMode == GGModeSingle) {
        [self choosePlayerType];
    } else {
        [self startTimer];
    }
    
}

- (IBAction)btnUndo_TouchUp:(UIButton *)sender {
    
}

- (IBAction)btnBack_TouchUp:(UIButton *)sender {
    [timer invalidate];
    timer = nil;
    [self dismissViewControllerAnimated:NO completion:nil];
}
@end
