#import "GGPlayer.h"

@interface GGPlayer ()
{
    GGPlayerType _playerType;
    GGBoard *_board;
}

@end

@implementation GGPlayer

- (instancetype)initWithPlayer:(GGPlayerType)playerType {
    self = [super init];
    
    if (self) {
        _playerType = playerType;
        _board = [[GGMinimaxAI alloc] initWithPlayer:playerType];
    }
    
    return self;
}

- (void)update:(GGMove *)move {
    if (move == nil) {
        NSLog(@"!!!!Error!!!!");
    } else {
        [_board makeMove:move];
    }
}

- (GGMove *)getMove {
    if ([_board isEmpty]) {
        GGPoint point;
        point.i = 7;
        point.j = 7;
        GGMove *move = [[GGMove alloc] initWithPlayer:_playerType point:point];
        [self update:move];
        return move;
    } else {
        GGMove *move = [_board getBestMove];
        return move;
    }
}

@end
