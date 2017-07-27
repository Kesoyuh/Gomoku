#import "GGPlayer.h"

@interface GGPlayer ()
{
    GGPlayerType _playerType;
    GGBoard *_board;
}

@end

@implementation GGPlayer

- (instancetype)initWithPlayer:(GGPlayerType)playerType difficulty:(GGDifficulty)difficulty {
    self = [super init];
    
    if (self) {
        _playerType = playerType;
        
        switch (difficulty) {
            case GGDifficultyEasy:
                _board = [[GGGreedyAI alloc] initWithPlayer:playerType];
                break;
            case GGDifficultyMedium:
                _board = [[GGMinimaxAI alloc] initWithPlayer:playerType];
                [(GGMinimaxAI *)_board setDepth:6];
                break;
            case GGDifficultyHard:
                _board = [[GGMinimaxAI alloc] initWithPlayer:playerType];
                [(GGMinimaxAI *)_board setDepth:8];
                break;
        }
    }
    
    return self;
}

- (void)update:(GGMove *)move {
    if (move != nil) {
        [_board makeMove:move];
    }
}

- (void)regret:(GGMove *)move {
    if (move != nil) {
        [_board undoMove:move];
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
