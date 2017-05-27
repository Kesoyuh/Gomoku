#import "GGBoard.h"

static int const DIMENSION = 15;

@interface GGBoard ()
{
    GGPieceType _board[DIMENSION][DIMENSION];
}

@end

@implementation GGBoard

- (instancetype)init {
    self = [super init];
    
    if (self) {
        for (int i = 0; i < DIMENSION; i++) {
            for (int j = 0; j < DIMENSION; j++) {
                _board[i][j] = GGPieceTypeBlank;
            }
        }
    }
    
    return self;
}

- (BOOL)canMoveAtPoint:(GGPoint)point {
    return _board[point.i][point.j] == GGPieceTypeBlank;
};

- (void)makeMove:(GGMove *)move {
    GGPoint point = move.point;
    if ([self canMoveAtPoint:point]) {
        if (move.player == GGPlayerTypeBlack) {
            _board[point.i][point.j] = GGPieceTypeBlack;
        } else {
            _board[point.i][point.j] = GGPieceTypeWhite;
        }
    }
};

- (void)undoMove:(GGMove *)move {
    GGPoint point = move.point;
    _board[point.i][point.j] = GGPieceTypeBlank;
};

- (BOOL)checkWinAtPoint:(GGPoint)point {
    int count = 1;
    int i = point.i;
    int j = point.j;
    
    // Horizontal
    for (j++; j < DIMENSION; j++) {
        if (_board[i][j] == _board[point.i][point.j]) {
            count++;
        } else {
            j = point.j;
            break;
        }
    }
    for (j--; j >= 0; j--) {
        if (_board[i][j] == _board[point.i][point.j]) {
            count++;
        } else {
            j = point.j;
            break;
        }
    }
    if (count >= 5) {
        return YES;
    } else {
        count = 1;
    }
    
    // Vertical
    for (i++; i < DIMENSION; i++) {
        if (_board[i][j] == _board[point.i][point.j]) {
            count++;
        } else {
            i = point.i;
            break;
        }
    }
    for (i--; i >= 0; i--) {
        if (_board[i][j] == _board[point.i][point.j]) {
            count++;
        } else {
            i = point.i;
            break;
        }
    }
    if (count >= 5) {
        return YES;
    } else {
        count = 1;
    }
    
    // Oblique up
    i++;
    j++;
    for (; i < DIMENSION && j < DIMENSION; i++, j++) {
        if (_board[i][j] == _board[point.i][point.j]) {
            count++;
        } else {
            i = point.i;
            j = point.j;
            break;
        }
    }
    i--;
    j--;
    for (; i >= 0 && j >= 0; i--, j--) {
        if (_board[i][j] == _board[point.i][point.j]) {
            count++;
        } else {
            i = point.i;
            j = point.j;
            break;
        }
    }
    if (count >= 5) {
        return YES;
    } else {
        count = 1;
    }
    
    // Oblique down
    i++;
    j--;
    for (; i < DIMENSION && j >= 0; i++, j--) {
        if (_board[i][j] == _board[point.i][point.j]) {
            count++;
        } else {
            i = point.i;
            j = point.j;
            break;
        }
    }
    i--;
    j++;
    for (; i >= 0 && j < DIMENSION; i--, j++) {
        if (_board[i][j] == _board[point.i][point.j]) {
            count++;
        } else {
            i = point.i;
            j = point.j;
            break;
        }
    }
    if (count >= 5) {
        return YES;
    } else {
        return NO;
    }
};

@end
