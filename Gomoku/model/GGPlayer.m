#import "GGPlayer.h"

static int const BOARD_SIZE = 15;

@interface GGPlayer ()
{
    GGBoard *_board;
    GGPlayerType _playerType;
    GGPieceType _pieceType;
}

@end

@implementation GGPlayer

- (instancetype)initWithPlayer:(GGPlayerType)playerType {
    self = [super init];
    
    if (self) {
        _playerType = playerType;
        
        if (_playerType == GGPlayerTypeBlack) {
            _pieceType = GGPieceTypeBlack;
        } else {
            _pieceType = GGPieceTypeWhite;
        }
        
        _board = [[GGBoard alloc] init];
    }
    
    return self;
}

- (void)update:(GGMove *)move {
    [_board makeMove:move];
}

- (GGMove *)move {
    GGPoint point = [_board findBestPointWithPlayer:_playerType];
    return [[GGMove alloc] initWithPlayer:_playerType point:point];
}

@end
