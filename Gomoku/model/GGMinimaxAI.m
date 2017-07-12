#import "GGMinimaxAI.h"

static int const MAX_DEEP = 8;

typedef NS_ENUM(NSInteger, GGTupleType)
{
    GGTupleTypeLiveOne = 10,
    GGTupleTypeDeadOne = 1,
    GGTupleTypeLiveTwo = 100,
    GGTupleTypeDeadTwo = 10,
    GGTupleTypeLiveThree = 1000,
    GGTupleTypeDeadThree = 100,
    GGTupleTypeLiveFour = 10000,
    GGTupleTypeDeadFour = 1000,
    GGTupleTypeFive = 100000
};

typedef struct {
    GGPoint point;
    int score;
} GGPointHelper;

@interface GGMinimaxAI()
{
    GGPlayerType _playerType;
    GGMove *_bestMove;
}

@end

@implementation GGMinimaxAI

- (instancetype)initWithPlayer:(GGPlayerType)playerType {
    self = [super init];
    
    if (self) {
        _playerType = playerType;
        _bestMove = [[GGMove alloc] init];
    }
    
    return self;
}

- (GGMove *)getBestMove {
    int score;
    
    // iterative deepening
    for (int deep = 2; deep <= MAX_DEEP; deep += 2) {
        score = [self MinimaxWithDepth:deep who:1 alpha:-[self maxEvaluateValue] beta:[self maxEvaluateValue]];
        if (score >= GGTupleTypeLiveFour) {
            [self makeMove:_bestMove];
            int blackScore = [self evaluateWithPieceType:GGPieceTypeBlack];
            int whiteScore = [self evaluateWithPieceType:GGPieceTypeWhite];
            NSLog(@"Current black score: %d", blackScore);
            NSLog(@"Current white score: %d", whiteScore);
            return _bestMove;
        }
    }
    
    [self makeMove:_bestMove];
    int blackScore = [self evaluateWithPieceType:GGPieceTypeBlack];
    int whiteScore = [self evaluateWithPieceType:GGPieceTypeWhite];
    NSLog(@"Current black score: %d", blackScore);
    NSLog(@"Current white score: %d", whiteScore);
    return _bestMove;
}

- (int)MinimaxWithDepth:(int)depth who:(int)who alpha:(int)alpha beta:(int)beta {
    if (depth == 0 || [self finished]) {
        return who * [self evaluate];
    }
    
    int score;
    GGMove *bestMove;
    NSMutableArray *moves = [self getPossibleMoves];
    
    // moves are empty???
    
    if (who > 0) {
        for (GGMove *move in moves) {
            [self makeMove:move];
            [self switchPlayer];
            score = [self MinimaxWithDepth:depth - 1 who:-who alpha:alpha beta:beta];
            [self switchPlayer];
            [self undoMove:move];

            if (score > alpha) {
                alpha = score;
                bestMove = move;
                if (alpha >= beta) {
                    break;
                }
            }
        }
        
        _bestMove = bestMove;
        
        return alpha;
    } else {
        for (GGMove *move in moves) {
            [self makeMove:move];
            [self switchPlayer];
            score = [self MinimaxWithDepth:depth - 1 who:-who alpha:alpha beta:beta];
            [self switchPlayer];
            [self undoMove:move];
            
            if (score < beta) {
                beta = score;
                if (alpha >= beta) {
                    break;
                }
            }
        }
        
        return beta;
    }
}

- (NSMutableArray *)getPossibleMoves {
    NSMutableArray *moves = [NSMutableArray array];
    GGPointHelper points[GRID_SIZE * GRID_SIZE];
    int index = 0;
    
    for (int i = 0; i < GRID_SIZE; i++) {
        for (int j = 0; j < GRID_SIZE; j++) {
            GGPoint point;
            point.i = i;
            point.j = j;
            
            if ([self isNeighbour:point]) {
                GGPointHelper pointHelper;
                pointHelper.point = point;
                pointHelper.score = [self getScoreWithPoint:point];
                points[index] = pointHelper;
                index++;
            }
        }
    }
    
    // sort the points
    for (int i = 1; i < index; i++) {
        int j = i - 1;
        GGPointHelper temp = points[i];
        while (j >= 0 && temp.score > points[j].score) {
            points[j + 1] = points[j];
            j--;
        }
        points[j + 1] = temp;
    }
    
    // only return the first 10 points
    for (int i = 0; i < 10; i++) {
        GGMove *move = [[GGMove alloc] initWithPlayer:_playerType point:points[i].point];
        [moves addObject:move];
    }
    
    return moves;
}

- (BOOL)isNeighbour:(GGPoint)point {
    int i = point.i;
    int j = point.j;
    
    if (_grid[i][j] == GGPieceTypeBlank) {
        for (int m = i - 2; m <= i + 2; m++) {
            for (int n = j - 2; n <= j + 2; n++) {
                if (m >= 0 && m < GRID_SIZE && n >= 0 && n < GRID_SIZE) {
                    if (_grid[m][n] != GGPieceTypeBlank) {
                        return YES;
                    }
                }
            }
        }
    }
    
    return NO;
}

- (BOOL)finished {
    int blackScore = [self evaluateWithPieceType:GGPieceTypeBlack];
    int whiteScore = [self evaluateWithPieceType:GGPieceTypeWhite];
    
    if (blackScore >= GGTupleTypeFive || whiteScore >= GGTupleTypeFive) {
        return YES;
    }
    
    return NO;
}

- (int)evaluate {
    int blackScore = [self evaluateWithPieceType:GGPieceTypeBlack];
    int whiteScore = [self evaluateWithPieceType:GGPieceTypeWhite];
    
    if (_playerType == GGPlayerTypeBlack) {
        return blackScore - whiteScore;
    } else {
        return whiteScore - blackScore;
    }
}

- (int)evaluateWithPieceType:(GGPieceType)pieceType {
    int score = 0;
    
    // Horizontal
    for (int line = 0; line < GRID_SIZE; line++) {
        for (int index = 0; index < GRID_SIZE; index++) {
            if (_grid[line][index] == pieceType) {
                int block = 0;
                int piece = 1;
                
                // left
                if (index == 0 || _grid[line][index - 1] != GGPieceTypeBlank) {
                    block++;
                }
                
                // pieceNum
                for (index++; index < GRID_SIZE && _grid[line][index] == pieceType; index++) {
                    piece++;
                }
                
                // right
                if (index == GRID_SIZE || _grid[line][index] != GGPieceTypeBlank) {
                    block++;
                }
                
                score += [self evaluateWithBlock:block pieceNum:piece];
            }
        }
    }
    
    // Vertical
    for (int line = 0; line < GRID_SIZE; line++) {
        for (int index = 0; index < GRID_SIZE; index++) {
            if (_grid[index][line] == pieceType) {
                int block = 0;
                int piece = 1;
                
                // left
                if (index == 0 || _grid[index - 1][line] != GGPieceTypeBlank) {
                    block++;
                }
                
                // pieceNum
                for (index++; index < GRID_SIZE && _grid[index][line] == pieceType; index++) {
                    piece++;
                }
                
                // right
                if (index == GRID_SIZE || _grid[index][line] != GGPieceTypeBlank) {
                    block++;
                }
                
                score += [self evaluateWithBlock:block pieceNum:piece];
            }
        }
    }
    
    // Oblique up
    for (int line = 0; line < 21; line++) {
        int lineLength = GRID_SIZE - abs(line - 10);
        
        if (line <= 10) {
            for (int index = 0; index < lineLength; index++) {
                if (_grid[index][GRID_SIZE - lineLength + index] == pieceType) {
                    int block = 0;
                    int piece = 1;
                    
                    // left
                    if (index == 0 || _grid[index - 1][GRID_SIZE - lineLength + index - 1] != GGPieceTypeBlank) {
                        block++;
                    }
                    
                    // pieceNum
                    for (index++; index < lineLength && _grid[index][GRID_SIZE - lineLength + index] == pieceType; index++) {
                        piece++;
                    }
                    
                    // right
                    if (index == lineLength || _grid[index][GRID_SIZE - lineLength + index] != GGPieceTypeBlank) {
                        block++;
                    }
                    
                    score += [self evaluateWithBlock:block pieceNum:piece];
                }
            }
        } else {
            for (int index = 0; index < lineLength; index++) {
                if (_grid[GRID_SIZE - lineLength + index][index] == pieceType) {
                    int block = 0;
                    int piece = 1;
                    
                    // left
                    if (index == 0 || _grid[GRID_SIZE - lineLength + index - 1][index - 1] != GGPieceTypeBlank) {
                        block++;
                    }
                    
                    // pieceNum
                    for (index++; index < lineLength && _grid[GRID_SIZE - lineLength + index][index] == pieceType; index++) {
                        piece++;
                    }
                    
                    // right
                    if (index == lineLength || _grid[GRID_SIZE - lineLength + index][index] != GGPieceTypeBlank) {
                        block++;
                    }
                    
                    score += [self evaluateWithBlock:block pieceNum:piece];
                }
            }
        }
    }
    
    // Oblique down
    for (int line = 0; line < 21; line++) {
        int lineLength = GRID_SIZE - abs(line - 10);
        
        if (line <= 10) {
            for (int index = 0; index < lineLength; index++) {
                if (_grid[index][lineLength - 1 - index] == pieceType) {
                    int block = 0;
                    int piece = 1;
                    
                    // left
                    if (index == 0 || _grid[index - 1][lineLength - 1 - (index - 1)] != GGPieceTypeBlank) {
                        block++;
                    }
                    
                    // pieceNum
                    for (index++; index < lineLength && _grid[index][lineLength - 1 - index] == pieceType; index++) {
                        piece++;
                    }
                    
                    // right
                    if (index == lineLength || _grid[index][lineLength - 1 - index] != GGPieceTypeBlank) {
                        block++;
                    }
                    
                    score += [self evaluateWithBlock:block pieceNum:piece];
                }
            }
        } else {
            for (int index = 0; index < lineLength; index++) {
                if (_grid[GRID_SIZE - lineLength + index][GRID_SIZE - 1 - index] == pieceType) {
                    int block = 0;
                    int piece = 1;
                    
                    // left
                    if (index == 0 || _grid[GRID_SIZE - lineLength + index - 1][GRID_SIZE - 1 - (index - 1)] != GGPieceTypeBlank) {
                        block++;
                    }
                    
                    // pieceNum
                    for (index++; index < lineLength && _grid[GRID_SIZE - lineLength + index][GRID_SIZE - 1 - index] == pieceType; index++) {
                        piece++;
                    }
                    
                    // right
                    if (index == lineLength || _grid[GRID_SIZE - lineLength + index][GRID_SIZE - 1 - index] != GGPieceTypeBlank) {
                        block++;
                    }
                    
                    score += [self evaluateWithBlock:block pieceNum:piece];
                }
            }
        }
    }
    
    return score;
}

- (int)evaluateWithBlock:(int)block pieceNum:(int)piece {
    if (block == 0) {
        switch (piece) {
            case 1:
                return GGTupleTypeLiveOne;
            case 2:
                return GGTupleTypeLiveTwo;
            case 3:
                return GGTupleTypeLiveThree;
            case 4:
                return GGTupleTypeLiveFour;
            default:
                return GGTupleTypeFive;
        }
    } else if (block == 1) {
        switch (piece) {
            case 1:
                return GGTupleTypeDeadOne;
            case 2:
                return GGTupleTypeDeadTwo;
            case 3:
                return GGTupleTypeDeadThree;
            case 4:
                return GGTupleTypeDeadFour;
            default:
                return GGTupleTypeFive;
        }
    } else {
        if (piece >= 5) {
            return GGTupleTypeFive;
        } else {
            return 0;
        }
    }
}

- (int)maxEvaluateValue {
    return INT_MAX;
}

- (void)switchPlayer {
    if (_playerType == GGPlayerTypeBlack) {
        _playerType = GGPlayerTypeWhite;
    } else {
        _playerType = GGPlayerTypeBlack;
    }
}

@end
