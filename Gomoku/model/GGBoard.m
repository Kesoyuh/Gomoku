#import "GGBoard.h"

static int const BOARD_SIZE = 15;

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

@interface GGBoard ()
{
    GGPieceType _board[BOARD_SIZE][BOARD_SIZE];
}

@end

@implementation GGBoard

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self initBoard];
    }
    
    return self;
}

- (void)initBoard {
    for (int i = 0; i < BOARD_SIZE; i++) {
        for (int j = 0; j < BOARD_SIZE; j++) {
            _board[i][j] = GGPieceTypeBlank;
        }
    }
}

- (BOOL)canMoveAtPoint:(GGPoint)point {
    return _board[point.i][point.j] == GGPieceTypeBlank;
}

- (void)makeMove:(GGMove *)move {
    GGPoint point = move.point;
    if ([self canMoveAtPoint:point]) {
        if (move.playerType == GGPlayerTypeBlack) {
            _board[point.i][point.j] = GGPieceTypeBlack;
        } else {
            _board[point.i][point.j] = GGPieceTypeWhite;
        }
    }
}

- (void)undoMove:(GGMove *)move {
    GGPoint point = move.point;
    _board[point.i][point.j] = GGPieceTypeBlank;
}

- (BOOL)checkWinAtPoint:(GGPoint)point {
    int count = 1;
    int i = point.i;
    int j = point.j;
    
    // Horizontal
    for (j++; j < BOARD_SIZE; j++) {
        if (_board[i][j] == _board[point.i][point.j]) {
            count++;
        } else {
            break;
        }
    }
    j = point.j;
    for (j--; j >= 0; j--) {
        if (_board[i][j] == _board[point.i][point.j]) {
            count++;
        } else {
            break;
        }
    }
    if (count >= 5) {
        return YES;
    } else {
        count = 1;
    }
    
    // Vertical
    i = point.i;
    j = point.j;
    for (i++; i < BOARD_SIZE; i++) {
        if (_board[i][j] == _board[point.i][point.j]) {
            count++;
        } else {
            break;
        }
    }
    i = point.i;
    for (i--; i >= 0; i--) {
        if (_board[i][j] == _board[point.i][point.j]) {
            count++;
        } else {
            break;
        }
    }
    if (count >= 5) {
        return YES;
    } else {
        count = 1;
    }
    
    // Oblique up
    i = point.i + 1;
    j = point.j + 1;
    for (; i < BOARD_SIZE && j < BOARD_SIZE; i++, j++) {
        if (_board[i][j] == _board[point.i][point.j]) {
            count++;
        } else {
            break;
        }
    }
    i = point.i - 1;
    j = point.j - 1;
    for (; i >= 0 && j >= 0; i--, j--) {
        if (_board[i][j] == _board[point.i][point.j]) {
            count++;
        } else {
            break;
        }
    }
    if (count >= 5) {
        return YES;
    } else {
        count = 1;
    }
    
    // Oblique down
    i = point.i + 1;
    j = point.j - 1;
    for (; i < BOARD_SIZE && j >= 0; i++, j--) {
        if (_board[i][j] == _board[point.i][point.j]) {
            count++;
        } else {
            break;
        }
    }
    i = point.i - 1;
    j = point.j + 1;
    for (; i >= 0 && j < BOARD_SIZE; i--, j++) {
        if (_board[i][j] == _board[point.i][point.j]) {
            count++;
        } else {
            break;
        }
    }
    if (count >= 5) {
        return YES;
    } else {
        return NO;
    }
}

- (GGPoint)findBestPointWithPlayer:(GGPlayerType)playerType {
    GGPoint pointArray[BOARD_SIZE * BOARD_SIZE];
    
    for (int i = 0; i < BOARD_SIZE * BOARD_SIZE; i++) {
        GGPoint point;
        point.i = -1;
        point.j = -1;
        pointArray[i] = point;
    }
    
    int index = 0;
    for (int i = 0; i < BOARD_SIZE; i++) {
        for (int j = 0; j < BOARD_SIZE; j++) {
            GGPoint point;
            point.i = i;
            point.j = j;
            if ([self isValidPoint:point]) {
                pointArray[index] = point;
                index++;
            }
        }
    }
    
    if (index == 0) {
        GGPoint point;
        point.i = 7;
        point.j = 7;
        return point;
    }
    
    int maxScore = 0;
    int maxScoreIndex = 0;
    
    for (int i = 0; i < index; i++) {
        int score = [self getScoreWithPoint:pointArray[i] player:playerType];
        if (score > maxScore) {
            maxScore = score;
            maxScoreIndex = i;
        }
    }
//    sleep(2);
    return pointArray[maxScoreIndex];
}

- (int)getScoreWithPoint:(GGPoint)point player:(GGPlayerType)playerType {
    int score = 0;
    int i = point.i;
    int j = point.j;
    
    // Horizontal
    for (; i > point.i - 5; i--) {
        if (i >= 0 && i + 4 < BOARD_SIZE) {
            int m = i;
            int n = j;
            int black = 0;
            int white = 0;
            for (; m < i + 5; m++) {
                if (_board[m][n] == GGPieceTypeBlack) {
                    black++;
                }
                if (_board[m][n] == GGPieceTypeWhite) {
                    white++;
                }
            }
            score += [self getScoreWithTuple:[self getTupleTypeWithBlackNum:black whiteNum:white] player:playerType];
        }
    }
    
    // Vertical
    i = point.i;
    for (; j > point.j - 5; j--) {
        if (j >= 0 && j + 4 < BOARD_SIZE) {
            int m = i;
            int n = j;
            int black = 0;
            int white = 0;
            for (; n < j + 5; n++) {
                if (_board[m][n] == GGPieceTypeBlack) {
                    black++;
                }
                if (_board[m][n] == GGPieceTypeWhite) {
                    white++;
                }
            }
            score += [self getScoreWithTuple:[self getTupleTypeWithBlackNum:black whiteNum:white] player:playerType];
        }
    }
    
    // Oblique up
    i = point.i;
    j = point.j;
    for (; i > point.i - 5 && j > point.j - 5; i--, j--) {
        if (i >= 0 && j >= 0 && i + 4 < BOARD_SIZE && j + 4 < BOARD_SIZE) {
            int m = i;
            int n = j;
            int black = 0;
            int white = 0;
            for (; m < i + 5 && n < j + 5; m++, n++) {
                if (_board[m][n] == GGPieceTypeBlack) {
                    black++;
                }
                if (_board[m][n] == GGPieceTypeWhite) {
                    white++;
                }
            }
            score += [self getScoreWithTuple:[self getTupleTypeWithBlackNum:black whiteNum:white] player:playerType];
        }
    }
    
    // Oblique down
    i = point.i;
    j = point.j;
    for (; i > point.i - 5 && j < point.j + 5; i--, j++) {
        if (i >= 0 && j < BOARD_SIZE && i + 4 < BOARD_SIZE && j - 4 > 0) {
            int m = i;
            int n = j;
            int black = 0;
            int white = 0;
            for (; m < i + 5 && n > j - 5; m++, n--) {
                if (_board[m][n] == GGPieceTypeBlack) {
                    black++;
                }
                if (_board[m][n] == GGPieceTypeWhite) {
                    white++;
                }
            }
            score += [self getScoreWithTuple:[self getTupleTypeWithBlackNum:black whiteNum:white] player:playerType];
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

- (int)getScoreWithTuple:(GGTupleType)tupleType player:(GGPlayerType)playerType {
    if (playerType == GGPlayerTypeBlack) {
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

- (BOOL)isValidPoint:(GGPoint)point {
    int i = point.i;
    int j = point.j;
    
    if (_board[i][j] == GGPieceTypeBlank) {
        for (int m = i - 2; m <= i + 2; m++) {
            for (int n = j - 2; n <= j + 2; n++) {
                if (m >= 0 && m < BOARD_SIZE && n >= 0 && n < BOARD_SIZE) {
                    if (abs(m - i) + abs(n - j) != 0 && abs(m - i) + abs(n - j) != 3) {
                        if (_board[m][n] != GGPieceTypeBlank) {
                            return YES;
                        }
                    }
                }
            }
        }
    }
    
    return NO;
}

@end
