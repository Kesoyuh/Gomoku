//
//  GGBoardController.m
//  Gomoku
//
//  Created by Changchang on 27/5/17.
//  Copyright © 2017 University of Melbourne. All rights reserved.
//

#import "GGBoardController.h"
#import "GGPacket.h"
#import "GGHostListController.h"
@import CocoaAsyncSocket;

@interface GGBoardController () <GCDAsyncSocketDelegate, GGHostListControllerDelegate> {
    GGBoard *board;
    GGPlayerType playerType;
    GGPlayer *AI;
    int timeSecBlack;
    int timeMinBlack;
    int timeSecWhite;
    int timeMinWhite;
    NSTimer *timer;
    BOOL isHost;
    BOOL oppositeReset;
    BOOL shouldDismiss;
    
}

@property (weak, nonatomic) IBOutlet UIButton *btnReset;
@property (weak, nonatomic) IBOutlet UILabel *timerWhiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerBlackLabel;
@property (strong, nonatomic) UIAlertController *resetWaitAlertController;
@property (strong, nonatomic) UIAlertController *resetChooseAlertController;
@property (strong, nonatomic) UIAlertController *resetRejectAlertController;
@property (strong, nonatomic) UIAlertController *waitAlertController;
@property (strong, nonatomic) UIAlertController *winAlertController;
@property (strong, nonatomic) GCDAsyncSocket *socket;


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
    _boardView.delegate = self;
    
    if (_gameMode == GGModeSingle) {
        [self choosePlayerType];
    } else if (_gameMode == GGModeDouble) {
        [self startTimer];
    } else if (_gameMode == GGModeLAN && shouldDismiss == YES) {
        [self dismissViewControllerAnimated:NO completion:nil];
    } else if (_gameMode == GGModeLAN && _socket == nil) {
        [self performSegueWithIdentifier:@"findGame" sender:nil];
    } else if (_gameMode == GGModeLAN && _socket != nil) {
        [self startGameInLANMode];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController *destinationNavigationController = segue.destinationViewController;
    GGHostListController *targetController = (GGHostListController *)(destinationNavigationController.topViewController);
    targetController.delegate = self;
}


#pragma mark - Gomoku basic logic

- (void)startGameInLANMode {
    [self startTimer];
    if (!isHost) {
        self.waitAlertController = [UIAlertController alertControllerWithTitle:@"请等待对方先下" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:_waitAlertController animated:YES completion:nil];
    }
    _btnReset.enabled = NO;
}

- (void)choosePlayerType {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请选择先后手" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionBlack = [UIAlertAction actionWithTitle:@"先手" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self startTimer];
        AI = [[GGPlayer alloc] initWithPlayer:GGPlayerTypeWhite difficulty:GGDifficultyHard];
    }];
    UIAlertAction *actionWhite = [UIAlertAction actionWithTitle:@"后手" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self startTimer];
        AI = [[GGPlayer alloc] initWithPlayer:GGPlayerTypeBlack difficulty:GGDifficultyHard];
        [self AIPlayWithMove:nil];
    }];
    [alert addAction:actionBlack];
    [alert addAction:actionWhite];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)moveAtPoint:(GGPoint)point sendPacketInLAN:(BOOL)sendPacket {
    if([board canMoveAtPoint:point]) {
        _btnReset.enabled = YES;
        GGMove *move = [[GGMove alloc] initWithPlayer:playerType point:point];
        [board makeMove:move];
        
        [_boardView insertPieceAtPoint:point playerType:playerType];
        
        if ([board checkWinAtPoint:point]) {
            if (_gameMode == GGModeLAN && sendPacket == YES) {
                NSDictionary *data = @{ @"i" : @(point.i), @"j" : @(point.j) };
                GGPacket *packet = [[GGPacket alloc] initWithData:data type:GGPacketTypeMove action:GGPacketActionUnknown];
                [self sendPacket:packet];
            }
            [self handleWin];
        } else {
            [self switchPlayer];
            
            if (_gameMode == GGModeSingle) {
                [self AIPlayWithMove:move];
            } else if (_gameMode == GGModeLAN && sendPacket == YES) {
                NSDictionary *data = @{ @"i" : @(point.i), @"j" : @(point.j) };
                GGPacket *packet = [[GGPacket alloc] initWithData:data type:GGPacketTypeMove action:GGPacketActionUnknown];
                [self sendPacket:packet];
                _boardView.userInteractionEnabled = NO;
            } else if (_gameMode == GGModeLAN && sendPacket == NO) {
                _boardView.userInteractionEnabled = YES;
            }
        }
    }
}

- (void)AIPlayWithMove:(GGMove *)move {
    _boardView.userInteractionEnabled = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [AI update:move];
        GGMove *AIMove = [AI getMove];
        [board makeMove:AIMove];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_boardView insertPieceAtPoint:AIMove.point playerType:AIMove.playerType];
            if ([board checkWinAtPoint:AIMove.point]) {
                [self handleWin];
                NSLog(@"win %ld", (long)playerType);
            } else {
                [self switchPlayer];
                _boardView.userInteractionEnabled = YES;
            }
        });
        
    });
    
}

- (void)handleWin {
    NSString *alertTitle;
    if (playerType == GGPlayerTypeBlack) {
        alertTitle = @"Black Win!";
    } else {
        alertTitle = @"White Win!";
    }
    
    [self dismissAlertControllers];
    
    self.winAlertController = [UIAlertController alertControllerWithTitle:alertTitle message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [_winAlertController addAction:action];
    [self presentViewController:_winAlertController animated:YES completion:nil];
    
    _btnReset.enabled = YES;
    _boardView.userInteractionEnabled = NO;
    [self stopTimer];
}

- (void)handleReset {
    [self stopTimer];
    [board initBoard];
    _boardView.userInteractionEnabled = YES;
    playerType = GGPlayerTypeBlack;
    [_boardView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)switchPlayer {
    if (playerType == GGPlayerTypeBlack) {
        playerType = GGPlayerTypeWhite;
    } else {
        playerType = GGPlayerTypeBlack;
    }
}

- (void)startTimer {
    // initialize the timer label
    timeSecBlack = 0;
    timeMinBlack = 0;
    timeSecWhite = 0;
    timeMinWhite = 0;
    
    NSString* timeNow = [NSString stringWithFormat:@"%02d:%02d", timeMinBlack, timeSecBlack];
    
    _timerWhiteLabel.text = timeNow;
    _timerBlackLabel.text = timeNow;
    
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
        _timerBlackLabel.text= timeNow;
    } else {
        timeSecWhite++;
        if (timeSecWhite == 60)
        {
            timeSecWhite = 0;
            timeMinWhite++;
        }
        //Format the string 00:00
        NSString* timeNow = [NSString stringWithFormat:@"%02d:%02d", timeMinWhite, timeSecWhite];
        _timerWhiteLabel.text= timeNow;
    }
}

- (void) dismissAlertControllers {
    [_winAlertController dismissViewControllerAnimated:YES completion:nil];
    [_waitAlertController dismissViewControllerAnimated:YES completion:nil];
    [_resetWaitAlertController dismissViewControllerAnimated:YES completion:nil];
    [_resetChooseAlertController dismissViewControllerAnimated:YES completion:nil];
    [_resetRejectAlertController dismissViewControllerAnimated:YES completion:nil];
    
    self.winAlertController = nil;
    self.waitAlertController = nil;
    self.resetWaitAlertController = nil;
    self.resetChooseAlertController = nil;
    self.resetRejectAlertController = nil;
}


#pragma mark - Socket related functions

- (void)sendPacket:(GGPacket *)packet {
    
    // Encode Packet Data
    NSMutableData *packetData = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:packetData];
    [archiver encodeObject:packet forKey:@"packet"];
    [archiver finishEncoding];
    
    // Initialize Buffer
    NSMutableData *buffer = [[NSMutableData alloc] init];
    
    // Fill Buffer
    [buffer appendBytes:packetData.bytes length:packetData.length];
    
    [_socket writeData:buffer withTimeout:-1.0 tag:0];
    
}


- (void)parseData:(NSData *)data {
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    GGPacket *packet = [unarchiver decodeObjectForKey:@"packet"];
    [unarchiver finishDecoding];


    if ([packet type] == GGPacketTypeMove) {
        NSNumber *i = [(NSDictionary *)[packet data] objectForKey:@"i"];
        
        NSNumber *j = [(NSDictionary *)[packet data] objectForKey:@"j"];
        
        GGPoint point;
        point.i = i.intValue;
        point.j = j.intValue;
        
        if (_waitAlertController != nil) {
            [_waitAlertController dismissViewControllerAnimated:YES completion:nil];
            self.waitAlertController = nil;
        }
        [self moveAtPoint:point sendPacketInLAN:NO];
        
    } else if ([packet type] == GGPacketTypeReset) {
        if ([packet action] == GGPacketActionResetRequest) {
            
            [self dismissAlertControllers];
            
            self.resetChooseAlertController = [UIAlertController alertControllerWithTitle:@"对方请求重开" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionAgree = [UIAlertAction actionWithTitle:@"同意" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                GGPacket *packet = [[GGPacket alloc] initWithData:nil type:GGPacketTypeReset action:GGPacketActionResetAgree];
                [self sendPacket:packet];
                [self handleReset];
                [self startGameInLANMode];
            }];

            UIAlertAction *actionReject = [UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                GGPacket *packet = [[GGPacket alloc] initWithData:nil type:GGPacketTypeReset action:GGPacketActionResetReject];
                [self sendPacket:packet];
            }];
            
            [_resetChooseAlertController addAction:actionAgree];
            [_resetChooseAlertController addAction:actionReject];
            [self presentViewController:_resetChooseAlertController animated:YES completion:nil];
            
        } else if ([packet action] == GGPacketActionResetAgree) {
            [self dismissAlertControllers];
            
            [self handleReset];
            [self startGameInLANMode];
            
        } else if ([packet action] == GGPacketActionResetReject) {
            [self dismissAlertControllers];
            
            self.resetRejectAlertController = [UIAlertController alertControllerWithTitle:@"对方拒绝了你的请求" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            
            [_resetRejectAlertController addAction:action];
            [self presentViewController:_resetRejectAlertController animated:YES completion:nil];
        }
        
    }
}


#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)socket didReadData:(NSData *)data withTag:(long)tag {
    [self parseData:data];
    [socket readDataWithTimeout:-1 tag:1];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)socket withError:(NSError *)error {
    if (error) {
        NSLog(@"Socket Did Disconnect with Error %@ with User Info %@.", error, [error userInfo]);
    } else {
        NSLog(@"Socket Disconnect.");
    }
    
    if (_socket == socket) {
        _socket.delegate = nil;
        _socket = nil;
    }
    [self stopTimer];
    
    [self dismissAlertControllers];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"对方已经断开连接" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - GGBoardViewDelegate

- (void)boardView:(GGBoardView *)boardView didTapOnPoint:(GGPoint)point {
    [self moveAtPoint:point sendPacketInLAN:YES];
}


#pragma mark - GGHostListControllerDelegate

- (void)controller:(GGHostListController *)controller didJoinGameOnSocket:(GCDAsyncSocket *)socket {
    self.socket = socket;
    [_socket setDelegate:self];
    _boardView.userInteractionEnabled = NO;
    isHost = NO;
    
    [_socket readDataWithTimeout:-1 tag:1];
    
}

- (void)controller:(GGHostListController *)controller didHostGameOnSocket:(GCDAsyncSocket *)socket {
    self.socket = socket;
    [_socket setDelegate:self];
    isHost = YES;
    [_socket readDataWithTimeout:-1 tag:1];
}

- (void)shouldDismiss {
    shouldDismiss = YES;
}


#pragma mark - IBAction

- (IBAction)btnReset_TouchUp:(UIButton *)sender {
    
    if (_gameMode == GGModeSingle) {
        [self handleReset];
        [self choosePlayerType];
    } else if (_gameMode == GGModeDouble){
        [self handleReset];
        [self startTimer];
    } else if (_gameMode == GGModeLAN) {
        if (oppositeReset == YES) {
            [self handleReset];
            [self startGameInLANMode];
            
            oppositeReset = NO;
            NSString *data = @"reset";
            GGPacket *packet = [[GGPacket alloc] initWithData:data type:GGPacketTypeReset action:GGPacketActionUnknown];
            [self sendPacket:packet];
        } else {
            self.resetWaitAlertController = [UIAlertController alertControllerWithTitle:@"等待对方回应" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:_resetWaitAlertController animated:YES completion:nil];
            
            NSString *data = @"reset";
            GGPacket *packet = [[GGPacket alloc] initWithData:data type:GGPacketTypeReset action:GGPacketActionResetRequest];
            [self sendPacket:packet];
        }
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
