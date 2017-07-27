#import "GGGreedyAI.h"

typedef NS_ENUM(NSInteger, GGTupleType)
{
    GGTupleTypeBlank,
    GGTupleTypeB,
    GGTupleTypeBB,
    GGTupleTypeBBB,
    GGTupleTypeBBBB,
    GGTupleTypeW,
    GGTupleTypeWW,
    GGTupleTypeWWW,
    GGTupleTypeWWWW,
    GGTupleTypePolluted
};

@interface GGGreedyAI()
{
    GGPlayerType _playerType;
}

@end

@implementation GGGreedyAI

- (instancetype)initWithPlayer:(GGPlayerType)playerType {
    self = [super init];
    
    if (self) {
        _playerType = playerType;
    }
    
    return self;
}

- (GGMove *)getBestMove {
    int maxScore = 0;
    GGPoint bestPoint;
    
    int index = 0;
    GGPoint bestPoints[GRID_SIZE * GRID_SIZE];
    
    for (int i = 0; i < GRID_SIZE; i++) {
        for (int j = 0; j < GRID_SIZE; j++) {
            if (_grid[i][j] == GGPieceTypeBlank) {
                GGPoint point;
                point.i = i;
                point.j = j;
                
                int score = [self getScoreWithPoint:point];
                if (score == maxScore) {
                    bestPoints[index] = point;
                    index++;
                } else if (score > maxScore) {
                    maxScore = score;
                    index = 0;
                    bestPoints[index] = point;
                    index++;
                }
            }
        }
    }
    
    bestPoint = bestPoints[arc4random_uniform(index)];
    
    GGMove *bestMove = [[GGMove alloc] initWithPlayer:_playerType point:bestPoint];
    [self makeMove:bestMove];
    
    return bestMove;
}

- (int)getScoreWithPoint:(GGPoint)point {
    int score = 0;
    int i = point.i;
    int j = point.j;
    
    // Horizontal
    for (; i > point.i - 5; i--) {
        if (i >= 0 && i + 4 < GRID_SIZE) {
            int m = i;
            int n = j;
            int black = 0;
            int white = 0;
            for (; m < i + 5; m++) {
                if (_grid[m][n] == GGPieceTypeBlack) {
                    black++;
                }
                if (_grid[m][n] == GGPieceTypeWhite) {
                    white++;
                }
            }
            score += [self evaluateWithTuple:[self getTupleTypeWithBlackNum:black whiteNum:white]];
        }
    }
    
    // Vertical
    i = point.i;
    for (; j > point.j - 5; j--) {
        if (j >= 0 && j + 4 < GRID_SIZE) {
            int m = i;
            int n = j;
            int black = 0;
            int white = 0;
            for (; n < j + 5; n++) {
                if (_grid[m][n] == GGPieceTypeBlack) {
                    black++;
                }
                if (_grid[m][n] == GGPieceTypeWhite) {
                    white++;
                }
            }
            score += [self evaluateWithTuple:[self getTupleTypeWithBlackNum:black whiteNum:white]];
        }
    }
    
    // Oblique up
    i = point.i;
    j = point.j;
    for (; i > point.i - 5 && j > point.j - 5; i--, j--) {
        if (i >= 0 && j >= 0 && i + 4 < GRID_SIZE && j + 4 < GRID_SIZE) {
            int m = i;
            int n = j;
            int black = 0;
            int white = 0;
            for (; m < i + 5 && n < j + 5; m++, n++) {
                if (_grid[m][n] == GGPieceTypeBlack) {
                    black++;
                }
                if (_grid[m][n] == GGPieceTypeWhite) {
                    white++;
                }
            }
            score += [self evaluateWithTuple:[self getTupleTypeWithBlackNum:black whiteNum:white]];
        }
    }
    
    // Oblique down
    i = point.i;
    j = point.j;
    for (; i > point.i - 5 && j < point.j + 5; i--, j++) {
        if (i >= 0 && j < GRID_SIZE && i + 4 < GRID_SIZE && j - 4 >= 0) {
            int m = i;
            int n = j;
            int black = 0;
            int white = 0;
            for (; m < i + 5 && n > j - 5; m++, n--) {
                if (_grid[m][n] == GGPieceTypeBlack) {
                    black++;
                }
                if (_grid[m][n] == GGPieceTypeWhite) {
                    white++;
                }
            }
            score += [self evaluateWithTuple:[self getTupleTypeWithBlackNum:black whiteNum:white]];
        }
    }
    
    return score;
}

- (GGTupleType)getTupleTypeWithBlackNum:(int)black whiteNum:(int)white {
    if (black + white == 0) {
        return GGTupleTypeBlank;
    }
    if (black == 1 && white == 0) {
        return GGTupleTypeB;
    }
    if (black == 2 && white == 0) {
        return GGTupleTypeBB;
    }
    if (black == 3 && white == 0) {
        return GGTupleTypeBBB;
    }
    if (black == 4 && white == 0) {
        return GGTupleTypeBBBB;
    }
    if (black == 0 && white == 1) {
        return GGTupleTypeW;
    }
    if (black == 0 && white == 2) {
        return GGTupleTypeWW;
    }
    if (black == 0 && white == 3) {
        return GGTupleTypeWWW;
    }
    if (black == 0 && white == 4) {
        return GGTupleTypeWWWW;
    } else {
        return GGTupleTypePolluted;
    }
}

- (int)evaluateWithTuple:(GGTupleType)tupleType {
    if (_playerType == GGPlayerTypeBlack) {
        switch (tupleType) {
            case GGTupleTypeBlank:
                return 7;
            case GGTupleTypeB:
                return 35;
            case GGTupleTypeBB:
                return 800;
            case GGTupleTypeBBB:
                return 15000;
            case GGTupleTypeBBBB:
                return 800000;
            case GGTupleTypeW:
                return 15;
            case GGTupleTypeWW:
                return 400;
            case GGTupleTypeWWW:
                return 1800;
            case GGTupleTypeWWWW:
                return 100000;
            case GGTupleTypePolluted:
                return 0;
        }
    } else {
        switch (tupleType) {
            case GGTupleTypeBlank:
                return 7;
            case GGTupleTypeB:
                return 15;
            case GGTupleTypeBB:
                return 400;
            case GGTupleTypeBBB:
                return 1800;
            case GGTupleTypeBBBB:
                return 100000;
            case GGTupleTypeW:
                return 35;
            case GGTupleTypeWW:
                return 800;
            case GGTupleTypeWWW:
                return 15000;
            case GGTupleTypeWWWW:
                return 800000;
            case GGTupleTypePolluted:
                return 0;
        }
    }
}

@end
