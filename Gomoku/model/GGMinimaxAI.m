#import "GGMinimaxAI.h"

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

- (GGMove *)findBestMove {
    [self MinimaxWithDepth:4 who:1 alpha:-[self maxEvaluateValue] beta:[self maxEvaluateValue]];
    return _bestMove;
}

- (int)MinimaxWithDepth:(int)depth who:(int)who alpha:(int)alpha beta:(int)beta {
    if (depth == 0 || [self finished]) {
        return who * [self evaluate];
    }
    
    int score;
    GGMove *bestMove = nil;
    GGMove *moves[GRID_SIZE * GRID_SIZE];
    GGMove *moves1[GRID_SIZE * GRID_SIZE];
    
    for (int i = 0; i < GRID_SIZE * GRID_SIZE; i++) {
        moves[i] = nil;
        moves1[i] = nil;
    }
    
    int index = 0;
    int index1 = 0;
    for (int i = 0; i < GRID_SIZE; i++) {
        for (int j = 0; j < GRID_SIZE; j++) {
            GGPoint point;
            point.i = i;
            point.j = j;
            
            if ([self isNeighbour:point]) {
                moves[index] = [[GGMove alloc] initWithPlayer:_playerType point:point];
                index++;
            } else if ([self isNextNeighbour:point]) {
                moves1[index] = [[GGMove alloc] initWithPlayer:_playerType point:point];
                index1++;
            }
        }
    }
    
    for (int i = index; i < index + index1; i++) {
        moves[i] = moves1[i - index];
    }
    
    index += index1;
    
    // moves are empty???
    
    if (who > 0) {
        for (int i = 0; i < index; i++) {
            GGMove *move = moves[i];
            [self switchPlayer];
            [self makeMove:move];
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
        
        if (depth == 4) {
            _bestMove = bestMove;
        }
        
        return alpha;
    } else {
        for (int i = 0; i < index; i++) {
            GGMove *move = moves[i];
            [self switchPlayer];
            [self makeMove:move];
            score = [self MinimaxWithDepth:depth - 1 who:-who alpha:alpha beta:beta];
            [self switchPlayer];
            [self undoMove:move];
            
            if (score < beta) {
                beta = score;
                bestMove = move;
                if (alpha >= beta) {
                    break;
                }
            }
        }
        
        return beta;
    }
}

- (BOOL)isNeighbour:(GGPoint)point {
    int i = point.i;
    int j = point.j;
    
    if (_grid[i][j] == GGPieceTypeBlank) {
        for (int m = i - 1; m <= i + 1; m++) {
            for (int n = j - 1; n <= j + 1; n++) {
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

- (BOOL)isNextNeighbour:(GGPoint)point {
    int i = point.i;
    int j = point.j;
    
    if (_grid[i][j] == GGPieceTypeBlank) {
        for (int m = i - 2; m <= i + 2; m += 2) {
            for (int n = j - 2; n <= j + 2; n += 2) {
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
    for (int i = 0; i < GRID_SIZE; i++) {
        for (int j = 0; j < GRID_SIZE; j++) {
            if (_grid[i][j] != GGPieceTypeBlank) {
                GGPoint point;
                point.i = i;
                point.j = j;
                if ([self checkWinAtPoint:point]) {
                    return YES;
                }
            }
        }
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
        return 0;
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

/*
- (int)evaluateWithPieceType:(GGPieceType)pieceType {
    int score = 0;
    
    // Horizontal
    for (int i = 0; i < GRID_SIZE; i++) {
        int index = -1;
        while (index <= GRID_SIZE - 5) {
            GGPoint pointTuple[6];
            
            for (int j = 0; j < 6; j++) {
                GGPoint point;
                point.i = i;
                point.j = index + j;
                pointTuple[j] = point;
            }
            
            int singleScore = [self evaluateWithTuple:pointTuple pieceType:pieceType];
            score += singleScore;
            
            if (singleScore >= 720) {
                for (int j = 1; j < 6; j++) {
                    if ([self pieceAtPoint:pointTuple[j]] == GGPieceTypeUsed) {
                        index = index + j;
                        break;
                    }
                    if (j == 5) {
                        index = index + j;
                    }
                }
            } else if (singleScore >= 20) {
                for (int j = 1; j < 6; j++) {
                    if ([self pieceAtPoint:pointTuple[j]] == pieceType) {
                        index += j + 1;
                        break;
                    }
                }
            } else {
                index++;
            }
        }
    }
    
    // Vertical
    [self recoverUsedPiece];    
    for (int j = 0; j < GRID_SIZE; j++) {
        int index = -1;
        while (index <= GRID_SIZE - 5) {
            GGPoint pointTuple[6];
            
            for (int i = 0; i < 6; i++) {
                GGPoint point;
                point.i = index + i;
                point.j = j;
                pointTuple[i] = point;
            }
            
            int singleScore = [self evaluateWithTuple:pointTuple pieceType:pieceType];
            score += singleScore;
            
            if (singleScore >= 720) {
                for (int i = 1; i < 6; i++) {
                    if ([self pieceAtPoint:pointTuple[i]] == GGPieceTypeUsed) {
                        index = index + i;
                        break;
                    }
                    if (i == 5) {
                        index = index + i;
                    }
                }
            } else if (singleScore >= 20) {
                for (int i = 1; i < 6; i++) {
                    if ([self pieceAtPoint:pointTuple[i]] == pieceType) {
                        index += i + 1;
                        break;
                    }
                }
            } else {
                index++;
            }
        }
    }
    
    // Oblique up
    [self recoverUsedPiece];
    for (int x = 0; x < 21; x++) {
        int pieceNumber = GRID_SIZE - abs(x - 10);
        int index = -1;
        while (index <= pieceNumber - 5) {
            GGPoint pointTuple[6];
            
            for (int y = 0; y < 6; y++) {
                GGPoint point;
                if (x <= 10) {
                    point.i = index + y;
                    point.j = GRID_SIZE - pieceNumber + index + y;
                } else {
                    point.i = GRID_SIZE - pieceNumber + index + y;
                    point.j = index + y;
                }
                pointTuple[y] = point;
            }
            
            int singleScore = [self evaluateWithTuple:pointTuple pieceType:pieceType];
            score += singleScore;
            
            if (singleScore >= 720) {
                for (int y = 1; y < 6; y++) {
                    if ([self pieceAtPoint:pointTuple[y]] == GGPieceTypeUsed) {
                        index = index + y;
                        break;
                    }
                    if (y == 5) {
                        index = index + y;
                    }
                }
            } else if (singleScore >= 20) {
                for (int y = 1; y < 6; y++) {
                    if ([self pieceAtPoint:pointTuple[y]] == pieceType) {
                        index += y + 1;
                        break;
                    }
                }
            } else {
                index++;
            }
            
        }
    }
    
    // Oblique down
    [self recoverUsedPiece];
    for (int x = 0; x < 21; x++) {
        int pieceNumber = GRID_SIZE - abs(x - 10);
        int index = -1;
        while (index <= pieceNumber - 5) {
            GGPoint pointTuple[6];
            
            for (int y = 0; y < 6; y++) {
                GGPoint point;
                if (x <= 10) {
                    point.i = index + y;
                    point.j = pieceNumber - 1 - index - y;
                } else {
                    point.i = GRID_SIZE - pieceNumber + index + y;
                    point.j = GRID_SIZE - 1 - index - y;
                }
                pointTuple[y] = point;
            }
            
            int singleScore = [self evaluateWithTuple:pointTuple pieceType:pieceType];
            score += singleScore;
            
            if (singleScore >= 720) {
                for (int y = 1; y < 6; y++) {
                    if ([self pieceAtPoint:pointTuple[y]] == GGPieceTypeUsed) {
                        index = index + y;
                        break;
                    }
                    if (y == 5) {
                        index = index + y;
                    }
                }
            } else if (singleScore >= 20) {
                for (int y = 1; y < 6; y++) {
                    if ([self pieceAtPoint:pointTuple[y]] == pieceType) {
                        index += y + 1;
                        break;
                    }
                }
            } else {
                index++;
            }
            
        }
    }
    
    return score;
}

- (GGPieceType)pieceAtPoint:(GGPoint)point {
    if (point.i < 0 || point.i >= GRID_SIZE || point.j < 0 || point.j >= GRID_SIZE) {
        return GGPieceTypeBlock;
    }
    return _grid[point.i][point.j];
}

- (void)recoverUsedPiece {
    for (int i = 0; i < GRID_SIZE; i++) {
        for (int j = 0; j < GRID_SIZE; j++) {
            if (_grid[i][j] == GGPieceTypeUsed) {
                _grid[i][j] = GGPieceTypeBlank;
            }
        }
    }
}

- (int)evaluateWithTuple:(GGPoint *)pointTuple pieceType:(GGPieceType)pieceType {
    GGPieceType pieceTuple[6];
    
    for (int i = 0; i < 6; i++) {
        pieceTuple[i] = [self pieceAtPoint:pointTuple[i]];
    }
    
    // OOOOO_
    if (pieceTuple[0] == pieceType &&
        pieceTuple[1] == pieceType &&
        pieceTuple[2] == pieceType &&
        pieceTuple[3] == pieceType &&
        pieceTuple[4] == pieceType) {
        return 50000;
    }
    
    // +OOOO+
    if (pieceTuple[0] == (GGPieceTypeBlank | GGPieceTypeUsed) &&
        pieceTuple[1] == pieceType &&
        pieceTuple[2] == pieceType &&
        pieceTuple[3] == pieceType &&
        pieceTuple[4] == pieceType &&
        pieceTuple[5] == GGPieceTypeBlank) {
        _grid[pointTuple[5].i][pointTuple[5].j] = GGPieceTypeUsed;
        return 4320;
    }
    
    // +OOO++
    if (pieceTuple[0] == (GGPieceTypeBlank | GGPieceTypeUsed) &&
        pieceTuple[1] == pieceType &&
        pieceTuple[2] == pieceType &&
        pieceTuple[3] == pieceType &&
        pieceTuple[4] == GGPieceTypeBlank &&
        pieceTuple[5] == (GGPieceTypeBlank | GGPieceTypeUsed)) {
        _grid[pointTuple[4].i][pointTuple[4].j] = GGPieceTypeUsed;
        return 720;
    }
    
    // ++OOO+
    if (pieceTuple[0] == (GGPieceTypeBlank | GGPieceTypeUsed) &&
        pieceTuple[1] == GGPieceTypeBlank &&
        pieceTuple[2] == pieceType &&
        pieceTuple[3] == pieceType &&
        pieceTuple[4] == pieceType &&
        pieceTuple[5] == (GGPieceTypeBlank | GGPieceTypeUsed)) {
        _grid[pointTuple[1].i][pointTuple[1].j] = GGPieceTypeUsed;
        return 720;
    }
    
    // +OO+O+
    if (pieceTuple[0] == (GGPieceTypeBlank | GGPieceTypeUsed) &&
        pieceTuple[1] == pieceType &&
        pieceTuple[2] == pieceType &&
        pieceTuple[3] == GGPieceTypeBlank &&
        pieceTuple[4] == pieceType &&
        pieceTuple[5] == (GGPieceTypeBlank | GGPieceTypeUsed)) {
        _grid[pointTuple[3].i][pointTuple[3].j] = GGPieceTypeUsed;
        return 720;
    }
    
    // +O+OO+
    if (pieceTuple[0] == (GGPieceTypeBlank | GGPieceTypeUsed) &&
        pieceTuple[1] == pieceType &&
        pieceTuple[2] == GGPieceTypeBlank &&
        pieceTuple[3] == pieceType &&
        pieceTuple[4] == pieceType &&
        pieceTuple[5] == (GGPieceTypeBlank | GGPieceTypeUsed)) {
        _grid[pointTuple[2].i][pointTuple[2].j] = GGPieceTypeUsed;
        return 720;
    }
    
    // XOOOO+
    if (pieceTuple[0] != (GGPieceTypeBlank | GGPieceTypeUsed | pieceType) &&
        pieceTuple[1] == pieceType &&
        pieceTuple[2] == pieceType &&
        pieceTuple[3] == pieceType &&
        pieceTuple[4] == pieceType &&
        pieceTuple[5] == GGPieceTypeBlank) {
        _grid[pointTuple[5].i][pointTuple[5].j] = GGPieceTypeUsed;
        return 720;
    }
    
    // +OOOOX
    if (pieceTuple[0] == GGPieceTypeBlank &&
        pieceTuple[1] == pieceType &&
        pieceTuple[2] == pieceType &&
        pieceTuple[3] == pieceType &&
        pieceTuple[4] == pieceType &&
        pieceTuple[5] == (GGPieceTypeBlank | GGPieceTypeUsed | pieceType)) {
        _grid[pointTuple[0].i][pointTuple[0].j] = GGPieceTypeUsed;
        return 720;
    }
    
    // OO+OO_
    if (pieceTuple[0] == pieceType &&
        pieceTuple[1] == pieceType &&
        pieceTuple[2] == GGPieceTypeBlank &&
        pieceTuple[3] == pieceType &&
        pieceTuple[4] == pieceType) {
        _grid[pointTuple[2].i][pointTuple[2].j] = GGPieceTypeUsed;
        return 720;
    }
    
    // O+OOO_
    if (pieceTuple[0] == pieceType &&
        pieceTuple[1] == GGPieceTypeBlank &&
        pieceTuple[2] == pieceType &&
        pieceTuple[3] == pieceType &&
        pieceTuple[4] == pieceType) {
        _grid[pointTuple[1].i][pointTuple[1].j] = GGPieceTypeUsed;
        return 720;
    }
    
    // OOO+O_
    if (pieceTuple[0] == pieceType &&
        pieceTuple[1] == pieceType &&
        pieceTuple[2] == pieceType &&
        pieceTuple[3] == GGPieceTypeBlank &&
        pieceTuple[4] == pieceType) {
        _grid[pointTuple[3].i][pointTuple[3].j] = GGPieceTypeUsed;
        return 720;
    }
    
    // ++OO++
    if (pieceTuple[0] == (GGPieceTypeBlank | GGPieceTypeUsed) &&
        pieceTuple[1] == (GGPieceTypeBlank | GGPieceTypeUsed) &&
        pieceTuple[2] == pieceType &&
        pieceTuple[3] == pieceType &&
        pieceTuple[4] == (GGPieceTypeBlank | GGPieceTypeUsed) &&
        pieceTuple[5] == (GGPieceTypeBlank | GGPieceTypeUsed)) {
        return 120;
    }
    
    // ++O+O+
    if (pieceTuple[0] == (GGPieceTypeBlank | GGPieceTypeUsed) &&
        pieceTuple[1] == (GGPieceTypeBlank | GGPieceTypeUsed) &&
        pieceTuple[2] == pieceType &&
        pieceTuple[3] == (GGPieceTypeBlank | GGPieceTypeUsed) &&
        pieceTuple[4] == pieceType &&
        pieceTuple[5] == (GGPieceTypeBlank | GGPieceTypeUsed)) {
        return 120;
    }
    
    // +O+O++
    if (pieceTuple[0] == (GGPieceTypeBlank | GGPieceTypeUsed) &&
        pieceTuple[1] == pieceType &&
        pieceTuple[2] == (GGPieceTypeBlank | GGPieceTypeUsed) &&
        pieceTuple[3] == pieceType &&
        pieceTuple[4] == (GGPieceTypeBlank | GGPieceTypeUsed) &&
        pieceTuple[5] == (GGPieceTypeBlank | GGPieceTypeUsed)) {
        return 120;
    }
    
    // +++O++
    if (pieceTuple[0] == (GGPieceTypeBlank | GGPieceTypeUsed) &&
        pieceTuple[1] == (GGPieceTypeBlank | GGPieceTypeUsed) &&
        pieceTuple[2] == (GGPieceTypeBlank | GGPieceTypeUsed) &&
        pieceTuple[3] == pieceType &&
        pieceTuple[4] == (GGPieceTypeBlank | GGPieceTypeUsed) &&
        pieceTuple[5] == (GGPieceTypeBlank | GGPieceTypeUsed)) {
        return 20;
    }
    
    // ++O+++
    if (pieceTuple[0] == (GGPieceTypeBlank | GGPieceTypeUsed) &&
        pieceTuple[1] == (GGPieceTypeBlank | GGPieceTypeUsed) &&
        pieceTuple[2] == pieceType &&
        pieceTuple[3] == (GGPieceTypeBlank | GGPieceTypeUsed) &&
        pieceTuple[4] == (GGPieceTypeBlank | GGPieceTypeUsed) &&
        pieceTuple[5] == (GGPieceTypeBlank | GGPieceTypeUsed)) {
        return 20;
    }
    
    return 0;
}
*/

@end
