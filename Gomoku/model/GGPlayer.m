#import "GGPlayer.h"


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
    if (move != nil) {
        [_board makeMove:move];
    }
}

- (GGMove *)getMove {
    GGPoint point = [_board findBestPointWithPlayer:_playerType];
    GGMove *move = [[GGMove alloc] initWithPlayer:_playerType point:point];
    [self update:move];
    return move;
}

@end
