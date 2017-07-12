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
    
    
}

@property (weak, nonatomic) IBOutlet UILabel *timerWhiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerBlackLabel;
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
    self.boardView.delegate = self;
    
    if (_gameMode == GGModeSingle) {
        [self choosePlayerType];
    } else if (_gameMode == GGModeDouble) {
        [self startTimer];
    } else if (_gameMode == GGModeLAN && self.socket == nil) {
        [self performSegueWithIdentifier:@"findGame" sender:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController *destinationNavigationController = segue.destinationViewController;
    GGHostListController *targetController = (GGHostListController *)(destinationNavigationController.topViewController);
    targetController.delegate = self;
}

#pragma mark - Gomoku basic logic

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

- (void)moveAtPoint:(GGPoint)point sendPacketInLAN:(BOOL)sendPacket {
    if([board canMoveAtPoint:point]) {
        
        GGMove *move = [[GGMove alloc] initWithPlayer:playerType point:point];
        [board makeMove:move];
        
        [self.boardView insertPieceAtPoint:point playerType:playerType];
        
        if ([board checkWinAtPoint:point]) {
            if (_gameMode == GGModeLAN && sendPacket == YES) {
                NSDictionary *data = @{ @"i" : @(point.i), @"j" : @(point.j) };
                GGPacket *packet = [[GGPacket alloc] initWithData:data type:GGPacketTypeMove action:GGPacketPieceUnknown];
                [self sendPacket:packet];
            }
            [self handleWin];
        } else {
            [self switchPlayer];
            
            if (_gameMode == GGModeSingle) {
                [self AIPlayWithMove:move];
            } else if (_gameMode == GGModeLAN && sendPacket == YES) {
                NSDictionary *data = @{ @"i" : @(point.i), @"j" : @(point.j) };
                GGPacket *packet = [[GGPacket alloc] initWithData:data type:GGPacketTypeMove action:GGPacketPieceUnknown];
                [self sendPacket:packet];
                self.boardView.userInteractionEnabled = NO;
            } else if (_gameMode == GGModeLAN) {
                self.boardView.userInteractionEnabled = YES;
            }
        }
    }
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
    uint64_t headerLength = packetData.length;
    [buffer appendBytes:&headerLength length:sizeof(uint64_t)];
    [buffer appendBytes:packetData.bytes length:packetData.length];
    
    [self.socket writeData:buffer withTimeout:-1.0 tag:0];
    [self.socket readDataToLength:sizeof(uint64_t) withTimeout:-1.0 tag:0];
}

- (uint64_t)parseHeader:(NSData *)data {
    uint64_t headerLength = 0;
    memcpy(&headerLength, [data bytes], sizeof(uint64_t));
    
    return headerLength;
}

- (void)parseBody:(NSData *)data {
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    GGPacket *packet = [unarchiver decodeObjectForKey:@"packet"];
    [unarchiver finishDecoding];

    
    if ([packet type] == GGPacketTypeMove) {
        NSNumber *i = [(NSDictionary *)[packet data] objectForKey:@"i"];
        
        NSNumber *j = [(NSDictionary *)[packet data] objectForKey:@"j"];
        
        GGPoint point;
        point.i = i.intValue;
        point.j = j.intValue;
        [self moveAtPoint:point sendPacketInLAN:NO];
        
    }
}


#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)socket didReadData:(NSData *)data withTag:(long)tag {
    if (tag == 0) {
        uint64_t bodyLength = [self parseHeader:data];
        [socket readDataToLength:bodyLength withTimeout:-1.0 tag:1];
        
    } else if (tag == 1) {
        [self parseBody:data];
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)socket withError:(NSError *)error {
    if (error) {
        NSLog(@"Socket Did Disconnect with Error %@ with User Info %@.", error, [error userInfo]);
    } else {
        NSLog(@"Socket Disconnect.");
    }
    
    if (self.socket == socket) {
        self.socket.delegate = nil;
        self.socket = nil;
    }
}

#pragma mark - GGBoardViewDelegate

- (void)boardView:(GGBoardView *)boardView didTapOnPoint:(GGPoint)point {
    [self moveAtPoint:point sendPacketInLAN:YES];
}



#pragma mark - GGHostListControllerDelegate

- (void)controller:(GGHostListController *)controller didJoinGameOnSocket:(GCDAsyncSocket *)socket {
    self.socket = socket;
    [self.socket setDelegate:self];
    self.boardView.userInteractionEnabled = NO;
    [self.socket readDataToLength:sizeof(uint64_t) withTimeout:-1.0 tag:0];
}

- (void)controller:(GGHostListController *)controller didHostGameOnSocket:(GCDAsyncSocket *)socket {
    self.socket = socket;
    [self.socket setDelegate:self];
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
